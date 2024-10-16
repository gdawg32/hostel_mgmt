import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateStudentUserPage extends StatefulWidget {
  const CreateStudentUserPage({super.key});

  @override
  _CreateStudentUserPageState createState() => _CreateStudentUserPageState();
}

class _CreateStudentUserPageState extends State<CreateStudentUserPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentPasswordController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentBranchController = TextEditingController();
  final TextEditingController _studentPassOutYearController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void createStudentUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "${_studentIdController.text}@hostel.com",
        password: _studentPasswordController.text,
      );

      await _firestore.collection("students").doc(userCredential.user?.uid).set({
        'student_id': _studentIdController.text,
        'name': _studentNameController.text,
        'branch': _studentBranchController.text,
        'pass_out_year': _studentPassOutYearController.text,
        'email': userCredential.user?.email,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student User Created")));
      // Clear the text fields
      _clearFields();
    } catch (e) {
      print("Error creating student: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error creating student")));
    }
  }

  void _clearFields() {
    _studentIdController.clear();
    _studentPasswordController.clear();
    _studentNameController.clear();
    _studentBranchController.clear();
    _studentPassOutYearController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Student User"),
        backgroundColor: Colors.teal, // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Create a New Student Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              _buildTextField(_studentIdController, "Student ID", Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_studentPasswordController, "Password", Icons.lock, obscureText: true),
              const SizedBox(height: 16),
              _buildTextField(_studentNameController, "Student Name", Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(_studentBranchController, "Branch", Icons.school),
              const SizedBox(height: 16),
              _buildTextField(
                _studentPassOutYearController, 
                "Pass Out Year", 
                Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: createStudentUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.teal, // Button color
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  "Create Student User",
                  style: TextStyle(color: Colors.white),
                  ), 

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
    );
  }
}
