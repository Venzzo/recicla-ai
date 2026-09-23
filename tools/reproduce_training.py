"""
RECICLA.AI - Script de Reprodução Automatizada do Treinamento
Permite a professores e avaliadores reproduzir todo o pipeline experimental:
1. Download do checkpoint genérico YOLOv5n COCO
2. Treinamento (transfer learning) sobre o Garbage Classification 3
3. Avaliação no conjunto de teste independente (1.042 imagens)
4. Exportação do modelo definitivo para ONNX (320x320)

Uso:
    python tools/reproduce_training.py --help
    python tools/reproduce_training.py --check-env
    python tools/reproduce_training.py --data caminho/para/data.yaml --epochs 1
"""

import os
import sys
import urllib.request
import argparse
import time

def check_environment():
    print("=== Verificação do Ambiente de Execução ===")
    try:
        import torch
        print(f"  [OK] PyTorch instalado: v{torch.__version__} (Device: {'cuda' if torch.cuda.is_available() else 'cpu'})")
    except ImportError:
        print("  [ERRO] PyTorch não encontrado. Instale com: pip install torch torchvision")
        return False

    try:
        import yolov5
        print(f"  [OK] YOLOv5 instalado")
    except ImportError:
        print("  [ERRO] YOLOv5 não encontrado. Instale com: pip install yolov5")
        return False

    try:
        import onnx
        import onnxruntime
        print(f"  [OK] ONNX e ONNX Runtime instalados (v{onnx.__version__} / v{onnxruntime.__version__})")
    except ImportError:
        print("  [ERRO] ONNX não encontrado. Instale com: pip install onnx onnxruntime")
        return False

    print("Ambiente pronto para reprodução!")
    return True

def download_generic_weights(output_path="yolov5n_coco.pt"):
    if os.path.exists(output_path):
        print(f"Checkpoint genérico já existe em: {output_path}")
        return output_path

    url = "https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5n.pt"
    print(f"Baixando checkpoint genérico COCO Ultralytics de: {url} ...")
    urllib.request.urlretrieve(url, output_path)
    print(f"Download concluído: {output_path} ({os.path.getsize(output_path)/(1024*1024):.2f} MB)")
    return output_path

def apply_compatibility_patches():
    import torch
    orig_load = torch.load
    torch.load = lambda *args, **kwargs: orig_load(
        *args,
        **{k: v for k, v in kwargs.items() if k != "weights_only"},
        weights_only=False
    )

    from PIL import ImageFont
    if not hasattr(ImageFont.FreeTypeFont, 'getsize'):
        ImageFont.FreeTypeFont.getsize = lambda self, text: (
            self.getbbox(text)[2] - self.getbbox(text)[0],
            self.getbbox(text)[3] - self.getbbox(text)[1]
        )
    if not hasattr(ImageFont.ImageFont, 'getsize'):
        ImageFont.ImageFont.getsize = lambda self, text: (
            self.getbbox(text)[2] - self.getbbox(text)[0],
            self.getbbox(text)[3] - self.getbbox(text)[1]
        )

def main():
    parser = argparse.ArgumentParser(description="RECICLA.AI - Reprodutor de Treinamento Metodológico")
    parser.add_argument("--check-env", action="store_true", help="Verifica bibliotecas e ambiente")
    parser.add_argument("--data", type=str, default="data.yaml", help="Caminho para o data.yaml do dataset")
    parser.add_argument("--epochs", type=int, default=1, help="Número de épocas de treino (padrão: 1)")
    parser.add_argument("--batch-size", type=int, default=32, help="Tamanho do batch (padrão: 32)")
    parser.add_argument("--imgsz", type=int, default=320, help="Resolução de entrada (padrão: 320)")
    parser.add_argument("--weights", type=str, default="", help="Caminho dos pesos genéricos (baixa automático se vazio)")
    parser.add_argument("--output-dir", type=str, default="runs/reproduce", help="Diretório de saída")
    args = parser.parse_args()

    if args.check_env:
        check_environment()
        return

    print("=" * 70)
    print("  RECICLA.AI — Pipeline de Reprodução do Treinamento Oficial")
    print("=" * 70)

    if not check_environment():
        sys.exit(1)

    apply_compatibility_patches()

    # 1. Pesos Base Genéricos COCO
    base_weights = args.weights
    if not base_weights or not os.path.exists(base_weights):
        base_weights = download_generic_weights()

    # 2. Dataset
    if not os.path.exists(args.data):
        print(f"\n[ERRO] Arquivo de dados não encontrado: {args.data}")
        print("Consulte a seção '4. Dataset e Treinamento' do README.md para obter")
        print("o Garbage Classification 3 e configurar o data.yaml.")
        sys.exit(1)

    import yolov5.train as train
    import yolov5.val as val
    import yolov5.export as export

    # 3. Treinamento
    print(f"\nIniciando Treinamento por {args.epochs} época(s)...")
    t0 = time.time()
    train.run(
        data=args.data,
        weights=base_weights,
        epochs=args.epochs,
        batch_size=args.batch_size,
        imgsz=args.imgsz,
        device="cpu",
        workers=0,
        project=args.output_dir,
        name="training_run",
        exist_ok=True,
        plots=False
    )
    print(f"Treinamento concluído em: {(time.time() - t0)/60:.1f} minutos")

    best_pt = os.path.join(args.output_dir, "training_run", "weights", "best.pt")
    if not os.path.exists(best_pt):
        best_pt = os.path.join(args.output_dir, "training_run", "weights", "last.pt")

    # 4. Avaliação Cega
    print(f"\nAvaliando modelo treinado ({best_pt}) no split de teste...")
    val.run(
        data=args.data,
        weights=best_pt,
        task="test",
        batch_size=args.batch_size,
        imgsz=args.imgsz,
        device="cpu",
        workers=0,
        project=args.output_dir,
        name="test_evaluation",
        exist_ok=True
    )

    # 5. Exportação ONNX
    print(f"\nExportando para formato ONNX ({args.imgsz}x{args.imgsz})...")
    export.run(
        weights=best_pt,
        imgsz=(args.imgsz, args.imgsz),
        include=['onnx'],
        device="cpu"
    )

    onnx_file = best_pt.replace(".pt", ".onnx")
    print("\n" + "=" * 70)
    print("REPRODUÇÃO CONCLUÍDA COM SUCESSO!")
    print(f"  • Modelo PyTorch: {best_pt}")
    print(f"  • Modelo ONNX:    {onnx_file}")
    print(f"  • Para atualizar os assets do Flutter: cp {onnx_file} assets/models/best.onnx")
    print("=" * 70)

if __name__ == "__main__":
    main()
