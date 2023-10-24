import 'package:field_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';
import '../notification.dart';
import '../services/auth_services.dart';

class SKAppBar extends StatelessWidget implements PreferredSizeWidget {
  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  final double height;

  SKAppBar({
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);


  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      elevation: 7,
      centerTitle: true,
      actions: [
        IconButton(onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>UserNotification(),
              ));
        }, icon: Icon(Icons.notifications)),
        IconButton(onPressed: (){
          clearSharedPreferences();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>LoginSignupPage(),
            ),
          );
        }, icon: Icon(Icons.logout)),
      ],
      leading:IconButton(onPressed: (){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>Profile(),
            ));
      }, icon: Icon(Icons.person,)),


    );
  }
}

