import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUpUser() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    if (firstName.isEmpty || emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // NOTE: saving 'name' explicitly (not just firstName/lastName) because
      // ProfileScreen reads data['name'] directly.
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': '$firstName $lastName'.trim(),
        'firstName': firstName,
        'lastName': lastName,
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.authGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black45)],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start tracking your expenses smartly',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 36),
                _buildInputField(hint: 'First Name', controller: firstNameController, icon: Icons.person_outline),
                const SizedBox(height: 14),
                _buildInputField(hint: 'Last Name', controller: lastNameController, icon: Icons.person_outline),
                const SizedBox(height: 14),
                _buildInputField(hint: 'Email', controller: emailController, icon: Icons.email_outlined),
                const SizedBox(height: 14),
                _buildPasswordField(
                  hint: 'Password',
                  controller: passwordController,
                  isVisible: _isPasswordVisible,
                  toggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  hint: 'Confirm Password',
                  controller: confirmPasswordController,
                  isVisible: _isConfirmPasswordVisible,
                  toggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
                const SizedBox(height: 28),
                _buildButton(text: 'Sign Up', onPressed: signUpUser),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8)],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          prefixIcon: Icon(icon, color: Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8)],
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black45),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8)],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
