import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_flags/country_flags.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:country_picker/country_picker.dart';

import 'l10n/language.dart';


class Profile  extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}
class ProfileState extends State<Profile> {

  @override
  void initState() {
    super.initState();
    getUserAttributes();
  }
  String name ="";
  String region = '';
  String userRegion = '';
  String country ='';
  String zone ='';
  String role = '';
  String email = "";
  void changeAppLanguage(Locale locale) {
    Localizations.override(context: context, locale: locale);
  }
  void getUserAttributes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
    });
    name = prefs.getString("name")!;
    email = prefs.getString("email")!;
    userRegion =  prefs.getString("area")!;
    country =  prefs.getString("country")!;
    role = prefs.getString("role")!;
    zone =  prefs.getString("zone")!;
    // Process the user attributes


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [

          ClipOval(
            child: Material(
              color:Colors.grey.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
          Text(name),
          Text(email),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){},child: Text('$role',style: TextStyle(color: Colors.black),)),
              TextButton(onPressed: (){},child:Text('Area: $userRegion',style: TextStyle(color: Colors.black))),

            ],

          ),
    Consumer<LanguageChangeController>(
      builder: (context, provider, child){
        return PopupMenuButton(
        onSelected: (value) {
        switch (value) {
        case 'en':
        provider.changelanguage(Locale('en'));
        break;
        case 'hi':
        provider.changelanguage(Locale('hi'));
        break;
        case 'my':
        provider.changelanguage(Locale('my'));
        break;
        case 'pt':

        provider.changelanguage(Locale('pt'));
        break;
        }
        },
        itemBuilder: (BuildContext context)   =>[
        PopupMenuItem(
        value: "en",
        child: CountryFlag.fromCountryCode('GB',height: 30,width: 30,),
        ),
        PopupMenuItem(
        value: "hi",
        child: CountryFlag.fromCountryCode('IN',height: 30,width: 30,),
        ),
        PopupMenuItem(
        value: "my",
        child: CountryFlag.fromCountryCode('MM',height: 30,width: 30,),
        ),
        PopupMenuItem(
        value: "pt",
        child: CountryFlag.fromCountryCode('PT',height: 30,width: 30,),
        ),
        ],
        icon: const Icon(Icons.language, color: Colors.black),

        );
      },

    ),


          Card(
            shadowColor: Colors.amber,
            color: Colors.black,
            child: ListTile(
              title: Center(
                  child: Text(AppLocalizations.of(context)!.user_details,
                      style: TextStyle(fontSize: 15, color: Colors.yellow))),
              dense: true,
            ),
          ),
          ElevatedButton(onPressed: (){

          }, child: Text(AppLocalizations.of(context)!.update_detail))


        ],
      ),
    );
  }

}