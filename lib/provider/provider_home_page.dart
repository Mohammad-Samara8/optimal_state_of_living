import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:optimal_state_of_living/provider/add_client_page.dart';
import 'package:optimal_state_of_living/provider/provider_settings_page.dart';
import 'package:optimal_state_of_living/provider/remove_client_page.dart';
import 'package:optimal_state_of_living/provider/view_clients.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class ProviderHomePage extends StatelessWidget {
  const ProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Provider Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/logo.jpg'),
              const Text(
                'Green Light',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('providers')
                    .where('email', isEqualTo: email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('Error fetching provider data');
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('Provider not found');
                  }

                  var providerData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  String firstName = providerData['firstName'] ?? 'Unknown';
                  String lastName = providerData['lastName'] ?? 'Unknown';

                  return Text(
                    'Welcome $firstName $lastName',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40.0),
              _buildButton(context, 'Add Client', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddClientPage(currentUserEmail: email),
                  ),
                );
              }),
              const SizedBox(height: 20.0),
              _buildButton(context, 'Remove Client', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RemoveClientPage(currentUserEmail: email),
                  ),
                );
              }),
              const SizedBox(height: 20.0),
              _buildButton(context, 'View Clients', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewClientsPage(providerEmail: email),
                  ),
                );
              }),
              const SizedBox(height: 20.0),
              _buildButton(context, 'Settings', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProviderSettingsPage(
                      userEmail: email,
                    ),
                  ),
                );
              }),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                    (route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
    );
  }
}
