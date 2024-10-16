import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_panel.dart'; // Import your StudentPanel screen

class StudentAccountSettingsPage extends StatefulWidget {
  const StudentAccountSettingsPage({super.key});

  @override
  _StudentAccountSettingsPageState createState() =>
      _StudentAccountSettingsPageState();
}

class _StudentAccountSettingsPageState
    extends State<StudentAccountSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  User? _user;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _branchController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchStudentDetails();
  }

  // Fetch student data from Firestore
  void _fetchStudentDetails() async {
    if (_user != null) {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(_user!.uid)
          .get();

      if (studentSnapshot.exists) {
        Map<String, dynamic> data = studentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _branchController.text = data['branch'] ?? '';
          _yearController.text = data['pass_out_year'] ?? '';
        });
      }
    }
  }

  // Update student data in Firestore
  void _updateStudentDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update Firestore data
        await FirebaseFirestore.instance
            .collection('students')
            .doc(_user!.uid)
            .update({
          'name': _nameController.text,
          'branch': _branchController.text,
          'pass_out_year': _yearController.text,
        });

        // Navigate back to StudentPanel with updated data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentPanel(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update details: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Your Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _branchController,
                      decoration: const InputDecoration(
                        labelText: 'Branch',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your branch';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Pass Out Year',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pass out year';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _updateStudentDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text(
                        'Update Details',
                        style: TextStyle(color: Colors.white), // White text
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
