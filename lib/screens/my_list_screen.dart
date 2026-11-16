import 'package:flutter/material.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi lista')),
      body: const Center(child: Text('Aquí irá tu lista de seguimiento')),
    );
  }
}
