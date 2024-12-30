import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderChangePersonalSetting extends StatefulWidget {
  final String? userEmail;
  const ProviderChangePersonalSetting({super.key, required this.userEmail});

  @override
  State<ProviderChangePersonalSetting> createState() =>
      ProviderChangePersonalSettingState();
}

class ProviderChangePersonalSettingState
    extends State<ProviderChangePersonalSetting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showChangeDialog({
    required String title,
    required String fieldName,
    required String fieldLabel,
  }) async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: fieldLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  final snapshot = await _firestore
                      .collection('providers')
                      .where('email', isEqualTo: widget.userEmail)
                      .get();

                  if (snapshot.docs.isNotEmpty) {
                    final documentId = snapshot.docs[0].id;
                    await _firestore
                        .collection('providers')
                        .doc(documentId)
                        .update({
                      fieldName: controller.text.trim(),
                    });
                  } else {}

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$fieldName updated successfully!')),
                  );

                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(labelText: "Old Password"),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: "New Password"),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: "Confirm New Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final user = _auth.currentUser;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No user signed in.')),
                  );
                  return;
                }

                try {
                  final String oldPassword = oldPasswordController.text.trim();
                  final String newPassword = newPasswordController.text.trim();
                  final String confirmPassword =
                      confirmPasswordController.text.trim();

                  if (newPassword != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match!')),
                    );
                    return;
                  }

                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPassword,
                  );

                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPassword);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password updated successfully!')),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDateOfBirthDialog() async {
    int? selectedDay;
    String? selectedMonth;
    int? selectedYear;

    List<int> days = List.generate(31, (index) => index + 1);

    List<int> years =
        List.generate(100, (index) => DateTime.now().year - index);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Date of Birth"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Day"),
                value: selectedDay,
                items: days
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Month"),
                value: selectedMonth,
                items: [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ]
                    .map((month) => DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Year"),
                value: selectedYear,
                items: years
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (selectedDay != null &&
                    selectedMonth != null &&
                    selectedYear != null) {
                  String dateOfBirth =
                      "$selectedDay $selectedMonth $selectedYear";

                  final snapshot = await _firestore
                      .collection('providers')
                      .where('email', isEqualTo: widget.userEmail)
                      .get();

                  if (snapshot.docs.isNotEmpty) {
                    final documentId = snapshot.docs[0].id;
                    await _firestore
                        .collection('providers')
                        .doc(documentId)
                        .update({
                      'dateOfBirth': dateOfBirth,
                    });
                  } else {}

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Date of Birth updated successfully!')),
                  );

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select all fields!')),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setting',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('images/logo.jpg'),
              Text(
                'Green Light',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 40),
              _buildButton(context, 'Change First Name', () {
                _showChangeDialog(
                  title: "Change First Name",
                  fieldName: "firstName",
                  fieldLabel: "Enter New First Name",
                );
              }),
              SizedBox(height: 20),
              _buildButton(context, 'Change Last Name', () {
                _showChangeDialog(
                  title: "Change Last Name",
                  fieldName: "lastName",
                  fieldLabel: "Enter New Last Name",
                );
              }),
              SizedBox(height: 20),
              _buildButton(
                  context, 'Change Password', _showChangePasswordDialog),
              SizedBox(height: 20),
              _buildButton(context, 'Change Phone', () {
                _showChangeDialog(
                  title: "Change Phone",
                  fieldName: "phone",
                  fieldLabel: "Enter New Phone Number",
                );
              }),
              SizedBox(height: 20),
              _buildButton(
                  context, 'Change Date of Birth', _showDateOfBirthDialog),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
