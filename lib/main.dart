import 'package:field_app/services/db.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'routing/bottom_nav.dart';
import 'login.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}
enum AuthMode { Login, Signup }
class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();

  String _email ='';
  String _password ='';
  String _confirmPassword ='';
  String role ='';
  String zone ='';
  String region ='';
  String area ='';
  String country ='';
  String firstname ='';
  String lastname ='';
  AuthMode _authMode = AuthMode.Login;

  Future<void> _submitForm() async {
    print(_authMode);
    if (_formKey.currentState!.validate()) {
      var connection = await Database.connect();
      if(_authMode == AuthMode.Login){
        var results = await connection.query( "SELECT * FROM fieldappusers_feildappuser WHERE email = @email AND password = @password",
          substitutionValues: {"email":_email,"password": _password},);
        SharedPreferences prefs = await SharedPreferences.getInstance();



        if (results.isNotEmpty) {
          print(results);
          var Row = results[0];
          prefs.setString('email', Row[4]);
          prefs.setString('name', Row[6]);
          prefs.setString('country', Row[8]);
          prefs.setString('zone', Row[10]);
          prefs.setString('region', Row[9]);
          prefs.setString('area', Row[14]);
          prefs.setString('role', Row[11]);
          prefs.setString('email', _email);
          prefs.setBool('isLogin',true);
          print(prefs.get('name'));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavPage()));
        }else{
          final snackBar = SnackBar(
            content: Text('Incorrect credentials please try again'),
            duration: Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }else {
        try{
          await  connection.execute("insert into fieldappusers_feildappuser (username,email,password, first_name,last_name,country,zone,region,area,role,is_superuser,is_staff,is_active) values ('$_email','$_email','$_password','$firstname','$lastname','$country','$zone','$region','$zone','$role','false','true','true')   ");
        }catch (e) {
          print('Error executing query: $e');
        } finally {
          await connection.close();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10,100.0,0,0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(_authMode == AuthMode.Signup)
                  Column(children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your First Name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        firstname = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Last Name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        lastname = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Country'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Country';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        country = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Zone'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Zone';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        zone = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Region'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Region';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        region = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Role'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Role';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        role = value;
                      },
                    ),
                  ],),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _email = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _password = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)

                  TextFormField(
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter confirm password';
                      } else if (value != _password) {
                        return 'Password does not match';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                  ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  child: Text(_authMode == AuthMode.Login ? 'Login' : 'Sign Up'),
                  onPressed: _submitForm,
                ),
                TextButton(
                  child: Text(_authMode == AuthMode.Login ? 'Create Account' : 'Back to Login'),
                  onPressed: () {
                    setState(() {
                      _authMode = _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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

