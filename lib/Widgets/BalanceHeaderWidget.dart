import 'package:flutter/material.dart';

class BalanceHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const BalanceHeaderWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Text('Balance Header Component', style: TextStyle(color: Colors.white)),
    );
  }
}