import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentComplaintWidget extends StatefulWidget {
  const StudentComplaintWidget({super.key});

  @override
  _StudentComplaintWidgetState createState() => _StudentComplaintWidgetState();
}

class _StudentComplaintWidgetState extends State<StudentComplaintWidget> {
  final TextEditingController _complaintController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitComplaint() async {
    String uid = _auth.currentUser?.uid ?? '';
    if (_complaintController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('complaints').add({
        'student_id': uid,
        'complaint': _complaintController.text,
        'status': 'pending',  // Initial status
        'submitted_at': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully.')),
      );
      _complaintController.clear();  // Clear the input field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            color: Colors.black26,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Complaint',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _complaintController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your complaint or feedback',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitComplaint,
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

