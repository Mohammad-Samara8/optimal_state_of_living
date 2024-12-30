import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TakeAssessmentPage extends StatefulWidget {
  final String userEmail;

  const TakeAssessmentPage({super.key, required this.userEmail});

  @override
  TakeAssessmentPageState createState() => TakeAssessmentPageState();
}

class TakeAssessmentPageState extends State<TakeAssessmentPage> {
  final List<String> _categories = ['Gold', 'White', 'Blue', 'Red'];
  String? selectedStatus;
  String? currentName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.userEmail)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data() as Map<String, dynamic>;
        setState(() {
          currentName = '${userData['firstName']} ${userData['lastName']}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user: $e')),
      );
    }
  }

  Future<void> _submitAssessment() async {
    if (selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status')),
      );
      return;
    }

    final String lastDateUpdate =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String time = DateFormat('hh:mm:ss a').format(DateTime.now());

    try {
      await FirebaseFirestore.instance.collection('assessments').add({
        'email': widget.userEmail,
        'lastDateUpdate': lastDateUpdate,
        'time': time,
        'status': selectedStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment submitted successfully!')),
      );

      setState(() {
        selectedStatus = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit assessment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assessment Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('images/mental.jpg'),
              Text(
                currentName != null
                    ? 'Welcome, $currentName'
                    : 'Fetching your name...',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: selectedStatus,
                items: _categories
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitAssessment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
