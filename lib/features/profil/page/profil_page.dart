import 'package:flutter/material.dart';
import '../widget/profil_widget.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: SafeArea(child: ProfilWidget()),
    );
  }
}
