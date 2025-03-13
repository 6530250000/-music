import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // เพิ่ม Firestore Import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ต้องใส่เพื่อให้ใช้ async ได้ใน main()
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp()); // ลบคำว่า 'const' ออก
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Changed primary color
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
          ), // White text for readability
          bodyMedium: TextStyle(color: Colors.white),
        ),
        scaffoldBackgroundColor: Color(0xFF121212), // Dark background
      ),
      home: MusicPage(),
    );
  }
}

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final TextEditingController songController = TextEditingController();
  final TextEditingController artistController = TextEditingController();
  final TextEditingController genreController = TextEditingController();

  CollectionReference songs = FirebaseFirestore.instance.collection('Songs');

  // Add song to Firestore
  Future<void> addSong(String song, String artist, String genre) {
    return songs
        .add({'song': song, 'artist': artist, 'genre': genre})
        .then((value) => print("Song Added"))
        .catchError((error) => print("Failed to add song: $error"));
  }

  // Delete song from Firestore
  Future<void> deleteSong(String songId) {
    return songs
        .doc(songId)
        .delete()
        .then((value) => print("Song Deleted"))
        .catchError((error) => print("Failed to delete song: $error"));
  }

  // Update song in Firestore
  Future<void> updateSong(
    String songId,
    String song,
    String artist,
    String genre,
  ) {
    return songs
        .doc(songId)
        .update({'song': song, 'artist': artist, 'genre': genre})
        .then((value) => print("Song Updated"))
        .catchError((error) => print("Failed to update song: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music App'),
        backgroundColor: Colors.deepPurple, // Custom app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form to add a new song with styling
            TextField(
              controller: songController,
              decoration: InputDecoration(
                labelText: 'Song Name',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.deepPurple[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: artistController,
              decoration: InputDecoration(
                labelText: 'Artist Name',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.deepPurple[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: genreController,
              decoration: InputDecoration(
                labelText: 'Genre',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.deepPurple[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addSong(
                  songController.text,
                  artistController.text,
                  genreController.text,
                );
                songController.clear();
                artistController.clear();
                genreController.clear();
              },
              child: Text('Add Song'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            // Display song list with a nice card design
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: songs.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No songs found.'));
                  }
                  var songList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: songList.length,
                    itemBuilder: (context, index) {
                      var song = songList[index];
                      return Card(
                        color: Colors.deepPurple[50],
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            song['song'],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${song['artist']} - ${song['genre']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () {
                                  songController.text = song['song'];
                                  artistController.text = song['artist'];
                                  genreController.text = song['genre'];
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('Edit Song'),
                                          content: Column(
                                            children: [
                                              TextField(
                                                controller: songController,
                                                decoration: InputDecoration(
                                                  labelText: 'Song Name',
                                                ),
                                              ),
                                              TextField(
                                                controller: artistController,
                                                decoration: InputDecoration(
                                                  labelText: 'Artist Name',
                                                ),
                                              ),
                                              TextField(
                                                controller: genreController,
                                                decoration: InputDecoration(
                                                  labelText: 'Genre',
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                updateSong(
                                                  song.id,
                                                  songController.text,
                                                  artistController.text,
                                                  genreController.text,
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Save'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteSong(song.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
