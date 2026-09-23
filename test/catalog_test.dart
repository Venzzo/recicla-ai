import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RECICLA.AI - Validação do Catálogo de Materiais CONAMA', () {
    late Map<String, dynamic> catalogJson;

    setUpAll(() {
      final file = File('assets/data/materials_catalog.json');
      expect(file.existsSync(), isTrue, reason: 'materials_catalog.json deve existir em assets/data/');
      final content = file.readAsStringSync();
      catalogJson = json.decode(content) as Map<String, dynamic>;
    });

    test('Catálogo contém metadados do projeto e disclaimer acadêmico', () {
      expect(catalogJson['project'], equals('RECICLA.AI'));
      expect(catalogJson['version'], equals('1.0.0'));
      expect(catalogJson['standard'], contains('CONAMA nº 275/2001'));
      expect(catalogJson['academic_disclaimer'], contains('protótipo acadêmico'));
      
      final thresholds = catalogJson['confidence_thresholds'] as Map<String, dynamic>;
      expect(thresholds['low_confidence_warning'], contains('Baixa confiança'));
    });

    test('Catálogo contém exatamente as 6 classes do dataset de treino', () {
      final classes = catalogJson['classes'] as Map<String, dynamic>;
      final expectedClasses = [
        'biodegradable',
        'cardboard',
        'glass',
        'metal',
        'paper',
        'plastic'
      ];

      for (final className in expectedClasses) {
        expect(classes.containsKey(className), isTrue,
            reason: 'Classe $className deve estar presente no catálogo');

        final classData = classes[className] as Map<String, dynamic>;
        expect(classData['name_pt'], isNotEmpty);
        expect(classData['conama_hex_color'], startsWith('#'));
        expect(classData['disposal_bin'], isNotEmpty);
        expect(classData['general_instructions'], isNotEmpty);
        expect(classData['preparation_steps'], isNotEmpty);
        expect(classData['academic_model_notes'], isNotEmpty);
      }
    });

    test('Mapeamento de Cores CONAMA está em conformidade com a Resolução 275/2001', () {
      final classes = catalogJson['classes'] as Map<String, dynamic>;

      expect(classes['biodegradable']['conama_color_name'], equals('Marrom'));
      expect(classes['cardboard']['conama_color_name'], equals('Azul'));
      expect(classes['glass']['conama_color_name'], equals('Verde'));
      expect(classes['metal']['conama_color_name'], equals('Amarelo'));
      expect(classes['paper']['conama_color_name'], equals('Azul'));
      expect(classes['plastic']['conama_color_name'], equals('Vermelho'));
    });

    test('Modelo ONNX oficial está presente e possui tamanho esperado (~7.2 MB)', () {
      final onnxFile = File('assets/models/best.onnx');
      expect(onnxFile.existsSync(), isTrue, reason: 'best.onnx deve estar em assets/models/');
      final sizeBytes = onnxFile.lengthSync();
      final sizeMb = sizeBytes / (1024 * 1024);
      expect(sizeMb, greaterThan(7.0));
      expect(sizeMb, lessThan(8.0));
    });
  });
}
