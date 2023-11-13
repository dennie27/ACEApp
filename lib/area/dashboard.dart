import 'dart:core';
import 'package:field_app/services/calls_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/themes/theme.dart';
import 'package:permission_handler/permission_handler.dart';

import 'account_location.dart';

class AreaDashboard extends StatefulWidget {
  const AreaDashboard({Key? key}) : super(key: key);
  @override
  AreaDashboardState createState() => AreaDashboardState();
}

class AreaDashboardState extends State<AreaDashboard> {
  bool isLogin = true;
  String name ="";
  String region = '';
  String country ='';
  String area ='';
  String role = '';
  void showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('You have permanently denied some permissions.\n'
            ' Please enable them in app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text('Open App Settings'),
          ),
        ],
      ),
    );
  }

  checkCallLog() async{
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.phone,
      Permission.storage
    ].request();
    var log =  await Permission.phone.request();

    if(statuses[Permission.storage]!.isPermanentlyDenied ||
        statuses[Permission.phone]!.isPermanentlyDenied
        ||statuses[Permission.camera]!.isPermanentlyDenied){

      showPermanentlyDeniedDialog();
    }else{
      if(statuses[Permission.storage]!.isDenied){
        await Permission.storage.request() ;
      }
      if(statuses[Permission.phone]!.isDenied){
        await Permission.phone.request() ;
      }
      if(statuses[Permission.camera]!.isDenied){
        await Permission.camera.request() ;
      }

    }
    print(await Permission.storage.status);
    print(await Permission.phone.status);
    print(await Permission.camera.status);


  }
  void userArea() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var login  = prefs.get("isLogin");
    print(login);
    if(login == true){
      setState(() {
        isLogin = false;
        role = prefs.getString("role")!;
        area = prefs.getString("area")!;
        name = prefs.getString("name")!;
        region = prefs.getString("region")!;
        country = prefs.getString("country")!;
      });
    }


  }

  @override
  initState() {
    super.initState();
    userArea();
    checkCallLog();


  }
  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationMap(),
                      ));
                },
                child: Text("Map")),
            const KpiTittle(
              title_color: AppColor.mycolor,
              label: 'Calls Summary',
              txtColor: Colors.black87,
            ),
            Row(
              children: [
                RowData(
                  value: 0,
                  label: 'Call Attempt',
                  future: USerCallDetail().countComplete('Call'),
                ),
                RowData(
                  value: 0,
                  label: 'Call Made',
                  future: USerCallDetail().countCallMade('Call'),
                ),
                RowData(
                  label: 'Calls Pending',
                  value: 0,
                  future: USerCallDetail().countPendingCall('Call'),
                ),


              ],
            ),
            Row(
              children: [
                RowData(
                  value: 0,
                  label: 'Complete Rate',
                  future: USerCallDetail().completeCallRate('Call'),
                ),
                RowData(
                  value: 32,
                  label: 'Success Calls',
                  future: USerCallDetail().countSucceful('Call'),
                ),
                RowData(
                  value: 35,
                  label: 'Total Collected',
                  future: USerCallDetail().amount('Call'),
                ),
              ],
            ),
            const KpiTittle(
              title_color: AppColor.mycolor,
              label: 'Visit Summary',
              txtColor: Colors.black87,
            ),
            Row(
              children: [
                RowData(
                  value: 20,
                  label: 'Visit Attempt',
                  future: USerCallDetail().countComplete('Visit'),
                ),
                RowData(
                  value: 20,
                  label: 'Visit Made',
                  future: USerCallDetail().countVisitMade('Visit'),
                ),
                RowData(
                  value: 40,
                  label: 'Visit Pending',
                  future: USerCallDetail().countPendingVisit('Visit'),
                ),
              ],
            ),
            Row(
              children: [

                RowData(
                  value: 35,
                  label: 'Complete Rate',
                  future: USerCallDetail().completeVistRate('Visit'),
                ),

                RowData(
                  value: 20,
                  label: 'Success Visit',
                  future: USerCallDetail().countSucceful('Visit'),
                ),
                RowData(
                  value: 35,
                  label: 'Total Collected',
                  future: USerCallDetail().amount('Visit'),
                ),
              ],
            ),
            const KpiTittle(
              title_color: AppColor.mycolor,
              label: 'Disable Task  Summary',
              txtColor: Colors.black87,
            ),

            Row(
              children: [
                RowData(
                  value: 0,
                  label: 'Task Attempt',
                  future: USerCallDetail().countComplete('Disable'),
                ),
                RowData(
                  value: 0,
                  label: 'Task Made',
                  future: USerCallDetail().countCallMade('Disable'),
                ),
                RowData(
                  label: 'Task Pending',
                  value: 0,
                  future: USerCallDetail().countPendingCall('Disable'),
                ),


              ],
            ),
            Row(
              children: [
                RowData(
                  value: 0,
                  label: 'Complete Rate',
                  future: USerCallDetail().completeCallRate('Disable'),
                ),
                RowData(
                  value: 32,
                  label: 'Success Calls',
                  future: USerCallDetail().countSucceful('Disable'),
                ),
                RowData(
                  value: 35,
                  label: 'Total Collected',
                  future: USerCallDetail().amount('Disable'),
                ),
              ],
            ),
            const KpiTittle(
              title_color: AppColor.mycolor,
              label: 'Restricted Agents',
              txtColor: Colors.black87,
            ),
            Row(
              children: [
                RowData(
                  value: 0,
                  label: 'Agent Restricted',
                  future: USerCallDetail().countRestricted(),
                ),
                RowData(
                  value: 0,
                  label: 'Agent Moved out',
                  future: USerCallDetail().countMoveOut(),
                ),
                RowData(
                  label: 'Agent Move In',
                  value: 0,
                  future: USerCallDetail().countMoveIn(),
                ),


              ],
            ),

            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class KpiTittle extends StatelessWidget {
  final Color title_color;
  final String label;
  final Color txtColor;
  const KpiTittle(
      {Key? key,
        required this.title_color,
        required this.txtColor,
        required this.label})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.amber,
      color: title_color,
      child: ListTile(
        title: Center(
            child:
            Text(label, style: TextStyle(fontSize: 20, color: txtColor))),
        dense: true,
      ),
    );
  }
}

class RowData extends StatelessWidget {
  final int value;
  final String label;
  final future;

  const RowData({Key? key, required this.value, required this.label,required this.future})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<dynamic>(
          future:future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return InkWell(
                onTap: () {},
                child: Card(
                  elevation: 3,
                  child: SizedBox(
                    height: 50,
                    width: 100,
                    child: Column(
                      children: [
                        Text(snapshot.data.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                            )),
                        Text(label, style: const TextStyle(fontSize: 15))
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return InkWell(
                onTap: () {},
                child: Card(
                  elevation: 3,
                  child: SizedBox(
                    height: 40,
                    width: 60,
                    child: Column(
                      children: [
                        const Text('0',
                            style: TextStyle(
                              fontSize: 15,
                            )),
                        Text(label, style: const TextStyle(fontSize: 9))
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Column(children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text('run...'),
              ]);
            }
          }),
    );
  }
}
