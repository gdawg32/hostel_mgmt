import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminComplaintReviewWidget extends StatefulWidget {
  const AdminComplaintReviewWidget({super.key});

  @override
  _AdminComplaintReviewWidgetState createState() =>
      _AdminComplaintReviewWidgetState();
}

class _AdminComplaintReviewWidgetState
    extends State<AdminComplaintReviewWidget> {
  // Function to update complaint status
  void _updateComplaintStatus(String complaintId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'status': newStatus});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Complaint status updated to $newStatus')),
    );
  }

  // Function to get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'working on it':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Complaints'),
        backgroundColor: Colors.teal, // AppBar color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No complaints available.'));
          }

          var complaints = snapshot.data!.docs;

          // Sort complaints by submitted date (descending)
          complaints.sort((a, b) => b['submitted_at']
              .compareTo(a['submitted_at']));

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              var complaint = complaints[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('students')
                    .doc(complaint['student_id'])
                    .get(),
                builder: (context, studentSnapshot) {
                  if (studentSnapshot.hasData) {
                    var student = studentSnapshot.data!;
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complaint:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.teal.shade800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              complaint['complaint'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Submitted by: ${student['name']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.teal.shade600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Submitted on: ${complaint['submitted_at'].toDate()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(complaint['status']),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    complaint['status'].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: complaint['status'],
                                  onChanged: (String? newStatus) {
                                    if (newStatus != null) {
                                      _updateComplaintStatus(complaint.id, newStatus);
                                    }
                                  },
                                  items: <String>['pending', 'working on it', 'resolved']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  underline: Container(),
                                  style: const TextStyle(color: Colors.teal),
                                  iconEnabledColor: Colors.teal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          );
        },
      ),
    );
  }
}
