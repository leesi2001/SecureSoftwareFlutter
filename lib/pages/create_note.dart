import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_software/pages/login.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _noteController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _addNote() async {
    final String noteContent = _noteController.text.trim();
    if (noteContent.isNotEmpty) {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference userDoc =
            _firestore.collection('users').doc(user.uid);

        await userDoc.set({
          'notes': FieldValue.arrayUnion([noteContent])
        }, SetOptions(merge: true));

        _noteController.clear();
        _fetchNotes();
      }
    }
  }

  void _deleteNote(String noteToDelete) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.update({
        'notes': FieldValue.arrayRemove([noteToDelete])
      });

      _fetchNotes();
    }
  }

  void _fetchNotes() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        List<dynamic> fetchedNotes = userDoc.get('notes') ?? [];
        setState(() {
          notes = List<String>.from(fetchedNotes);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notes'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.orange,
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                  labelText: 'Enter your note here',
                  fillColor: Colors.white,
                  filled: true),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addNote,
              style: ElevatedButton.styleFrom(
                  primary: Colors.black, onPrimary: Colors.white),
              child: Text('Add Note'),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(notes[index],
                          style: TextStyle(color: Colors.black)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNote(notes[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
