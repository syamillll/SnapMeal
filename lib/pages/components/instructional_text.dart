import 'package:flutter/material.dart';

class InstructionalText extends StatelessWidget {
  final String text;

  const InstructionalText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
