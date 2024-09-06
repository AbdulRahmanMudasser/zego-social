import 'package:flutter/material.dart';

class TextPost extends StatelessWidget {
  const TextPost({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.indigo.shade50,
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      child: Text(text),
    );
  }
}
