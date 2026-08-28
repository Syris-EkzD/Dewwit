import 'package:flutter/material.dart';

void main() {
  runApp(const DewwitApp());
}

class DewwitApp extends StatelessWidget {
  const DewwitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dewwit',
      home: const DewwitHomePage(),
    );
  }
}

class DewwitHomePage extends StatelessWidget {
  const DewwitHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dewwit')),
      body: const SizedBox.shrink(),
    );
  }
}
