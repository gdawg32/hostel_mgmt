import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomSelectionScreen extends StatefulWidget {
  const RoomSelectionScreen({super.key});

  @override
  _RoomSelectionScreenState createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedRoomId; // Track the selected room

  // Function to select a room
  void _onRoomTap(String roomId) {
    setState(() {
      _selectedRoomId = roomId; // Update the selected room
    });
  }

  // Function to submit the room request
  Future<void> _submitRoomRequest() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null || _selectedRoomId == null) return;

    // Add room request to a new collection called "room_requests"
    await FirebaseFirestore.instance.collection('room_requests').doc(uid).set({
      'student_id': uid,
      'requested_room_id': _selectedRoomId,
      'status': 'pending', // This can be updated later by admin to 'approved' or 'denied'
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Room request submitted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Selection"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var rooms = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    var room = rooms[index];
                    String roomId = room.id;
                    int currentOccupancy = room['current_occupancy'];
                    int maxCapacity = room['max_capacity'];

                    bool isSelected = _selectedRoomId == roomId; // Check if the room is selected

                    return GestureDetector(
                      onTap: currentOccupancy < maxCapacity ? () => _onRoomTap(roomId) : null,
                      child: Card(
                        elevation: 5,
                        color: currentOccupancy >= maxCapacity
                            ? Colors.grey[300]
                            : (isSelected ? Colors.blue[100] : Colors.white), // Highlight selected room
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Room $roomId",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "$currentOccupancy / $maxCapacity occupied",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: currentOccupancy >= maxCapacity ? Colors.red : Colors.green,
                                ),
                              ),
                              if (currentOccupancy >= maxCapacity)
                                const Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "Room Full",
                                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Submit button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _selectedRoomId != null ? _submitRoomRequest : null, // Only enable when a room is selected
                  child: const Text("Submit Room Request"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
