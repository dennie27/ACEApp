// main.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:field_app/area/customer_visit.dart';
import 'package:field_app/services/user_detail.dart';
import 'package:call_log/call_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';

import '../widget/drop_down.dart';
import 'customer_profile.dart';

class AgentTask extends StatefulWidget {
  const AgentTask({Key? key}) : super(key: key);

  @override
  AgentTaskState createState() => AgentTaskState();
}

class AgentTaskState extends State<AgentTask> {
  bool visit = false;
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

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var currentUser = FirebaseAuth.instance.currentUser;
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
  void userArea() {
    UserDetail().getUserArea().then((value) {
      setState(() {
        Area = value;
      });
    });
  }

  String _searchQuery = '';
  List<DocumentSnapshot> _data = [];
  Future<void> _getDocuments() async {
    QuerySnapshot querySnapshot = await firestore
        .collection("new_calling")
        .where("Area", isEqualTo: await UserDetail().getUserArea())
        .where('Status', isNotEqualTo: 'Complete').get();
    setState(() {
      _data = querySnapshot.docs;
    });
  }

  Future<void> _getFilterdata(String task) async {
    QuerySnapshot querySnapshot = await firestore
        .collection("new_calling")
        .where("Area", isEqualTo: await UserDetail().getUserArea())
        .where('Status', isNotEqualTo: 'Complete')
        .where('Task', isEqualTo: task)
        .get();
    setState(() {
      _data = querySnapshot.docs;
      visit = false;
    });
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  void callLogs(String docid, String feedback, String angaza) async {
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
        "date": DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now()),
        "Task Type": "Call",
        "Status": "Complete",
        "Promise date": dateInputController.text,
      });
      CollectionReference feedBack = firestore.collection("FeedBack");
      await feedBack.add({
        "Angaza ID": angaza,
        "Duration": duration1update,
        "User UID": currentUser?.uid,
        "date": DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now()),
        "Task Type": "Call",
        "Status": "Complete",
        "Promise date": DateFormat('yyyy-MM-dd')
            .format(dateInputController.text as DateTime),
        "Feedback": feedback
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your call has been record successfull'),
        ),
      );
      return Navigator.of(context, rootNavigator: true).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'the call was not recorded as its not meet required duretion'),
        ),
      );
      return Navigator.of(context, rootNavigator: true).pop();
    }
  }

  String? feedbackselected;
  var feedback = [
    'Customer will pay',
    'System will be repossessed',
    'At the shop for replacement',
    'Product is with EO',
    'Not the owner',
  ];
  String? phoneselected;

  TextEditingController feedbackController = TextEditingController();
  TextEditingController dateInputController = TextEditingController();
  _callNumber(String phoneNumber, String docid, String angaza) async {
    List<String> phone = phoneNumber.split(',');
    final _formKey = GlobalKey<FormState>();
    phone = phone.toSet().toList();
    String txt = feedbackController.text;

    String _docid = docid;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
                title: Text('Customer Feedback'),
                content: SizedBox(
                    height: 500,
                    child: Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        AppDropDown(
                            disable: false,
                            label: 'Phone Number',
                            hint: 'Select Phone Number',
                            items: phone,
                            onChanged: (String value) async {
                              setState(() {
                                phoneselected = value;
                              });
                              await FlutterPhoneDirectCaller.callNumber(
                                  phoneselected!);
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                            isExpanded: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a feedback option';
                              }
                              return null;
                            },
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
                                child: Text(
                                  items,
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                feedbackselected = val!;
                              });
                            }),
                        TextFormField(
                          onChanged: (value) {
                            txt = value;
                          },
                          maxLines: 4,
                          validator: (value) {
                            if (txt.isEmpty) {
                              return 'Please fill additional feedback';
                            }
                            return null;
                          },
                          controller: feedbackController,
                          decoration: const InputDecoration(
                            labelText: 'Additional Feedback',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Date',
                            border: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue, width: 1)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue, width: 1)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue, width: 1)),
                          ),
                          controller: dateInputController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate:
                                DateTime.now().add( const Duration(days: 5)));

                            if (pickedDate != null) {
                              dateInputController.text = pickedDate.toString();
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
                                child:const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      phoneselected != null &&
                                      dateInputController.text != null) {
                                    callLogs(_docid, feedbackController.text,
                                        angaza);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                        Text("Please fill all the detail"),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Submit'),
                              ),
                            ])
                      ]),
                    ))),
          );
        });
  }

  bool isDescending = false;

  // This list holds the data for the list view

  @override
  initState() {
    // at the beginning, all users are shown
    userArea();
    _getDocuments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () => setState(() => isDescending = !isDescending),
                icon: Icon(
                  isDescending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 20,
                  color: Colors.yellow,
                ),
                splashColor: Colors.lightGreen,
              ),
            ),
            PopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 'All':
                    _getDocuments();

                    break;
                  case 'Call':

                    _getFilterdata('Call');
                    break;
                  case 'Disabled':

                    _getFilterdata('Disable');
                    break;
                  case 'Visit':
                    _getFilterdata('Visit');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem( value: "All", child: Text("All"), ),
                const PopupMenuItem( value: "Call",child: Text("Call"),),
                const PopupMenuItem(value: "Disabled",child: Text("Disabled"), ),
                const PopupMenuItem( value: "Visit",child: Text("Visit"),),
              ],
              icon: const Icon(Icons.filter_list_alt, color: Colors.yellow),
            ),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                    labelText: 'Search', suffixIcon: Icon(Icons.search)),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: _data.isEmpty
              ? ListView.separated(
            itemCount: _data.length,
            itemBuilder: (context, index) {
              DocumentSnapshot data = _data[index];
              String phoneList = '${data["Customer Phone Number"]},${data["Phone Number 1"].toString()},${data["Phone Number 2"].toString()},${data["Phone Number 3"].toString()},${data["Phone Number 4"].toString()},';
              if (data["Task"] == 'Visit') {
                visit = true;
              } else {
                visit = false;
              }
              if (_searchQuery.isNotEmpty &&
                  !_data[index]['Customer Name']
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())) {
                return const SizedBox();
              }
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CProfile(
                          id: data.id,
                          angaza: data['Angaza ID'],
                        ),
                      ));
                },
                key: ValueKey(_data[index]),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children:  [
                                Text(
                                  "Name:",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                ),
                                Text("Account:",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                Text("Product:",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                // Text("${account}"),
                              ],
                            ),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text("${data['Customer Name']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    )),
                                Text(
                                    data['Account Number'].toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    )),
                                Text("${data['Product Name']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    )),
                                // Text("${account}"),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            visit
                                ? IconButton(
                                padding:const  EdgeInsets.all(0.0),
                                onPressed: () {},
                                icon: Transform.rotate(
                                    angle: 90,
                                    child: const Icon(Icons.phone_disabled,
                                        size: 20.0)))
                                : IconButton(
                                padding: const  EdgeInsets.all(0.0),
                                onPressed: () {
                                  _callNumber(phoneList, data.id,
                                      data["Angaza ID"]);
                                },
                                icon: const Icon(Icons.phone, size: 20.0)),
                            IconButton(
                                padding: const  EdgeInsets.all(0.0),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomerVisit(
                                              id: data.id,
                                              angaza: data["Angaza ID"],
                                            ),
                                      ));
                                },
                                icon: const Icon(Icons.location_on_outlined,
                                    size: 20.0))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );

            },
            separatorBuilder: (BuildContext context, int index) =>
            const Divider(),
          )
              : const Text(
            'No results found',
            style: TextStyle(fontSize: 15),
          ),
        )
      ],
    );
  }
}
