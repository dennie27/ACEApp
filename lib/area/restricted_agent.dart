
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../services/user_detail.dart';
class RestrictedTask extends StatefulWidget {
  @override
  RestrictedTaskState createState() => new RestrictedTaskState();
}
class RestrictedTaskState extends State<RestrictedTask> {
  List data =[];
  final List<Map<String, dynamic>> _allUsers = [
    {"id": 1, "name": "Abdallah", "region":"Northern", "task":"High Risk Agent - Stock","area":"Kahama"},
    {"id": 2, "name": "Dennis", "region":"South", "task":"Restricted","area":"Arusha"},
    {"id": 3, "name": "Jackson", "region":"Coast", "task":"Restricted EO","area":"Mwanza"},
    {"id": 4, "name": "Barbara","region":"Central", "task":"Restricted Agents - Phone","area":"Mbeya"},
    {"id": 5, "name": "Candy", "region":"West", "task":"Monthly Sales Restriction","area":"Tanga"},

  ];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _data = [];
  bool isDescending =false;
  Future<void> _getDocuments() async {
    QuerySnapshot querySnapshot = await firestore
        .collection("agent_restricted").where("Current Area", isEqualTo: await UserDetail().getUserArea())
        .get();
    setState(() {

      _data = querySnapshot.docs;
      print(_data);
    });
  }


  void _nameFilter(String _status) {
    List<Map<String, dynamic>> results = [];
    switch(_status) {

      case "Abdallah": { results = _allUsers.where((user) =>
          user["name"].toLowerCase().contains(_status.toLowerCase()))
          .toList(); }
      break;

      case "Dennis": {  results = _allUsers
          .where((user) =>
          user["name"].toLowerCase().contains(_status.toLowerCase()))
          .toList(); }
      break;

      case "Jackson": {  results = _allUsers
          .where((user) =>
          user["name"].toLowerCase().contains(_status.toLowerCase()))
          .toList(); }
      break;
      case "zainab": {  results = _allUsers
          .where((user) =>
          user["name"].toLowerCase().contains(_status.toLowerCase()))
          .toList(); }
      break;
      case "Candy": {  results = _allUsers
          .where((user) =>
          user["name"].toLowerCase().contains(_status.toLowerCase()))
          .toList(); }
      break;
      case "All": {  results = _allUsers; }
    }


    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }
  List<Map<String, dynamic>> _foundUsers = [];
  @override
  void initState(){
    _getDocuments();
    _foundUsers = _allUsers;
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Restricted Agent"),
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () =>
                        setState(() => isDescending = !isDescending),
                    icon: Icon(
                      isDescending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 20,
                      color: Colors.yellow,
                    ),
                    splashColor: Colors.lightGreen,
                  ),
                ),
                PopupMenuButton(
                  onSelected:(reslust) =>_nameFilter(reslust),
                  itemBuilder: (context) => [

                    PopupMenuItem(
                        child: Text("All"),
                        value: "All"
                    ),
                    PopupMenuItem(
                        child: Text("Abdallah"),
                        value: "Abdallah"
                    ),
                    PopupMenuItem(
                        child: Text("Dennis"),
                        value: "Dennis"
                    ),
                    PopupMenuItem(
                        child: Text("Jackson"),
                        value: "Jackson"
                    ),
                    PopupMenuItem(
                        child: Text("Zainab"),
                        value: "zainab"
                    ),
                    //mewnu
                    PopupMenuItem(child: Text("Candy"),
                        value: "Candy"
                    )
                  ],
                  icon: Icon(
                      Icons.filter_list_alt,color: Colors.yellow
                  ),

                )
              ],
            )


          ],
        ),
        Expanded(child: ListView.builder(
          itemCount: _data.length,

          itemBuilder: (context, index) {
            DocumentSnapshot data = _data[index];

            final sortedItems = _data
              ..sort((item1, item2) => isDescending
                  ? item2['User'].compareTo(item1['User'])
                  : item1['User'].compareTo(item2['User']));
            return Container(
              margin: EdgeInsets.all(5),
              child: InkWell(
                onTap: (){
                },
                child:Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.amber.shade800,
                      radius:35,
                      child: Text(data['User'][0]),),
                    SizedBox(width: 10,),
                    Flexible(
                      child: Container(
                        width: 350,
                        height: 90,
                        child: Card(
                          elevation: 5,

                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10.0,5,0,0),
                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Name: ${data['User']}"),
                                Text("Current Role: ${data['Role']}"),
                                Text("Username: ${data['Username']}"),
                                Text("Phone Number: ${data['Primary Phone Number']}")

                              ],
                            ),
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              ),
            );
          },
        ))
      ],
    );
  }
}

class MySource extends DataTableSource {
  List value;
  MySource(this.value) {
    print(value);
  }
  @override
  DataRow getRow(int index) {
    // TODO: implement getRow
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(value[index]["id"].toString())),
        DataCell(Text(value[index]["task_title"].toString())),
        DataCell(Text(value[index]["task_status"].toString())),
        DataCell(Text(value[index]["task_start_date"].toString())),
        DataCell(InkWell(
          onTap:(){
            //fill the form above the table and after user fill it, the data inside the table will be refreshed
          },
          child: Text("Click"),
        ),),
      ],);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => value.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount =>0;
}
/* ListTile(
          title:
          leading:
          ),
        )*/