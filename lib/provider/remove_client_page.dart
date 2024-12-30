import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveClientPage extends StatefulWidget {
  final String? currentUserEmail;

  const RemoveClientPage({
    super.key,
    required this.currentUserEmail,
  });

  @override
  RemoveClientPageState createState() => RemoveClientPageState();
}

class RemoveClientPageState extends State<RemoveClientPage> {
  String? _selectedClientEmail;

  Future<void> _confirmRemove() async {
    if (_selectedClientEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a client to remove')),
      );
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('user email', isEqualTo: _selectedClientEmail)
          .where('provider email', isEqualTo: widget.currentUserEmail)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client removed successfully')),
      );

      setState(() {
        _selectedClientEmail = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove client: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(String email) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data();
      }
    } catch (e) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Remove Client',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('images/logo.jpg', height: 100),
            const SizedBox(height: 10),
            const Text(
              'Remove Client',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clients')
                    .where('provider email', isEqualTo: widget.currentUserEmail)
                    .snapshots(),
                builder: (context, clientSnapshot) {
                  if (clientSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!clientSnapshot.hasData ||
                      clientSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No clients available for this provider'),
                    );
                  }

                  final clientDocs = clientSnapshot.data!.docs;

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: Future.wait(
                      clientDocs.map((clientDoc) async {
                        final clientData =
                            clientDoc.data() as Map<String, dynamic>;
                        final userEmail = clientData['user email'];
                        final userData = await _fetchUserData(userEmail);
                        return userData != null
                            ? {'id': clientDoc.id, ...userData}
                            : {};
                      }),
                    ),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final userDataList = userSnapshot.data ?? [];

                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('Client Name')),
                          DataColumn(label: Text('Select')),
                        ],
                        rows: userDataList.map((userData) {
                          final fullName =
                              '${userData['firstName'] ?? 'Unknown'} ${userData['lastName'] ?? ''}';
                          final userEmail = userData['email'] ?? '';

                          return DataRow(
                            cells: [
                              DataCell(Text(fullName)),
                              DataCell(
                                Radio<String>(
                                  value: userEmail,
                                  groupValue: _selectedClientEmail,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedClientEmail = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirmRemove,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
