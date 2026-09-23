import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/detection_result.dart';
import '../widgets/bounding_box_painter.dart';

class AcademicDidacticScreen extends StatefulWidget {
  final Uint8List? originalBytes;
  final Uint8List? preprocessedBytes;
  final List<DetectionResult>? detections;

  const AcademicDidacticScreen({
    Key? key,
    this.originalBytes,
    this.preprocessedBytes,
    this.detections,
  }) : super(key: key);

  @override
  State<AcademicDidacticScreen> createState() => _AcademicDidacticScreenState();
}

class _AcademicDidacticScreenState extends State<AcademicDidacticScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apresentação Didática da IA'),
        backgroundColor: Colors.indigo.shade800,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3.5,
          tabs: const [
            Tab(icon: Icon(Icons.image_outlined), text: '1. Original'),
            Tab(icon: Icon(Icons.aspect_ratio_rounded), text: '2. Processada'),
            Tab(icon: Icon(Icons.check_box_outlined), text: '3. Detecções'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Visualizador de Imagens por Aba
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOriginalTab(),
                _buildPreprocessedTab(),
                _buildDetectionsTab(),
              ],
            ),
          ),

          // Painel Inferior Fixo com Métricas Técnicas Reais
          _buildMetricsFooter(),
        ],
      ),
    );
  }

  Widget _buildOriginalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStageHeader(
            stage: 'Etapa 1: Captura Original',
            title: 'Imagem Bruta do Dispositivo',
            description:
                'Foto original capturada pelo sensor óptico da câmera ou selecionada da galeria. '
                'Possui alta resolução e aspect ratio variável que não pode ser processado diretamente pela rede neural.',
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: widget.originalBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      widget.originalBytes!,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Fotografe ou selecione uma imagem para ver o comparativo',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          _buildFeatureRow('Espaço de Cores:', 'RGB 24-bit padrão (sRGB)'),
          _buildFeatureRow('Aspect Ratio:', 'Variável (4:3, 16:9 ou 1:1)'),
          _buildFeatureRow('Processamento:', 'Armazenado temporariamente em RAM'),
        ],
      ),
    );
  }

  Widget _buildPreprocessedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStageHeader(
            stage: 'Etapa 2: Pré-Processamento',
            title: 'Letterbox 320x320 e Normalização NCHW',
            description:
                'A imagem é escalada proporcionalmente e centralizada em uma tela quadrada de 320x320 pixels '
                'com preenchimento de bordas cinzas (RGB 114, 114, 114). Cada pixel é normalizado para [0.0, 1.0].',
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF727272),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: widget.preprocessedBytes != null
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        widget.preprocessedBytes!,
                        width: 260,
                        height: 260,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Aguardando imagem para gerar pré-processamento 320x320',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          _buildFeatureRow('Resolução de Entrada:', '320 x 320 pixels (Fixa)'),
          _buildFeatureRow('Tensor Shape:', '[1, 3, 320, 320] Float32 (NCHW)'),
          _buildFeatureRow('Padding:', 'Letterbox neutro (114/255) sem distorção geométrica'),
        ],
      ),
    );
  }

  Widget _buildDetectionsTab() {
    final detections = widget.detections ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStageHeader(
            stage: 'Etapa 3: Inferência e Pós-Processamento',
            title: 'Detecções com Bounding Boxes e NMS',
            description:
                'O modelo YOLOv5n avalia 6.300 âncoras candidatas. As caixas válidas são filtradas por confiança '
                'e submetidas à Supressão de Não-Máximos (IoU > 0.45) para descarte de predições sobrepostas.',
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.originalBytes != null
                ? Center(
                    child: CustomPaint(
                      foregroundPainter: BoundingBoxPainter(
                        detections: detections,
                      ),
                      child: Image.memory(
                        widget.originalBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Nenhuma detecção para exibir no momento',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            'Detecções Registradas (${detections.length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          if (detections.isEmpty)
            Text(
              'Nenhum objeto detectado acima do limiar mínimo (0.15).',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            )
          else
            ...detections.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: d.boxColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${d.displayName} (${d.className})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      d.confidencePercentage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: d.isLowConfidence ? Colors.orange : Colors.green,
                        fontSize: 12.5,
                      ),
                    ),
                    if (d.isLowConfidence)
                      const Text(
                        ' ⚠️ Baixa',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageHeader({
    required String stage,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.indigo.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            stage,
            style: TextStyle(
              color: Colors.indigo.shade900,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Tamanho ONNX', '7.20 MB'),
              _buildMetricItem('Latência CPU', '7.19 ms'),
              _buildMetricItem('Vazão (FPS)', '139.2 FPS'),
              _buildMetricItem('mAP@0.50 (Teste)', '12.11%'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Métricas reais mensuradas no hardware Qualcomm Snapdragon X (ARM64) sobre 1.042 imagens de teste independente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
            color: Colors.indigo.shade900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
