import 'package:field_app/utils/themes/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'routing/bottom_nav.dart';
import 'login.dart';
import 'package:rxdart/rxdart.dart';
final _messageStreamController = BehaviorSubject<RemoteMessage>();
Future<void> backgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  User? user;
  bool isLogin = false;
  late FirebaseMessaging messaging;
  @override


  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      isLogin = true;
    } else {
      isLogin = false;
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      /*darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,*/
      debugShowCheckedModeBanner: false,
      home: /*CustomerScreen()*/ isLogin ? NavPage() : Login(),
    );
  }
}

/*class FirebaseListView extends StatefulWidget {
  @override
  _FirebaseListViewState createState() => _FirebaseListViewState();
}

class _FirebaseListViewState extends State<FirebaseListView> {
  String _searchQuery = '';
  List<DocumentSnapshot> _data = [];
  CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('new_calling');

  @override
  void initState() {
    super.initState();
    _getDocuments();
  }

  Future<void> _getDocuments() async {
    QuerySnapshot querySnapshot =
    await _collectionRef.orderBy('name').get();
    setState(() {
      _data = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          if (_searchQuery.isNotEmpty &&
              !_data[index]['name']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) {
            return SizedBox();
          }
          return ListTile(
            title: Text(_data[index]['name']),
            subtitle: Text(_data[index]['description']),
          );
        },
      ),
    );
  }
}*/

