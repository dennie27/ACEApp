import 'package:field_app/task_actions.dart';
import 'package:field_app/utils/themes/theme.dart';
import 'package:field_app/widget/drop_down.dart';
import 'package:flutter/material.dart';


class Team extends StatefulWidget {
  final Function(List?) onSave;
  String? subtask;
  Team({required this.subtask,required this.onSave});
  @override
  State<Team> createState() => _TeamState();
}

class _TeamState extends State<Team> {
  String? selectedSubTask;
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
        if(widget.subtask == 'Assist a team member to improve the completion rate')
          AppDropDown(
            disable: false,
              label: "Improve Completetion Rate",
              hint: "Improve Completetion Rate",
              items: ["visit 1","visit 2"],
              onChanged: (String value) {
                widget.onSave([value!]);
              }),
        if(widget.subtask == 'Raise a reminder to a team member')
          AppDropDown(
            disable: false,
              label: "Reminder",
              hint: "Reminder",
              items: ["Reminder 1","Reminder 2"],
              onChanged: (String value) {
                widget.onSave([value!]);
              }),
        if(widget.subtask == 'Raise a warning to a team member')
          AppDropDown(
            disable: false,
              label: "Warning to a team member",
              hint: "Warning to a team member",
              items: ["warning 1","waring 2"],
              onChanged: (String value) {
                widget.onSave([value!]);
              }),
        if(widget.subtask == 'Raise a new task to a team member')
          AppDropDown(
            disable: false,
              label: "New Task",
              hint: "New Task",
              items: ["Task 1","Task 2"],
              onChanged: (String value) {
                widget.onSave([value!]);
              }),
        if(widget.subtask == 'Inform the team member of your next visit to his area, and planning needed')
          AppDropDown(
            disable: false,
              label: "Field Visit",
              hint: "Field Visit",
              items: ["visit 1","visit 2"],
              onChanged: (String value) {
                widget.onSave([value!]);
              }),
        if(widget.subtask== 'Others')
          AppDropDown(
            disable: false,
              label: "other",
              hint: "others",
              items: ["others 1","others 2"],
              onChanged: (value) {
                widget.onSave([value!]);
              }),
      ],
    );
  }
}



