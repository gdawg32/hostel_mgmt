import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminRoomRequestsScreen extends StatefulWidget {
  const AdminRoomRequestsScreen({super.key});

  @override
  _AdminRoomRequestsScreenState createState() => _AdminRoomRequestsScreenState();
}

class _AdminRoomRequestsScreenState extends State<AdminRoomRequestsScreen> {
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle request decision
  Future<void> _handleRequestDecision(String requestId, String decision) async {
    await FirebaseFirestore.instance.collection('room_requests').doc(requestId).update({
      'status': decision,
    });

    // Update the room occupancy if accepted
    if (decision == 'accepted') {
      DocumentSnapshot requestSnapshot = await FirebaseFirestore.instance.collection('room_requests').doc(requestId).get();
      String roomId = requestSnapshot['requested_room_id'];
      String studentId = requestSnapshot['student_id'];

      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'current_occupancy': FieldValue.increment(1),
        'student_ids': FieldValue.arrayUnion([studentId]),
      });

      await FirebaseFirestore.instance.collection('students').doc(studentId).update({
        'room_id': roomId,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request $decision successfully!")),
    );
  }

  // Fetch student name from studentId
  Future<String> _getStudentName(String studentId) async {
    DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance.collection('students').doc(studentId).get();
    return studentSnapshot['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Requests"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('room_requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No room requests available."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              String requestId = request.id;
              String studentId = request['student_id'];
              String roomId = request['requested_room_id'];
              String status = request['status'];

              return FutureBuilder<String>(
                future: _getStudentName(studentId),
                builder: (context, nameSnapshot) {
                  if (!nameSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  String studentName = nameSnapshot.data ?? 'Unknown';

                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 5,
                    child: ListTile(
                      title: Text("Student: $studentName"),
                      subtitle: Text("Requested Room: $roomId\nStatus: $status"),
                      trailing: status == 'pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _handleRequestDecision(requestId, 'accepted'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _handleRequestDecision(requestId, 'rejected'),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
