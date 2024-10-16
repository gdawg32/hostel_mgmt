import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateRooms() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  for (int i = 1; i <2; i++) {
    await firestore.collection('rooms').doc(i.toString()).set({
      'room_id': i,
      'max_capacity': 4,
      'current_occupancy': 0,
      'student_ids': [],
    });
  }

  print('Rooms added to Firestore!');
}
