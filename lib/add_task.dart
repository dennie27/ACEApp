import 'package:field_app/routing/bottom_nav.dart';
import 'package:field_app/task.dart';
import 'package:field_app/task/collection.dart';
import 'package:field_app/task/pilot_process.dart';
import 'package:field_app/task/portfolio.dart';
import 'package:field_app/task/team.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:field_app/widget/drop_down.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'task/customer.dart';

class AddTask extends StatefulWidget {
  @override
  _StepFormState createState() => _StepFormState();
}

class _StepFormState extends State<AddTask> {
  var caseselected;
  var customerselected;
  List<TextEditingController> _controllers = [];
  formPost() async {
    CollectionReference task = firestore.collection("task");
    var currentUser = FirebaseAuth.instance.currentUser;
    await task.add({
      "task_title": selectedTask,
      "User UID": currentUser?.uid,
      "sub_task": selectedSubTask,
      "task_description": _text.text.toString(),
      "process_audit":"",
      "task_start_date":  DateTime.now(),
      "task_end_date": DateTime.now(),
      "task_status": "Pending",
      "task_with": agentselected,
      "task_area": areaselected.toString(),
      "task_region": regionselected,
      "submited_by":currentUser?.displayName ,
      "case_name":caseselected,
      "Customer": customerselected,
      "submited_role": null,
      "task_country": "Tanzania",
      "priority": priority,
      "timestamp": DateTime.now(),
      "is_approved": "pending"
    }
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Task()),
    );

    /* Map data = {
        'task_title': _myActivitiesResult.toString().replaceAll("(^\\[|\\]", ""),
        'sub_task': _subtaskResult,
        'task_region': _regionResult,
        'task_area': _areaResult,
        'priority': priority.toString(),
        'task_with': _userRoleResult,
        'task_description': 'Testing',
        'task_start_date': '2022-11-04',
        'task_end_date': '2022-11-09',
        'task_status': 'Pending',
        'submited_by': 'Dennis',
        'timestamp': '23454',
        'is_approved': 'No'
      };
      var body = json.encode(data);
      var url = Uri.parse('https://sun-kingfieldapp.herokuapp.com/api/create');
      http.Response response = await http.post(url, body: body, headers: {
        "Content-Type": "application/json",
      });
      print(response.body);*/
  }


  late String _myActivitiesResult;
  bool _validate = false;
  List? _myActivities;
  late bool laststep;
  final _text = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _myActivities = [];
    _myActivitiesResult = '';
    laststep = false;
  }

  _saveForm() {
    var form = _formKey.currentState!;
    if (form.validate()) {
      print(_myActivities);
      form.save();
      setState(() {
        _myActivitiesResult = _myActivities.toString();
        items1 = _myActivities!.toList();
        int? num = _myActivities?.toList().length;
        print(items1?.length);
        for (int i = 0; i < items1!.toString().length; i++) {
          print(items1?[i]);
        }
      });
    }
  }

  int _currentStep = 0;
  String? selectedTask;
  String? selectedSubTask;
  String? regionselected;
  String? areaselected;
  String? agentselected;
  String? priority;
  String? target;
  List? items1;
  List<String> priortySelected = [];
  StepperType stepperType = StepperType.vertical;
  bool _isSelected = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var currentUser = FirebaseAuth.instance.currentUser;

  Widget build(BuildContext context) {
    List<Step> stepList() => [
      Step(title: Text('Location'), content: LocationForm(
        onregionselected: (value) {
          regionselected = value;
        },
        onareaselected: (value) {
          areaselected = value;
        },) ),
      Step(title: Text('Task'),content: TaskForm(
        onTask: (value) {
          selectedTask = value;
        },
        taskResult: (value){
          _myActivities = value;
        },
        onSubTask: (value) {
          selectedSubTask = value;
        },
      ),),
      Step(title: Text('Task Action '),content: Container(
        height:600,
        child: ListView.builder(
          itemCount: _myActivities!.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  SizedBox(height: 10,),
                AppDropDown(
                  disable: false,
                items: ['1%', '2%', '3%', '4%','5%'],
                  label: _myActivities![index],
                  hint: selectedSubTask,
                  onChanged: (String? value ) {
                  target = value;
                  },
              ),
                  Row(
                    children: [

                      Expanded(
                        child: RadioListTile(
                          contentPadding: EdgeInsets.all(0.0),
                          title: const Text("High"),
                          value: "high${index}",
                          dense: true,
                          groupValue: "priority${index}",
                          onChanged: (value) {
                            setState(() {

                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          contentPadding: EdgeInsets.all(0.0),
                          title: Text("Normal"),
                          value: "normal${index}",
                          dense: true,
                          groupValue: "priority${index}",
                          onChanged: (value) {
                            setState(() {

                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          contentPadding: EdgeInsets.all(0.0),
                          title: Text("Low"),
                          value: "low${index}",
                          dense: true,
                          groupValue: "priority${index}",
                          onChanged: (value) {
                            setState(() {

                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      controller: _text,
                      maxLines: 5,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: AppColor.mycolor, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black12, width: 1.0),
                        ),
                        errorText: _validate ? 'Value Can\'t Be Empty' : null,
                        labelText: 'Describe the task',
                      )),
                ],
              );
            }),


      )),
      Step(title: Text('Confirm details'),content: Column(
        children: [
          Text(regionselected??""),
          Text(areaselected??''),
          Text(selectedTask??''),
          Text(selectedSubTask??''),
          Text(_myActivities.toString()),
          Text(target??'')
          
        ],
      ))
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new task"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
            child: Column(
              children: [
                Expanded(
                    child: Stepper(
                        type: stepperType,
                        physics: ScrollPhysics(),
                        currentStep: _currentStep,
                        onStepTapped: (int index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                        onStepContinue: () {
                          if (_currentStep < (stepList().length)) {
                            setState(() {

                              _currentStep += 1;
                              _isSelected = false;
                              if (_currentStep == (stepList().length - 1)) {
                                laststep = true;

                              } else {
                                laststep = false;
                                _isSelected = false;
                              }
                            });
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep == 0) {

                            return;
                          }
                          setState(() {
                            _currentStep -= 1;

                            laststep = false;
                          });
                        },
                        controlsBuilder:
                            (BuildContext context, ControlsDetails details) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: laststep
                                ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      formPost();
                                      _formKey.currentState?.save();
                                      print("# $_myActivities");

                                    },
                                    child:const Text('Submit'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text('Back'),
                                  ),
                                ),
                              ],
                            )
                                : Row(
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: details.onStepContinue,
                                    child: const Text('Next'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text('Back'),
                                  ),
                                ),
                              ],
                            ),
                          ); /*Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              child: Text('Continue'),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepCancel,
                              child: Text('Back'),
                            ),
                          ),
                        ],
                      );*/
                        },
                        steps: stepList()))
              ],
            )),
      ),
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }
}
class LocationForm extends StatefulWidget {
  final Function(String) onregionselected;
  final Function(String) onareaselected;
  const LocationForm({super.key, required this.onregionselected,required this.onareaselected});

  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {


  String? regionselected;
  String? areaselected;
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var currentUser = FirebaseAuth.instance.currentUser;
    return Column(children: <Widget>[
      SizedBox(
        height: 10,
      ),
      StreamBuilder(
          stream: firestore
              .collection("Users")
              .where('UID', isEqualTo: currentUser!.uid)
              .get()
              .asStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            List<String> region = List.generate(snapshot.data!.size, (index) {
              DocumentSnapshot data = snapshot.data!.docs[index];
              return data['Region'].toString();
            }).toSet().toList();
            if (snapshot.hasData) {
              return AppDropDown(
                disable: false,
                label: 'Region',
                hint: 'Select Region',
                items: region ?? [],
                onChanged: (String value) {
                  widget.onregionselected(value!);
                },
                onSave: (value) {
                  widget.onregionselected(value!);
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
      SizedBox(
        height: 10,
      ),
      StreamBuilder(
          stream: firestore
              .collection("TZ_agent_welcome_call")
              .where('Region', isEqualTo: "Lake Zone")
              .get()
              .asStream(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              List<String> area = List.generate(snapshot.data!.size, (index) {
                DocumentSnapshot data = snapshot.data!.docs[index];
                return data['Area'].toString();
              }).toSet().toList();
              return AppDropDown(
                disable: false,
                label: 'Area',
                hint: 'Select Area',
                items: area ?? [],
                onChanged: (String value) {
                  widget.onareaselected(value!);
                },
                onSave: (value) {
                  widget.onareaselected(value!);
                },
              );
            }
            return CircularProgressIndicator();
          }),
    ]);
  }
}

class TaskForm extends StatefulWidget {
  final Function(String) onTask;
  final Function(String) onSubTask;
  final Function(List?) taskResult;
  TaskForm({required this.onTask,required this.onSubTask, required this.taskResult});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  String? selectedTask;

  String? selectedSubTask;

  bool _isSelected = false;
  onTaskChanged(value) {
    setState(() {
      print(value);
      selectedTask= value;
      _isSelected = true;
    });
  }

  late Map<String, List<String>> dataTask = {
    'Portfolio Quality': portfolio,
    'Team Management': team,
    'Collection Drive': collection,
    'Pilot/Process Management': pilot,
    'Customer Management': customer,
  };


  final List<String> Task = [
    'Portfolio Quality',
    'Team Management',
    'Collection Drive',
    'Pilot/Process Management',
    'Customer Management',
  ];

  final List<String> portfolio = [
    'Visiting unreachable welcome call clients',
    'Work with the Agents with low welcome calls to improve',
    'Change a red zone CSAT area to orange',
    'Attend to Fraud Cases',
    'Visit at-risk accounts',
    'Visits FPD/SPDs',
    'Other'
  ];

  final List<String> customer = [
    'Visiting of issues raised',
    'Repossession of customers needing repossession',
    'Look at the number of replacements pending at the shops',
    'Look at the number of repossession pending at the shops',
    'Other - Please Expound'
  ];

  final List<String> pilot = [
    'Conduct the process audit',
    'Conduct a pilot audit',
    'Testing the GPS accuracy of units submitted',
    'Reselling of repossessed units',
    'Repossessing qualified units for Repo and Resale',
    'Increase the Kazi Visit Percentage',
    'Other'
  ];

  final List<String> collection = [
    'Field Visits with low-performing Agents in Collection Score',
    'Repossession of accounts above 180',
    'Visits Tampering Home 400',
    'Work with restricted Agents',
    'Calling of special book',
    'Sending SMS to clients',
    'Table Meeting/ Collection Sensitization Training',
    'Others'
  ];

  final List<String> team = [
    'Assist a team member to improve the completion rate',
    'Raise a reminder to a team member',
    'Raise a warning to a team member',
    'Raise a new task to a team member',
    'Inform the team member of your next visit to his area, and planning needed',
    'Other'
  ];
  List _myActivities = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DropdownButtonFormField<String?>(
          value: selectedTask,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Task Title",
            border: OutlineInputBorder(),
            hintStyle: TextStyle(color: Colors.white),
            hintText: "Task Title",
          ),
          items: dataTask.keys.map((e) {
            return DropdownMenuItem<String?>(
              value: e,
              child: Text(
                '$e',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value){
            widget.onTask(value!);
            setState(() {
              selectedTask = value;

            });
            widget.onTask(value!);},
          onSaved:(value) {
            widget.onTask(value!);

          } ,
        ),
        SizedBox(
          height: 10,
        ),
        DropdownButtonFormField<String?>(
          value: selectedSubTask,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Sub Task",
            border: OutlineInputBorder(),
            hintStyle: TextStyle(color: Colors.grey[800]),
            hintText: "Name",
          ),
          items: (dataTask[selectedTask] ?? []).map((e) {
            return DropdownMenuItem<String?>(
              value: e,
              child: Text(
                '$e',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSubTask = value;
            });
            widget.onSubTask!(value!);},
          onSaved: (value) {widget.onSubTask!(value!);},
        ),
        if (selectedTask ==  'Portfolio Quality')
          Portfolio(
    subtask: selectedSubTask,
    onSave: (value) {
      widget.taskResult(value);
    })
        else if (
        selectedTask == 'Team Management')
          Team(
            onSave: (value) {
              widget.taskResult(value);
          },
            subtask: selectedSubTask??'',)
        else if (selectedTask == 'Collection Drive')
            Collection(
              subtask: selectedSubTask ?? '',
                onSave: (value) {
                  widget.taskResult(value);
                }
               )
          else if (selectedTask == 'Pilot/Process Management')
              Pilot(
                  subtask: selectedSubTask ?? '',
                  onSave: (value) {
                    widget.taskResult(value);
                  }
              )
            else if (selectedTask == 'Customer Management')
                CustomerManagement(
                    subtask: selectedSubTask ?? '',
                    onSave: (value) {
                      widget.taskResult(value);
                    }
                )
      ],
    );
  }
}
