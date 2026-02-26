import 'package:flutter/material.dart';

class ProPage extends StatelessWidget {
  const ProPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Pro (Subscription + Lifetime)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
