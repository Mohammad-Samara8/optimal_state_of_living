import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewHistory extends StatefulWidget {
  final String userEmail;

  const ViewHistory({super.key, required this.userEmail});

  @override
  ViewHistoryState createState() => ViewHistoryState();
}

class ViewHistoryState extends State<ViewHistory> {
  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;

  final List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> months =
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> years =
      List.generate(10, (index) => (2024 - index).toString());

  late Stream<QuerySnapshot> _assessmentStream;

  @override
  void initState() {
    super.initState();
    _assessmentStream = _fetchAssessmentData();
  }

  Stream<QuerySnapshot> _fetchAssessmentData() {
    final selectedDate = _getSelectedDate();

    if (selectedDate == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('assessments')
        .where('email', isEqualTo: widget.userEmail)
        .where('lastDateUpdate', isEqualTo: selectedDate)
        .orderBy('time', descending: true)
        .snapshots();
  }

  String? _getSelectedDate() {
    if (selectedDay != null && selectedMonth != null && selectedYear != null) {
      return '$selectedYear-$selectedMonth-$selectedDay';
    }
    return null;
  }

  void _updateStream() {
    setState(() {
      _assessmentStream = _fetchAssessmentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Day'),
                    value: selectedDay,
                    items: days
                        .map((day) =>
                            DropdownMenuItem(value: day, child: Text(day)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value;
                        _updateStream();
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Month'),
                    value: selectedMonth,
                    items: months
                        .map((month) =>
                            DropdownMenuItem(value: month, child: Text(month)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                        _updateStream();
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Year'),
                    value: selectedYear,
                    items: years
                        .map((year) =>
                            DropdownMenuItem(value: year, child: Text(year)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                        _updateStream();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _assessmentStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error.toString()}'));
                }

                if (_getSelectedDate() == null) {
                  return const Center(
                      child: Text('Please select a date to view data.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child:
                          Text('No assessments found for the selected date.'));
                }

                final docs = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Check Time')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final checkTime = data['time'] ?? 'N/A';
                      final status = data['status'] ?? 'N/A';

                      return DataRow(
                        cells: [
                          DataCell(Text(checkTime)),
                          DataCell(Text(status)),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
