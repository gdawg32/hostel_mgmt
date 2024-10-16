import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceMarkingPage extends StatefulWidget {
  const AttendanceMarkingPage({super.key});

  @override
  _AttendanceMarkingPageState createState() => _AttendanceMarkingPageState();
}

class _AttendanceMarkingPageState extends State<AttendanceMarkingPage> {
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  DateTime endDate = DateTime.now();
  TimeOfDay endTime = TimeOfDay.now();
  List<Map<String, dynamic>> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }

  void fetchAttendanceRecords() async {
    String studentId = 'current_student_id'; // Replace with actual student ID
    var snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('student_id', isEqualTo: studentId)
        .get();

    setState(() {
      attendanceRecords = snapshot.docs.map((doc) {
        return {
          'start_date': doc['start_date'] ?? 'N/A',
          'start_time': doc['start_time'] ?? 'N/A',
          'end_date': doc['end_date'] ?? 'N/A',
          'end_time': doc['end_time'] ?? 'N/A',
        };
      }).toList();
    });
  }

  void markAttendance() async {
    try {
      String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
      String startTimeString = startTime.format(context);
      String endDateString = DateFormat('yyyy-MM-dd').format(endDate);
      String endTimeString = endTime.format(context);

      await FirebaseFirestore.instance.collection('attendance').add({
        'start_date': startDateString,
        'start_time': startTimeString,
        'end_date': endDateString,
        'end_time': endTimeString,
        'student_id': 'current_student_id', // Replace with actual student ID
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance marked successfully")),
      );
      fetchAttendanceRecords(); // Refresh the attendance records
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error marking attendance")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start Date Picker
              const Text('Select Start Date', style: TextStyle(fontSize: 18)),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: startDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    startDate = selectedDay;
                  });
                },
                selectedDayPredicate: (day) => isSameDay(startDate, day),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),

              // Start Time Picker
              const Text('Select Start Time', style: TextStyle(fontSize: 18)),
              TimePickerSpinner(
                is24HourMode: false,
                normalTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
                highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.teal),
                spacing: 20,
                onTimeChange: (time) {
                  setState(() {
                    startTime = TimeOfDay(hour: time.hour, minute: time.minute);
                  });
                },
              ),
              const SizedBox(height: 32),

              // End Date Picker
              const Text('Select End Date', style: TextStyle(fontSize: 18)),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: endDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    endDate = selectedDay;
                  });
                },
                selectedDayPredicate: (day) => isSameDay(endDate, day),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),

              // End Time Picker
              const Text('Select End Time', style: TextStyle(fontSize: 18)),
              TimePickerSpinner(
                is24HourMode: false,
                normalTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
                highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.teal),
                spacing: 20,
                onTimeChange: (time) {
                  setState(() {
                    endTime = TimeOfDay(hour: time.hour, minute: time.minute);
                  });
                },
              ),
              const SizedBox(height: 32),

              // Mark Attendance Button
              Center(
                child: ElevatedButton(
                  onPressed: markAttendance,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.teal, // Text Color
                  ),
                  child: const Text("Mark Attendance"),
                ),
              ),
              const SizedBox(height: 20),

              // Past Attendance Records Header
              const Text(
                'Past Attendance Records:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              SizedBox(
  height: 200,
  child: ListView.builder(
    itemCount: attendanceRecords.length,
    itemBuilder: (context, index) {
      var record = attendanceRecords[index];

      // Parse the date and time strings into DateTime objects
      DateTime startDateTime = DateTime.parse('${record['start_date']} ${record['start_time']}');
      DateTime endDateTime = DateTime.parse('${record['end_date']} ${record['end_time']}');

      // Format the date and time for display
      String formattedStartDate = DateFormat('MMMM d, yyyy').format(startDateTime);
      String formattedStartTime = DateFormat('hh:mm a').format(startDateTime);
      String formattedEndDate = DateFormat('MMMM d, yyyy').format(endDateTime);
      String formattedEndTime = DateFormat('hh:mm a').format(endDateTime);

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    'Start:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('$formattedStartDate at $formattedStartTime'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'End:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('$formattedEndDate at $formattedEndTime'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
