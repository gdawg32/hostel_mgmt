import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'StudentComplaintWidget.dart';
import 'StudentComplaintStatusWidget.dart';
import 'student_room_selection.dart';
import 'student_fees.dart';
import 'StudentAccountSettingsPage.dart';
import 'AttendanceMarking.dart';

class StudentPanel extends StatefulWidget {
  const StudentPanel({super.key});

  @override
  _StudentPanelState createState() => _StudentPanelState();
}

class _StudentPanelState extends State<StudentPanel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchStudentData();
  }

  // Fetch student data from Firestore
  void _fetchStudentData() async {
    if (_user != null) {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(_user!.uid) // Use user ID as document ID
          .get();
      if (studentSnapshot.exists) {
        setState(() {
          _studentData = studentSnapshot.data() as Map<String, dynamic>?;
        });
      } else {
        print('No student data found for user ${_user!.uid}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Panel'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: _studentData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(),
                  _buildActivitiesSection(),
                  _buildComplaintStatusSection(),
                  _buildSettingsSection(context, _user!.uid), // Pass the document ID here
                ],
              ),
            ),
    );
  }

  // Profile Card Widget
  Widget _buildProfileCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _studentData?['name'] ?? 'Student Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Branch: ${_studentData?['branch'] ?? 'Branch'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Pass Out Year: ${_studentData?['pass_out_year'] ?? 'Year'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Check if room_id is null
            if (_studentData?['room_id'] == null) 
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RoomSelectionScreen(), // Navigate to the room selection screen
                    ),
                  );
                },
                child: const Text('Select Room'),
              ),
            if (_studentData?['room_id'] != null) 
              Text(
                'Room: ${_studentData?['room_id']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Activities Section
  Widget _buildActivitiesSection() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          StudentComplaintWidget(),
        ],
      ),
    );
  }

  // Complaint Status Section
  Widget _buildComplaintStatusSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complaint Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StudentComplaintStatusWidget(),
                ),
              );
            },
            child: const Text('View Status'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AttendanceMarkingPage()),
              );
            },
            child: const Text("Mark Attendance"),
          ),

        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String documentId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.only(top: 10),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: const Text('View Fees'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // Navigate to the student's fees screen with the document ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PayFeesScreen(studentId: documentId),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.only(top: 10),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Account Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // Navigate to settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentAccountSettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
