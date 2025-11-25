import 'package:flutter/material.dart';

class RegisterModel {
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  RegisterModel({
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  String get fullName => nameController.text.trim();
  String get username => usernameController.text.trim();
  String get email => emailController.text.trim();
  String get password => passwordController.text;
  String get confirmPassword => confirmPasswordController.text;

  bool get hasEmptyField =>
      fullName.isEmpty ||
      username.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty;

  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
