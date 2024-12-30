import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddClientPage extends StatefulWidget {
  final String? currentUserEmail;

  const AddClientPage({super.key, required this.currentUserEmail});

  @override
  AddClientPageState createState() => AddClientPageState();
}

class AddClientPageState extends State<AddClientPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _addClient() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    try {
      QuerySnapshot clientQuery = await FirebaseFirestore.instance
          .collection('clients')
          .where('user email', isEqualTo: email)
          .where('provider email', isEqualTo: widget.currentUserEmail)
          .get();

      if (clientQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client already exists')),
        );
        return;
      }

      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found with this email')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('clients').add({
        'user email': email,
        'provider email': widget.currentUserEmail,
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added to clients successfully!')),
      );

      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding client: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Client',
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
              'Add Client',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Client Email',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'User Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addClient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Add to Clients',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
