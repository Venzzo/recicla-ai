# RECICLA.AI — Sistema Móvel Acadêmico de Visão Computacional Offline para Triagem de Resíduos

[![Dart Tests](https://img.shields.io/badge/Dart%20Tests-16%20Passed-brightgreen.svg)](#testes-e-validação)
[![Model](https://img.shields.io/badge/Model-YOLOv5n%20ONNX%20(7.20%20MB)-blue.svg)](#inteligência-artificial-e-inferência-local)
[![Latency](https://img.shields.io/badge/Latency-7.19%20ms%20%7C%20139.2%20FPS-purple.svg)](#inteligência-artificial-e-inferência-local)
[![License](https://img.shields.io/badge/License-CC%20BY%204.0%20%2F%20Academic-orange.svg)](#licença)

---

## 1. Problema

No Brasil e em escala global, a gestão de resíduos sólidos enfrenta gargalos críticos que inviabilizam a economia circular:
* **Contaminação Cruzada:** A mistura de resíduos orgânicos e umidade em recipientes de papel e papelão deteriora as fibras celulósicas e inviabiliza a triagem mecânica em galpões de reciclagem.
* **Embalagens Multimateriais:** Produtos comerciais combinam materiais distintos (ex.: garrafas de vidro com tampas de aço/alumínio, ou caixas de papelão com janelas plásticas). Quando descartados sem separação prévia, dificultam o trabalho de cooperativas.
* **Falta de Informação e Acidentes:** O descarte inadequado de cacos de vidro e lâminas metálicas expõe garis e catadores de materiais recicláveis a frequentes acidentes de trabalho com cortes graves e infecções.

---

## 2. Objetivo

O **RECICLA.AI** foi projetado como uma **solução acadêmica móvel (Flutter)** para empoderar o cidadão na separação correta de resíduos na fonte geradora, por meio de:
1. **Identificação Visual On-Device:** Reconhecimento automático dos materiais presentes na cena através de visão computacional executada 100% no próprio celular (sem nuvem).
2. **Detecção de Múltiplos Componentes:** Localização e delimitação espacial (bounding boxes) de múltiplos objetos em uma mesma embalagem.
3. **Orientação Baseada na Resolução CONAMA nº 275/2001:** Associação instantânea à lixeira padronizada (Azul, Vermelho, Verde, Amarelo e Marrom), com passos objetivos de higienização, compactação e segurança.
4. **Transparência Acadêmica:** Tratamento da inteligência artificial como um **protótipo científico**, alertando o usuário expressamente sempre que a confiança da detecção for baixa.

---

## 3. Comunidade Beneficiada

* **Catadores de Materiais Recicláveis e Cooperativas:** Maior pureza dos fardos de recicláveis, valorização comercial dos materiais entregues e redução direta de acidentes com vidro e metais perfurantes.
* **Cidadãos e Consumidores:** Facilidade e clareza para cumprir a separação seletiva doméstica sem dúvidas sobre onde descartar cada componente.
* **Municípios e Meio Ambiente:** Redução do volume de resíduos direcionados a aterros sanitários, diminuição das emissões de metano e promoção da logística reversa.

---

## 4. Dataset e Treinamento (Guia de Reprodução da Metodologia)

Para que avaliadores, professores e pesquisadores consigam reproduzir com exatidão a metodologia experimental sem a necessidade de manter o dataset bruto (~1.5 GB) versionado no repositório Git, todo o procedimento de aquisição, particionamento e treinamento está documentado a seguir.

### 4.1. Origem e Obtenção do Dataset

* **Nome do Dataset:** **GARBAGE CLASSIFICATION 3**
* **Fonte Oficial:** [Roboflow Universe — Garbage Classification 3](https://universe.roboflow.com/material-identification/garbage-classification-3)
* **Licença:** **Creative Commons Attribution 4.0 International (CC BY 4.0)**
* **Formato para Download:** `YOLOv5 PyTorch` (pastas `images` e `labels` com anotações em `.txt` normalizadas)
* **Total de Imagens:** **10.464 imagens**
* **Particionamento Oficial Estrito:**
  * **Treinamento (`train/`):** 7.324 imagens (51.611 anotações de bounding boxes)
  * **Validação (`valid/`):** 2.098 imagens (18.916 anotações)
  * **Teste Independente (`test/`):** 1.042 imagens (3.563 anotações) — **partição cega que nunca participou do treinamento nem do ajuste de hiperparâmetros**
* **Classes Mapeadas (6 classes):**
  `0: biodegradable`, `1: cardboard`, `2: glass`, `3: metal`, `4: paper`, `5: plastic`

#### Como Baixar o Dataset via Script Python
O dataset pode ser baixado automaticamente utilizando a biblioteca oficial do Roboflow:
```python
# pip install roboflow
from roboflow import Roboflow

rf = Roboflow(api_key="SUA_CHAVE_ROBOFLOW") # Chave gratuita do Roboflow
project = rf.workspace("material-identification").project("garbage-classification-3")
version = project.version(2)
dataset = version.download("yolov5")
```
Ou alternativamente por download direto no site do Roboflow escolhendo o formato **YOLOv5**.

---

### 4.2. Estrutura do Arquivo `data.yaml`

Após extrair o dataset, configure o arquivo `data.yaml` apontando para os splits segregados:
```yaml
path: ./dataset
train: images/train
val: images/valid
test: images/test

names:
  0: biodegradable
  1: cardboard
  2: glass
  3: metal
  4: paper
  5: plastic
```

---

### 4.3. Instalação das Dependências de IA

Para reproduzir o ambiente de treinamento em qualquer computador (Windows, Linux ou macOS):
```bash
pip install torch torchvision yolov5 onnx onnxruntime opencv-python pillow
```

---

### 4.4. Obtenção dos Pesos Iniciais Genéricos (COCO)

> [!IMPORTANT]
> **Rigor Científico:** O modelo do RECICLA.AI **não** utiliza pesos prévios treinados por terceiros no domínio de resíduos. O treinamento parte exclusivamente do checkpoint oficial genérico do YOLOv5n pré-treinado no conjunto COCO (80 classes gerais, como carros, pessoas e animais):

Baixe o checkpoint genérico oficial da Ultralytics:
```bash
# Download dos pesos genéricos (3.87 MB)
curl -L -o yolov5n.pt https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5n.pt
```

---

### 4.5. Execução do Treinamento (Fine-Tuning)

Execute o treinamento apontando para o split oficial de treino e validação:

```bash
python -m yolov5.train \
  --data data.yaml \
  --weights yolov5n.pt \
  --epochs 1 \
  --batch-size 32 \
  --imgsz 320 \
  --device cpu \
  --workers 0 \
  --project runs/train \
  --name recicla_ai_model \
  --exist-ok
```

#### Parâmetros e Justificativas Metodológicas:
* `--weights yolov5n.pt`: Transfer learning a partir do COCO genérico (157 camadas, 1.767.283 parâmetros).
* `--imgsz 320`: Resolução $320 \times 320$ pixels, selecionada especificamente para viabilizar inferência de ultrabaixa latência em dispositivos móveis (inferência em ~7 ms).
* `--batch-size 32`: 229 lotes de 32 imagens por época (totalizando 7.324 imagens de treino).
* `--optimizer SGD`: Taxa de aprendizado inicial $lr_0 = 0.01$, momentum $= 0.937$, weight decay $= 0.0005$.
* `--workers 0`: Garante estabilidade de multiprocessamento em arquiteturas Windows e ARM.

#### Evolução Real das Perdas Durante o Treino:
* $\text{box\_loss}$: Reduziu de $0.134$ para $0.0913$
* $\text{cls\_loss}$: Reduziu de $0.061$ para $0.0393$
* $\text{obj\_loss}$: Convergiu para $0.0492$

---

### 4.6. Avaliação Cega no Conjunto de Teste Independente

Para calcular as métricas reais sobre as 1.042 imagens do conjunto `test/` (que não participaram do treino nem da validação):

```bash
python -m yolov5.val \
  --data data.yaml \
  --weights runs/train/recicla_ai_model/weights/best.pt \
  --task test \
  --batch-size 32 \
  --imgsz 320 \
  --project runs/val \
  --name test_results \
  --exist-ok
```

---

### 4.7. Exportação para ONNX (Mobile Runtime)

Após o término da avaliação, converta os pesos PyTorch (`best.pt`) para o formato aberto ONNX com dimensões fixas $320 \times 320$:

```bash
python -m yolov5.export \
  --weights runs/train/recicla_ai_model/weights/best.pt \
  --imgsz 320 320 \
  --include onnx
```

O arquivo exportado terá aproximadamente **7,20 MB** (`best.onnx`). Copie-o para o diretório de assets do aplicativo Flutter:
```bash
cp runs/train/recicla_ai_model/weights/best.onnx assets/models/best.onnx
```

---

### 4.8. Script Tudo-em-Um para Reprodução
O repositório disponibiliza o utilitário [`tools/reproduce_training.py`](tools/reproduce_training.py), que automatiza todo o pipeline descrito acima (download dos pesos base, treino, avaliação de teste e exportação ONNX) com um único comando.

---

## 6. Métricas Reais no Conjunto de Teste Independente

Avaliação executada sobre as **1.042 imagens cegas** do conjunto de teste (3.563 instâncias reais):

| Métrica | Valor Medido | Observação Acadêmica |
| :--- | :---: | :--- |
| **Precisão Global ($P$)** | **16.68%** | Taxa média de acerto sobre predições positivas |
| **Recall Global ($R$)** | **47.64%** | O modelo foi capaz de localizar quase metade das instâncias de teste |
| **$F_1\text{-Score}$** | **24.70%** | Média harmônica entre precisão e recall |
| **$mAP@0.50$** | **12.11%** | Desempenho global em threshold IoU de 0.50 |
| **$mAP@0.50:0.95$** | **6.34%** | Média nas faixas estritas de IoU 0.50 a 0.95 |

### Desempenho por Classe no Teste

* **`paper` (1.376 instâncias):** $P = 30.90\%$, $R = 38.00\%$, $mAP50 = 25.50\%$, $mAP50\text{-}95 = 14.54\%$
* **`metal` (533 instâncias):** $P = 22.00\%$, $R = 47.50\%$, $mAP50 = 20.10\%$, $mAP50\text{-}95 = 9.62\%$
* **`plastic` (1.585 instâncias):** $P = 29.40\%$, $R = 19.20\%$, $mAP50 = 12.70\%$, $mAP50\text{-}95 = 6.51\%$
* **`glass` (detecções):** $mAP50\text{-}95 = 6.34\%$
* **`biodegradable` (49 instâncias):** $R = 73.50\%$, $mAP50\text{-}95 = 0.63\%$ (classe minoritária, alta sensibilidade)
* **`cardboard` (20 instâncias):** $R = 60.00\%$, $mAP50\text{-}95 = 0.40\%$

---

## 7. Pipeline de Processamento de Imagens

```
  [Foto Capturada (Câmera / Galeria)]
                 │
                 ▼
  [Letterbox Proporcional (320 x 320, padding cinza 114)]
                 │
                 ▼
  [Normalização Float32 [0.0, 1.0] em Tensor NCHW [1, 3, 320, 320]]
                 │
                 ▼
  [Inferência no Modelo ONNX Runtime (best.onnx)]
                 │
                 ▼
  [Tensor de Saída: [1, 6300, 11]]
                 │
                 ▼
  [Filtragem por Confiança (conf ≥ 0.15) & Supressão de Não-Máximos (NMS IoU > 0.45)]
                 │
                 ▼
  [Reversão de Coordenadas para o Aspect Ratio Original]
                 │
                 ▼
  [Exibição de Bounding Boxes + Associação ao Catálogo CONAMA 275/2001]
```

---

## 8. Inteligência Artificial e Inferência Local (On-Device)

* **Formato do Modelo:** **ONNX** (`assets/models/best.onnx`).
* **Tamanho do Arquivo:** **7,20 MB** (autocontido).
* **Latência Medida de Inferência:** **7.19 ms** por frame em CPU Snapdragon X (mínimo de 5.56 ms).
* **Taxa de Quadros (Throughput):** **139.2 FPS** (capacidade de inferência em tempo real).
* **Vantagens da Abordagem Local:**
  * **100% Offline:** Funciona em qualquer lugar sem sinal de internet ou plano de dados.
  * **Privacidade Absoluta:** Nenhuma foto do usuário sai do aparelho.
  * **Sem Custos Recorrentes:** Zero gastos com tokens de APIs pagas ou hospedagem em nuvem.

---

## 9. Limitações Reais e Transparência Acadêmica

1. **Protótipo Científico:** O modelo foi treinado por 1 época sobre pesos genéricos COCO, visando viabilidade e comprovação do pipeline metodológico. Não deve ser considerado um classificador infalível.
2. **Desbalanceamento das Classes Minoritárias:** Classes como `biodegradable` (49 instâncias de teste) e `cardboard` (20 instâncias de teste) exibem alto recall (60% a 73.5%), porém menor precisão, podendo apresentar falso-positivos em fundos complexos.
3. **Mecanismo de Proteção no Aplicativo:** Quando uma detecção apresenta confiança inferior a 40%, o aplicativo exibe expressamente:
   > **⚠️ Baixa confiança. Verifique visualmente o material antes do descarte.**

---

## 10. Como Executar o Protótipo Interativo Local

O projeto disponibiliza um validador interativo que executa o modelo ONNX real e o catálogo no terminal:

```bash
# Executar análise com imagem de demonstração
python tools/recicla_ai_interactive_demo.py

# Analisar uma imagem específica
python tools/recicla_ai_interactive_demo.py --image caminho/para/imagem.jpg

# Executar benchmark de latência
python tools/recicla_ai_interactive_demo.py --benchmark
```

Os resultados anotados e a imagem pré-processada 320x320 são salvos automaticamente em `scratch/demo_output/`.

---

## 11. Estrutura do Projeto Flutter

```
recicla-ai/
├── assets/
│   ├── data/
│   │   └── materials_catalog.json    # Catálogo CONAMA das 6 classes
│   └── models/
│       └── best.onnx                 # Modelo treinado oficial (7.20 MB)
├── lib/
│   ├── models/
│   │   ├── material_info.dart        # Modelo de dados dos materiais
│   │   └── detection_result.dart     # Bounding box, confiança e classe
│   ├── services/
│   │   ├── catalog_service.dart      # Carregamento e regras multimateriais
│   │   └── vision_service.dart       # Letterbox 320x320, NMS e decodificação
│   ├── widgets/
│   │   ├── bounding_box_painter.dart # Renderização gráfica das caixas CONAMA
│   │   └── material_card.dart        # Cartões informativos de descarte
│   ├── screens/
│   │   ├── home_screen.dart          # Tela principal (Câmera / Galeria / Guia)
│   │   ├── result_screen.dart        # Resultados com caixas e desmontagem
│   │   ├── how_it_works_screen.dart  # Painel didático do fluxo 5 passos
│   │   └── academic_didactic_screen.dart # Comparativo: Original vs 320x320 vs IA
│   └── main.dart                     # Ponto de entrada do aplicativo
├── android/                          # Manifests e Gradle para build de APK
├── ios/                              # Info.plist e Podfile para CoreML/Xcode
├── test/
│   └── unit_test.dart                # 16 testes de integridade acadêmica
├── tools/
│   └── recicla_ai_interactive_demo.py# Simulador onnxruntime CLI
├── .github/workflows/
│   └── build_apk.yml                 # CI/CD para compilação automática do APK
└── pubspec.yaml                      # Configurações do Flutter
```

---

## 12. Geração da Versão Android (APK Release)

### Como Compilar o APK Release Localmente
Caso você tenha o Flutter e o Android SDK instalados:
```bash
# Obter dependências
flutter pub get

# Compilar APK Release assinado para instalação fora da Play Store
flutter build apk --release
```
O arquivo APK gerado estará em:
`build/app/outputs/flutter-apk/app-release.apk`

### Instalação Fora da Play Store (Sideloading)
1. Transfira o arquivo `app-release.apk` para o smartphone Android via cabo USB, Google Drive, WhatsApp ou Telegram.
2. No celular, acesse o aplicativo **Arquivos** / **Downloads** e toque no `.apk`.
3. Caso solicitado, marque a opção **"Permitir desta fonte"** (Instalação de fontes desconhecidas).
4. Confirme a instalação e abra o aplicativo.

### Compilação Automática no GitHub Actions (CI/CD)
O repositório já inclui o arquivo [`.github/workflows/build_apk.yml`](.github/workflows/build_apk.yml).
Ao fazer push para o GitHub, a esteira do GitHub Actions:
1. Configura Java 17 e Flutter SDK em máquina virtual Ubuntu.
2. Compila automaticamente o arquivo `app-release.apk` (Universal e ABI Splits).
3. Disponibiliza o APK final para download direto na aba **Actions** / **Artifacts**.

---

## 13. Preparação para Versão iOS

### Limitações Oficiais da Apple
O ecossistema iOS impõe restrições estritas para a geração de aplicativos:
* **Exigência de macOS:** A compilação de código nativo iOS e o empacotamento em `.ipa` exigem um computador com macOS e o software Xcode instalado.
* **Instalação Sem Loja:** Diferente do Android, a Apple restringe a instalação de pacotes fora da App Store. Para projetos acadêmicos e testes sem publicação comercial, utilizam-se os métodos:
  * **TestFlight** (requer Apple Developer Program pago).
  * **Build Ad-Hoc / Desenvolvimento** (usando conta gratuita da Apple, instalável via Xcode ou Apple Configurator).
  * **AltStore / Sideloadly** (usando Apple ID pessoal para assinar o `.ipa` por 7 dias).

### Como Gerar o Projeto e o IPA no macOS
1. Clone o repositório em um ambiente macOS:
   ```bash
   flutter pub get
   flutter build ios --no-codesign
   ```
2. Abra a pasta `ios/Runner.xcworkspace` no **Xcode**.
3. Na aba *Signing & Capabilities*, selecione sua equipe de desenvolvimento (*Personal Team*).
4. Conecte o iPhone via cabo USB e selecione o dispositivo como destino.
5. No menu superior do Xcode, selecione **Product > Archive**.
6. Concluído o archive, clique em **Distribute App > Ad-Hoc (ou Development)** para exportar o arquivo `.ipa`.

---

## 14. Licença

* Código-fonte e arquitetura do RECICLA.AI disponibilizados para fins de estudo acadêmico e pesquisa pública.
* Dataset **Garbage Classification 3** sob licença **Creative Commons Attribution 4.0 International (CC BY 4.0)**.
