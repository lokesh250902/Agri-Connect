import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoiceAiApp());
}

class VoiceAiApp extends StatelessWidget {
  const VoiceAiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Voice AI Assistant',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), scaffoldBackgroundColor: const Color(0xFFF7F5FA)),
    home: const HomeScreen(),
  );
}
