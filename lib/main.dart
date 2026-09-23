import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloqueio de orientação para modo retrato para estabilidade da câmera móvel
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ReciclaAiApp());
}

class ReciclaAiApp extends StatelessWidget {
  const ReciclaAiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RECICLA.AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal.shade800,
          secondary: Colors.amber.shade700,
          background: Colors.grey.shade50,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
