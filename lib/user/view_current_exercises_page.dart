import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCurrentExercisesPage extends StatefulWidget {
  final String userEmail;

  const ViewCurrentExercisesPage({super.key, required this.userEmail});

  @override
  ViewCurrentExercisesPageState createState() =>
      ViewCurrentExercisesPageState();
}

class ViewCurrentExercisesPageState extends State<ViewCurrentExercisesPage> {
  String? userCategory;
  List<String> breathingExercises = [];
  List<String> recommendedFoods = [];
  String? videoLink;
  String? bookLink;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserCategory(widget.userEmail);
  }

  Future<void> fetchUserCategory(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('assessments')
          .where('email', isEqualTo: email)
          .orderBy('lastDateUpdate', descending: true)
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userCategory = snapshot.docs.first['status'];
        });
        fetchExercises();
      } else {
        setState(() {
          userCategory = null;
        });
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchExercises() async {
    try {
      if (userCategory != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('mental health')
            .where('categorgy', isEqualTo: userCategory)
            .get();

        setState(() {
          breathingExercises = snapshot.docs
              .map((doc) => doc['Breathing excersise'].toString())
              .toList();
          recommendedFoods =
              snapshot.docs.map((doc) => doc['food'].toString()).toList();
          videoLink =
              snapshot.docs.isNotEmpty ? snapshot.docs.first['video'] : null;
          bookLink =
              snapshot.docs.isNotEmpty ? snapshot.docs.first['book'] : null;
        });
      }
    } catch (e) {}
  }

  void openLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exercises',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Image.asset('images/logo.jpg'),
                  Text(
                    'Exercises',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (userCategory == null) ...[
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'No assessments found for the current user.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                  ] else if (userCategory != null &&
                      breathingExercises.isEmpty) ...[
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Loading exercises...',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                  ] else ...[
                    buildExpandableTile(
                        'Breathing Exercises', breathingExercises),
                    buildExpandableTile('Recommended Foods', recommendedFoods),
                    if (videoLink != null)
                      ListTile(
                        title: Text('Watch Video'),
                        subtitle: Text('Tap to open video link'),
                        onTap: () => openLink(videoLink!),
                        leading: Icon(Icons.video_library),
                      ),
                    if (bookLink != null)
                      ListTile(
                        title: Text('Book Recommendation'),
                        subtitle: Text('Tap to view the book'),
                        onTap: () => openLink(bookLink!),
                        leading: Icon(Icons.book),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget buildExpandableTile(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        child: ExpansionTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          children: items
              .map((exercise) => ListTile(
                    title: Text(exercise),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
