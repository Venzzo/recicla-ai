# RECICLA.AI — Sistema Móvel Acadêmico de Visão Computacional Offline para Triagem de Resíduos

[![Dart Tests](https://img.shields.io/badge/Dart%20Tests-17%20Passed-brightgreen.svg)](#instalação-e-execução)
[![Model](https://img.shields.io/badge/Model-YOLOv5n%20ONNX%20(7.20%20MB)-blue.svg)](#integração-com-inteligência-artificial)
[![Latency](https://img.shields.io/badge/Latency-7.19%20ms%20%7C%20139.2%20FPS-purple.svg)](#inferência-no-aplicativo)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.3%20%7C%20Dart%203.5.3-02569B.svg)](#tecnologias-utilizadas)
[![License](https://img.shields.io/badge/License-CC%20BY%204.0%20%2F%20Academic-orange.svg)](#licença)

---

## Integrantes

Mateus Fernandes Da Silva.
Miguel Souza Soares.

---

## Descrição do Projeto

### Objetivo do Aplicativo
O **RECICLA.AI** é uma solução acadêmica desenvolvida em Flutter projetada para orientar e capacitar cidadãos, condomínios e cooperativas na separação e destinação ambientalmente adequada de resíduos sólidos recicláveis diretamente na fonte geradora. O aplicativo transforma o smartphone em uma ferramenta portátil de triagem seletiva, utilizando visão computacional e inteligência artificial on-device (100% offline) para identificar os materiais presentes na cena e indicar imediatamente a lixeira correta conforme a legislação ambiental brasileira (**Resolução CONAMA nº 275/2001**).

### Problema que Resolve
No Brasil e no cenário internacional, a logística reversa e a reciclagem de resíduos sólidos enfrentam gargalos críticos:
1. **Contaminação Cruzada na Coleta Seletiva:** A mistura de resíduos orgânicos úmidos ou gorduras com materiais secos (como papel e papelão) degrada as fibras celulósicas e inviabiliza lotes inteiros de materiais nos galpões de triagem.
2. **Descarte Incorreto de Embalagens Multimateriais:** Produtos comerciais comuns combinam materiais de naturezas distintas (por exemplo: garrafas de vidro com tampas metálicas, caixas de papelão com visores plásticos, copos descartáveis com tampas acrílicas). Quando descartados inteiros sem separação prévia dos componentes, dificultam ou inviabilizam o trabalho das esteiras de reciclagem.
3. **Segurança e Riscos Ocupacionais:** O descarte desprotegido de cacos de vidro e lâminas metálicas perfurocortantes provoca frequentes acidentes de trabalho com lacerações graves e infecções entre garis e catadores de materiais recicláveis.

### Como o Usuário Interage com o Aplicativo
O fluxo de uso foi construído para ser intuitivo, didático e ágil:
1. **Captura ou Seleção da Imagem:** Na tela principal (`HomeScreen`), o usuário pode tirar uma fotografia em tempo real utilizando a câmera do smartphone ou selecionar uma foto existente da galeria.
2. **Processamento Instantâneo:** A imagem é analisada localmente em milissegundos sem enviar qualquer dado para servidores remotos.
3. **Exibição dos Resultados com Caixas Delimitadoras:** Na tela de resultados (`ResultScreen`), a foto capturada é apresentada com caixas delimitadoras coloridas (*bounding boxes*) desenhadas exatamente sobre os objetos identificados.
4. **Orientações Práticas e Separação de Componentes:** Abaixo da foto, o usuário visualiza cartões com as cores oficiais CONAMA (Azul, Vermelho, Verde, Amarelo, Marrom), passos detalhados de higienização (ex.: enxaguar recipientes, desrosquear e separar tampas, compactar latas e garrafas) e regras para componentes mistos.
5. **Alerta Preventivo de Baixa Confiança:** Caso o modelo identifique um material com nível de confiança estatística inferior a 40%, um aviso destacado em amarelo alerta o usuário para realizar a verificação visual humana antes do descarte.
6. **Módulos Educativos Integrados:** O usuário tem acesso à tela didática *"Como Funciona"* (passo a passo de 5 etapas) e à tela de *"Apresentação Acadêmica"*, onde é possível comparar visualmente a imagem original, a imagem pré-processada em 320×320 com Letterbox cinza e as detecções da rede neural com as métricas do modelo.

### Tecnologias Utilizadas
* **Desenvolvimento Mobile Multiplataforma:** Flutter 3.24.3 e Dart 3.5.3 (suporte a Android e iOS).
* **Arquitetura de Rede Neural / IA:** YOLOv5n (Ultralytics, variante Nano com 1,77 milhão de parâmetros).
* **Formato do Modelo e Execução Local:** ONNX (*Open Neural Network Exchange*) rodando on-device via biblioteca de tensores autocontida.
* **Processamento de Imagens em Dart:** Pacote `image` para decodificação de imagem, redimensionamento proporcional com Letterbox cinza neutro (114) e estruturação de tensores NCHW `[1, 3, 320, 320]`.
* **Pós-Processamento e Algoritmos:** Implementação nativa em Dart de Non-Maximum Suppression (NMS) e decodificação vetorial de âncoras.
* **Padrão Normativo Ambiental:** Resolução CONAMA nº 275/2001 do Conselho Nacional do Meio Ambiente, mapeada em catálogo JSON local (`assets/data/materials_catalog.json`).
* **Ambiente de Pesquisa e IA (Python):** Python 3.10+, PyTorch 2.x, YOLOv5, OpenCV, ONNX Runtime e Roboflow.

### Papel do Processamento de Imagens
O processamento de imagens atua nas duas pontas da rede neural:
* **No Pré-processamento:** Adapta fotografias de qualquer resolução e proporção para o formato estrito exigido pelo modelo ($320 \times 320$ pixels). Aplica a técnica de *Letterbox*, que insere bordas cinzas neutras para manter intacta a proporção geométrica dos objetos (evitando distorções anamórficas que prejudicam a detecção). Em seguida, converte os canais para RGB e normaliza a intensidade dos pixels da escala $[0, 255]$ para valores de ponto flutuante Float32 no intervalo $[0.0, 1.0]$.
* **No Pós-processamento:** Converte as coordenadas do espaço $320 \times 320$ de volta para o sistema original de coordenadas da fotografia capturada, permitindo que a camada de renderização gráfica desenhe com precisão as caixas sobre a foto na tela do smartphone.

### Papel da Inteligência Artificial
A Inteligência Artificial desempenha o papel de **motor de detecção de objetos (Object Detection)**. Diferente de um classificador simples que analisa uma imagem inteira como um rótulo único, o modelo detecta simultaneamente múltiplos materiais presentes na mesma imagem, retornando tanto as classes preditas (`biodegradable`, `cardboard`, `glass`, `metal`, `paper`, `plastic`) quanto a posição espacial tridimensional estimada de cada objeto.

### Como o Resultado é Apresentado ao Usuário
* **Sobreposição Gráfica Direta:** Caixas delimitadoras coloridas desenhadas diretamente sobre a fotografia com a cor exata regulamentada pelo CONAMA para cada material.
* **Badges de Confiança e Classe:** Rótulos indicando o nome do material em português e o percentual de certeza estatística do modelo.
* **Cartões Operacionais de Manejo:** Painéis informativos indicando a lixeira adequada, cuidados higiênicos e etapas de desmontagem.
* **Sinalização Explícita de Cautela:** Advertência visual preventiva quando a confiança for inferior a 40%, assegurando postura ética e transparência científica.

---

## Tecnologias Utilizadas

| Componente | Tecnologia | Finalidade no Projeto |
| :--- | :--- | :--- |
| **Framework Mobile** | Flutter 3.24.3 / Dart 3.5.3 | Construção da interface responsiva e lógica de aplicação para Android e iOS |
| **Arquitetura de Visão** | YOLOv5n (Ultralytics Nano) | Modelo de detecção de objetos leve (1,77M parâmetros, 4,1 GFLOPs) |
| **Formato de Exportação** | ONNX (*Open Neural Network Exchange*) | Formato aberto e portável (`best.onnx`, 7,20 MB) para inferência on-device |
| **Processamento de Imagens** | Dart `image` package | Decodificação, Letterbox 320x320, padding cinza e tensores NCHW Float32 |
| **Pós-processamento** | NMS (Non-Maximum Suppression) | Eliminação de detecções duplicadas e filtragem de ruídos com limiar IoU = 0.45 |
| **Base Normativa** | CONAMA nº 275/2001 | Catálogo oficial de cores e regras para resíduos sólidos recicláveis no Brasil |
| **Ambiente de Treinamento** | Python 3.10+, PyTorch, Ultralytics | Scripts de transfer learning, validação cega independente e exportação ONNX |
| **Ambiente de Validação CLI** | OpenCV + ONNX Runtime | Simulador interativo em terminal (`tools/recicla_ai_interactive_demo.py`) |
| **Automação CI/CD** | GitHub Actions | Compilação automática do APK release universal no repositório |

---

## Pipeline de Processamento de Imagens

O processamento de imagens do RECICLA.AI cobre 14 etapas encadeadas, desde a entrada da foto bruta até a apresentação final na tela do usuário.

```
       [ 1. Origem da Imagem ] (Câmera do aparelho ou Galeria)
                  │
                  ▼
       [ 2. Captura / Seleção ] (image_picker em Uint8List)
                  │
                  ▼
       [ 3. Decodificação & Letterbox ] (320 × 320, padding cinza RGB 114)
                  │
                  ▼
       [ 4. Conversão de Canais ] (Garantia do padrão de cores RGB)
                  │
                  ▼
       [ 5. Normalização de Pixels ] (Divisão por 255.0 para Float32 [0.0, 1.0])
                  │
                  ▼
       [ 6. Estruturação do Tensor ] (Formato NCHW: [1, 3, 320, 320])
                  │
                  ▼
       [ 7. Execução da Inferência ] (Processamento local com modelo ONNX)
                  │
                  ▼
       [ 8. Tratamento da Saída ] (Tensor bruto [1, 6300, 11])
                  │
                  ▼
       [ 9. Filtragem por Confiança ] (Score = obj_conf × class_score ≥ 0.15)
                  │
                  ▼
       [ 10. Non-Maximum Suppression ] (NMS por classe com limiar IoU = 0.45)
                  │
                  ▼
       [ 11. Recuperação das Coordenadas ] (Desfazer Letterbox e subtrair paddings)
                  │
                  ▼
       [ 12. Geração das Bounding Boxes ] (Mapeamento normalizado [0, 1] no aspecto original)
                  │
                  ▼
       [ 13. Associação ao Catálogo CONAMA ] (Mapeamento de classe, cor e regras de descarte)
                  │
                  ▼
       [ 14. Apresentação no Aplicativo ] (Pintura de caixas, cartões de manejo e alertas)
```

### Detalhamento das Etapas Implementadas no Código

1. **Origem da Imagem:** O fluxo tem início quando o usuário opta por fotografar um resíduo ou escolher uma imagem do armazenamento interno do aparelho.
2. **Captura / Seleção da Imagem:** Realizada via plugin `image_picker`, capturando a imagem como fluxo de bytes brutos em memória (`Uint8List`).
3. **Redimensionamento Proporcional com Letterbox:** Implementado na função `preprocessImage` de [`lib/services/vision_service.dart`](lib/services/vision_service.dart). Para não distorcer o aspecto geométrico do objeto, calcula-se o fator de escala proporcional:
   $$scale = \min\left(\frac{320}{largura\_original}, \frac{320}{altura\_original}\right)$$
   A imagem original é redimensionada proporcionalmente e colada centralizada em um canvas quadrado de $320 \times 320$ pixels com fundo cinza neutro (`RGB 114, 114, 114`), gerando os deslocamentos de padding `padX` e `padY`.
4. **Conversão de Canais:** Os pixels decodificados são processados garantindo a ordenação correta dos canais de cor Red, Green e Blue (RGB).
5. **Normalização:** Cada valor inteiro de pixel de 8 bits no intervalo $[0, 255]$ é dividido por $255.0$, transformando a matriz em números reais de ponto flutuante Float32 no intervalo normalizado $[0.0, 1.0]$.
6. **Transformação para o Formato do Modelo (Tensor NCHW):** O array plano de pixels é reorganizado na ordem dimensional canônica de redes neurais convolucionais: Batch ($N=1$), Canais ($C=3$), Altura ($H=320$) e Largura ($W=320$). O vetor resultante contém $1 \times 3 \times 320 \times 320 = 307.200$ valores `Float32`.
7. **Execução da Inferência:** O tensor formatado é processado on-device pelo modelo YOLOv5n (`best.onnx`).
8. **Tratamento da Saída do Modelo:** A rede neural retorna uma matriz de predições com dimensões $[1, 6300, 11]$. As 6.300 linhas correspondem às caixas âncora candidatas geradas nas 3 escalas da pirâmide de características (Feature Pyramid). Para cada linha, os 11 atributos contêm:
   * Índices `[0, 1, 2, 3]`: Coordenadas do centro, largura e altura da caixa $[cx, cy, w, h]$ no espaço 320×320.
   * Índice `[4]`: Confiança de objetividade (`objectness score`).
   * Índices `[5 ... 10]`: Probabilidades condicionais das 6 classes (`biodegradable`, `cardboard`, `glass`, `metal`, `paper`, `plastic`).
9. **Filtragem por Confiança:** Para cada âncora, determina-se a classe de maior probabilidade e calcula-se a confiança final combinada:
   $$\text{confiança} = \text{objectness} \times \max(\text{probabilidade\_classe})$$
   Candidatos com $\text{confiança} < 0.15$ (15%) são descartados sumariamente.
10. **Non-Maximum Suppression (NMS):** As caixas candidatas sobreviventes são ordenadas de forma decrescente por confiança. O algoritmo NMS calcula a Intersecção sobre a União (IoU) entre pares de caixas da mesma classe:
    $$\text{IoU}(A, B) = \frac{\text{Área}(A \cap B)}{\text{Área}(A \cup B)}$$
    Se duas caixas da mesma classe possuírem $\text{IoU} > 0.45$, a caixa com menor confiança é suprimida para evitar caixas redundantes sobre o mesmo objeto.
11. **Recuperação das Coordenadas (Desfazer Letterbox):** As coordenadas no espaço $320 \times 320$ são convertidas de $[cx, cy, w, h]$ para bordas $[left, top, right, bottom]$. Em seguida, os deslocamentos `padX` e `padY` são removidos e os valores são divididos pela escala $scale$, mapeando as coordenadas normalizadas de volta para o intervalo $[0.0, 1.0]$ da imagem original capturada.
12. **Geração das Bounding Boxes:** As coordenadas recuperadas são empacotadas em estruturas geométricas `Rect` normalizadas.
13. **Associação/Identificação do Material:** O identificador numérico da classe (`classId`) é associado ao catálogo oficial [`assets/data/materials_catalog.json`](assets/data/materials_catalog.json), recuperando o nome em português, a cor CONAMA correspondente, instruções de manejo e regras de embalagens mistas.
14. **Apresentação do Resultado no Aplicativo:** O widget `BoundingBoxPainter` desenha as caixas coloridas com suas etiquetas sobre a imagem original, e a interface exibe os cartões com as instruções de higienização e alertas caso a confiança seja inferior a 40%.

---

## Integração com Inteligência Artificial

A integração da disciplina de Inteligência Artificial no projeto RECICLA.AI cobre todo o ciclo de vida do aprendizado de máquina, desde a seleção e validação do dataset até a execução em tempo real no dispositivo móvel.

```
                  [ 1. Dataset Bruto ] (Garbage Classification 3)
                            │
                            ▼
              [ 2. Preparação & Split dos Dados ] (Train: 70% | Valid: 20% | Test: 10%)
                            │
                            ▼
                [ 3. Modelo Base Pré-treinado ] (YOLOv5n COCO Genérico)
                            │
                            ▼
            [ 4. Treinamento / Fine-Tuning ] (Transfer Learning nas 6 classes)
                            │
                            ▼
               [ 5. Avaliação Cega Independente ] (Métricas no split test/ isolado)
                            │
                            ▼
                 [ 6. Seleção do Melhor Modelo ] (Checkpoint weights/best.pt)
                            │
                            ▼
              [ 7. Exportação para Formato ONNX ] (best.pt ➔ best.onnx 320×320)
                            │
                            ▼
          [ 8. Empacotamento Local no Flutter ] (Asset assets/models/best.onnx)
                            │
                            ▼
              [ 9. Inferência On-Device Offline ] (Execução local em ~7 ms no smartphone)
                            │
                            ▼
             [ 10. Apresentação das Detecções ] (Coordenadas, cores CONAMA e classes)
```

### Explicação Detalhada de Cada Etapa

1. **Dataset Utilizado:** Foi selecionado o dataset **Garbage Classification 3**, obtido publicamente no Roboflow Universe.
2. **Preparação dos Dados:** O dataset foi organizado no formato padrão YOLOv5, dividindo imagens (`images/`) e rótulos (`labels/`) em arquivos de texto contendo as anotações espaciais normalizadas `class_id x_center y_center width height`.
3. **Modelo Base:** Foi utilizado como ponto de partida o modelo leve **YOLOv5n** pré-treinado no conjunto genérico COCO da Ultralytics (`yolov5n.pt`, com 80 classes gerais como carros e animais).
   > **Rigor Metodológico Acadêmico:** O projeto **não** utilizou modelos previamente treinados por terceiros no domínio de resíduos. O aprendizado sobre o domínio de lixo e reciclagem foi construído integralmente no projeto a partir de transfer learning.
4. **Treinamento / Fine-Tuning:**
   * **Resolução de Entrada:** $320 \times 320$ pixels, estabelecida para viabilizar inferência em smartphones modestos sem engasgos de memória.
   * **Hiperparâmetros:** Otimizador SGD (*Stochastic Gradient Descent*) com taxa de aprendizado inicial $lr_0 = 0.01$, momentum $= 0.937$ e decaimento de peso (*weight decay*) de $0.0005$.
   * **Épocas e Lotes:** Treinamento executado por 1 época completa sobre as 7.324 imagens da partição `train/`, divididas em 229 lotes de 32 imagens.
   * **Convergência:** As perdas de regressão de caixa ($\text{box\_loss}$) caíram de $0.134$ para $0.0913$, e as perdas de classificação ($\text{cls\_loss}$) reduziram de $0.061$ para $0.0393$.
5. **Avaliação Cega Independente:**
   * A avaliação final foi realizada estritamente sobre a partição `test/` (1.042 imagens com 3.563 objetos reais), que nunca participou do treinamento nem da validação de hiperparâmetros.
   * As métricas reais aferidas foram:
     * **Precisão Global ($P$):** **16.68%**
     * **Recall Global ($R$):** **47.64%**
     * **$F_1\text{-Score}$ Global:** **24.70%**
     * **$mAP@0.50$:** **12.11%**
     * **$mAP@0.50:0.95$:** **6.34%**
6. **Seleção do Modelo:** O checkpoint dos pesos ótimos obtidos no treinamento foi salvo em `runs/train/recicla_ai_model/weights/best.pt`.
7. **Exportação do Modelo:** Os pesos em formato PyTorch foram convertidos para a especificação aberta ONNX (*Open Neural Network Exchange*) com dimensões estáticas $320 \times 320$ através do script oficial de exportação:
   ```bash
   python -m yolov5.export --weights best.pt --imgsz 320 320 --include onnx
   ```
   O arquivo resultante `best.onnx` possui apenas **7,20 MB**, ideal para distribuição móvel.
8. **Modelo Utilizado pelo Aplicativo:** O arquivo `best.onnx` foi copiado para o diretório de assets do aplicativo (`assets/models/best.onnx`) e declarado no `pubspec.yaml`, sendo empacotado diretamente dentro do APK/IPA.
9. **Inferência no Dispositivo:** A inferência é executada de forma 100% on-device no smartphone, sem conexões de rede, sem APIs de terceiros e sem custos de nuvem, atingindo latência de inferência de **7.19 ms** por quadro (**139.2 FPS**).
10. **Resultado Final:** As caixas delimitadoras e classes preditas são filtradas, vinculadas à legislação CONAMA nº 275/2001 e renderizadas na tela para orientação do usuário.

---

## Dataset

A integridade metodológica do RECICLA.AI baseia-se no uso de um dataset aberto e verificado empiricamente.

* **Nome Completo do Dataset:** **GARBAGE CLASSIFICATION 3**
* **Fonte Oficial:** [Roboflow Universe](https://universe.roboflow.com/)
* **Link Oficial do Dataset:** [https://universe.roboflow.com/material-identification/garbage-classification-3](https://universe.roboflow.com/material-identification/garbage-classification-3)
* **Licença de Uso:** **Creative Commons Attribution 4.0 International (CC BY 4.0)**
* **Formato dos Dados:** YOLOv5 PyTorch (imagens JPEG com arquivos de texto `.txt` correspondentes, contendo anotações no formato `class_id x_center y_center width height` normalizadas no intervalo $[0, 1]$).
* **Quantidade Total de Imagens Confirmada:** **10.464 imagens**
* **Quantidade de Classes Confirmada:** **6 classes de materiais**

### Particionamento Oficial dos Dados

| Partição | Quantidade de Imagens | Percentual | Instâncias Anotadas (Bounding Boxes) | Função no Pipeline |
| :--- | :---: | :---: | :---: | :--- |
| **Treinamento (`train/`)** | 7.324 | 70,0% | 51.611 caixas | Ajuste dos pesos sinápticos e filtros convolucionais |
| **Validação (`valid/`)** | 2.098 | 20,0% | 18.916 caixas | Monitoramento do gradiente e prevenção de sobreajuste |
| **Teste Independente (`test/`)** | 1.042 | 10,0% | 3.563 caixas | Aferição imparcial e cega das métricas finais |
| **Total Consolidado** | **10.464** | **100%** | **74.090 caixas** | Dataset completo com múltiplas classes por imagem |

### Classes Mapeadas e Cores Oficiais (Resolução CONAMA nº 275/2001)

| Índice | Classe no Dataset | Nome em Português | Cor da Lixeira CONAMA | Código Hex |
| :---: | :--- | :--- | :--- | :---: |
| `0` | **`biodegradable`** | Matéria Orgânica / Biodegradável | **Marrom** | `#795548` |
| `1` | **`cardboard`** | Papelão | **Azul** | `#1976D2` |
| `2` | **`glass`** | Vidro | **Verde** | `#388E3C` |
| `3` | **`metal`** | Metal (Aço / Alumínio) | **Amarelo** | `#FBC02D` |
| `4` | **`paper`** | Papel | **Azul** | `#1976D2` |
| `5` | **`plastic`** | Plástico | **Vermelho** | `#D32F2F` |

---

## Treinamento do Modelo

Para que avaliadores, professores e pesquisadores consigam reproduzir com fidelidade a metodologia sem necessitar baixar previamente todo o repositório do dataset bruto (~1,5 GB), as instruções reproduzíveis estão detalhadas a seguir.

### 1. Instalação das Dependências do Ambiente Python
Clone o repositório e instale as bibliotecas necessárias para treinamento, validação e exportação através do arquivo `requirements.txt`:
```bash
pip install -r requirements.txt
```

### 2. Download do Dataset
O download pode ser realizado via script utilizando a API do Roboflow:
```python
from roboflow import Roboflow

rf = Roboflow(api_key="SUA_CHAVE_ROBOFLOW") # Chave gratuita em roboflow.com
project = rf.workspace("material-identification").project("garbage-classification-3")
version = project.version(2)
dataset = version.download("yolov5")
```
Ou manualmente no site oficial [Roboflow — Garbage Classification 3](https://universe.roboflow.com/material-identification/garbage-classification-3), selecionando o formato **YOLOv5 PyTorch**.

### 3. Configuração do Arquivo `data.yaml`
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

### 4. Download do Checkpoint Genérico Base (COCO)
Baixe os pesos originais genéricos oficiais da Ultralytics:
```bash
curl -L -o yolov5n.pt https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5n.pt
```

### 5. Execução do Treinamento
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

### 6. Avaliação Imparcial no Conjunto de Teste
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

### 7. Exportação para Formato ONNX
```bash
python -m yolov5.export \
  --weights runs/train/recicla_ai_model/weights/best.pt \
  --imgsz 320 320 \
  --include onnx
```
O arquivo exportado (`best.onnx`) terá aproximadamente **7,20 MB** e deve ser posicionado em `assets/models/best.onnx`.

### 8. Script Tudo-em-Um de Reprodução
O repositório disponibiliza o utilitário automatizado [`tools/reproduce_training.py`](tools/reproduce_training.py), que executa todas as etapas acima com um único comando:
```bash
python tools/reproduce_training.py --data caminho/para/data.yaml --epochs 1
```

---

## Inferência no Aplicativo

O modelo definitivo foi incorporado diretamente ao pacote do aplicativo móvel:

* **Arquivo ONNX:** [`assets/models/best.onnx`](assets/models/best.onnx).
* **Tamanho do Arquivo:** **7,20 MB** (compacto para download em redes móveis).
* **Latência de Inferência Local:** **7.19 ms** por quadro (medido em processador Snapdragon X).
* **Taxa de Processamento:** **139.2 quadros por segundo (FPS)**.
* **Segurança e Privacidade:** Processamento local e off-grid; as fotos capturadas não são transmitidas nem armazenadas em servidores de terceiros.
* **Custo Zero:** Independente de infraestrutura de nuvem ou chaves de API pagas.

---

## Instalação e Execução

### 1. Pré-requisitos
* **Flutter SDK**: 3.24.3 ou superior.
* **Java JDK**: 17 (compatível com Android Gradle Toolchain).
* **Python**: 3.10 ou superior (para reprodução do ambiente de IA ou CLI interativa).

### 2. Execução da Validador Interativo (Python / Terminal)
Para validar o modelo ONNX e o catálogo CONAMA diretamente pelo computador:
```bash
# 1. Instalar dependências de IA
pip install -r requirements.txt

# 2. Executar análise com imagem de demonstração
python tools/recicla_ai_interactive_demo.py

# 3. Analisar uma imagem específica
python tools/recicla_ai_interactive_demo.py --image caminho/para/imagem.jpg

# 4. Executar medição de latência e benchmark de FPS
python tools/recicla_ai_interactive_demo.py --benchmark
```

### 3. Validação do Código Flutter e Testes Automatizados
```bash
# Obter dependências do aplicativo
flutter pub get

# Validação estática de tipos e análise de código
flutter analyze

# Execução da suíte de 17 testes unitários de integridade
dart test/unit_test.dart
```

### 4. Compilação do APK Release para Android (Sideloading)
```bash
# Limpeza e resolução de dependências
flutter clean
flutter pub get

# Compilação do APK Release universal
flutter build apk --release
```
O arquivo APK pronto para instalação direta estará disponível em:
`build/app/outputs/flutter-apk/app-release.apk` (aproximadamente **27,8 MB**).

#### Como Instalar o APK no Celular Android:
1. Conecte o smartphone via cabo USB ou transfira o arquivo `app-release.apk` via Google Drive, WhatsApp ou Telegram.
2. Abra o gerenciador de arquivos do celular e clique sobre o `.apk`.
3. Caso solicitado pelo sistema Android, ative a opção **"Permitir desta fonte"** (Instalação de fontes desconhecidas).
4. Conclua a instalação e abra o aplicativo.

### 5. Compilação Automática no GitHub Actions (CI/CD)
O repositório conta com uma esteira de integração contínua em [`.github/workflows/build_apk.yml`](.github/workflows/build_apk.yml). A cada push na branch principal, o GitHub Actions:
1. Instala o ambiente Java 17 e Flutter 3.24.3 em máquina virtual Linux Ubuntu.
2. Gera a keystore de assinatura release.
3. Compila o APK universal release.
4. Disponibiliza o instalador para download na aba **Actions** do repositório.

### 6. Preparação para iOS (Xcode / macOS)
1. Conforme as diretrizes oficiais da Apple, a compilação para iOS exige ambiente macOS com Xcode instalado:
   ```bash
   flutter pub get
   flutter build ios --no-codesign
   ```
2. Abra `ios/Runner.xcworkspace` no Xcode, selecione sua equipe de desenvolvimento (*Personal Team*) e use a opção **Product > Archive > Distribute App (Ad-Hoc / Development)** para gerar o arquivo `.ipa`.

---

## Estrutura do Projeto

```
recicla-ai/
├── .github/
│   └── workflows/
│       └── build_apk.yml             # Pipeline de CI/CD para compilação do APK Release
├── assets/
│   ├── data/
│   │   └── materials_catalog.json    # Catálogo normativo CONAMA 275/2001 (6 classes)
│   └── models/
│       └── best.onnx                 # Modelo treinado oficial compactado (7.20 MB)
├── lib/
│   ├── models/
│   │   ├── material_info.dart        # Modelo de dados de descarte e cores CONAMA
│   │   └── detection_result.dart     # Estrutura com bounding boxes, scores e classes
│   ├── services/
│   │   ├── catalog_service.dart      # Carregamento do catálogo e regras de desmontagem
│   │   └── vision_service.dart       # Pipeline: Letterbox 320x320, NMS e decodificação
│   ├── widgets/
│   │   ├── bounding_box_painter.dart # Renderização gráfica das caixas em cores CONAMA
│   │   └── material_card.dart        # Cartões de orientação e aviso de baixa confiança
│   ├── screens/
│   │   ├── home_screen.dart          # Tela principal (Câmera, Galeria, Guia CONAMA)
│   │   ├── result_screen.dart        # Exibição da foto anotada e cards de materiais
│   │   ├── how_it_works_screen.dart  # Painel didático do pipeline de 5 passos
│   │   └── academic_didactic_screen.dart # Comparativo: Original vs Letterbox vs IA
│   └── main.dart                     # Ponto de entrada do app Flutter (Material 3)
├── android/                          # Manifests, permissões e Gradle para build Android
├── ios/                              # Info.plist e configurações nativas para iOS
├── test/
│   └── unit_test.dart                # Suíte de testes unitários de integridade acadêmica
├── tools/
│   ├── recicla_ai_interactive_demo.py# Validador de inferência ONNX em linha de comando
│   └── reproduce_training.py         # Script tudo-em-um para reprodução do treinamento
├── pubspec.yaml                      # Configurações de dependências e assets do Flutter
├── requirements.txt                  # Dependências do ambiente Python e IA
└── README.md                         # Documentação acadêmica completa do projeto
```

---

## Limitações e Observações Acadêmicas

1. **Natureza do Protótipo Científico:** O modelo foi treinado por 1 época sobre o checkpoint genérico COCO, objetivando comprovar a viabilidade e reprodutibilidade do pipeline de ponta a ponta em hardware acessível. Como em qualquer protótipo acadêmico de visão computacional, o modelo não deve ser tratado como um classificador infalível.
2. **Desbalanceamento Entre Classes Minoritárias:** Classes com menor volume de instâncias anotadas no conjunto de teste, como `biodegradable` (49 instâncias) e `cardboard` (20 instâncias), apresentam alto recall (60% a 73.5%), porém menor precisão média, podendo apresentar falso-positivos ocasionais em fundos visualmente ruidosos.
3. **Mecanismo de Proteção e Transparência no App:** Quando uma detecção apresenta confiança estatística inferior a 40%, o aplicativo exibe em destaque um banner preventivo:
   > **⚠️ Baixa confiança. Verifique visualmente o material antes do descarte.**

---

## Licença

* O código-fonte, arquitetura e documentação do **RECICLA.AI** são disponibilizados para fins de pesquisa, estudo acadêmico e desenvolvimento sustentável.
* O dataset **Garbage Classification 3** está sob licença [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
