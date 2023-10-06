import 'dart:core';
import 'package:field_app/services/calls_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/themes/theme.dart';

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
  String role = '';
  void userArea() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var login  = prefs.get("isLogin");
    print(login);
    if(login == true){
      setState(() {
        isLogin = false;
        role = prefs.getString("role")!;
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


  }
  @override
  Widget build(BuildContext context) {

    return isLogin?const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Hi! Welcome"),
        Text("You are new user please contact the admin")
      ],
    ):SingleChildScrollView(
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                  future: USerCallDetail().CountComplete('Call'),
                ),
                RowData(
                  value: 0,
                  label: 'Call Made',
                  future: USerCallDetail().CountCallMade('Call'),
                ),
                RowData(
                  label: 'Calls Pending',
                  value: 0,
                  future: USerCallDetail().CountPendingCall('Call'),
                ),


              ],
            ),
            Row(
              children: [
                RowData(
                  value: 0,
                  label: 'Complete Rate',
                  future: USerCallDetail().CompleteCallRate('Call'),
                ),
                RowData(
                  value: 32,
                  label: 'Success Calls',
                  future: USerCallDetail().CountSucceful('Call'),
                ),
                RowData(
                  value: 35,
                  label: 'Total Collected',
                  future: USerCallDetail().Amount('Call'),
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
                  future: USerCallDetail().CountComplete('Visit'),
                ),
                RowData(
                  value: 20,
                  label: 'Visit Made',
                  future: USerCallDetail().CountVisitMade('Visit'),
                ),
                RowData(
                  value: 40,
                  label: 'Visit Pending',
                  future: USerCallDetail().CountPendingVisit('Visit'),
                ),
              ],
            ),
            Row(
              children: [

                RowData(
                  value: 35,
                  label: 'Complete Rate',
                  future: USerCallDetail().CompleteVistRate('Visit'),
                ),

                RowData(
                  value: 20,
                  label: 'Success Visit',
                  future: USerCallDetail().CountSucceful('Visit'),
                ),
                RowData(
                  value: 35,
                  label: 'Total Collected',
                  future: USerCallDetail().Amount('Visit'),
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
                  future: USerCallDetail().CountComplete('Disable'),
                ),
                RowData(
                  value: 0,
                  label: 'Task Made',
                  future: USerCallDetail().CountCallMade('Disable'),
                ),
                RowData(
                  label: 'Task Pending',
                  value: 0,
                  future: USerCallDetail().CountPendingCall('Disable'),
                ),


              ],
            ),
            Row(
              children: [
                RowData(
                  value: 0,
                  label: 'Complete Rate',
                  future: USerCallDetail().CompleteCallRate('Disable'),
                ),
                RowData(
                  value: 32,
                  label: 'Success Calls',
                  future: USerCallDetail().CountSucceful('Disable'),
                ),
                RowData(
                  value: 35,
                  label: 'Total Collected',
                  future: USerCallDetail().Amount('Disable'),
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
                  future: USerCallDetail().CountRestricted(),
                ),
                RowData(
                  value: 0,
                  label: 'Agent Moved out',
                  future: USerCallDetail().CountMoveOut(),
                ),
                RowData(
                  label: 'Agent Move In',
                  value: 0,
                  future: USerCallDetail().CountMoveIn(),
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
