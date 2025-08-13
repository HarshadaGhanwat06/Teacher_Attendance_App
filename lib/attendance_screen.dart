import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import your tabs
import 'attendance_tab.dart';
import 'history_tab.dart';
import 'profile_tab.dart';

class AttendanceScreen extends StatefulWidget {
  final String teacherName;
  final String phoneNumber;

  const AttendanceScreen({
    super.key,
    required this.teacherName,
    required this.phoneNumber,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _currentIndex = 0; // Index of the currently selected tab
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool hasCheckedIn = false; // Tracks if teacher checked IN today
  bool hasCheckedOut = false; // Tracks if teacher checked OUT today
  String docId = ""; // Firestore document ID for today's attendance
  bool isLoading = true; // Loading spinner for initial status check
  String currentTime = ""; // Live clock string

  Timer? _timer;

  late List<Widget> _tabs; // List of tab widgets for BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _checkTodayStatus(); // Load today's attendance status
    _startClock(); // Start live clock

    // Initialize tabs with corrected parameter names
    _tabs = [
      // Attendance Tab: contains your current IN/OUT UI
      AttendanceTab(
        teacherName: widget.teacherName,
        phoneNumber: widget.phoneNumber,
      ),

      // History Tab: displays attendance history
      HistoryTab(
        teacherPhone: widget.phoneNumber, // corrected parameter name
      ),

      // Profile Tab: allows editing teacher info
      ProfileTab(
        teacherName: widget.teacherName,
        teacherPhone: widget.phoneNumber, // corrected parameter name
      ),
    ];
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop live clock timer
    super.dispose();
  }

  /// Starts live clock updated every second
  void _startClock() {
    currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
      });
    });
  }

  /// Generates unique document ID for today based on phone + date
  String _generateDocId() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return "${widget.phoneNumber}_$today";
  }

  /// Checks Firestore if teacher has checked IN/OUT today
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

  /// Records check-in to Firestore
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

  /// Records check-out to Firestore
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
    return Scaffold(
      // Display the currently selected tab
      body: SafeArea(child: _tabs[_currentIndex]),

      // Bottom navigation bar for switching tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Switch selected tab
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// import 'attendance_tab.dart';
// import 'history_tab.dart';
// import 'profile_tab.dart';

// class AttendanceScreen extends StatefulWidget {
//   final String teacherName;
//   final String phoneNumber;

//   const AttendanceScreen({
//     super.key,
//     required this.teacherName,
//     required this.phoneNumber,
//   });

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   int _currentIndex = 0; // Current tab index
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late List<Widget> _tabs; // List of tab widgets

//   bool hasCheckedIn = false; // Tracks if teacher checked IN today
//   bool hasCheckedOut = false; // Tracks if teacher checked OUT today
//   String docId = ""; // Firestore document ID for today's attendance
//   bool isLoading = true; // Show spinner while loading status
//   String currentTime = ""; // Live clock string

//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _checkTodayStatus(); // Load today's attendance status
//     _startClock(); // Start live clock
//   }

//   @override
//   void dispose() {
//     _timer?.cancel(); // Stop clock timer
//     super.dispose();
//   }

//   /// Starts live clock updated every second
//   void _startClock() {
//     currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
//       });
//     });
//   }

//   /// Generates unique document ID for today based on phone + date
//   String _generateDocId() {
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     return "${widget.phoneNumber}_$today";
//   }

//   /// Checks Firestore if teacher has checked IN/OUT today
//   Future<void> _checkTodayStatus() async {
//     final id = _generateDocId();
//     final doc = await _firestore.collection('attendance').doc(id).get();

//     if (doc.exists) {
//       final data = doc.data()!;
//       setState(() {
//         hasCheckedIn = data['checkInTime'] != null;
//         hasCheckedOut = data['checkOutTime'] != null;
//         docId = id;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         hasCheckedIn = false;
//         hasCheckedOut = false;
//         docId = id;
//         isLoading = false;
//       });
//     }
//   }

//   /// Records check-in to Firestore
//   Future<void> _checkIn() async {
//     final now = DateTime.now();
//     final formattedTime = DateFormat('hh:mm a').format(now);

//     await _firestore.collection('attendance').doc(docId).set({
//       'teacherName': widget.teacherName,
//       'phoneNumber': widget.phoneNumber,
//       'date': DateFormat('yyyy-MM-dd').format(now),
//       'checkInTime': formattedTime,
//       'checkOutTime': null,
//     });

//     setState(() => hasCheckedIn = true);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Checked in successfully ✅")),
//     );
//   }

//   /// Records check-out to Firestore
//   Future<void> _checkOut() async {
//     final now = DateTime.now();
//     final formattedTime = DateFormat('hh:mm a').format(now);

//     await _firestore.collection('attendance').doc(docId).update({
//       'checkOutTime': formattedTime,
//     });

//     setState(() => hasCheckedOut = true);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Checked out successfully ✅")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Live Clock
//               Text(
//                 "Current Time: $currentTime",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 30),

//               // Welcome message
//               Text(
//                 "Welcome, ${widget.teacherName}",
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 40),

//               // Check IN Button
//               if (!hasCheckedIn)
//                 ElevatedButton(
//                   onPressed: _checkIn,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                   ),
//                   child: const Text("Check IN"),
//                 ),

//               // Check OUT Button
//               if (hasCheckedIn && !hasCheckedOut)
//                 ElevatedButton(
//                   onPressed: _checkOut,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                   ),
//                   child: const Text("Check OUT"),
//                 ),

//               // Completed Status
//               if (hasCheckedIn && hasCheckedOut)
//                 const Text(
//                   "Attendance completed for today ✅",
//                   style: TextStyle(fontSize: 16, color: Colors.green),
//                 ),
//             ],
//           );
//   }
// }
