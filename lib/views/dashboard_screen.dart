import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logstoreproject/views/login_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // firebase_storage.FirebaseStorage storage =
  //     firebase_storage.FirebaseStorage.instance;

  File? _photo;

  String? uid;

  String imageName = "";
  XFile? imagePath;
  final ImagePicker _picker = ImagePicker();
  var descriptionController = new TextEditingController();
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef = FirebaseStorage.instance;
  String collectionName =
      "${FirebaseAuth.instance.currentUser!.uid.toString()}";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    imageName == "" ? Container() : Text("${imageName}"),
                    SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        imagePicker();
                      },
                      child: Text("Select Image"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _uploadImage();
                      },
                      child: Text("Upload"),
                    ),
                    Expanded(
                      child: FutureBuilder<QuerySnapshot>(
                        future: firestoreRef.collection(collectionName).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.docs.length > 0) {
                            List<DocumentSnapshot> arrData =
                                snapshot.data!.docs;
                            return ListView.builder(
                                itemCount: arrData.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: Row(
                                      children: [
                                        Image.network(
                                          arrData[index]['image'],
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.fill,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(arrData[index]['description']
                                                    .length >
                                                20
                                            ? arrData[index]['description']
                                                    .substring(0, 20) +
                                                '...'
                                            : arrData[index]['description']),
                                      ],
                                    ),
                                  );
                                });
                          } else {
                            return Center(
                              child: Text("No Data Found"),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _uploadImage() async {
    setState(() {
      _isLoading = true;
    });
    var uniquekey = firestoreRef.collection(collectionName).doc();
    String uploadFileName =
        DateTime.now().microsecondsSinceEpoch.toString() + '.jpg';
    Reference reference = storageRef.ref().child("Image").child(uploadFileName);
    UploadTask uploadTask = reference.putFile(File(imagePath!.path));
    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() +
          "\t" +
          event.totalBytes.toString());
    });
    await uploadTask.whenComplete(() async {
      var uploadPath = await uploadTask.snapshot.ref.getDownloadURL();

      if (uploadPath.isNotEmpty) {
        firestoreRef.collection(collectionName).doc(uniquekey.id).set({
          "description": descriptionController.text,
          "image": uploadPath
        }).then((value) => _showMessage("Record Inserted."));
      } else {
        _showMessage("Something While Uploading Image.");
      }
      setState(() {
        _isLoading = false;
        descriptionController.text = "";
        imageName = "";
      });
    });
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

  imagePicker() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        descriptionController.text = Faker().lorem.sentence();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }
}
