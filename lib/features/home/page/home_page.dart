import 'package:flutter/material.dart';
import '../widget/home_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: SafeArea(child: HomeWidget()),
    );
  }
}
