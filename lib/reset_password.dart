import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  ForgetPasswordState createState() => ForgetPasswordState();
}

class ForgetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  Future<void> _sendResetEmail(BuildContext context) async {
    final email = emailController.text.trim();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _showBanner(context,
          "Password reset email sent to $email. Please check your inbox.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showBanner(context,
            "No user found with that email. Please enter a registered email.");
      } else {
        _showBanner(context, "Failed to send reset email: ${e.message}");
      }
    } catch (e) {
      _showBanner(context, "An unexpected error occurred: $e");
    }
  }

  void _showBanner(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        backgroundColor: Colors.green,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('images/logo.jpg'),
              const SizedBox(height: 50),
              const Text(
                "Enter your registered email to reset password.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required.";
                  }
                  if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(value)) {
                    return "Please enter a valid email address.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              MaterialButton(
                height: 50,
                minWidth: double.infinity,
                color: Colors.green,
                textColor: Colors.white,
                child: const Text(
                  "Send Reset Email",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendResetEmail(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
