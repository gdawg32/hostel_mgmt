import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_management_app/screens/admin_panel.dart';
import 'student_login.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loginAdmin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminPanel()),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'user-not-found'
          ? "Admin account not found"
          : e.code == 'wrong-password'
              ? "Incorrect password"
              : "Error: ${e.message}";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Admin Login Header
              Text(
                'Admin Portal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800, // Dark teal for contrast
                ),
              ),
              const SizedBox(height: 50),

              // Admin Email TextField
              _buildTextField(
                controller: _emailController,
                label: 'Admin Email',
                hintText: 'admin@example.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Password TextField
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: '********',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 40),

              // Login Button
              ElevatedButton(
                onPressed: loginAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Teal button color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Login as Admin',
                  style: TextStyle(
                    color: Colors.white, // White text for button
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Student Login Option
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudentLoginPage()),
                  );
                },
                child: const Text(
                  'Not an admin? Login as a student',
                  style: TextStyle(
                    color: Colors.teal, // Teal text for the link
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black), // Black text input
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal), // Teal label color
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey), // Gray hint color
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey.shade200, // Light gray for background
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.teal.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }
}
