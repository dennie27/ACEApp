import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:field_app/services/db.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:field_app/widget/drop_down.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'amplifyconfiguration.dart';
import 'routing/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
final _messageStreamController = BehaviorSubject<RemoteMessage>();
Future<void> backgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

}
void callbackDispatcher() {
  Future<void> ACETask(key) async {
    try {

      StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
          key: key)
          .result;
      final response = await http.get(urlResult.url);
      print(response.body);
      final jsonData = jsonDecode(response.body);
      print('File Data: $jsonData');
      final List<dynamic> filteredTasks = jsonData;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String filteredTasksJson = jsonEncode(filteredTasks);
      await prefs.setString('filteredTasks', filteredTasksJson);
      print(filteredTasksJson);

      print(filteredTasks.length);
    } on StorageException catch (e) {
      safePrint('Could not retrieve properties: ${e.message}');
      rethrow;
    }
  }
  Future<StorageItem?> listItems() async {
    var key = "ACE_Data";
    try {
      StorageListOperation<StorageListRequest, StorageListResult<StorageItem>>
      operation = await Amplify.Storage.list(
        options: const StorageListOptions(
          accessLevel: StorageAccessLevel.guest,
          pluginOptions: S3ListPluginOptions.listAll(),

        ),
      );

      Future<StorageListResult<StorageItem>> result = operation.result;
      List<StorageItem> resultList = (await operation.result).items;
      resultList = resultList.where((file) => file.key.contains(key)).toList();
      if (resultList.isNotEmpty) {
        // Sort the files by the last modified timestamp in descending order
        resultList.sort((a, b) => b.lastModified!.compareTo(a.lastModified!));
        StorageItem latestFile = resultList.first;
        ACETask(latestFile.key);
        print(latestFile.key);
        return resultList.first;
      } else {
        print('No files found in the S3 bucket with key containing "$key".');
        return null;
      }
    } on StorageException catch (e) {
      safePrint('Error listing items: $e');
    }
  }


}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    '1',
    'simpleTask',
    frequency:  Duration(days: 1)
  );
  await Firebase.initializeApp();
  await _configureAmplify();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    final storage = AmplifyStorageS3();
    final auth = AmplifyAuthCognito();



    await Amplify.addPlugins([
      storage,
      auth
    ]);

    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin = false;
  bool newList =  false;
  void getUserAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? auth = prefs.getBool('isLogin');
    bool? newData =prefs.getBool('isNewData');
    print('New data $newData');
    setState(() {
      if(auth != null){
        isLogin = auth!;
      }

    });

  }

  late FirebaseMessaging messaging;
  @override
  Future<StorageItem?> listItems(key) async {
    try {
      StorageListOperation<StorageListRequest, StorageListResult<StorageItem>>
      operation = await Amplify.Storage.list(
        options: const StorageListOptions(
          accessLevel: StorageAccessLevel.guest,
          pluginOptions: S3ListPluginOptions.listAll(),

        ),
      );

      Future<StorageListResult<StorageItem>> result = operation.result;
      List<StorageItem> resultList = (await operation.result).items;
      resultList = resultList.where((file) => file.key.contains(key)).toList();
      if (resultList.isNotEmpty) {
        // Sort the files by the last modified timestamp in descending order
        resultList.sort((a, b) => b.lastModified!.compareTo(a.lastModified!));
        StorageItem latestFile = resultList.first;
        StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
            key: key)
            .result;
        print(urlResult.url);
        ACETask(latestFile.key);
        print(latestFile.key);
        return resultList.first;
      } else {
        print('No files found in the S3 bucket with key containing "$key".');
        return null;
      }
    } on StorageException catch (e) {
      safePrint('Error listing items: $e');
    }
  }
  Future<void> ACETask(key) async {
    try {

      StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
          key: key)
          .result;
      final response = await http.get(urlResult.url);
      final jsonData = jsonDecode(response.body);
      final List<dynamic> filteredTasks = jsonData;
      print(filteredTasks);
      print(filteredTasks.length);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String filteredTasksJson = jsonEncode(filteredTasks);
      await prefs.setString('filteredTasks', filteredTasksJson);
      print(filteredTasksJson);
    } on StorageException catch (e) {
      safePrint('Could not retrieve properties: ${e.message}');
      rethrow;
    }
  }
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
            ),
          );
        }else if(permission == LocationPermission.deniedForever){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS Service is not enabled, turn on GPS location'),
        ),
      );

    }

    /*setState(() {
      //refresh the UI
    });*/
  }
  void initState() {
    checkGps();
    super.initState();

    getUserAuth();
    listItems("ACE_Data");
    if(newList !=null){
      print("not empty");
    }else{
      print("empty");

    }


  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      /*darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,*/
      debugShowCheckedModeBanner: false,
      home: /*CustomerScreen()*/ isLogin ? NavPage() : LoginSignupPage(),
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
  bool isLoading = true;
  List? data = [];
  List<String> countrydata = [];
  AuthMode _authMode = AuthMode.Login;
  Future<StorageItem?> listItems(key) async {
    try {
      StorageListOperation<StorageListRequest, StorageListResult<StorageItem>>
      operation = await Amplify.Storage.list(
        options: const StorageListOptions(
          accessLevel: StorageAccessLevel.guest,
          pluginOptions: S3ListPluginOptions.listAll(),
        ),
      );

      Future<StorageListResult<StorageItem>> result = operation.result;
      List<StorageItem> resultList = (await operation.result).items;
      resultList = resultList.where((file) => file.key.contains(key)).toList();
      if (resultList.isNotEmpty) {
        // Sort the files by the last modified timestamp in descending order
        resultList.sort((a, b) => b.lastModified!.compareTo(a.lastModified!));
        StorageItem latestFile = resultList.first;

        CoutryData(latestFile.key);
        print(latestFile.key);
        return resultList.first;
      } else {
        print('No files found in the S3 bucket with key containing "$key".');
        return null;
      }
      safePrint('Got items: ${resultList.length}');
    } on StorageException catch (e) {
      safePrint('Error listing items: $e');
    }
  }
  Future<void> CoutryData(key) async {
    List<String> uniqueCountry = [];
    print("object: $key");

    try {

      StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
          key: key)
          .result;

      final response = await http.get(urlResult.url);
      print(response.body);
      final jsonData = jsonDecode(response.body);
      print('File_team: $jsonData');

      print(jsonData.length);

      for (var item in jsonData) {
        uniqueCountry.add(item['Region']);

      }
      setState(() {
        countrydata = uniqueCountry.toSet().toList();
        data = jsonData;
        isLoading = false;

      });
    } on StorageException catch (e) {
      safePrint('Could not retrieve properties: ${e.message}');
      rethrow;
    }
  }
  Future<void> _submitForm() async {
    print(_authMode);
    if (_formKey.currentState!.validate()) {
      var connection = await Database.connect();
      if(_authMode == AuthMode.Login){
        final response = await http.post(
          Uri.parse('https://sun-kingfieldapp.herokuapp.com/api/auth/signin'), // Replace with your API endpoint URL.
          body: {
            'email': _email,
            'pass1': _password,
          },
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        print(response.statusCode);
        if (response.statusCode== 200) {
          var results = await connection.query( "SELECT * FROM fieldappusers_feildappuser WHERE email = @email",
            substitutionValues: {"email":_email});
          var Row = results[0];
          prefs.setString('email', Row[4]);
          prefs.setString('name', Row[6] + ' ' + Row[7]);
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
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          String successMessage = responseData['error'];
          final snackBar = SnackBar(
            content: Text(successMessage),
            duration: Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }else {
        try{
          final response = await http.post(
            Uri.parse('https://sun-kingfieldapp.herokuapp.com/api/auth/signup'),
            body: {
              'username' : _email,
              'fname' :firstname ,
              'lname' : lastname,
              'email' : _email,
              'country' :country,
              'zone' : zone,
              'region' :region ,
              'area' : area,
              'role' : role,
              'pass1' : _password,
              'pass2' : _confirmPassword,

          },
          );
          if(response.statusCode == 201){
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            String successMessage = responseData['message'];
            final snackBar = SnackBar(

              content: Text(successMessage),
              duration: Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              _authMode = AuthMode.Login;
            });
          }else{
            print(response.body);
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            String successMessage = responseData['error'];
            final snackBar = SnackBar(
              content: Text(successMessage),
              duration: Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            print(successMessage);
          }
        }catch (e) {
          print('Error executing query: $e');
        } finally {
          await connection.close();
        }
      }
    }
  }
@override
  void initState()  {

    // TODO: implement initState
    super.initState();
      //listItems("country");


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10,100.0,10,0),
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
                    SizedBox(height: 10,),
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
                    SizedBox(height: 10,),
                    AppDropDown(
                        disable: false,
                        label: "Country",
                        hint: "Country",
                        items: countrydata,
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Country';
                          }
                          return null;
                        },
                        onChanged: (value){
                          country = value;
                        }),
                    SizedBox(height: 10,),
                    AppDropDown(
                        disable: false,
                        label: "Zone",
                        hint: "Zone",
                        items: ["West"],
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Zone';
                          }
                          return null;
                        },
                        onChanged: (value){
                          zone = value;
                        }),
                    SizedBox(height: 10,),

                    AppDropDown(
                        disable: false,
                        label: "Region",
                        hint: "Region",
                        items: ["Central"],
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Zone';
                          }
                          return null;
                        },
                        onChanged: (value){
                          region = value;
                        }),
                    SizedBox(height: 10,),
                    AppDropDown(
                        disable: false,
                        label: "Area",
                        hint: "Area",
                        items: ["Singida"],
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Area';
                          }
                          return null;
                        },
                        onChanged: (value){
                          area = value;
                        }),
                    SizedBox(height: 10,),
                    AppDropDown(
                        disable: false,
                        label: "Role",
                        hint: "Role",
                        items: const ["Area Collection Executive"],
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Role';
                          }
                          return null;
                        },
                        onChanged: (value){
                          role = value;
                        }),

                  ],),
                SizedBox(height: 10,),
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

