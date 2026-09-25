import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const AgriVoiceApp());

class AgriVoiceApp extends StatelessWidget {
  const AgriVoiceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Agri Voice AI',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
    home: const HomeScreen(),
  );
}
