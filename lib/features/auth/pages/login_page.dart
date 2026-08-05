import 'package:flutter/material.dart';
import '../widgets/login_widget.dart';

/// LoginPage — Wrapper halaman untuk LoginWidget.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginWidget(),
    );
  }
}
