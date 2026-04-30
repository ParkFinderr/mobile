import 'package:flutter/material.dart';
import '../widget/register_widget.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: RegisterWidget(),
    );
  }
}
