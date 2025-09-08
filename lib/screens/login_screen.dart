import 'package:finance_tracker_app/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';

/// Login screen with email & password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or Icon
              Icon(Icons.account_balance_wallet, size: 80),

              const SizedBox(height: 20),
              Text(
                "Welcome Back 👋",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                "Login to continue tracking your finances",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),

              const SizedBox(height: 40),
              CustomTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: passwordController,
                label: "Password",
                obscureText: true,
                icon: Icons.lock,
              ),

                           const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          String? error = await authProvider.login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                          setState(() => _isLoading = false);

                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login successful!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _navigateToDashboard();
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      :  Text("Login"),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child:Text("Don’t have an account? Register", style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}