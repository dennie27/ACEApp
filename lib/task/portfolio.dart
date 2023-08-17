import 'package:field_app/task_actions.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:field_app/widget/drop_down.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class Portfolio extends StatefulWidget {
  final Function(List?) onSave;
  final String? subtask;
  final String? area;

  Portfolio({this.area,required this.subtask,required this.onSave});
  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var currentUser = FirebaseAuth.instance.currentUser!.uid;
  List<String> _data = [];
  List? _mydata = [];
  initState() {
    print("Dennis ${widget.subtask}");
if(widget.subtask=='Work with the Agents with low welcome calls to improve'){
_getData();

}

    super.initState();
  }

  Future<void> _getData() async {

    QuerySnapshot querySnapshot =
    await firestore.collection("TZ_agent_welcome_call")
        .where("Area", isEqualTo:await widget.area)
        .get();
    setState(() {

      _data =querySnapshot.docs.map((doc) => "${doc["Agent"]} ${"-"} ${doc["Unreachabled rate within SLA"]}".toString()).toSet().toList();

    });
  }
  List<dynamic>? _myActivities;
  late String _myActivitiesResult;
  List? data =   [
  {
  "display": "Task 1",
  "value": "Task 1",
  },
  {
  "display": "Task 2",
  "value": "Task 2",
  },
  {
  "display": "Task 3",
  "value": "Task 3",
  },
  {
  "display": "Task 4",
  "value": "Task 4",
  },
  {
  "display": "Task 5",
  "value": "Task 5",
  },
  {
  "display": "Task 6",
  "value": "Task 6",
  },
  {
  "display": "Task 7",
  "value": "Task 7",
  },
  ];


  @override
  Widget build(BuildContext context) {
    String? _selectedValue;
    return Column(
      children: [
        SizedBox(height: 10,),
        if(widget.subtask == 'Visiting unreachable welcome call clients')
          AppMultselect(
            title: widget.subtask!,
            onSave: (value) {

              widget.onSave(value);
              if (value == null) return;

              widget.onSave(value);
            },
            items: data,


          ),
        if(widget.subtask == 'Work with the Agents with low welcome calls to improve')
          Column(
            children: [
              Text("Number of agent ${_data.length}"),
              MultiSelectFormField(
                textField: 'display',
                valueField: 'value',
                okButtonLabel: 'OK',
                cancelButtonLabel: 'CANCEL',
                hintWidget: Text('Please choose one or more'),
                title: Text(
                  "Portfolio",
                  style: TextStyle(fontSize: 16),
                ),
                onSaved: (value){
                  widget.onSave(value.map((option) => option.toString()).toList());
                },
                dataSource: _data.map((value) => {'display': value, 'value': value})
        .toList().cast<dynamic>()),

              /*AppMultselect(
                title: widget.subtask!,
                onSave: (value) {
                  _myActivities = value;
                },
                onChange:(value){
                  print(value);
                  setState(() {
                    _myActivities = value;
                  });
                  print(_myActivities);
                },
                items: _mydata,

              ),*/
            ],
          ),
        if(widget.subtask == 'Change a red zone CSAT area to orange')
          Column(
            children: [
              Text("Number of case ${data!.length}"),
              AppMultselect(
                title: widget.subtask!,
                onSave: (value) {
                  if (value == null) return;
                  widget.onSave(value);
                },
                items: data,


              ),
            ],
          ),
        if(widget.subtask == 'Attend to Fraud Cases')
          Column(
            children: [
              Text("Number of Fraud Case ${data!.length}"),
              AppMultselect(
                title: widget.subtask!,
                onSave: (value) {
                  if (value == null) return;
                  widget.onSave(value);
                },
                items: data,


              ),
            ],
          ),
        if(widget.subtask == 'Visit at-risk accounts')
          Container(

            child: Column(
              children: [
                Text("Number of accounts ${data!.length}"),
                AppMultselect(
                  title: widget.subtask!,
                  onSave: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                    setState(() {
                      _myActivities = value;
                    });

                  },
                  items: data,


                ),
                Text(_myActivities.toString())
              ],
            ),
          ),

        if(widget.subtask== 'Visits FPD/SPDs')
          Column(
            children: [
              Text("Number of accounts ${data!.length}"),
              AppMultselect(
                title: widget.subtask!,
                onSave: (value) {
                  if (value == null) return;
                  widget.onSave(value);
                },
                items: data,


              ),
            ],
          ),
        if(widget.subtask== 'Others')
          Column(
            children: [
              Text("Number of accounts ${data!.length}"),
              AppMultselect(
                title: widget.subtask!,
                onSave: (value) {
                  if (value == null) return;
                  widget.onSave(value);
                },
                items: data,


              ),
            ],
          ),
      ],
    );
  }
}


