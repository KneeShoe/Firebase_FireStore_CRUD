import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_app/userDetails.dart';
import 'package:image_picker/image_picker.dart';

class home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('User');
  int _update;
  String number;
  String address;
  final _formkey=new GlobalKey<FormState>();

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(doc.data()['image']),
                        fit: BoxFit.fill),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '${doc.data()['name']}',
                  style: TextStyle(fontSize: 25),
                ),
              ],
            ),
            Text(
              '${doc.data()['number']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${doc.data()['address']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateData(doc),
                  child: Text('Update', style: TextStyle(color: Colors.white)),
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                FlatButton(
                  onPressed: () => deleteData(doc),
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void updateData(DocumentSnapshot doc) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(overflow: Overflow.visible, children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                      TextFormField(
                        initialValue: doc.data()['number'],
                        decoration: new InputDecoration(hintText: "Phone Number"),
                        validator: (value) =>
                            value.isEmpty ? 'Please fill in your number' : null,
                        onSaved: (value) => number = value,
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        initialValue: doc.data()['address'],
                        decoration: new InputDecoration(hintText: "Address"),
                        validator: (value) =>
                            value.isEmpty ? 'Please fill in your address' : null,
                        onSaved: (value) => address = value,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    RaisedButton(
                      child: Text("Update"),
                      onPressed: () {
                        if(_formkey.currentState.validate()){
                          _formkey.currentState.save();
                          print(number);
                          Navigator.of(context).pop();
                        }
                      },
                    )
                  ],
                ),
              ),
            ]),
          );
        });
      await collectionReference.doc(doc.id).update({"number": number,"address": address});
  }

  void deleteData(DocumentSnapshot doc) async {
    await collectionReference.doc(doc.id).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: collectionReference.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List values = snapshot.data.docs;
              return ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    return buildItem(values[index]);
                  });
            } else
              return CircularProgressIndicator();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MyDialog();
              });
          setState(() {});
        },
        tooltip: 'Add User',
        child: Icon(Icons.add),
      ),
    );
  }
}
