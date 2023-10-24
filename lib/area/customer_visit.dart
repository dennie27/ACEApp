import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:field_app/area/location.dart';
import 'package:field_app/area/pending_calls.dart';
import 'package:field_app/widget/drop_down.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/db.dart';
import '../utils/themes/theme.dart';
class CustomerVisit  extends StatefulWidget {

  final id;
  final angaza;
  const CustomerVisit({Key? key,required this.id,required this.angaza}) : super(key: key);
  @override
  CustomerVisitState createState() => CustomerVisitState();
}
class CustomerVisitState extends State<CustomerVisit> {
  bool isLoading = false;
  List? _data = [];
  List? data = [0];

  Future<void> ACETask(account) async {


    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('filteredTasks') ?? '[]';
    var area = prefs.getString('area');
    var dataList = jsonDecode(data);
    var filteredTasks =  dataList.where((task) => task['Area'] ==area && task['Angaza ID']
        == account
    ).toList();
    setState(() {
      _data = filteredTasks;
      isLoading = true;
    });
  }
  String? phoneselected;
  String? feedbackselected;
  TextEditingController feedbackController = TextEditingController();
  TextEditingController dateInputController = TextEditingController();

  var fnumberupdate;
  var cmnumberupdate;
  var number1update;
  var name1update;
  var calltypeupdate;
  var name;
  var timedateupdate;
  var duration1update;
  var accidupdate;
  var simnameupdate;
  String? promisedate = null;
  getAccountData(String angazaid) async {

    String username = 'dennis+angaza@greenlightplanet.com';
    String password = 'sunking';
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    var headers = {
      "Accept": "application/json",
      "method":"GET",
      "Authorization": '${basicAuth}',
      "account_qid" : "AC5156322",
    };

    var uri = Uri.parse('https://payg.angazadesign.com/data/accounts/$angazaid');
    var response = await http.get(uri, headers: headers);


    var dd = json.decode(response.body);
    var id = dd['client_qids'][0];

    var uriphoto = Uri.parse('https://payg.angazadesign.com/data/clients/$id');
    var responsephoto = await http.get(uriphoto, headers: headers);

    var bodyphoto = json.decode(responsephoto.body);

    var attribute = bodyphoto["attribute_values"];


    List<Map<String, dynamic>> attributes =
    attribute.cast<Map<String, dynamic>>();

    String photo = attributes
        .firstWhere((attr) => attr['name'] == 'Client Photo')['value'];
    return photo;
  }
  getPhoto(String client) async {
    String username = 'dennis+angaza@greenlightplanet.com';
    String password = 'sunking';
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    var headers = {
      "Accept": "application/json",
      "method": "GET",
      "Authorization": '${basicAuth}',
      "account_qid": "AC5156322",
    };
    var uri = Uri.parse('https://payg.angazadesign.com/data/clients/$client');
    var response = await http.get(uri, headers: headers);
    var body = json.decode(response.body);
    var attribute = body["attribute_values"];
    List<Map<String, dynamic>> attributes =
    attribute.cast<Map<String, dynamic>>();
    String photo = attributes
        .firstWhere((attr) => attr['name'] == 'Client Photo')['value'];
    return photo;
  }
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  late GoogleMapController mapController;
  bool servicestatus = false;
  bool haspermission = false;
  late List<CameraDescription>? cameras;
  XFile? image;
  File? imageFile;
  late CameraController? controller;
  late LocationPermission permission;
  late Position position;
  double long =0.0, lat=0.0;
  late StreamSubscription<Position> positionStream;
  var feedback = [
    'Customer will pay',
    'System will be repossessed',
    'At the shop for replacement',
    'Product is with EO',
    'Not the owner',
  ];

  @override
  void initState() {
    super.initState();

    //loadCamera();
    ACETask(widget.angaza);

  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

  }
  void getImage() async{
    final file  = await ImagePicker().pickImage(source: ImageSource.camera);
    if(file?.path != null){
      setState(() {
        imageFile = File(file!.path);
      });
    }
  }
  final formKey = GlobalKey<FormState>();
  updateCustomer() async {
    if(/*imageFile == null ||*/ reasonselected == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select reason and capture image'),
        ),
      );

    }else{
      final fileName = DateTime.now();
      final destination = 'files/$fileName';
      final awsFile = AWSFile.fromPath(imageFile!.path);


      try {
        final resultUpload = await Amplify.Storage.uploadFile(
          key: destination,
          localFile: awsFile,

        ).result;
        print(resultUpload.uploadedItem.key);
        GeoPoint newLocation = GeoPoint(lat, long);

        var connection = await Database.connect();
        var date =DateFormat('yyyy-MM-dd').format(DateTime.now());
        var col = '"angaza_id", "user", "date", "task", "status", "promise_date", "feedback","reason","location"';
        var value = "'${widget.angaza}','dennis Juma','$date','Visit','Complete','$date','deniis feedback','$reasonselected','{newLocation}'";
        var result = await connection.query("INSERT INTO feedback ($col) VALUES ($value)");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task Updated successfully'),
          ),
        );
        Navigator.of(context).pop();
      }catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(

            content: Text('An error occur when submit ${e.toString()} '),
          ),
        );
      }


    }


    }

  loadCamera() async {
    cameras = await availableCameras();
    if(cameras != null){
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const  SnackBar(
            content: Text('No any camera found'),
          )
      );
    }
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied'),
              ),
          );
        }else if(permission == LocationPermission.deniedForever){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }

      if(haspermission){
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS Service is not enabled, turn on GPS location'),
        ),
      );

    }

    /*setState(() {
      //refresh the UI
    });*/
  }
  String? reasonselected;
  getLocation() async {
    position = await Geolocator.getCurrentPosition();

    long = position.longitude;
    lat = position.latitude;

    setState(() {

      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
       //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {

      long = position.longitude;
      lat = position.latitude;

      setState(() {
        //refresh UI on update
      });
    });
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: isLoading?Column(
                  children: [

                    Center(
                        child: FutureBuilder<dynamic>(
                            future: getAccountData(widget.angaza),
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> photourl) {
                              if (photourl.hasData) {

                                String photo = photourl.data!;
                                return Container(
                                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  width: 150.0,
                                  height: 150.0,
                                  color: Colors.grey.withOpacity(0.3),
                                  child:  Center(child: Image.network(photo)),
                                );
                              } else if (photourl.hasError) {
                                return Text('Error: ${photourl.error}');
                              } else {
                                return const CircularProgressIndicator();
                              }
                            })),
                    Text('Name:  ${_data![0]['Customer Name']}',style:const TextStyle(fontSize: 15)),
                    Text('Account : ${_data![0]['Account Number']}',style:const TextStyle(fontSize: 15)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: (){
                         /* _callNumber(
                              phoneList,
                              data.id,
                              data["Angaza ID"]
                          );*/

                        },child: Text(_data![0]['Customer Phone Number'],style:const TextStyle(fontSize: 20,color: Colors.black),),),
                        TextButton(onPressed: (){},child: Text(_data![0]['Area'].toString(),style:const TextStyle(fontSize: 20,color: Colors.black))),

                      ],


                    ),
                    const Card(
                      shadowColor: Colors.amber,
                      color: Colors.black,
                      child: ListTile(
                        title: Center(
                            child: Text("Customer visit action",
                                style: TextStyle(fontSize: 15, color: Colors.yellow))),
                        dense: true,
                      ),
                    ),
                    Form(
                      key: formKey,
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            AppDropDown(
                              disable: false,
                                label: 'Reason for not pay',
                                hint: 'select a reason',
                                items:feedback,
                                onChanged:  (String value) {
                                  setState(() {
                                    reasonselected = value;
                                  });}),
              const SizedBox(height: 10,),
             if(reasonselected != null)
               TextFormField(
                 controller: feedbackController,
                   maxLines: 5,
                   decoration: InputDecoration(
              labelText:reasonselected,
                     focusedBorder: const OutlineInputBorder(
                       borderSide:
                       BorderSide(color: AppColor.mycolor, width: 1.0),
                     ),
                     enabledBorder: const OutlineInputBorder(
                       borderSide:
                       BorderSide(color: Colors.black12, width: 1.0),
                     ),
                   )),
              const SizedBox(height: 10,),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                onPressed:()=>getImage(),
                icon: const Icon(Icons.camera),
                label: const Text("Capture Image"),

                ),
              ),
                            Container( //show captured image
                              padding: const EdgeInsets.all(30),
                              child: imageFile == null?
                              const Text("No image captured"):
                              Image.file(File(imageFile!.path), height: 300,),
                              //display captured image
                            ),
              TextFormField(
              decoration: const InputDecoration(
              hintText: 'Promise Date',
              border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1)),
              focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1)),
              enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1)),
              ),
              controller: dateInputController,
              readOnly: true,
              onTap: () async {
              DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 5)));

              if (pickedDate != null) {
              dateInputController.text = DateFormat('yyyy-MM-dd').format(pickedDate).toString();
              }
              },
              ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(onPressed: (){
                                  updateCustomer();
                                  const PendingCalls();
                                }, child:const Text('Submit')),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
              onPressed: () {
                if(_data![0]['Location Latitudelongitude'] == null || _data![0]['Location Latitudelongitude'] == ''){

                }else{

                  Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerLocation(id: widget.id, customerLocation: _data![0]['Location Latitudelongitude'],name: _data![0]['Customer Name'],),
                      ));
                }

              },
                          label: const Text('Get direction'),
                          icon: const Icon(Icons
                              .location_on_outlined),
                        ),
                      ),
                    ),
                                     ],
                ):const Center(child: CircularProgressIndicator(

    ))
      )
    );

   }

}