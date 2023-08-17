import 'package:field_app/task_actions.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:flutter/material.dart';

import '../widget/drop_down.dart';


class Pilot extends StatefulWidget {
  final Function(List?) onSave;
  String subtask;

  Pilot({required this.subtask,required this.onSave});

  @override
  State<Pilot> createState() => _PilotState();
}

class _PilotState extends State<Pilot> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List? _myActivities;
  late String _myActivitiesResult;
  List? data =   [
    {
      "display": "Pilot A",
      "value": "Pilot A",
    },
    {
      "display": "Pilot B",
      "value": "Pilot B",
    },
    {
      "display": "Pilot C",
      "value": "Pilot C",
    },
    {
      "display": "Pilot D",
      "value": "Pilot D",
    },
    {
      "display": "Pilot E",
      "value": "Pilot E",
    },
    {
      "display": "Pilot F",
      "value": "Pilot F",
    },
  ];


  @override
  Widget build(BuildContext context) {
    String? _selectedValue;
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(height: 10,),
          if(widget.subtask == 'Conduct the process audit')
            Column(
              children: [
                Text("Number of process ${data!.length}"),
                AppMultselect(
                  title: widget.subtask,
                  onSave: (value) {
                    if (value == null) return;
                    setState(() {
                      _myActivities = value;
                    });
                  },
                  items: data,


                ),
              ],
            ),
          if(widget.subtask == 'Conduct a pilot audit')
            Column(
              children: [
                Text("Number of pilot: ${data!.length}"),
                AppMultselect(
                  title: widget.subtask,
                  onSave: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  onChange: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  items: data,
                ),
              ],
            ),
          if(widget.subtask == 'Testing the GPS accuracy of units submitted')
            Column(
              children: [
                Text("Number of GPS ${data!.length}"),
                AppMultselect(
                  title: widget.subtask,
                  onSave: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  onChange: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  items: data,
                ),
              ],
            ),
          if(widget.subtask == 'Reselling of repossessed units')
            Column(
              children: [
                Text("Number of Qualify units ${data!.length}"),
                AppMultselect(
                  title: widget.subtask,
                  onSave: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  onChange: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  items: data,
                ),
              ],
            ),
          if(widget.subtask == 'Repossessing qualified units for Repo and Resale')
            Column(
              children: [
                Text("Number of qualified units ${data!.length}"),
                AppMultselect(
                  title: widget.subtask,
                  onSave: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  onChange: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  items: data,


                ),
              ],
            ),
          if(widget.subtask == 'Increase the Kazi Visit Percentage')
            Column(
              children: [
                Text("Number of agent ${data!.length}"),
                AppMultselect(
                  title: widget.subtask,
                  onSave: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  onChange: (value) {
                    if (value == null) return;
                    widget.onSave(value);
                  },
                  items: data,


                ),
              ],
            ),
        ],
      ),
    );
  }
}



