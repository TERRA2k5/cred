import 'package:flutter/material.dart';

class TopBarWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const TopBarWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[900],
      child: const Center(
        child: Text(
          'Top Bar Component',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}