import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceTab extends StatefulWidget {
  final String teacherName;
  final String phoneNumber;

  const AttendanceTab({
    super.key,
    required this.teacherName,
    required this.phoneNumber,
  });

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  String docId = "";
  bool isLoading = true;
  String currentTime = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkTodayStatus(); // Load today's attendance
    _startClock(); // Start live clock
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop timer
    super.dispose();
  }

  /// Starts live clock
  void _startClock() {
    currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
      });
    });
  }

  /// Generates today's unique attendance document ID
  String _generateDocId() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return "${widget.phoneNumber}_$today";
  }

  /// Fetch today's attendance status from Firestore
  Future<void> _checkTodayStatus() async {
    final id = _generateDocId();
    final doc = await _firestore.collection('attendance').doc(id).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        hasCheckedIn = data['checkInTime'] != null;
        hasCheckedOut = data['checkOutTime'] != null;
        docId = id;
        isLoading = false;
      });
    } else {
      setState(() {
        hasCheckedIn = false;
        hasCheckedOut = false;
        docId = id;
        isLoading = false;
      });
    }
  }

  /// Check IN logic
  Future<void> _checkIn() async {
    final now = DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(now);

    await _firestore.collection('attendance').doc(docId).set({
      'teacherName': widget.teacherName,
      'phoneNumber': widget.phoneNumber,
      'date': DateFormat('yyyy-MM-dd').format(now),
      'checkInTime': formattedTime,
      'checkOutTime': null,
    });

    setState(() => hasCheckedIn = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checked in successfully ✅")),
    );
  }

  /// Check OUT logic
  Future<void> _checkOut() async {
    final now = DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(now);

    await _firestore.collection('attendance').doc(docId).update({
      'checkOutTime': formattedTime,
    });

    setState(() => hasCheckedOut = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checked out successfully ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Live Clock
        Text(
          "Current Time: $currentTime",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        // Welcome message
        Text(
          "Welcome, ${widget.teacherName}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),

        // IN Button
        if (!hasCheckedIn)
          ElevatedButton(
            onPressed: _checkIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text("Check IN"),
          ),

        // OUT Button
        if (hasCheckedIn && !hasCheckedOut)
          ElevatedButton(
            onPressed: _checkOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text("Check OUT"),
          ),

        // Completed Status
        if (hasCheckedIn && hasCheckedOut)
          const Text(
            "Attendance completed for today ✅",
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
      ],
    );
  }
}
