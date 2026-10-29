import 'package:flutter/material.dart';
import 'package:jogo1/paginas/tela_inicial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF176B87);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flags Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFF5F8FA),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        scaffoldBackgroundColor: const Color(0xFFF5F8FA),
      ),
      home: const TelaInicial(),
    );
  }
}
