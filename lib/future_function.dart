import 'package:field_app/widget/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BaseData extends StatefulWidget {
  @override
  _BaseDataState createState() => _BaseDataState();
}

class _BaseDataState extends State<BaseData> {
  TextEditingController feedbackController = TextEditingController();
  bool isCalling = false;
  String? reasonselected;
  String? phoneselected;
  var phone = ['123456890', '2345678905', '3456789012'];
  var feedback = [
    'Customer will pay',
    'system will be repossessed',
    'at the shop for replacement',
    'Product is with EO',
    'not the owner',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: AlertDialog(
                        title: Text('Phone Call'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppDropDown(
                              disable: false,
                                label: 'Phone Number',
                                hint: 'Select Phone Number',
                                items: phone,
                                onChanged: (String value) {
                                  setState(() {
                                    phoneselected = value;
                                    launch('tel:$value');
                                  });
                                }),
                            SizedBox(
                              height: 10,
                            ),
                            AppDropDown(
                              disable: false,
                                label: 'Reason for not pay',
                                hint: 'select a reason',
                                items: feedback,
                                onChanged: (String value) {
                                  setState(() {
                                    reasonselected = value;
                                    print(reasonselected);
                                  });
                                }),
                            SizedBox(height: 10),
                            if (reasonselected == 'Customer will pay')
                              Text("date"),
                            TextField(
                              maxLines: 4,
                              controller: feedbackController,
                              decoration: InputDecoration(
                                labelText: 'Additional Feedback',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          isCalling
                              ? CircularProgressIndicator()
                              : TextButton(
                                  child: Text('Call'),
                                  onPressed: () async {
                                    // Start recording feedback
                                    setState(() {
                                      isCalling = true;
                                    });

                                    // Wait for 3 seconds to simulate a phone call
                                    await Future.delayed(Duration(seconds: 3));

                                    // Save feedback to a database
                                    String feedback = feedbackController.text;
                                    print('Recorded Feedback: $feedback');

                                    // End recording feedback
                                    setState(() {
                                      isCalling = false;
                                    });

                                    Navigator.of(context).pop();
                                  },
                                ),
                        ],
                      ),
                    );
                  });
            },
            child: Text("DEnnis"),
          ),
        ),
      ),
    );
  }
}
