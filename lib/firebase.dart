import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<dynamic> _selectedItems = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _documents = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  List<String> _data = [];
  List _mydata = [];
  Future<void> _getData() async {

    QuerySnapshot querySnapshot =
    await _firestore.collection("TZ_agent_welcome_call")
        .where("Area", isEqualTo:await "Morogoro")
        .get();
    setState(() {
      _data =querySnapshot.docs.map((doc) => doc["Agent"].toString()).toSet().toList();
      List<Map<String, String>> mylist = _data.map((item) => {"display": item, "value": item}).toList();
      _mydata =mylist;
      print(_mydata);

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Select Dropdown Example'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: _buildDropdown(),
      ),
    );
  }

  Widget _buildDropdown() {
    return MultiSelectFormField(

      title: Text('Select Items'),
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Please select one or more items';
        }
        return null;
      },
      dataSource:_mydata,
      textField: 'display',
      valueField: 'value',
      okButtonLabel: 'OK',
      cancelButtonLabel: 'CANCEL',
      hintWidget: Text("Please select one or more items"),
      initialValue: _selectedItems,
      onSaved: (value) {
        if (value == null) return;
        setState(() {
          _selectedItems = value;
        });
      },
    );
  }
}
