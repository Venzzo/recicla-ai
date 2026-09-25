import 'dart:convert';
import 'dart:io';

void main() {
  print('=== TESTES UNITÁRIOS DE INTEGRIDADE DO RECICLA.AI ===\n');

  int passed = 0;
  int failed = 0;

  void assertTest(String description, bool condition, [String? errorMsg]) {
    if (condition) {
      print('  [PASS] $description');
      passed++;
    } else {
      print('  [FAIL] $description: ${errorMsg ?? "Falha na asserção"}');
      failed++;
    }
  }

  // 1. Arquivo de Modelo ONNX
  final onnxFile = File('assets/models/best.onnx');
  assertTest(
    'Modelo oficial ONNX (best.onnx) existe no diretório de assets',
    onnxFile.existsSync(),
  );

  final onnxSizeMb = onnxFile.lengthSync() / (1024 * 1024);
  assertTest(
    'Tamanho do modelo ONNX é adequado para mobile (~7.2 MB)',
    onnxSizeMb >= 7.0 && onnxSizeMb <= 8.0,
    'Tamanho obtido: ${onnxSizeMb.toStringAsFixed(2)} MB',
  );

  // 2. Catálogo de Materiais
  final catalogFile = File('assets/data/materials_catalog.json');
  assertTest(
    'Catálogo de materiais (materials_catalog.json) existe',
    catalogFile.existsSync(),
  );

  final catalog = json.decode(catalogFile.readAsStringSync()) as Map<String, dynamic>;

  assertTest(
    'Catálogo contém padrão CONAMA nº 275/2001 e aviso acadêmico',
    catalog['standard'].toString().contains('CONAMA nº 275/2001') &&
    catalog['academic_disclaimer'].toString().contains('protótipo acadêmico'),
  );

  final classes = catalog['classes'] as Map<String, dynamic>;
  final expected = ['biodegradable', 'cardboard', 'glass', 'metal', 'paper', 'plastic'];

  assertTest(
    'Catálogo possui exatamente as 6 classes treinadas',
    classes.length == 6 && expected.every((c) => classes.containsKey(c)),
  );

  // 3. Validação das Cores CONAMA
  final conamaColors = {
    'biodegradable': 'Marrom',
    'cardboard': 'Azul',
    'glass': 'Verde',
    'metal': 'Amarelo',
    'paper': 'Azul',
    'plastic': 'Vermelho',
  };

  for (final entry in conamaColors.entries) {
    final cls = classes[entry.key] as Map<String, dynamic>;
    assertTest(
      'Classe ${entry.key} mapeada para lixeira ${entry.value}',
      cls['conama_color_name'] == entry.value,
      'Obtido: ${cls['conama_color_name']}',
    );
  }

  // 4. Limiar de Baixa Confiança (< 40%)
  final thresholds = catalog['confidence_thresholds'] as Map<String, dynamic>;
  final lowConfWarning = thresholds['low_confidence_warning'] as String;
  assertTest(
    'Alerta explícito de baixa confiança configurado',
    lowConfWarning.contains('Baixa confiança') && lowConfWarning.contains('Verifique visualmente'),
    'Obtido: $lowConfWarning',
  );

  // 5. Configurações Android e iOS
  final androidManifest = File('android/app/src/main/AndroidManifest.xml');
  assertTest(
    'AndroidManifest.xml configurado com permissões de câmera',
    androidManifest.existsSync() &&
    androidManifest.readAsStringSync().contains('android.permission.CAMERA'),
  );

  final androidGradle = File('android/app/build.gradle');
  assertTest(
    'build.gradle configurado com applicationId e build release para sideload',
    androidGradle.existsSync() &&
    androidGradle.readAsStringSync().contains('com.reciclaai.app') &&
    androidGradle.readAsStringSync().contains('signingConfigs.release'),
  );

  final iosPlist = File('ios/Runner/Info.plist');
  assertTest(
    'Info.plist configurado com NSCameraUsageDescription e NSPhotoLibraryUsageDescription',
    iosPlist.existsSync() &&
    iosPlist.readAsStringSync().contains('NSCameraUsageDescription') &&
    iosPlist.readAsStringSync().contains('NSPhotoLibraryUsageDescription'),
  );

  final workflowFile = File('.github/workflows/build_apk.yml');
  assertTest(
    'GitHub Actions CI/CD configurado para build automático de release APK',
    workflowFile.existsSync() &&
    workflowFile.readAsStringSync().contains('flutter build apk --release'),
  );

  final readmeFile = File('README.md');
  assertTest(
    'README.md contém seção de Dataset e Treinamento com instruções de reprodução',
    readmeFile.existsSync() &&
    (readmeFile.readAsStringSync().contains('## Dataset') || readmeFile.readAsStringSync().contains('## 4. Dataset e Treinamento')) &&
    readmeFile.readAsStringSync().contains('Roboflow Universe') &&
    readmeFile.readAsStringSync().contains('yolov5n.pt'),
  );

  print('\n-----------------------------------------------------');
  print('RESULTADO DOS TESTES: $passed PASSOU, $failed FALHOU');
  print('-----------------------------------------------------');

  if (failed > 0) {
    exit(1);
  }
}
