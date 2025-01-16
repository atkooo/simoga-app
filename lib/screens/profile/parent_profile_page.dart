// Parent Profile Page
import 'package:flutter/material.dart';

class ParentProfilePage extends StatelessWidget {
  const ParentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Profile'),
      ),
      body: Center(
        child: Text('This is the Parent Profile Page'),
      ),
    );
  }
}
