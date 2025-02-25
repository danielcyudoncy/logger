// views/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

final supabase = Supabase.instance.client;

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController =
      Get.put(AuthController(), permanent: true);

  LoginPage({super.key});

  void _handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty');
      return;
    }

    authController.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  onPressed:
                      authController.isLoading.value ? null : _handleLogin,
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Get.toNamed(Routes.register);
              },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
