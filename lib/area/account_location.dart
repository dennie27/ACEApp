
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/db.dart';
class LocationMap  extends StatefulWidget {
  LocationMapState createState() => LocationMapState();
}

class  LocationMapState extends State<LocationMap> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    maploading = false;
    getUserAttributes();

    _getCurrentLocation();

  }
  List<String> attributeList = [];
  String name ="";
  String country ="";
  int complete= 0;
  void getUserAttributes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {

      name = prefs.getString("name")!;
      country =prefs.getString("country")!;
    });
    listItems("ace_data");
    if (kDebugMode) {
      print(country);
      print("$name");
    }
  }
  List? data = [];
  List<String> region= [];
  bool isLoading = true;
  double _radius  = 30000;

  void _showPointDetailsDialog(String name, String account,String phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Point Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Name: $name"),
              Text("Address: $account"),
              Text("Phone: $phone"),
              // Add more details as needed
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }



  Future<LatLng> getCurrentLocation() async {



    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }
  Future<StorageItem?> listItems(key) async {
    try {
      StorageListOperation<StorageListRequest, StorageListResult<StorageItem>>
      operation = await Database.listItems();

      Future<StorageListResult<StorageItem>> result = operation.result;
      List<StorageItem> resultList = (await operation.result).items;
      resultList = resultList.where((file) => file.key.contains(key)).toList();
      if (resultList.isNotEmpty) {
        // Sort the files by the last modified timestamp in descending order
        resultList.sort((a, b) => b.lastModified!.compareTo(a.lastModified!));
        StorageItem latestFile = resultList.first;
        _loadCoordinates(latestFile.key);
        print(latestFile.key);
        print("Key: $key");

        return resultList.first;
      } else {
        print('No files found in the S3 bucket with key containing "$key".');
        return null;
      }

      for (StorageItem item in resultList) {
        print('Key: ${item.key}');
        print('Last Modified: ${item.lastModified}');
        // Access other properties as needed
      }

      safePrint('Got items: ${resultList.length}');
    } on StorageException catch (e) {
      safePrint('Error listing items: $e');
    }
  }
  final List<dynamic> _coordinates = [];
  List<Marker> _markers = [];
  Set<Circle> _createCircle() {
    return <Circle>{
      Circle(
        circleId: CircleId('radius'),
        center: _currentLocation,
        radius: _radius,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeWidth: 0,
      ),
    };
  }
  List<LatLng> polylineCoordinates = [];
  List<LatLng> latLngList = [ ];
  bool maploading = true;
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _currentLocation = LatLng(0, 0);
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }
  Future<void> _loadCoordinates(key) async {
    try{
      StorageGetUrlResult urlResult = await Amplify.Storage.getUrl(
          key: key)
          .result;

      final response = await http.get(urlResult.url);
      final jsonData = jsonDecode(response.body);
      print(jsonData);

      var _country = country.replaceAll('"', '');
      final List<dynamic> filteredTasks = jsonData
          .where((task) => task['Country'] == _country).toList();
      Position position = await Geolocator.getCurrentPosition(
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      for (final task in filteredTasks) {
        print(task);
        final coordinate = task['Location Latitudelongitude'];
        if (coordinate != null && coordinate != '') {
          List<String> coordinatevalue = coordinate.split(',');
          if (coordinatevalue.length >= 2) {
            double latitude = double.parse(coordinatevalue[0]);
            double longitude = double.parse(coordinatevalue[1]);
            LatLng latLng = LatLng(latitude, longitude);
            double distance = await Geolocator.distanceBetween(
              currentLocation.latitude,
              currentLocation.longitude,
              latLng.latitude,
              latLng.longitude,
            );
            if (distance / 1000 <= 100) {
              latLngList.add(latLng);
              _markers.add(
                  Marker(
                    markerId: MarkerId(task['Angaza ID']),
                    position: latLng, // Location for Leyla R Abdallah
                    infoWindow: InfoWindow(
                        title: task['Customer Name'],
                        snippet: 'Disabled: ${task['Days Disabled']} Phone: ${task['Customer Phone Number']}'),
                  )

              );


            }
          }

        }

      }
      setState(() {
        print(latLngList);
        maploading = true;
        complete = latLngList.length;
      });

      print(latLngList);


    }on StorageException catch (e) {
      print('Error loading coordinates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Customers'),
          elevation: 2,
        ),
        body:complete>0?

        FutureBuilder<LatLng>(

            future: getCurrentLocation(),

            builder: (context, snapshot)
            {
              if (snapshot.hasData) {
                LatLng currentLocation = snapshot.data!;
                _markers.add(
                  Marker(
                      markerId: MarkerId('currentLocation'),
                      position: currentLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: InfoWindow(title: '$name current location')
                  ),
                );
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target:  currentLocation,
                    zoom: 14,
                  ),
                  circles: _createCircle(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers.toSet(),
                  onMapCreated: (mapController) {
                    _controller.complete(mapController);
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: const Color(0xFF7B61FF),
                      width: 6,
                    ),
                  },
                );

              }
              else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }else{
                return Center(child: CircularProgressIndicator());
              }
            }
        ):
        maploading?Center(child: Text("No Customer in your current place"),):Center(child: CircularProgressIndicator()));
  }

}