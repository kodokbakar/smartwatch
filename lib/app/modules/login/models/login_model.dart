import 'package:flutter/material.dart';

class LoginModel {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  LoginModel({
    required this.emailController,
    required this.passwordController,
  });

  String get email => emailController.text.trim();
  String get password => passwordController.text;

  bool get hasEmptyField => email.isEmpty || password.isEmpty;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
