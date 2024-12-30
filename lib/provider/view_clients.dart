import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewClientsPage extends StatelessWidget {
  final String providerEmail;

  const ViewClientsPage({super.key, required this.providerEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Optimal State of Living',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Image.asset('images/logo.jpg', height: 100),
          const SizedBox(height: 10),
          const Text(
            'Current Clients',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clients')
                  .where('provider email', isEqualTo: providerEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final clients = snapshot.data?.docs ?? [];

                if (clients.isEmpty) {
                  return const Center(child: Text('No clients found.'));
                }

                return ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client =
                        clients[index].data() as Map<String, dynamic>;
                    final clientEmail = client['user email'];
                    final clientNameFuture = _fetchClientName(clientEmail);

                    return FutureBuilder<String>(
                      future: clientNameFuture,
                      builder: (context, nameSnapshot) {
                        if (nameSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        }

                        if (nameSnapshot.hasError) {
                          return ListTile(
                            title: Text('Error fetching name'),
                          );
                        }

                        final clientName = nameSnapshot.data ?? 'Unknown Name';

                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('assessments')
                              .where('email', isEqualTo: clientEmail)
                              .orderBy('lastDateUpdate', descending: true)
                              .orderBy('time', descending: true)
                              .limit(1)
                              .get(),
                          builder: (context, assessmentSnapshot) {
                            if (assessmentSnapshot.hasError) {
                              return const SizedBox.shrink();
                            }

                            final assessmentDocs =
                                assessmentSnapshot.data?.docs ?? [];

                            if (assessmentDocs.isEmpty) {
                              return ListTile(
                                title: Text(clientName),
                                subtitle:
                                    const Text('No assessment data available.'),
                              );
                            }

                            final assessment = assessmentDocs.first.data()
                                as Map<String, dynamic>;

                            final lastDateUpdate =
                                assessment['lastDateUpdate'] ?? 'N/A';
                            final time = assessment['time'] ?? 'N/A';
                            final status = assessment['status'] ?? 'White';

                            return Card(
                              child: ListTile(
                                title: Text(clientName),
                                subtitle: Text(
                                    'Last Update: $lastDateUpdate\nTime: $time'),
                                trailing: Icon(Icons.circle,
                                    color: _getStatusColor(status)),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Back',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Gold':
        return Colors.amber;
      case 'Red':
        return Colors.red;
      case 'Blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<String> _fetchClientName(String clientEmail) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: clientEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        final firstName = userData['firstName'] ?? 'Unknown';
        final lastName = userData['lastName'] ?? '';
        return '$firstName $lastName';
      }
    } catch (e) {}
    return 'Unknown Name';
  }
}
