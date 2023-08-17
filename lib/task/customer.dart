import 'package:field_app/task_actions.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:flutter/material.dart';

import '../widget/drop_down.dart';


class CustomerManagement extends StatefulWidget {
  final Function(List?) onSave;
  String subtask;

  CustomerManagement({required this.subtask,required this.onSave});
  @override
  State<CustomerManagement> createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> {
  String? selectedSubTask;
  List? _myActivities;
  late String _myActivitiesResult;
  List? data =   [
    {
      "display": "Customer 1",
      "value": "Customer 1",
    },
    {
      "display": "Customer 2",
      "value": "Customer 2",
    },
    {
      "display": "Customer 3",
      "value": "Customer 3",
    },
    {
      "display": "Customer 4",
      "value": "Customer 4",
    },
    {
      "display": "Customer 5",
      "value": "CUstomer 5",
    },
    {
      "display": "CUstomer 6",
      "value": "Cusomtomer 6",
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
        if(widget.subtask == 'Visiting of issues raised')
          Column(
            children: [
              Text("Number of issue ${data!.length}"),
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
        if(widget.subtask == 'Repossession of customers needing repossession')
          Column(
            children: [
              Text("Number of accounts ${data!.length}"),
              AppMultselect(
                title: widget.subtask,
                onSave: (value) {
                  if (value == null) return;
                  setState(() {
                    _myActivities = value;
                  });
                },
                onChange: (value) {
                  if (value == null) return;
                  setState(() {
                    _myActivities = value;
                  });
                },
                items: data,


              ),
            ],
          ),
        if(widget.subtask == 'Look at the number of replacements pending at the shops')
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
        if(widget.subtask == 'Look at the number of repossession pending at the shops')
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



