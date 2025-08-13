import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatefulWidget {
  final String teacherPhone; // Teacher's phone number to fetch attendance

  const HistoryTab({super.key, required this.teacherPhone});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true; // Show spinner while fetching data
  List<Map<String, dynamic>> attendanceList = []; // List to store attendance records

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  /// Fetches all attendance records for the teacher
  Future<void> _fetchAttendanceHistory() async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('phoneNumber', isEqualTo: widget.teacherPhone)
          .orderBy('date', descending: true) // latest first
          .get();

      if (snapshot.docs.isNotEmpty) {
        attendanceList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'date': data['date'],
            'checkInTime': data['checkInTime'],
            'checkOutTime': data['checkOutTime'],
          };
        }).toList();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching attendance history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Returns status based on check-in/check-out
  String _getStatus(Map<String, dynamic> record) {
    if (record['checkInTime'] != null && record['checkOutTime'] != null) {
      return "Present";
    } else if (record['checkInTime'] != null) {
      return "Partial";
    } else {
      return "Absent";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (attendanceList.isEmpty) {
      return const Center(
        child: Text(
          "No attendance records found.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendanceList.length,
      itemBuilder: (context, index) {
        final record = attendanceList[index];
        final date = record['date'];
        final status = _getStatus(record);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              status == "Present"
                  ? Icons.check_circle
                  : status == "Partial"
                      ? Icons.timelapse
                      : Icons.cancel,
              color: status == "Present"
                  ? Colors.green
                  : status == "Partial"
                      ? Colors.orange
                      : Colors.red,
            ),
            title: Text(
              DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Status: $status"),
            trailing: status != "Absent"
                ? Text(
                    "IN: ${record['checkInTime'] ?? '-'}\nOUT: ${record['checkOutTime'] ?? '-'}",
                    textAlign: TextAlign.right,
                  )
                : null,
          ),
        );
      },
    );
  }
}
