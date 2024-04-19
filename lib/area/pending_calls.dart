import 'dart:convert';
import 'package:field_app/area/customer_visit.dart';
import 'package:call_log/call_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/db.dart';
import '../widget/drop_down.dart';
import 'customer_profile.dart';

class PendingCalls extends StatefulWidget {
  const PendingCalls({Key? key}) : super(key: key);

  @override
  PendingCallsState createState() => PendingCallsState();
}

class PendingCallsState extends State<PendingCalls> {
  String _searchText = '';
  bool visit = false;
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
  bool isLogin = true;
  String name = "";
  String region = '';
  String country = '';
  List? data = [];
  List? _data = [];
  String role = '';
  String area = '';
  bool isLoading = true;
  void userArea() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var login = prefs.get("isLogin");
    var task = prefs.get("filteredTasks");
    if (login == true) {
      setState(() {
        role = prefs.getString("role")!;
        name = prefs.getString("name")!;
        region = prefs.getString("region")!;
        country = prefs.getString("country")!;
      });
    }
  }

  String _searchQuery = '';
  Future<void> ACETask() async {
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
    var area = prefs.getString('area');
    var areaspace =area!.replaceAll(" ", "");
    List<String> targetArea = areaspace!.split(",");
    var dataList = jsonDecode(data);
    if(country == "India" || country == "Myanmar (Burma)"){

      var filteredTasks =  dataList.where((task) {
        return targetArea.contains(task['Area']);
      }
      ).toList();
      print(filteredTasks);
      var postList = uniqueAngazaIds.toSet();
      print(postList);
      filteredTasks.removeWhere((element) => postList.contains(element["Angaza ID"]));

      setState(() {
        _data = filteredTasks;
        isLoading = false;
      });
    }else{
      var filteredTasks = dataList.where((task) => task['Area'] == area ).toList();
      print(filteredTasks);
      var postList = uniqueAngazaIds.toSet();
      print(postList);
      filteredTasks
          .removeWhere((element) => postList.contains(element["Angaza ID"]));

      setState(() {
        _data = filteredTasks;
        isLoading = false;
      });
    }

  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  void callLogs(String feedback, String angaza, String reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
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

    if (duration1update >= 0) {
      var connection = await Database.connect();
      var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var col =
          '"angaza_id", "duration", "user", "date", "task", "status", "promise_date", "feedback","reason"';
      var value =
          "'$angaza','$duration1update','$name','$date','Call','Complete','$date','$feedback','$reason'";
      var result =
      await connection.query("INSERT INTO feedback ($col) VALUES ($value)");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your call has been record successfull'),
        ),
      );
      return Navigator.of(context, rootNavigator: true).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(
              AppLocalizations.of(context)!.not_record),
        ),
      );
      return Navigator.of(context, rootNavigator: true).pop();
    }
  }
  String? feedbackselected;
  String? phoneselected;
  var feedback = [
    'Customer will pay',
    'System will be repossessed',
    'At the shop for replacement',
    'Product is with EO',
    'Not the owner',
  ];

  TextEditingController feedbackController = TextEditingController();
  TextEditingController dateInputController = TextEditingController();
  _callNumber(String phoneNumber, String docid, String angaza) async {
    List<String> phone = phoneNumber.split(',');
    final _formKey = GlobalKey<FormState>();
    phone = phone.toSet().toList();
    String txt = feedbackController.text;
    String datetxt = dateInputController.text.toString();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
                title:  Text(AppLocalizations.of(context)!.customer_feedback),
                content: SizedBox(
                    height: 500,
                    child: Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        AppDropDown(
                            disable: false,
                            label: AppLocalizations.of(context)!.phonenumber,
                            hint: AppLocalizations.of(context)!.select_phonenumber,
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
                                return AppLocalizations.of(context)!.feedback_option;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              labelText: AppLocalizations.of(context)!.feedback,
                              border: const OutlineInputBorder(),
                              hintStyle: TextStyle(color: Colors.grey[800]),
                              hintText: AppLocalizations.of(context)!.name,
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
                            if (txt == null || txt.isEmpty) {
                              return AppLocalizations.of(context)!.fill_all;
                            }
                            return null;
                          },
                          controller: feedbackController,
                          decoration:  InputDecoration(
                            labelText: AppLocalizations.of(context)!.add_feedback,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration:  InputDecoration(
                            hintText: AppLocalizations.of(context)!.date,
                            border: const OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black, width: 1)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black, width: 1)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black, width: 1)),
                          ),
                          controller: dateInputController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 5)));

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
                                child:  Text(AppLocalizations.of(context)!.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      phoneselected != null &&
                                      dateInputController.text != null) {
                                    callLogs( feedbackController.text,
                                        angaza, feedbackselected!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(
                                        content:
                                        Text(AppLocalizations.of(context)!.fill_all),
                                      ),
                                    );
                                  }
                                },
                                child:  Text(AppLocalizations.of(context)!.submit),
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
  void initState() {
    super.initState();
    userArea();
    ACETask();
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
                    break;
                  case 'Call':
                    break;
                  case 'Disabled':
                    break;
                  case 'Visit':
                    break;
                }
              },
              itemBuilder: (context) => [
                 PopupMenuItem(
                  value: "All",
                  child: Text(AppLocalizations.of(context)!.all),
                ),
                 PopupMenuItem(
                  value: "Call",
                  child: Text(AppLocalizations.of(context)!.call),
                ),
                 PopupMenuItem(
                  value: "Disabled",
                  child: Text(AppLocalizations.of(context)!.disabled),
                ),
                 PopupMenuItem(
                  value: "Visit",
                  child: Text(AppLocalizations.of(context)!.visit),
                ),
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
                decoration:  InputDecoration(
                    labelText: AppLocalizations.of(context)!.search, suffixIcon: Icon(Icons.search)),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: _data!.isNotEmpty
              ? ListView.separated(
            itemCount: _data!.length,
            itemBuilder: (context, index) {
              var data = _data![index];
              String phoneList =
                  '${data["Customer Phone Number"]},${data["Phone Number 1"].toString()},${data["Phone Number 2"].toString()},${data["Phone Number 3"].toString()},${data["Phone Number 4"].toString()},';
              if (data["Task"] == 'Visit') {
                visit = true;
              } else {
                visit = false;
              }
              if (_searchQuery.isNotEmpty &&
                  !_data![index]['Customer Name']
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
                          id: data['Angaza ID'],
                          angaza: data['Angaza ID'],
                        ),
                      ));
                },
                key: ValueKey(_data![index]),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                             Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                ),
                                Text(AppLocalizations.of(context)!.account,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                Text(AppLocalizations.of(context)!.product,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                Text(AppLocalizations.of(context)!.area,
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
                                Text(data['Account Number'].toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    )),
                                Text("${data['Product Name']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    )),
                                Text("${data['Area']}",
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
                                padding: const EdgeInsets.all(0.0),
                                onPressed: () {},
                                icon: Transform.rotate(
                                    angle: 90,
                                    child: const Icon(
                                        Icons.phone_disabled,
                                        size: 20.0)))
                                : IconButton(
                                padding: const EdgeInsets.all(0.0),
                                onPressed: () {
                                  _callNumber(
                                      phoneList,
                                      data["Angaza ID"],
                                      data["Angaza ID"]);

                                  /* _callNumber(phoneList, data["Angaza ID"],
                                                data["Angaza ID"]);*/
                                },
                                icon: const Icon(Icons.phone,
                                    size: 20.0)),
                            if (data['Location Latitudelongitude'] ==
                                null ||
                                data['Location Latitudelongitude'] == "")
                              IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: () {},
                                  icon: const Icon(Icons.location_off,
                                      size: 20.0)),
                            if (data['Location Latitudelongitude'] != "")
                              IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerVisit(
                                                id: data["Angaza ID"],
                                                angaza: data["Angaza ID"],
                                              ),
                                        ));
                                  },
                                  icon: const Icon(
                                      Icons.location_on_outlined,
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
              :  Text(
            AppLocalizations.of(context)!.no_results,
            style: const TextStyle(fontSize: 15),
          ),
        )
      ],
    );
  }
}