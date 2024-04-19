
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LanguageChangeController with ChangeNotifier {
  Locale? _appLocale;
  Locale? get  appLocale => _appLocale;
  void changelanguage (Locale type) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _appLocale = type;
    if(type == Locale('en')){
      await prefs.setString('language', 'en');
    }else if(type == Locale('hi')){
      await prefs.setString('language', 'hi');
    }else if(type == Locale('my')){
      await prefs.setString('language', 'my');
    }else if(type == Locale('pt')){
      await prefs.setString('language', 'pt');
    }
    notifyListeners();
  }

}