import 'dart:convert';
import 'dart:core';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:field_app/area/pending_calls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'complete_calls.dart';

class Customer extends StatefulWidget {
  const Customer({Key? key}) : super(key: key);
  @override
  CustomerState createState() => CustomerState();
}

class CustomerState extends State<Customer> {
  bool isDescending = false;
  bool isLoading = false;
  String name ="";
  String region = '';
  String country ='';
  List? data = [];
  String role = '';
  String area = '';
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
        ACETask(latestFile.key);
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
  Future<void> ACETask(key) async {
    List<String> uniqueRegion = [];
    print("object: $key");


    try {

      StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
          key: key)
          .result;

      final response = await http.get(urlResult.url);
      final jsonData = jsonDecode(response.body);
      print('File Data: $jsonData');
      final List<dynamic> filteredTasks = jsonData
          .where((task) => task['Area'] == area &&
          task['Country'] == country
      ).toList();
      print(filteredTasks.length);

      for (var item in filteredTasks) {
        //String region = item['Region'];
        //region?.add(region);
        if(item['Region'] == null){
        }else{
          uniqueRegion.add(item['Region']);
        }

      }
      setState(() {

        data = filteredTasks;
        isLoading = false;


      });
    } on StorageException catch (e) {
      safePrint('Could not retrieve properties: ${e.message}');
      rethrow;
    }
  }
  bool isLogin = true;
  void userArea() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var login  = prefs.get("isLogin");
    if(login == true){
      setState(() {
        isLogin = false;
        role = prefs.getString("role")!;
        name = prefs.getString("name")!;
        region = prefs.getString("region")!;
        country = prefs.getString("country")!;
      });
    }
  }

  @override
  initState() {
    // at the beginning, all users are shown
    userArea();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return isLogin?const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Hi! Welcome"),
        Text("You are new user please contact the admin")
      ],
    ):DefaultTabController(
      length: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const TabBar(tabs: [
            Tab(
              text: "Pending ",
            ),
            Tab(text: "Completed"),
            //Tab(text: "Agent"),
          ]),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(5),
              child: const TabBarView(
                children: [
                  PendingCalls(),
                  CompleteCalls(),
                  //AgentTask(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
