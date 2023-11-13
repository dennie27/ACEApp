import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
import 'package:field_app/services/db.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:field_app/widget/drop_down.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'amplifyconfiguration.dart';
import 'routing/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
final _messageStreamController = BehaviorSubject<RemoteMessage>();
Future<void> backgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

}
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        return resultList.first;
      } else {
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
      print("uri ${urlResult.url}");
      final response = await http.get(urlResult.url);
      final jsonData = jsonDecode(response.body);
      final List<dynamic> filteredTasks = jsonData;
      print(filteredTasks);
      print(filteredTasks.length);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String filteredTasksJson = jsonEncode(filteredTasks);
      await prefs.setString('filteredTasks', filteredTasksJson);
    } on StorageException catch (e) {
      rethrow;
    }
  }
  bool servicestatus = false;
  bool calllog = false;
  bool haspermission = false;
  bool islogin = false;
  late LocationPermission permission;
  LoginCheck()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      islogin = prefs.getBool('isLogin')!;
      print(islogin);
    });

  }
  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
            ),
          );
        }else if(permission == LocationPermission.deniedForever){
          permission = await Geolocator.requestPermission();
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
  List<Permission> statuses = [

    Permission.camera,
    Permission.phone,
    Permission.storage,
  ];

  void initState() {
    checkGps();
    super.initState();
    getUserAuth();
    //checkCallLog();
    listItems("ace_data");

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home:isLogin?NavPage():LoginSignupPage(),
    );
  }
}


