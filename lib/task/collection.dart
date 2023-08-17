import 'package:field_app/task_actions.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:flutter/material.dart';

import '../widget/drop_down.dart';


class Collection extends StatefulWidget {
  String subtask;
  final Function(List?) onSave;
  Collection({required this.subtask,required this.onSave});
  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  String? selectedSubTask;
  List? _myActivities;
  late String _myActivitiesResult;
  List? data =   [
    {
      "display": "coll 1",
      "value": "coll 1",
    },
    {
      "display": "coll 2",
      "value": "coll 2",
    },
    {
      "display": "coll 3",
      "value": "coll 3",
    },
    {
      "display": "coll 4",
      "value": "coll 4",
    },
    {
      "display": "Coll 5",
      "value": "CColl 5",
    },
    {
      "display": "coll 6",
      "value": "coll 6",
    },
  ];
  onSubTaskChanged(String? value) {
    setState(() {
      selectedSubTask = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? _selectedValue;
    return Column(
      children: [
        SizedBox(height: 10,),
        if(widget.subtask == 'Field Visits with low-performing Agents in Collection Score')
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
        if(widget.subtask == 'Repossession of accounts above 180')
          Column(
            children: [
              Text("Number of accounts ${data!.length}"),
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
        if(widget.subtask == 'Visits Tampering Home 400')
          Column(
            children: [
              Text("Number of accounts ${data!.length}"),
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
        if(widget.subtask == 'Work with restricted Agents')
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
        if(widget.subtask == 'Calling of special book')
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
        if(widget.subtask == 'Sending SMS to clients')
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
        if(widget.subtask == 'Table Meeting/ Collection Sensitization Training')
          Column(
            children: [
              Text("Number of Table meeting to attend ${data!.length}"),
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
        if(widget.subtask== 'Others')
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
    );
  }
}



