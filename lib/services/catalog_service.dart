import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/material_info.dart';
import '../models/detection_result.dart';

class CatalogService {
  static final CatalogService _instance = CatalogService._internal();
  factory CatalogService() => _instance;
  CatalogService._internal();

  final Map<int, MaterialInfo> _materialsById = {};
  final Map<String, MaterialInfo> _materialsByName = {};
  String _disclaimer = '';
  String _lowConfidenceWarning =
      'Baixa confiança. Verifique visualmente o material antes do descarte.';
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  String get academicDisclaimer => _disclaimer;
  String get lowConfidenceWarning => _lowConfidenceWarning;
  List<MaterialInfo> get allMaterials => _materialsById.values.toList();

  Future<void> initialize() async {
    if (_isLoaded) return;
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/materials_catalog.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      _disclaimer = data['academic_disclaimer'] as String? ?? '';
      final thresholds =
          data['confidence_thresholds'] as Map<String, dynamic>?;
      if (thresholds != null) {
        _lowConfidenceWarning = thresholds['low_confidence_warning'] as String? ??
            _lowConfidenceWarning;
      }

      final classesMap = data['classes'] as Map<String, dynamic>? ?? {};
      classesMap.forEach((key, value) {
        final info = MaterialInfo.fromJson(value as Map<String, dynamic>);
        _materialsById[info.id] = info;
        _materialsByName[info.nameEn.toLowerCase()] = info;
        _materialsByName[key.toLowerCase()] = info;
      });

      _isLoaded = true;
    } catch (e) {
      _loadFallbackData();
    }
  }

  MaterialInfo? getMaterialById(int id) {
    if (!_isLoaded) _loadFallbackData();
    return _materialsById[id];
  }

  MaterialInfo? getMaterialByName(String name) {
    if (!_isLoaded) _loadFallbackData();
    return _materialsByName[name.toLowerCase()];
  }

  /// Verifica se há múltiplos materiais na cena e retorna orientações de desmontagem
  String? checkMultiMaterialAlert(List<DetectionResult> detections) {
    if (detections.length < 2) return null;

    final uniqueClassIds =
        detections.map((d) => d.classId).toSet().toList();
    if (uniqueClassIds.length < 2) return null;

    final names = uniqueClassIds
        .map((id) => getMaterialById(id)?.namePt ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    // Vidro (2) + Metal (3)
    if (uniqueClassIds.contains(2) && uniqueClassIds.contains(3)) {
      return '⚠️ Embalagem Multimaterial Detectada (Vidro + Metal):\n'
          'Separe a tampa metálica da garrafa ou pote de vidro antes do descarte. '
          'Descarte a garrafa na Lixeira Verde e a tampa na Lixeira Amarela.';
    }

    // Papel (4) ou Papelão (1) + Plástico (5)
    if ((uniqueClassIds.contains(4) || uniqueClassIds.contains(1)) &&
        uniqueClassIds.contains(5)) {
      return '⚠️ Embalagem Combinada (Papel/Papelão + Plástico):\n'
          'Separe os componentes plásticos (tampa, canudo ou janela de visualização) '
          'do papelão antes do descarte para garantir a reciclagem adequada de ambos.';
    }

    // Vidro (2) + Plástico (5)
    if (uniqueClassIds.contains(2) && uniqueClassIds.contains(5)) {
      return '⚠️ Embalagem Combinada (Vidro + Plástico):\n'
          'Desrosqueie a tampa de plástico (Lixeira Vermelha) e higienize o frasco de vidro (Lixeira Verde).';
    }

    // Metal (3) + Biodegradável (0) ou Plástico (5) + Biodegradável (0)
    if (uniqueClassIds.contains(0) &&
        (uniqueClassIds.contains(3) || uniqueClassIds.contains(5))) {
      return '⚠️ Resíduo Orgânico em Embalagem Reciclável:\n'
          'Remova todo o resíduo orgânico para a Lixeira Marrom/Compostagem e enxágue a embalagem '
          'reciclável antes de descartá-la na lixeira de coleta seletiva.';
    }

    return 'ℹ️ Múltiplos materiais detectados na mesma cena (${names.join(', ')}). '
        'Separe cada componente na lixeira seletiva correspondente.';
  }

  void _loadFallbackData() {
    _disclaimer =
        'Este aplicativo é um protótipo acadêmico com modelo de visão computacional leve (YOLOv5n) executado 100% localmente no dispositivo.';
    _lowConfidenceWarning =
        'Baixa confiança. Verifique visualmente o material antes do descarte.';

    final fallback = [
      MaterialInfo(
        id: 0,
        nameEn: 'biodegradable',
        namePt: 'Biodegradável / Orgânico',
        conamaColorName: 'Marrom',
        conamaHexColor: '#795548',
        conamaTextColor: '#FFFFFF',
        icon: 'eco',
        recyclable: false,
        compostable: true,
        disposalBin: 'Lixeira Marrom (Orgânicos)',
        generalInstructions:
            'Destine para composteira doméstica ou coleta de resíduos orgânicos.',
        preparationSteps: [
          'Escorra líquidos excedentes antes de ensacar.',
          'Não misture com recicláveis secos.'
        ],
        examples: ['Restos de alimentos', 'Cascas de frutas', 'Borra de café'],
        multiMaterialNotes:
            'Separe alimentos de potes plásticos ou latas antes do descarte.',
        academicModelNotes:
            'Classe minoritária no dataset com alto recall e menor precisão.',
      ),
      MaterialInfo(
        id: 1,
        nameEn: 'cardboard',
        namePt: 'Papelão',
        conamaColorName: 'Azul',
        conamaHexColor: '#1976D2',
        conamaTextColor: '#FFFFFF',
        icon: 'inventory_2',
        recyclable: true,
        compostable: false,
        disposalBin: 'Lixeira Azul (Papel / Papelão)',
        generalInstructions:
            'Mantenha as caixas secas, limpas e sempre desmontadas.',
        preparationSteps: [
          'Desmonte e dobre as caixas.',
          'Remova fitas adesivas grossas.'
        ],
        examples: ['Caixas de papelão', 'Embalagens de cereais'],
        multiMaterialNotes:
            'Fundo de pizza engordurado deve ir para o lixo comum.',
        academicModelNotes:
            'Identificado com 60% de recall no teste independente.',
      ),
      MaterialInfo(
        id: 2,
        nameEn: 'glass',
        namePt: 'Vidro',
        conamaColorName: 'Verde',
        conamaHexColor: '#388E3C',
        conamaTextColor: '#FFFFFF',
        icon: 'wine_bar',
        recyclable: true,
        compostable: false,
        disposalBin: 'Lixeira Verde (Vidro)',
        generalInstructions:
            'O vidro é 100% infinitamente reciclável. Lave para retirar resíduos.',
        preparationSteps: [
          'Enxágue para retirar restos de bebidas/alimentos.',
          'Vidro quebrado: embale em caixa ou jornal sinalizado.'
        ],
        examples: ['Garrafas de vidro', 'Potes de conserva', 'Copos'],
        multiMaterialNotes:
            'Desrosqueie tampas metálicas ou plásticas antes do descarte.',
        academicModelNotes: 'mAP50-95 de 6.34% no teste independente.',
      ),
      MaterialInfo(
        id: 3,
        nameEn: 'metal',
        namePt: 'Metal',
        conamaColorName: 'Amarelo',
        conamaHexColor: '#FBC02D',
        conamaTextColor: '#000000',
        icon: 'view_in_ar',
        recyclable: true,
        compostable: false,
        disposalBin: 'Lixeira Amarela (Metal)',
        generalInstructions:
            'Latas de alumínio e embalagens de aço têm alto valor de reciclagem.',
        preparationSteps: [
          'Enxágue para evitar odores.',
          'Amasse as latas de alumínio para otimizar espaço.'
        ],
        examples: ['Latas de alumínio', 'Latas de conserva de aço', 'Tampinhas'],
        multiMaterialNotes:
            'Certifique-se de que latas de aerosol estejam totalmente vazias.',
        academicModelNotes: 'mAP50 de 20.10% e precisão de 22% no teste.',
      ),
      MaterialInfo(
        id: 4,
        nameEn: 'paper',
        namePt: 'Papel',
        conamaColorName: 'Azul',
        conamaHexColor: '#1976D2',
        conamaTextColor: '#FFFFFF',
        icon: 'description',
        recyclable: true,
        compostable: false,
        disposalBin: 'Lixeira Azul (Papel / Papelão)',
        generalInstructions:
            'Mantenha o papel seco e limpo. Evite amassar excessivamente.',
        preparationSteps: [
          'Dobre em vez de amassar em bola.',
          'Separe papéis engordurados (não recicláveis).'
        ],
        examples: ['Jornais', 'Folhas de escritório', 'Revistas', 'Cadernos'],
        multiMaterialNotes:
            'Copos de café com filme plástico interno requerem triagem especial.',
        academicModelNotes:
            'Classe com melhor índice no teste (mAP50 de 25.50%).',
      ),
      MaterialInfo(
        id: 5,
        nameEn: 'plastic',
        namePt: 'Plástico',
        conamaColorName: 'Vermelho',
        conamaHexColor: '#D32F2F',
        conamaTextColor: '#FFFFFF',
        icon: 'local_drink',
        recyclable: true,
        compostable: false,
        disposalBin: 'Lixeira Vermelha (Plástico)',
        generalInstructions:
            'Enxágue e compacte as garrafas. Verifique o símbolo de reciclagem.',
        preparationSteps: [
          'Enxágue embalagens sujas de gordura ou xampu.',
          'Comprima garrafas PET e recoloque a tampa.'
        ],
        examples: ['Garrafas PET', 'Potes de xampu', 'Embalagens de limpeza'],
        multiMaterialNotes:
            'Retire rótulos plásticos termoretráteis quando destacáveis.',
        academicModelNotes: '1.585 instâncias no teste independente.',
      ),
    ];

    for (final info in fallback) {
      _materialsById[info.id] = info;
      _materialsByName[info.nameEn.toLowerCase()] = info;
    }
    _isLoaded = true;
  }
}
