import 'package:finance_tracker_app/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';

/// Register screen with email, password, confirm password.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet, size: 80),
            const SizedBox(height: 20),
            Text(
              "Create Account",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              "Register to start managing your finances",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email,
            ),
            CustomTextField(
              controller: passwordController,
              label: "Password",
              obscureText: true,
              icon: Icons.lock,
            ),
            CustomTextField(
              controller: confirmPasswordController,
              label: "Confirm Password",
              obscureText: true,
              icon: Icons.lock,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Passwords do not match!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => const Center(child: CircularProgressIndicator()),
                );

                String? error = await authProvider.register(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );

                // Close loading
                Navigator.of(context).pop();

                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Registration successful!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _navigateToDashboard();
                }
              },

              child: const Text("Register"),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Already have an account? Login",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

        
          ],
        ),
      ),
      ),
    );
  }
}
