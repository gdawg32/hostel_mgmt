import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_management_app/screens/AdminRoomRequestsScreen.dart';
import 'create_student_user.dart';
import 'AdminComplaintReviewWidget.dart';
import 'package:hostel_management_app/main.dart'; 
import 'RoomOccupancyScreen.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
        backgroundColor: Colors.teal, // Teal background for the app bar
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
                'Welcome to the Admin Panel',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Create Student Users Button
              _buildAdminButton(
                context,
                label: "Create Student Users",
                icon: Icons.person_add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateStudentUserPage()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Review Complaints Button
              _buildAdminButton(
                context,
                label: "Review Complaints",
                icon: Icons.report_problem,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminComplaintReviewWidget()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // View Room Requests Button
              _buildAdminButton(
                context,
                label: "View Room Requests",
                icon: Icons.room_service,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminRoomRequestsScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // View Room Occupancy Button
              _buildAdminButton(
                context,
                label: "View Room Occupancy",
                icon: Icons.house,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoomOccupancyScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red for logout button
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 30),
        title: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: onPressed,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      ),
    );
  }
}
