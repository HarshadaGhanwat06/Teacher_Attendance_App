//profile page
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  /// Save teacher profile to Firestore and navigate to AttendanceScreen
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Add teacher info to Firestore
      final docRef = await FirebaseFirestore.instance.collection('teachers').add({
        'name': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
      });

  

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      // Save locally so user doesn't need to login again
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacherName', _nameController.text.trim());
    await prefs.setString('teacherPhone', _mobileController.text.trim());

      // Navigate to AttendanceScreen with teacher details and document ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceScreen(
            teacherName: _nameController.text.trim(),
            phoneNumber: _mobileController.text.trim(),
            //teacherId: docRef.id, // Pass document ID for profile editing
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: "Mobile Number"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your mobile number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save & Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
