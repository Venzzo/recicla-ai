import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/catalog_service.dart';
import '../services/vision_service.dart';
import 'result_screen.dart';
import 'how_it_works_screen.dart';
import 'academic_didactic_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final VisionService _visionService = VisionService();
  final CatalogService _catalogService = CatalogService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _catalogService.initialize();
    _visionService.initialize();
  }

  Future<void> _processImageSource(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _isProcessing = true;
      });

      final bytes = await file.readAsBytes();
      final preprocessed = await _visionService.preprocessImage(bytes);
      final detections = await _visionService.detect(bytes, preprocessed: preprocessed);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imageBytes: bytes,
            preprocessed: preprocessed,
            detections: detections,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao analisar imagem: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.recycling, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'RECICLA.AI',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined, color: Colors.white),
            tooltip: 'Apresentação Acadêmica',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AcademicDidacticScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Como Funciona',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HowItWorksScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 4,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Executando IA Local...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Processando no modelo YOLOv5n (ONNX Runtime)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Cartão Hero / Apresentação
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Identificador de Resíduos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Execução 100% offline no celular',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Fotografe uma embalagem ou objeto para identificar os componentes (papel, plástico, vidro, metal, orgânico) e receber as orientações de descarte segundo a Resolução CONAMA 275/2001.',
                            style: TextStyle(fontSize: 13.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Botões de Ação Principal (Câmera e Galeria)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _processImageSource(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.photo_camera, size: 24),
                          label: const Text(
                            'Tirar Foto',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _processImageSource(ImageSource.gallery),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal.shade900,
                            side: BorderSide(color: Colors.teal.shade700, width: 1.8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.photo_library, size: 24),
                          label: const Text(
                            'Galeria',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Atalhos Didáticos Acadêmicos
                  const Text(
                    'Módulos Acadêmicos e Educativos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildNavigationCard(
                          icon: Icons.alt_route_rounded,
                          title: 'Como Funciona',
                          subtitle: 'Pipeline 5 passos',
                          color: Colors.indigo.shade50,
                          iconColor: Colors.indigo.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HowItWorksScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNavigationCard(
                          icon: Icons.compare_rounded,
                          title: 'Apresentação',
                          subtitle: 'Original vs IA',
                          color: Colors.purple.shade50,
                          iconColor: Colors.purple.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AcademicDidacticScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. Guia Rápido de Coleta Seletiva CONAMA
                  const Text(
                    'Cores da Coleta Seletiva (CONAMA 275/2001)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.15,
                    children: [
                      _buildBinCard('Azul', 'Papelão / Papel', const Color(0xFF1976D2), Colors.white),
                      _buildBinCard('Vermelho', 'Plástico', const Color(0xFFD32F2F), Colors.white),
                      _buildBinCard('Verde', 'Vidro', const Color(0xFF388E3C), Colors.white),
                      _buildBinCard('Amarelo', 'Metal', const Color(0xFFFBC02D), Colors.black),
                      _buildBinCard('Marrom', 'Orgânico', const Color(0xFF795548), Colors.white),
                      _buildBinCard('Cinza', 'Rejeito Geral', const Color(0xFF757575), Colors.white),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 5. Disclaimer Acadêmico Permanente
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.school, size: 20, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PROTÓTIPO ACADÊMICO: Modelo YOLOv5n (7.2 MB) treinado sobre o Garbage Classification 3 e executado 100% no dispositivo. Verifique visualmente previsões de baixa confiança (< 40%).',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade800,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildNavigationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBinCard(String colorName, String material, Color color, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            colorName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            material,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
