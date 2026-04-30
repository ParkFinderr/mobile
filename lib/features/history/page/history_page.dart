import 'package:flutter/material.dart';
import '../widget/history_widget.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: SafeArea(child: HistoryWidget()),
    );
  }
}
