import 'dart:convert';


import 'package:field_app/services/db.dart';
import 'package:field_app/services/user_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



getTotalUsers() {

}

class USerCallDetail{
  //to get number of calls
  var user = FirebaseFirestore.instance.collection('Users');


  CollectionReference<Map<String, dynamic>> calling =
  FirebaseFirestore.instance.collection('new_calling');
  CollectionReference<Map<String, dynamic>> feedback =
  FirebaseFirestore.instance.collection('FeedBack');
  //var uid = FirebaseFirestore.instance.collection("Users").where("UID",isEqualTo:currentUser);

  Future<void> getData() async {
    // Get docs from collection reference


    // Get data from docs and convert map to List

  }

  Future<int> countDocuments(String area) async {
    final connection =   await Database.connect();

    final results = await connection.query(
      "SELECT COUNT(*) FROM ace_task WHERE area = @area",
      substitutionValues: {'email': area},
    );

    await connection.close();
    final count = results[0][0] as int;

    return count;

  }
  //get data by user area
  Future<int> countDataByArea() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var area = prefs.getString("area");

    final connection =   await Database.connect();

    final results = await connection.query(
      "SELECT COUNT(*) FROM ace_task WHERE area = @area",
      substitutionValues: {'email': area},
    );

    await connection.close();
    final count = results[0][0] as int;
    return count;
  }
  Future<int> countPendingCall(String value) async {
    var connection = await Database.connect();
    var today = DateTime.now().toString().split(" ")[0];
    var results = await connection.query("SELECT angaza_id FROM feedbackwhere promise_date >= @today",
        substitutionValues: {'today': today});
    var uniqueAngazaIds = <String>{};
    for (var row in results) {
      uniqueAngazaIds.add(row[0] as String);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('filteredTasks') ?? '[]';
    var area  =  prefs.getString('area');
    var country =  prefs.getString('country');

    var region = prefs.getString('region');
    var areaspace =area!.replaceAll(" ", "");
    List<String> targetArea = areaspace!.split(",");

    var dataList = jsonDecode(data);
    if(country == "India" || country == "Myanmar (Burma)"){

      var filteredTasks =  dataList.where((task) {
        return targetArea.contains(task['Area']);
      }
      ).toList();

      var postList =  uniqueAngazaIds.toSet();
      filteredTasks.removeWhere((element) => postList.contains(element["Angaza ID"]));
      // Extract the count from the query result.
      final count = filteredTasks.length;
      return count;
    }else{
      var filteredTasks =  dataList.where((task) => task['Area'] == area
      ).toList();

      var postList =  uniqueAngazaIds.toSet();
      filteredTasks.removeWhere((element) => postList.contains(element["Angaza ID"]));
      // Extract the count from the query result.
      final count = filteredTasks.length;
      return count;
    }

  }
  Future<int> countRestricted() async {
    final connection =   await Database.connect();
    // Get docs from collection reference
    const query = '''
    SELECT COUNT(*) 
    FROM ace_task 
    WHERE 
      "Current Area" = @area
  ''';
    final results = await connection.query(
      query,
      substitutionValues: {'area': await UserDetail().getUserArea()},
    );
    // Get data from docs and convert map to List
    await connection.close();

    // Extract the count from the query result.
    final count = results[0][0] as int;

    return count;
  }
  Future<int> countMoveOut() async {

    final connection =   await Database.connect();
    // Get docs from collection reference
    const query = '''
    SELECT COUNT(*) 
    FROM ace_task 
    WHERE 
      "Current Area" = @area
      AND "Move" = 'Move Out'
  ''';

    final results = await connection.query(
      query,
      substitutionValues: {'area': await UserDetail().getUserArea()},
    );
    // Get data from docs and convert map to List
    await connection.close();

    // Extract the count from the query result.
    final count = results[0][0] as int;

    return count;
  }
  Future<int> countMoveIn() async {

    final connection =   await Database.connect();
    // Get docs from collection reference
    const query = '''
    SELECT COUNT(*) 
    FROM ace_task 
    WHERE 
      "Current Area" = @area
      AND "Move" = 'Move In'
  ''';
    final results = await connection.query(
      query,
      substitutionValues: {'area': await UserDetail().getUserArea()},
    );

    // Get data from docs and convert map to List
    await connection.close();

    // Extract the count from the query result.
    final count = results[0][0] as int;

    return count;
  }
  Future<int> countCallMade(String value) async {
    final connection =   await Database.connect();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString("name");


    const query = '''
    SELECT COUNT(DISTINCT "angaza_id") 
    FROM feedback 
    WHERE 
      "user" = @user
      AND "status" = 'Complete'
      AND "task" = @task
  ''';
    final results = await connection.query(
      query,
      substitutionValues: {'user': currentUser, 'task': value},
    );
    await connection.close();

    // Extract the count from the query result.
    final count = results[0][0] as int;

    return count;
  }
  Future<int> countPendingVisit(String value) async {
    var connection = await Database.connect();
    var today = DateTime.now().toString().split(" ")[0];
    var results = await connection.query("SELECT angaza_id FROM feedback where promise_date >= @today",
        substitutionValues: {'today': today});
    var uniqueAngazaIds = <String>{};
    for (var row in results) {
      uniqueAngazaIds.add(row[0] as String);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('filteredTasks') ?? '[]';
    var area = prefs.getString('area')!;
    var dataList = jsonDecode(data);
    var country =  prefs.getString('country');
    var areaspace =area!.replaceAll(" ", "");
    List<String> targetArea = areaspace!.split(",");
    if(country == "India" || country == "Myanmar (Burma)"){
      var filteredTasks =  dataList.where((task) {
        return targetArea.contains(task['Area']);
      }
      ).toList();
      var postList =  uniqueAngazaIds.toSet();
      filteredTasks.removeWhere((element) => postList.contains(element["Angaza ID"]));
      final count = filteredTasks.length;
      return count;

    }else{
      var filteredTasks =  dataList.where((task) => task['Area'] == area
      ).toList();
      var postList =  uniqueAngazaIds.toSet();
      filteredTasks.removeWhere((element) => postList.contains(element["Angaza ID"]));
      final count = filteredTasks.length;
      return count;
    }

    // Get docs from collection reference

    // Extract the count from the query result.

  }
  Future<int> countVisitMade(String value) async {
    final connection =   await Database.connect();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString("name");
    const query = '''
    SELECT COUNT(*) 
    FROM feedback 
    WHERE 
      "user" = @user
      AND "status" = 'Complete'
      AND "task" = @task
  ''';
    // Get docs from collection reference
    final results = await connection.query(
      query,
      substitutionValues: {'user': currentUser, 'task': value},
    );
    // Get data from docs and convert map to List
    final count = results[0][0] as int;


    return count;

  }
  amount(String taskType)async{
    double total = 0.0;
    var querySnapshot = await calling.
    where('Area', isEqualTo: await UserDetail().getUserArea()).
    where('Task Type',isEqualTo: taskType).get();
    // Get data from docs and convert map to List
    querySnapshot.docs.forEach((element) {
      var fieldValue = element.data()['Amount Collected'];
      total = total + fieldValue;
    });
    return total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

  }
  amountCollected(String value) async {
    int total = 0;
   var area = await UserDetail().getUserArea().then((areaValue){
    return areaValue;
   });
   var query = await calling.
    where('Area', isEqualTo: area).
    where('Task Type',isEqualTo: value).get();
    query.docs.forEach((element) {
      int fieldValue = element.data()['Amount Collected'];
      total = total + fieldValue;
    });
    // Get data from docs and convert map to List
    return total;
  }
  Future<int> countComplete(String value) async {
    final connection =   await Database.connect();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString("name");

    const query = '''
    SELECT COUNT(*) 
    FROM feedback 
    WHERE 
      "user" = @user
      AND "status" = 'Complete'
      AND "task" = @task
  ''';
    // Get docs from collection reference
    final results = await connection.query(
      query,
      substitutionValues: {'user': currentUser, 'task': value},
    );
    // Get data from docs and convert map to List
    final count = results[0][0] as int;

    return count;
  }
  Future<int> countCompleteTask(String value) async {
    // Get docs from collection reference
    var querySnapshot = await feedback.
    where('Area', isEqualTo: await UserDetail().getUserArea()).
    where('Status', isEqualTo: 'Complete').
    where('Task Type',isEqualTo: value).get();
    // Get data from docs and convert map to List
    int allData = querySnapshot.size;
    return allData;
  }
  Future<int> countSucceful(String value) async {
    // Get docs from collection reference
    var querySnapshot = await calling.
    where('Area', isEqualTo: await UserDetail().getUserArea()).
    where('successfull', isEqualTo: 'Yes').
    where('Task Type',isEqualTo: value).get();
    // Get data from docs and convert map to List
    int allData = querySnapshot.size;
    return allData;
  }
  Future<String> completeCallRate(String value) async {

    int pending = await countPendingCall(value);
    int complete = await countCallMade(value);
    double rate  = (complete.toDouble()/(complete.toDouble()+pending.toDouble()))*100;
    return rate.toStringAsFixed(0)+"%";
  }
  Future<String> completeVistRate(String value) async {

    int pending = await countPendingVisit(value);
    int complete = await countVisitMade(value);
    double rate  = (complete.toDouble()/(complete.toDouble()+pending.toDouble()))*100;
    return rate.toStringAsFixed(0)+"%";
  }
    Future getDataByArea() async {
    // Get docs from collection reference
    return await calling.where('Area', isEqualTo: await UserDetail().getUserArea().snapshot());
    // Get data from docs and convert map to List
  }

}


GetAccountDetail() async{
  String username = 'dennis+angaza@greenlightplanet.com';
  String password = 'sunking';
  String basicAuth = 'Basic ${base64.encode(utf8.encode('$username:$password'))}';
  var headers = {
    "Accept": "application/json",
    "method":"GET",
    "Authorization": basicAuth,
    "account_qid" : "AC5156322",
  };
  var uri = Uri.parse('https://payg.angazadesign.com/data/accounts/AC7406321');
  var response = await http.get(uri, headers: headers);
  var data = json.decode(response.body);
  //print(data);
  return data["status"];
}
