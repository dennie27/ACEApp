import 'dart:core';
import 'package:field_app/area/pending_calls.dart';
import 'package:flutter/material.dart';
import 'complete_calls.dart';

class Customer extends StatefulWidget {
  const Customer({Key? key}) : super(key: key);
  @override
  CustomerState createState() => CustomerState();
}

class CustomerState extends State<Customer> {
  @override
  initState() {
    // at the beginning, all users are shown
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const TabBar(tabs: [
            Tab(
              text: "Pending ",
            ),
            Tab(text: "Completed"),
            //Tab(text: "Agent"),
          ]),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(5),
              child: const TabBarView(
                children: [
                  PendingCalls(),
                  CompleteCalls(),
                  //AgentTask(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
