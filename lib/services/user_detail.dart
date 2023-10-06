
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';


class UserDetail{
  //to get number of calls

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString("name");
    // Get docs from collection reference
    // Get data from docs and convert map to List

    print("doc length $currentUser");
  }
  //get data by user area
 getDataByID(String value) async {
    // Get docs from collection reference
   SharedPreferences prefs = await SharedPreferences.getInstance();
   var name = prefs.getString("name");

   return name;
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