import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Como Funciona o RECICLA.AI'),
        backgroundColor: Colors.teal.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de Introdução
            Card(
              elevation: 2,
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pipeline de Visão Computacional On-Device',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'O RECICLA.AI opera de forma 100% autônoma e local no seu celular. '
                      'Nenhuma imagem é enviada para servidores ou APIs em nuvem, garantindo velocidade de inferência em milissegundos e total privacidade dos seus dados.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Fluxo de Execução em 5 Etapas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildStepCard(
              stepNumber: 1,
              title: 'Foto / Captura da Imagem',
              subtitle: 'Entrada visual capturada pela câmera ou galeria',
              description:
                  'O usuário aponta a câmera para a embalagem descartável ou escolhe uma foto existente. A imagem é lida na memória RAM do aparelho pelo Flutter.',
              icon: Icons.camera_alt_rounded,
              color: Colors.blue.shade700,
            ),
            _buildArrowDown(),

            _buildStepCard(
              stepNumber: 2,
              title: 'Processamento da Imagem',
              subtitle: 'Adaptação dimensional e normalização',
              description:
                  'A imagem original é redimensionada com técnica Letterbox mantendo o aspecto original para exatamente 320x320 pixels com padding neutro. Os valores RGB são normalizados para o intervalo [0.0, 1.0] no formato NCHW.',
              icon: Icons.aspect_ratio_rounded,
              color: Colors.indigo.shade700,
            ),
            _buildArrowDown(),

            _buildStepCard(
              stepNumber: 3,
              title: 'Inteligência Artificial (YOLOv5n)',
              subtitle: 'Execução local via ONNX Runtime',
              description:
                  'A rede neural convolucional YOLOv5n (7.2 MB) processa o tensor em menos de 10 ms utilizando o hardware local (CPU multi-thread ou aceleradores neurais NNAPI/CoreML), sem necessidade de internet.',
              icon: Icons.memory_rounded,
              color: Colors.purple.shade700,
            ),
            _buildArrowDown(),

            _buildStepCard(
              stepNumber: 4,
              title: 'Identificação dos Materiais',
              subtitle: 'Decodificação e Supressão de Não-Máximos (NMS)',
              description:
                  'O tensor de saída (1x6300x11) é decodificado para extrair caixas delimitadoras e probabilidades entre 6 classes. O algoritmo NMS elimina detecções duplicadas com IoU > 0.45.',
              icon: Icons.category_rounded,
              color: Colors.amber.shade800,
            ),
            _buildArrowDown(),

            _buildStepCard(
              stepNumber: 5,
              title: 'Orientação de Descarte CONAMA',
              subtitle: 'Associação à Resolução CONAMA nº 275/2001',
              description:
                  'Cada componente recebe a cor padrão da lixeira seletiva (Azul, Vermelho, Verde, Amarelo ou Marrom), etapas práticas de higienização e regras especiais para desmontagem de embalagens mistas.',
              icon: Icons.delete_outline_rounded,
              color: Colors.green.shade700,
            ),

            const SizedBox(height: 24),

            // Cartão de Princípios Acadêmicos
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diretrizes Acadêmicas do Projeto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCheckItem(
                      'Sem nuvem ou servidores externos',
                      'Independente de conexão e com zero custos de operação.',
                    ),
                    _buildCheckItem(
                      'Modelo próprio treinado em dataset público',
                      'Treinado sobre as 10.464 imagens do Garbage Classification 3 (CC BY 4.0).',
                    ),
                    _buildCheckItem(
                      'Transparência com previsões de baixa confiança',
                      'O aplicativo alerta expressamente quando a confiança for inferior a 40%.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Etapa $stepNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade800,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowDown() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Icon(Icons.arrow_downward_rounded, color: Colors.grey, size: 22),
      ),
    );
  }

  Widget _buildCheckItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.teal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        ],
      ),
    );
  }
}
