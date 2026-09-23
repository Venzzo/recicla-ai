import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/detection_result.dart';
import '../services/catalog_service.dart';
import '../services/vision_service.dart';
import '../widgets/bounding_box_painter.dart';
import '../widgets/material_card.dart';
import 'academic_didactic_screen.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final PreprocessedImage preprocessed;
  final List<DetectionResult> detections;

  const ResultScreen({
    Key? key,
    required this.imageBytes,
    required this.preprocessed,
    required this.detections,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final CatalogService _catalog = CatalogService();
  bool _showBoxes = true;

  @override
  Widget build(BuildContext context) {
    final multiMaterialAlert = _catalog.checkMultiMaterialAlert(widget.detections);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Análise'),
        backgroundColor: Colors.teal.shade800,
        actions: [
          IconButton(
            icon: Icon(_showBoxes ? Icons.visibility : Icons.visibility_off),
            tooltip: _showBoxes ? 'Ocultar Caixas' : 'Exibir Caixas',
            onPressed: () {
              setState(() {
                _showBoxes = !_showBoxes;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Ver Pipeline Didático',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AcademicDidacticScreen(
                    originalBytes: widget.imageBytes,
                    preprocessedBytes: widget.preprocessed.previewBytes,
                    detections: widget.detections,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Imagem com Bounding Boxes Sobrepostas
            Container(
              color: Colors.black,
              constraints: const BoxConstraints(maxHeight: 380),
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.preprocessed.originalWidth /
                      widget.preprocessed.originalHeight,
                  child: CustomPaint(
                    foregroundPainter: _showBoxes
                        ? BoundingBoxPainter(detections: widget.detections)
                        : null,
                    child: Image.memory(
                      widget.imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Barra de Controle e Contador de Detecções
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.teal.shade50,
              child: Row(
                children: [
                  Icon(
                    widget.detections.isNotEmpty
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    color: Colors.teal.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.detections.isNotEmpty
                          ? '${widget.detections.length} componente(s) detectado(s)'
                          : 'Nenhum resíduo detectado com o limiar atual',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showBoxes = !_showBoxes;
                      });
                    },
                    icon: Icon(
                      _showBoxes ? Icons.layers_clear : Icons.layers,
                      size: 18,
                    ),
                    label: Text(_showBoxes ? 'Ocultar' : 'Exibir'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.teal.shade900,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Alerta de Embalagem Multimaterial (Ex: Vidro + Metal)
            if (multiMaterialAlert != null) ...[
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade700, width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.handyman_rounded,
                        color: Colors.orange, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        multiMaterialAlert,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Lista de Materiais Detectados (Cards CONAMA)
            if (widget.detections.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Instruções de Descarte por Componente',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
              ...widget.detections.map(
                (d) => MaterialCard(detection: d),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foram identificadas embalagens com confiança suficiente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dicas: fotografe o objeto de mais perto, com boa iluminação e sobre um fundo neutro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 5. Botões de Ação Final
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AcademicDidacticScreen(
                        originalBytes: widget.imageBytes,
                        preprocessedBytes: widget.preprocessed.previewBytes,
                        detections: widget.detections,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo.shade800,
                  side: BorderSide(color: Colors.indigo.shade600),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.school, size: 20),
                label: const Text(
                  'Ver Comparativo Didático (Original vs IA)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  'Analisar Outra Imagem',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
