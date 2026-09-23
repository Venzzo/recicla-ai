import 'package:flutter/material.dart';
import '../models/detection_result.dart';

class MaterialCard extends StatelessWidget {
  final DetectionResult detection;

  const MaterialCard({
    Key? key,
    required this.detection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = detection.materialInfo;
    final color = detection.boxColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho com Ícone, Nome e Badge de Confiança
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getMaterialIcon(info?.icon),
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detection.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Classe: ${detection.className} (ID: ${detection.classId})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: detection.isLowConfidence
                        ? Colors.amber.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: detection.isLowConfidence
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                  child: Text(
                    detection.confidencePercentage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: detection.isLowConfidence
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),

            // 2. Banner de Alerta para Baixa Confiança (< 40%)
            if (detection.isLowConfidence) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Baixa confiança. Verifique visualmente o material antes do descarte.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // 3. Destinação Correta CONAMA
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        const TextSpan(
                          text: 'Descarte Recomendado: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: info?.disposalBin ?? 'Lixeira de Coleta Seletiva',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 4. Instruções de Preparo
            if (info != null && info.preparationSteps.isNotEmpty) ...[
              const Text(
                'Como preparar para a reciclagem:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              ...info.preparationSteps.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // 5. Nota Acadêmica sobre o Modelo
            if (info != null && info.academicModelNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Nota Acadêmica do Modelo: ${info.academicModelNotes}',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String? iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco_rounded;
      case 'inventory_2':
        return Icons.inventory_2_rounded;
      case 'wine_bar':
        return Icons.wine_bar_rounded;
      case 'view_in_ar':
        return Icons.view_in_ar_rounded;
      case 'description':
        return Icons.description_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      default:
        return Icons.recycling_rounded;
    }
  }
}
