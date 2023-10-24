import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:call_log/call_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/db.dart';
import '../widget/drop_down.dart';
import 'customer_visit.dart';

class CProfile extends StatefulWidget {
  final String id;
  final angaza;
  const CProfile({Key? key, required this.id,required this.angaza}) : super(key: key);

  @override
  CProfileState createState() => CProfileState();

}

class CProfileState extends State<CProfile> {
  var fnumberupdate;
  var cmnumberupdate;
  var number1update;
  var name1update;
  var calltypeupdate;
  var timedateupdate;
  var duration1update;
  var accidupdate;
  var simnameupdate;
  String? Status;
  String? Area;
  void callLogs(String docid,String feedback,String angaza) async {
    String _docid = docid;

    Iterable<CallLogEntry> entries = await CallLog.get();
    fnumberupdate = entries.elementAt(0).formattedNumber;
    cmnumberupdate = entries.elementAt(0).cachedMatchedNumber;
    number1update = entries.elementAt(0).number;
    name1update = entries.elementAt(0).name;
    calltypeupdate = entries.elementAt(0).callType;
    timedateupdate = entries.elementAt(0).timestamp;
    duration1update = entries.elementAt(0).duration;
    accidupdate = entries.elementAt(0).phoneAccountId;
    simnameupdate = entries.elementAt(0).simDisplayName;


    if (duration1update >= 30) {
      CollectionReference newCalling = firestore.collection("new_calling");
      await newCalling.doc(_docid).update({
        'Duration': duration1update,
        'ACE Name': currentUser?.displayName,
        "User UID": currentUser?.uid,
        "date": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
        "Task Type": "Call",
        "Status": "Complete",
        "Promise date": dateInputController.text,
      });
      CollectionReference feedBack = firestore.collection("FeedBack");
      await feedBack.add({
        "Angaza ID":angaza,
        "Duration": duration1update,
        "User UID": currentUser?.uid,
        "date": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
        "Task Type": "Call",
        "Status": "Complete",
        "Promise date": dateInputController.text,
        "Feedback":feedback
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your call has been record successful'),
        ),
      );
      return Navigator.of(context, rootNavigator: true).pop();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text('the call was not recorded as its not meet required duretion'),
        ),
      );
      return Navigator.of(context, rootNavigator: true).pop();

    }
  }
  String role = '';
  String area = '';
  String name ="";
  String region = '';
  String country ='';
  List? data = [];
  List? _data = [];
  void userArea() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var login  = prefs.get("isLogin");
    if(login == true){
      setState(() {
        role = prefs.getString("role")!;
        area = prefs.getString("area")!;
        name = prefs.getString("name")!;
        region = prefs.getString("region")!;
        country = prefs.getString("country")!;
      });
    }
  }
  Future<StorageItem?> listItems(key,account) async {
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
        ACETask(latestFile.key,account);

        return resultList.first;
      } else {

        return null;
      }
    } on StorageException catch (e) {
      safePrint('Error listing items: $e');
    }
  }
  Future<void> ACETask(key,account) async {
    var connection = await Database.connect();
    var results = await connection.query("SELECT * FROM feedback WHERE angaza_id = @angaza_id",
       substitutionValues: {"angaza_id":account});
    List<String> uniquearea = [];



    try {

      StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
          key: key)
          .result;
      final response = await http.get(urlResult.url);
      final jsonData = jsonDecode(response.body);

      final List<dynamic> filteredTasks = jsonData
          .where((task) => task['Area'] == area && task['Angaza ID'] == account
      ).toList();

      setState(() {
        _data = filteredTasks;
        data = results;
        isLoading = true;
      });
    } on StorageException catch (e) {
      safePrint('Could not retrieve properties: ${e.message}');
      rethrow;
    }
  }
  String? feedbackselected;
  var feedback = [
    'Customer will pay',
    'system will be repossessed',
    'at the shop for replacement',
    'Product is with EO',
    'not the owner',
  ];
  String? phoneselected;
  bool  isLoading = false;
  TextEditingController feedbackController = TextEditingController();
  TextEditingController dateInputController = TextEditingController();
  _callNumber(String phoneNumber, String docid,String angaza) async {
    List<String> phone = phoneNumber.split(',');
    phone  = phone.toSet().toList();


    String _docid = docid;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
                title: const Text('Customer Feedback'),
                content: SizedBox(
                    height: 400,
                    child: Column(children: <Widget>[
                      AppDropDown(
                        disable: false,
                          label: 'Phone Number',
                          hint: 'Select Phone Number',
                          items: phone,
                          onChanged: (String value) async {
                            setState((){
                              phoneselected = value;
                            });
                            await FlutterPhoneDirectCaller.callNumber(phoneselected!);
                          }),
                      const SizedBox(height: 10,),
                      DropdownButtonFormField(
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: "feedback",
                            border: const OutlineInputBorder(),
                            hintStyle: TextStyle(color: Colors.grey[800]),
                            hintText: "Name",
                          ),
                          items: feedback.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items,overflow: TextOverflow.clip, maxLines: 2,),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              feedbackselected = val!;
                            });
                          }),
                      TextField(
                        maxLines: 4,
                        controller: feedbackController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Feedback',
                        ),
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Date',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 1)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 1)),
                        ),
                        controller: dateInputController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 5)));

                          if (pickedDate != null) {
                            dateInputController.text =pickedDate.toString();
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                callLogs(_docid,feedbackController.text,angaza);
                              },
                              child:const  Text('Submit'),
                            ),
                          ])
                    ]))),
          );
        });
  }


  void initState() {

    super.initState();
    listItems("ACE_Data", widget.angaza);
  }
  getPhoto(String client) async {

    String username = 'dennis+angaza@greenlightplanet.com';
    String password = 'sunking';
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    var headers = {
      "Accept": "application/json",
      "method": "GET",
      "Authorization": basicAuth,
      "account_qid": "AC5156322",
    };
    var uri = Uri.parse('https://payg.angazadesign.com/data/clients/$client');
    var response = await http.get(uri, headers: headers);
    var body = json.decode(response.body);
    var attribute = body["attribute_values"];
    List<Map<String, dynamic>> attributes =
        attribute.cast<Map<String, dynamic>>();
    String photo = attributes
        .firstWhere((attr) => attr['name'] == 'Client Photo')['value'];
    return photo;
  }

  getAccountData(String angazaid) async {

    String username = 'dennis+angaza@greenlightplanet.com';
    String password = 'sunking';
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    var headers = {
      "Accept": "application/json",
      "method":"GET",
      "Authorization": basicAuth,
      "account_qid" : "AC5156322",
    };
    var uri = Uri.parse('https://payg.angazadesign.com/data/accounts/$angazaid');
    var response = await http.get(uri, headers: headers);

    var data = json.decode(response.body);
    var id = data['client_qids'][0];

    var uriphoto = Uri.parse('https://payg.angazadesign.com/data/clients/$id');
    var responsephoto = await http.get(uriphoto, headers: headers);

    var bodyphoto = json.decode(responsephoto.body);

    var attribute = bodyphoto["attribute_values"];


    List<Map<String, dynamic>> attributes =
    attribute.cast<Map<String, dynamic>>();

    String photo = attributes
        .firstWhere((attr) => attr['name'] == 'Client Photo')['value'];
    return photo;
  }
  var currentUser = FirebaseAuth.instance.currentUser;
  bool onclick = false;
  final querySnapshot =
      FirebaseFirestore.instance.collection('new_calling').doc().get();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
            child:isLoading? Column(
                children: [
                  Center(
                      child: FutureBuilder<dynamic>(
                          future: getAccountData(widget.angaza),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> photourl) {
                            if (photourl.hasData) {
                              String photo = photourl.data!;
                              return Container(
                                margin:const  EdgeInsets.fromLTRB(0, 20, 0, 0),
                                width: 150.0,
                                height: 150.0,
                                color: Colors.grey.withOpacity(0.3),
                                child: Center(child: Image.network(photo)),
                              );
                            } else if (photourl.hasError) {
                              return
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  width: 150.0,
                                  height: 150.0,
                                  color: Colors.grey.withOpacity(0.3),
                                  child: const Center(child: Icon(Icons.person)),
                                )
                              ;
                            } else {
                              return const CircularProgressIndicator();
                            }
                          })),
                        Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name:',
                                        style: TextStyle(fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text('Account:',
                                        style: TextStyle(fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_data![0]['Customer Name'],
                                        style: const TextStyle(fontSize: 20)),
                                    Text(_data![0]['Account Number'],
                                        style: const TextStyle(fontSize: 20)),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _callNumber(
                                        "phoneList",
                                       " data.id",
                                        'data["Angaza ID"]'
                                    );
                                  },
                                  child: Text(
                                    _data![0]['Customer Phone Number'],
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const CustomerVisit(id: "id",
                                                  angaza: "Angaza ID",
                                                ),
                                          ));
                                    },
                                    child: Text(_data![0]['Area'].toString(),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black))),
                              ],
                            ),
                            const Card(
                              shadowColor: Colors.amber,
                              color: Colors.black,
                              child: ListTile(
                                title: Center(
                                    child: Text("Account Detail",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.yellow))),
                                dense: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text('Agent Name: ',
                                          style: TextStyle(fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        'Agent Username: ',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Registration Date: ',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Product Name: ',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Is FPD: ',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('Amount to Collect: ',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),),
                                      Text('Amount Collected: ',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),),

                                      Text('Promise date: ',
                                          style: TextStyle(fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(_data![0]['Responsible User'].split('(')[0],
                                          style: const TextStyle(fontSize: 15)),
                                      Text(
                                        _data![0]['Responsible User'].split('(')[1].replaceAll(')', ''),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                          _data![0]['Date of Registration Date']
                                      ),

                                      const Text(
                                        'Product Name',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        _data![0]['Is First Pay Defaulted V2 (Yes / No)'],
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      Text(_data![0]['Amount Payable to Exit Risk Permanently RT'],
                                          style: const TextStyle(fontSize: 15)),
                                      const  Text('Amount Collected',
                                          style: TextStyle(fontSize: 15)),

                                      const  Text('Promise date',
                                          style: TextStyle(fontSize: 15)),
                                    ],
                                  )
                                ],
                              ),
                            ),


                            const SizedBox(
                              height: 10,
                            ),

                          ],
                        ),
                  const Card(
                    shadowColor: Colors.amber,
                    color: Colors.black,
                    child: ListTile(
                      title: Center(
                          child: Text("Call History",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.yellow))),
                      dense: true,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "No.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text("Task Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          )),
                      Text("Date Completed",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ))
                    ],
                  ),
                  SizedBox(
                      height: 300,
                      child:
                      ListView.separated(
                          itemCount: data!.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return CustomFeedBack(
                              serial: index + 1,
                              feedback: data![0][3].toString(),
                              task:data![0][8].toString(),
                              date: data![0][10].toString().split(' ')[0],

                            );
                          })
                  )
                ]):const Center(child: CircularProgressIndicator(

            ),)
        )
    );
  }
}

class CustomFeedBack extends StatefulWidget {
  final int serial;
  final String feedback;
  final String task;
  final String date;

  const CustomFeedBack({Key? key,required this.serial, required this.feedback,required this.task,required this.date}) : super(key: key);

  @override
  CustomFeedBackState createState() => CustomFeedBackState();
}

class CustomFeedBackState extends State<CustomFeedBack> {
  bool _showContainer = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _showContainer = !_showContainer;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text((widget.serial).toString()),
                Text(widget.task),
                Text(widget.date.toString()),
              ],
            ),
          ),
          _showContainer
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Feedback: ${widget.feedback}!',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
/*
InkWell(
                            onTap: (){
    setState(() {
      onclick = true;
      print(index);
    });
                            },
                            child: Container(
                              margin: EdgeInsets.all(5),
                              height: onclick?50:20,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text((index+1).toString()),
                                      Text("Visit"),
                                      Text("10/${index.toString()}")
                                    ],
                                  ),
                                  onclick?Text("data"):Spacer()
                                ],
                              ),
                            ),
                          )
 */
