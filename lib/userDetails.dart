import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {

  final _formKey= new GlobalKey<FormState>();
  String _name;
  String _number;
  String _address;
  String id;
  ProgressDialog progressDialog;

  File _imageFile;

  List data;


  void addData() async{
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('User');
    Reference imref= FirebaseStorage.instance.ref().child("Images");
    UploadTask uploadTask = imref.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    print("here");
    String url= await taskSnapshot.ref.getDownloadURL();
    print("here1");
    DocumentReference ref= await collectionReference.add({
      "name": _name,
      "number": _number,
      "address": _address,
      "image": url,
    });
    print("here2");
    _imageFile=null;
    setState(() {
      id= ref.id;
    });
  }


  Future<void> pickImage(ImageSource source) async{
    File _selected = await ImagePicker.pickImage(source: source);
    if(_selected != null){
      File cropped = await ImageCropper.cropImage(
        sourcePath: _selected.path,
        aspectRatio: CropAspectRatio(
          ratioX: 1, ratioY:1
        ),
        compressQuality: 10,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.blue,
          statusBarColor: Colors.blueAccent,
          backgroundColor: Colors.white,
        )
      );
      setState(() {
        _imageFile=cropped;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);
    return AlertDialog(
        content: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
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
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Create User", style: TextStyle(fontSize: 30),),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(decoration: new InputDecoration(hintText: "Name"),
                          validator: (value)=> value.isEmpty ? 'Please fill in your name' : null,
                          onSaved: (value) => _name=value,),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(decoration: new InputDecoration(hintText: "Phone Number"),
                          validator: (value)=> value.isEmpty ? 'Please fill in your number' : null,
                          onSaved: (value) => _number=value, keyboardType: TextInputType.phone,),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(decoration: new InputDecoration(hintText: "Address"),
                          validator: (value)=> value.isEmpty ? 'Please fill in your address' : null,
                          onSaved: (value) => _address=value,keyboardType: TextInputType.multiline, maxLines: null,),
                      ),
                      if(_imageFile!=null)
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            child: Image.file(_imageFile),
                            width: 100,
                            height: 100,
                          ),
                        ),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.camera),
                                onPressed: () {
                                  pickImage(ImageSource.camera);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.attach_file),
                                onPressed: () {
                                  pickImage(ImageSource.gallery);
                                },
                              )
                            ],
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Submit"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              if(_imageFile!=null){
                                _formKey.currentState.save();
                                addData();
                                Navigator.pop(context);
                              }
                              else
                                 showDialog(
                                  context: context,
                                   builder: (BuildContext context){
                                      return AlertDialog(
                                       content: Text("Please capture/select picture to upload!",style: TextStyle(color: Colors.red),),
                                     );
                                   }
                                 );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ])
    );
  }
}