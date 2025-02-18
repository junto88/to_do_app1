import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginPage.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    try {
    if (Firebase.apps.isEmpty) {  
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
   
  }
  
 FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: false,
  );


  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: AuthGate(onThemeChanged: () {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
      }),
    );
  }
}



class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  HomeScreen({required this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _listTitleController = TextEditingController();
  final TextEditingController _listDescriptionController = TextEditingController();
  Color _selectedColor = Colors.brown.shade200;
  final CollectionReference lists = FirebaseFirestore.instance.collection('lists');



Stream<QuerySnapshot> _getUserLists() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return FirebaseFirestore.instance
        .collection('lists')
        .where('userId', isEqualTo: user.uid) //  Filtra solo le liste dell'utente loggato
        .snapshots();
  }
  return Stream.empty();
}

Future<void> _logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().disconnect(); // Disconnette completamente l'account Google
    await GoogleSignIn().signOut(); // Rimuove l'account dalla cache

    //  Dopo il logout, reindirizza l'utente alla pagina di login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  } catch (e) {
    print("Errore durante il logout: $e");
  }
}

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Scegli un colore"),
          content: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  void _createList() {
  final user = FirebaseAuth.instance.currentUser;


  if (user == null) {
    print(" ERRORE: Nessun utente autenticato! ");
    return;
  }

  if (_listTitleController.text.trim().isEmpty) {
    print("Titolo della lista vuoto! ");
    return;
  }

  lists.add({
    'title': _listTitleController.text.trim(),
    'description': _listDescriptionController.text.trim(),
    'color': _selectedColor.value,
    'userId': user.uid, //  Importante per Firestore
  }).then((docRef) {
    
  }).catchError((error) {
    
  });

  _listTitleController.clear();
  _listDescriptionController.clear();
}



  void _deleteList(String id) {
    lists.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Liste di Attività', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold))),
        backgroundColor: Colors.brown.shade200,
         actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.onThemeChanged,
          ),
          IconButton(
  icon: Icon(Icons.logout),
  onPressed: () async {
    await _logout(); // Chiamata alla funzione di logout
  },
),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  cursorColor: Colors.brown,
                  controller: _listTitleController,
                  decoration: InputDecoration(
                    labelText: 'Titolo della lista',
                    labelStyle: GoogleFonts.poppins(color: Colors.brown, fontSize: 18),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 3.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  cursorColor: Colors.brown,
                  controller: _listDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrizione della lista',
                    labelStyle: GoogleFonts.poppins(color: Colors.brown, fontSize: 18),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 3.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickColor(context),
                  child: Text('Scegli Colore', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown,foregroundColor: Colors.white),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _createList,
                  child: Text('Crea Lista', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _getUserLists(), 
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nessuna lista disponibile.'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                     Color listColor = (doc.data() as Map<String, dynamic>).containsKey('color') 
    ? Color(doc['color']) 
    : Colors.brown.shade200; 
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: listColor,
                        borderRadius: BorderRadius.circular(15),
                       
                      ),
                      child: ListTile(
                        title: Text(doc['title'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text(doc['description'], style: GoogleFonts.poppins(color: Colors.white)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskScreen(listId: doc.id, listTitle: doc['title']),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white, size: 28),
                          onPressed: () => _deleteList(doc.id),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskScreen extends StatefulWidget {
  final String listId;
  final String listTitle;
  TaskScreen({required this.listId, required this.listTitle});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();



Stream<QuerySnapshot> _getUserTasks() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return FirebaseFirestore.instance
        .collection('lists')
        .doc(widget.listId)
        .collection('tasks')
        .where('userId', isEqualTo: user.uid) // ✅ Filtra i task per l'utente attuale
        .snapshots();
  }
  return Stream.empty();
}


 void _addTask() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && _taskController.text.isNotEmpty) {
    FirebaseFirestore.instance
        .collection('lists')
        .doc(widget.listId)
        .collection('tasks')
        .add({
      'title': _taskController.text.trim(),
      'completed': false,
      'userId': user.uid, 
    }).then((docRef) {
      
    }).catchError((error) {
      
    });

    _taskController.clear();
  }
}


  void _toggleTask(String taskId, bool currentStatus) {
    FirebaseFirestore.instance.collection('lists').doc(widget.listId).collection('tasks').doc(taskId).update({'completed': !currentStatus});
  }

  void _deleteTask(String taskId) {
    FirebaseFirestore.instance.collection('lists').doc(widget.listId).collection('tasks').doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listTitle, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown.shade200,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.brown,
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Aggiungi Attività',
                      labelStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.brown),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown, width: 3.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 28),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
  child: StreamBuilder(
    stream: _getUserTasks(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
      return ListView(
        children: snapshot.data!.docs.map((doc) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
              borderRadius: BorderRadius.circular(15),
              
            ),
            child: ListTile(
              title: Text(
                doc['title'],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: doc['completed'] ? TextDecoration.lineThrough : null,
                ),
              ),
              leading: Checkbox(
                value: doc['completed'],
                onChanged: (value) => _toggleTask(doc.id, doc['completed']),
                activeColor: Colors.brown,
                checkColor: Colors.white,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade400, size: 28),
                onPressed: () => _deleteTask(doc.id),
              ),
            ),
          );
        }).toList(),
      );
    },
  ),
),

        ],
      ),
    );
  }

  
}
