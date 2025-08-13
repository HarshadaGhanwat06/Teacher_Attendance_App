//profile tab
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- import SharedPreferences
import 'profile_page.dart'; // <-- import your ProfilePage

class ProfileTab extends StatefulWidget {
  final String teacherName;
  final String teacherPhone;

  const ProfileTab({
    super.key,
    required this.teacherName,
    required this.teacherPhone,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool isUpdating = false; // For showing progress while updating

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current teacher info
    _nameController = TextEditingController(text: widget.teacherName);
    _phoneController = TextEditingController(text: widget.teacherPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Updates teacher profile in Firestore
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isUpdating = true);

      try {
        // Query teacher document by phone number
        final snapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .where('mobile', isEqualTo: widget.teacherPhone)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final docId = snapshot.docs.first.id;

          await FirebaseFirestore.instance
              .collection('teachers')
              .doc(docId)
              .update({
            'name': _nameController.text.trim(),
            'mobile': _phoneController.text.trim(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully ✅")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Teacher profile not found ❌")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }

      setState(() => isUpdating = false);
    }
  }

  /// Log out: clears saved teacher info and navigates to ProfilePage
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clear all saved preferences

    // Navigate to ProfilePage and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 30),
            isUpdating
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text("Update Profile"),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15)),
                  ),
          ],
        ),
      ),
    );
  }
}
