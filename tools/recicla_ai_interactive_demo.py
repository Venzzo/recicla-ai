"""
RECICLA.AI - Protótipo Acadêmico Interativo e Validador de Pipeline
Executa 100% offline utilizando o modelo oficial ONNX (best.onnx) e o catálogo CONAMA.

Uso:
    python tools/recicla_ai_interactive_demo.py
    python tools/recicla_ai_interactive_demo.py --image caminho/para/imagem.jpg
    python tools/recicla_ai_interactive_demo.py --benchmark
"""

import os
import sys
import json
import time
import argparse
import numpy as np
import cv2
import onnxruntime as ort

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

MODEL_PATH = "assets/models/best.onnx"
CATALOG_PATH = "assets/data/materials_catalog.json"
INPUT_SIZE = 320
CONF_THRESHOLD = 0.15
IOU_THRESHOLD = 0.45

# Cores BGR para OpenCV correspondentes ao padrão CONAMA 275/2001
CONAMA_BGR = {
    0: (72, 85, 121),    # Biodegradável: Marrom #795548
    1: (210, 118, 25),   # Papelão: Azul #1976D2
    2: (60, 142, 56),    # Vidro: Verde #388E3C
    3: (45, 192, 251),   # Metal: Amarelo #FBC02D
    4: (210, 118, 25),   # Papel: Azul #1976D2
    5: (47, 47, 211),    # Plástico: Vermelho #D32F2F
}

CLASS_NAMES = ['biodegradable', 'cardboard', 'glass', 'metal', 'paper', 'plastic']

def load_catalog():
    if not os.path.exists(CATALOG_PATH):
        raise FileNotFoundError(f"Catálogo não encontrado em {CATALOG_PATH}")
    with open(CATALOG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def letterbox(img, new_shape=(INPUT_SIZE, INPUT_SIZE), color=(114, 114, 114)):
    shape = img.shape[:2] # [height, width]
    r = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
    
    new_unpad = int(round(shape[1] * r)), int(round(shape[0] * r))
    dw, dh = new_shape[1] - new_unpad[0], new_shape[0] - new_unpad[1]
    dw /= 2 # divide padding into 2 sides
    dh /= 2

    if shape[::-1] != new_unpad:
        img = cv2.resize(img, new_unpad, interpolation=cv2.INTER_LINEAR)
        
    top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
    left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
    img = cv2.copyMakeBorder(img, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color)
    return img, r, (dw, dh)

def xywh2xyxy(x):
    y = np.copy(x)
    y[:, 0] = x[:, 0] - x[:, 2] / 2 # top left x
    y[:, 1] = x[:, 1] - x[:, 3] / 2 # top left y
    y[:, 2] = x[:, 0] + x[:, 2] / 2 # bottom right x
    y[:, 3] = x[:, 1] + x[:, 3] / 2 # bottom right y
    return y

def nms(boxes, scores, iou_threshold):
    x1 = boxes[:, 0]
    y1 = boxes[:, 1]
    x2 = boxes[:, 2]
    y2 = boxes[:, 3]
    areas = (x2 - x1) * (y2 - y1)
    order = scores.argsort()[::-1]

    keep = []
    while order.size > 0:
        i = order[0]
        keep.append(i)
        xx1 = np.maximum(x1[i], x1[order[1:]])
        yy1 = np.maximum(y1[i], y1[order[1:]])
        xx2 = np.minimum(x2[i], x2[order[1:]])
        yy2 = np.minimum(y2[i], y2[order[1:]])

        w = np.maximum(0.0, xx2 - xx1)
        h = np.maximum(0.0, yy2 - yy1)
        inter = w * h
        ovr = inter / (areas[i] + areas[order[1:]] - inter)

        inds = np.where(ovr <= iou_threshold)[0]
        order = order[inds + 1]

    return keep

def run_inference(session, img_path):
    orig_bgr = cv2.imread(img_path)
    if orig_bgr is None:
        raise ValueError(f"Não foi possível abrir a imagem: {img_path}")
    
    orig_h, orig_w = orig_bgr.shape[:2]
    
    # 1. Letterbox 320x320
    padded_bgr, ratio, (dw, dh) = letterbox(orig_bgr, (INPUT_SIZE, INPUT_SIZE))
    
    # 2. Conversão BGR -> RGB e Normalização [0, 1] NCHW
    rgb = cv2.cvtColor(padded_bgr, cv2.COLOR_BGR2RGB)
    blob = rgb.astype(np.float32) / 255.0
    blob = blob.transpose(2, 0, 1) # HWC to CHW
    blob = np.expand_dims(blob, axis=0) # CHW to NCHW [1, 3, 320, 320]
    
    # 3. Execução ONNX Runtime
    input_name = session.get_inputs()[0].name
    t0 = time.perf_counter()
    preds = session.run(None, {input_name: blob})[0] # Shape [1, 6300, 11]
    latency_ms = (time.perf_counter() - t0) * 1000
    
    preds = preds[0] # [6300, 11]
    
    # 4. Decodificação e NMS
    obj_confs = preds[:, 4]
    mask = obj_confs >= CONF_THRESHOLD
    filtered_preds = preds[mask]
    
    detections = []
    if len(filtered_preds) > 0:
        cls_scores = filtered_preds[:, 5:11]
        best_cls = np.argmax(cls_scores, axis=1)
        best_scores = np.max(cls_scores, axis=1)
        confs = filtered_preds[:, 4] * best_scores
        
        valid_mask = confs >= CONF_THRESHOLD
        if np.any(valid_mask):
            filtered_boxes = filtered_preds[valid_mask, :4]
            filtered_confs = confs[valid_mask]
            filtered_cls = best_cls[valid_mask]
            
            xyxy_boxes = xywh2xyxy(filtered_boxes)
            
            # Rescale back to original coordinates
            xyxy_boxes[:, [0, 2]] = (xyxy_boxes[:, [0, 2]] - dw) / ratio
            xyxy_boxes[:, [1, 3]] = (xyxy_boxes[:, [1, 3]] - dh) / ratio
            xyxy_boxes[:, [0, 2]] = np.clip(xyxy_boxes[:, [0, 2]], 0, orig_w)
            xyxy_boxes[:, [1, 3]] = np.clip(xyxy_boxes[:, [1, 3]], 0, orig_h)
            
            keep_indices = nms(xyxy_boxes, filtered_confs, IOU_THRESHOLD)
            for idx in keep_indices:
                detections.append({
                    "box": xyxy_boxes[idx].tolist(),
                    "class_id": int(filtered_cls[idx]),
                    "class_name": CLASS_NAMES[filtered_cls[idx]],
                    "confidence": float(filtered_confs[idx]),
                    "is_low_conf": float(filtered_confs[idx]) < 0.40
                })
                
    return orig_bgr, padded_bgr, detections, latency_ms

def check_multi_material(detections):
    classes = list(set([d["class_id"] for d in detections]))
    if len(classes) < 2:
        return None
    if 2 in classes and 3 in classes:
        return "⚠️ Embalagem Multimaterial (Vidro + Metal): Separe a tampa metálica da garrafa antes do descarte (Lixeira Verde para o vidro e Lixeira Amarela para o metal)!"
    if (4 in classes or 1 in classes) and 5 in classes:
        return "⚠️ Embalagem Combinada (Papel/Papelão + Plástico): Destaque peças plásticas do papelão antes de descartar!"
    if 2 in classes and 5 in classes:
        return "⚠️ Embalagem Combinada (Vidro + Plástico): Remova a tampa plástica do pote de vidro!"
    return f"ℹ️ Múltiplos materiais detectados ({len(classes)} tipos). Separe os componentes nas respectivas lixeiras seletivas."

def annotate_image(orig_bgr, detections, catalog):
    annotated = orig_bgr.copy()
    classes_info = catalog.get("classes", {})
    
    for det in detections:
        box = [int(v) for v in det["box"]]
        cid = det["class_id"]
        cname = det["class_name"]
        conf = det["confidence"]
        is_low = det["is_low_conf"]
        
        color = CONAMA_BGR.get(cid, (0, 255, 0))
        cv2.rectangle(annotated, (box[0], box[1]), (box[2], box[3]), color, 3)
        
        info = classes_info.get(cname, {})
        pt_name = info.get("name_pt", cname)
        
        label = f"{pt_name}: {conf*100:.1f}%"
        if is_low:
            label += " (Baixa Conf.)"
            
        (tw, th), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2)
        top = max(0, box[1] - th - 10)
        cv2.rectangle(annotated, (box[0], top), (box[0] + tw + 10, top + th + 10), color, -1)
        
        text_color = (0, 0, 0) if cid == 3 else (255, 255, 255)
        cv2.putText(annotated, label, (box[0] + 5, top + th + 4),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, text_color, 2, cv2.LINE_AA)
        
    return annotated

def main():
    parser = argparse.ArgumentParser(description="RECICLA.AI - Teste Interativo de IA Offline")
    parser.add_argument("--image", type=str, default="", help="Caminho para imagem de teste")
    parser.add_argument("--benchmark", action="store_true", help="Executa benchmark de latência")
    args = parser.parse_args()
    
    print("=" * 70)
    print("  RECICLA.AI — Protótipo Acadêmico de Visão Computacional On-Device")
    print("  Execução 100% Local com ONNX Runtime (CPU/NNAPI/CoreML)")
    print("=" * 70)
    
    catalog = load_catalog()
    print(f"Catálogo carregado: {catalog['standard']}")
    print(f"Aviso Acadêmico: {catalog['academic_disclaimer']}")
    print("-" * 70)
    
    session = ort.InferenceSession(MODEL_PATH, providers=['CPUExecutionProvider'])
    print(f"Modelo carregado: {MODEL_PATH} ({os.path.getsize(MODEL_PATH)/(1024*1024):.2f} MB)")
    
    if args.benchmark:
        dummy = np.random.randn(1, 3, INPUT_SIZE, INPUT_SIZE).astype(np.float32)
        input_name = session.get_inputs()[0].name
        # Warmup
        for _ in range(10): session.run(None, {input_name: dummy})
        latencies = []
        for _ in range(50):
            t = time.perf_counter()
            session.run(None, {input_name: dummy})
            latencies.append((time.perf_counter() - t) * 1000)
        print(f"Latência Média: {np.mean(latencies):.2f} ms | Min: {np.min(latencies):.2f} ms | FPS: {1000/np.mean(latencies):.1f}")
        return

    # Imagem padrão de demonstração se não especificada
    img_path = args.image
    if not img_path:
        samples = [
            "scratch/sample_test_images/metal1017_jpg.rf.52c6bf2e21ee24727bd9c29fc7955f22.jpg",
            "scratch/sample_test_images/paper1083_jpg.rf.4bb79b10ea3255e6c730448738f72433.jpg",
            "scratch/sample_test_images/plastic20_jpg.rf.6b6841696757c2e821b31cf4a0fd8399.jpg",
            "scratch/sample_test_images/metal1000_jpg.rf.f972491130c59d3bff7e97b22e8e2980.jpg",
        ]
        for s in samples:
            if os.path.exists(s):
                img_path = s
                break
                
    if not img_path or not os.path.exists(img_path):
        print("Nenhuma imagem de teste encontrada. Especifique com --image <arquivo.jpg>")
        return

    print(f"\nAnalisando Imagem de Teste: {img_path}")
    orig_bgr, padded_bgr, detections, latency_ms = run_inference(session, img_path)
    print(f"Tempo de Inferência Local: {latency_ms:.2f} ms ({1000/latency_ms:.1f} FPS)")
    print(f"Total de Objetos Detectados: {len(detections)}")
    print("-" * 70)
    
    # Alerta Multimaterial
    multi_alert = check_multi_material(detections)
    if multi_alert:
        print(f"\n[ALERTA DE DESMONTAGEM]: {multi_alert}\n")
        
    classes_info = catalog.get("classes", {})
    for idx, det in enumerate(detections, 1):
        cname = det["class_name"]
        conf = det["confidence"]
        is_low = det["is_low_conf"]
        info = classes_info.get(cname, {})
        
        print(f"[{idx}] {info.get('name_pt', cname).upper()} ({cname})")
        print(f"    • Confiança: {conf*100:.1f}%")
        if is_low:
            print(f"    • ⚠️ AVISO: {catalog['confidence_thresholds']['low_confidence_warning']}")
        print(f"    • Lixeira CONAMA: {info.get('disposal_bin', 'Lixeira Geral')}")
        print(f"    • Cor da Lixeira: {info.get('conama_color_name', '')} ({info.get('conama_hex_color', '')})")
        if info.get("preparation_steps"):
            print("    • Como Preparar:")
            for step in info["preparation_steps"][:2]:
                print(f"      - {step}")
        print()

    # Salva imagem anotada e comparativo didático
    annotated = annotate_image(orig_bgr, detections, catalog)
    out_dir = "scratch/demo_output"
    os.makedirs(out_dir, exist_ok=True)
    out_annotated = os.path.join(out_dir, "output_annotated.jpg")
    out_preprocessed = os.path.join(out_dir, "output_preprocessed_320x320.jpg")
    cv2.imwrite(out_annotated, annotated)
    cv2.imwrite(out_preprocessed, padded_bgr)
    print(f"Imagem com detecções salva em: {out_annotated}")
    print(f"Imagem pré-processada (320x320 letterbox) salva em: {out_preprocessed}")
    print("=" * 70)

if __name__ == "__main__":
    main()
