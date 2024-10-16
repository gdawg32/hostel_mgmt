import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_panel.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loginStudent() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "${_studentIdController.text}@hostel.com",
        password: _passwordController.text,
      );
      // Navigate to student panel
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentPanel()));
    } catch (e) {
      print("Error logging in student: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Student Login"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              "Student Login",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: "Student ID",
                        border: OutlineInputBorder(),
                        hintText: "Enter your student ID",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        hintText: "Enter your password",
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: loginStudent,
                child: const Text("Login as Student"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

