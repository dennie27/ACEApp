import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';


class UserDetail{

  var user = FirebaseFirestore.instance.collection('Users');
  //to get number of calls

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString("name");
    // Get docs from collection reference
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await user.get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.size;
    print("doc length $allData");
  }
  //get data by user area
 getDataByID(String value) async {
    // Get docs from collection reference
    var querySnapshot = await user.where('UID', isEqualTo: value).get();
    // Get data from docs and convert map to List
    final allData = querySnapshot;

  }
  getUserArea() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var area = prefs.getString("area");

    return area;

  }
  getUserRegion() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var region = prefs.getString("region");
    return region;
  }
  getUSeRole()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var role = prefs.getString("role");

    return role;
  }
  getUserRegionSnap() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var query = prefs.getString("region");
    return query;
  }


}