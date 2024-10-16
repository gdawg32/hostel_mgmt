import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomOccupancyScreen extends StatelessWidget {
  const RoomOccupancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Occupancy"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .orderBy('room_id') // Sort by 'room_id'
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var rooms = snapshot.data!.docs;

          if (rooms.isEmpty) {
            return const Center(child: Text("No rooms available."));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              var room = rooms[index];
              String roomId = room.id;
              int currentOccupancy = room['current_occupancy'];
              List<dynamic> studentIds = room['student_ids'];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Room $roomId",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Occupancy: $currentOccupancy / 4",
                        style: const TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      const SizedBox(height: 10),
                      if (studentIds.isNotEmpty)
                        ...studentIds.map((studentId) => FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('students').doc(studentId).get(),
                          builder: (context, studentSnapshot) {
                            if (!studentSnapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            var studentData = studentSnapshot.data?.data() as Map<String, dynamic>?;

                            return ListTile(
                              title: Text(studentData?['name'] ?? 'Unknown'),
                              subtitle: Text("Branch: ${studentData?['branch'] ?? 'N/A'}\nPass Out Year: ${studentData?['pass_out_year'] ?? 'N/A'}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Change Room Button
                                  IconButton(
                                    icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                                    onPressed: () {
                                      _showChangeRoomDialog(context, studentId, roomId);
                                    },
                                  ),
                                  // Fees Button
                                  IconButton(
                                    icon: const Icon(Icons.payment, color: Colors.green),
                                    onPressed: () {
                                      _showFeesDialog(context, studentId);
                                    },
                                  ),
                                  // Remove Student Button
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _removeStudentFromRoom(context, studentId, roomId);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        )),
                      if (studentIds.isEmpty)
                        const Text("No students assigned.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to open a dialog to change the student's room
  void _showChangeRoomDialog(BuildContext context, String studentId, String currentRoomId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Room'),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var rooms = snapshot.data!.docs;

              // Sort rooms by 'room_id'
              rooms.sort((a, b) {
                int roomA = a['room_id'];
                int roomB = b['room_id'];
                return roomA.compareTo(roomB); // Ascending order
              });

              return ListView.builder(
                shrinkWrap: true,
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  var room = rooms[index];
                  String roomId = room.id;
                  int currentOccupancy = room['current_occupancy'];
                  int maxCapacity = 4;

                  return ListTile(
                    title: Text('Room $roomId'),
                    subtitle: Text('Occupancy: $currentOccupancy / $maxCapacity'),
                    onTap: currentOccupancy < maxCapacity
                        ? () {
                            _changeStudentRoom(studentId, currentRoomId, roomId);
                            Navigator.pop(context);
                          }
                        : null,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

// Function to show a dialog for managing fees
void _showFeesDialog(BuildContext context, String studentId) {
  showDialog(
    context: context,
    builder: (context) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(studentId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var studentData = snapshot.data?.data() as Map<String, dynamic>?;
          var totalFees = (studentData?['total_fees'] ?? 0).toInt();
          var dueFees = (studentData?['due_fees'] ?? 0).toInt();
          var totalFeesPaid = (studentData?['total_fees_paid'] ?? 0).toInt();
          var lastPaymentDate = studentData?['last_payment_date']?.toDate() ?? DateTime.now();

          final _feeController = TextEditingController();

          return AlertDialog(
            title: const Text('Manage Fees'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeeInfo('Total Fees', totalFees, Colors.blueGrey),
                  _buildFeeInfo('Due Fees', dueFees, Colors.red),
                  _buildFeeInfo('Fees Paid', totalFees - dueFees, Colors.green),
                  Text(
                    'Last Payment Date: ${lastPaymentDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _feeController,
                    decoration: const InputDecoration(
                      labelText: 'Add Due Fee Amount',
                      hintText: 'Enter fee amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await _updateDueFees(context, studentId, dueFees, totalFees, _feeController.text);
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () async {
                  await _clearAllDues(context, studentId, totalFeesPaid, dueFees);
                },
                child: const Text('Clear All Dues'),
              ),
            ],
          );
        },
      );
    },
  );
}

// Helper function to build fee information text
Widget _buildFeeInfo(String label, int amount, Color color) {
  return Text(
    '$label: ₹${amount}',
    style: TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}

// Function to update due fees
Future<void> _updateDueFees(BuildContext context, String studentId, int dueFees, int totalFees, String feeInput) async {
  var feeAmount = int.tryParse(feeInput);
  if (feeAmount != null) {
    await FirebaseFirestore.instance.collection('students').doc(studentId).update({
      'due_fees': dueFees + feeAmount,
      'total_fees': totalFees + feeAmount,
      'last_payment_date': DateTime.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Due fee updated successfully.")));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid fee amount.")));
  }
}

// Function to clear all dues
Future<void> _clearAllDues(BuildContext context, String studentId, int totalFeesPaid, int dueFees) async {
  await FirebaseFirestore.instance.collection('students').doc(studentId).update({
    'total_fees_paid': totalFeesPaid + dueFees,
    'due_fees': 0,
    'last_payment_date': DateTime.now(),
  });
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All dues cleared.")));
}


  // Function to change the student's room
  Future<void> _changeStudentRoom(String studentId, String oldRoomId, String newRoomId) async {
    // Decrease occupancy in the old room
    await FirebaseFirestore.instance.collection('rooms').doc(oldRoomId).update({
      'student_ids': FieldValue.arrayRemove([studentId]),
      'current_occupancy': FieldValue.increment(-1),
    });

    // Increase occupancy in the new room
    await FirebaseFirestore.instance.collection('rooms').doc(newRoomId).update({
      'student_ids': FieldValue.arrayUnion([studentId]),
      'current_occupancy': FieldValue.increment(1),
    });

    // Update student's room_id in the 'students' collection
    await FirebaseFirestore.instance.collection('students').doc(studentId).update({
      'room_id': newRoomId,
    });
  }

  // Function to remove the student from the room
  Future<void> _removeStudentFromRoom(BuildContext context, String studentId, String roomId) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'student_ids': FieldValue.arrayRemove([studentId]),
      'current_occupancy': FieldValue.increment(-1),
    });

    // Optionally, clear the room_id from the student's document if you want
    await FirebaseFirestore.instance.collection('students').doc(studentId).update({
      'room_id': FieldValue.delete(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student removed from room.")),
    );
  }
}
