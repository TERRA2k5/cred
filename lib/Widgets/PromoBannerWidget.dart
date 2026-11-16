import 'package:flutter/material.dart';

class PromoBannerWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const PromoBannerWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Text('Promo Banner Component', style: TextStyle(color: Colors.white)),
    );
  }
}