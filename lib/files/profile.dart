import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sanai3i/files/photoViwer.dart';
import 'package:sanai3i/files/reusable.dart';
import 'package:sanai3i/files/settings.dart';

import 'database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool validateName = false;
  bool validatePhone = false;
  bool validatePhone2 = false;
  bool editUserData = false;
  bool switchBtn = true;
  bool? newStatus;
  final bool _wipUpload = false;
  String? newName, newPhone2;
  late var _rate;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<User>(context, listen: false);
    var screenSize = MediaQuery.of(context).size;

    File image;
    String imageURL;
    File workImages;
    String workImageURL;

    Future getImage(ImageSource source) async {
      // ignore: deprecated_member_use
      var image = await ImagePicker.platform.getImage(source: source);
      setState(() {
        image = File(image!.path) as XFile?;
      });
    }

    Future getWorkImage() async {
      // ignore: deprecated_member_use
      var image = await ImagePicker.platform.getImage(source: ImageSource.gallery);
      setState(() {
        workImages = File(image!.path);
      });
    }

    Future uploadPic(BuildContext context) async {
      /// if (_image != null) {
      ///   final _storage = FirebaseStorage.instance.ref().child('profilePics/${userState.uid.toString()}.jpg');
      ///   final uploadTask = _storage.putFile(_image);
      ///   setState(() {
      ///     _wipUpload = uploadTask.isInProgress;
      ///   });
      ///   final taskSnapshot = await uploadTask.onComplete;
      ///   imageURL = await taskSnapshot.ref.getDownloadURL();
      ///   DatabaseService(uid: userState.uid).updateUsersProfilePic(imageURL);
      ///   setState(() {
      ///     imageURL != null ? _wipUpload = false : _wipUpload = true;
      ///   });
      /// } else {
      ///   print('**************************************no image');
      /// }
    }

    Future uploadWorkImage(BuildContext context) async {
      /// if (_workImages != null) {
      ///   StorageReference _storage = FirebaseStorage.instance.ref().child(basename(_workImages.path));
      ///   StorageUploadTask uploadTask = _storage.putFile(_workImages);
      ///   setState(() {
      ///     _workImageUpload = uploadTask.isInProgress;
      ///     _workImageUpload
      ///         ? Fluttertoast.showToast(msg: lang(context, 'uploadPicPro'), toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM)
      ///         : _workImageUpload = false;
      ///   });
      ///   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      ///   workImageURL = await taskSnapshot.ref.getDownloadURL();
      ///   DatabaseService(uid: userState.uid).updateUsersWorkImages(workImageURL);
      /// } else {
      ///   print('******************* no image selected *******************');
      /// }
    }

    _showQRDialog(String? uid) {
      showModal(
        configuration: const FadeScaleTransitionConfiguration(),
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: <Widget>[
              Text(
                lang(context, 'requestRate')!,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: screenSize.width * .75,
                  child: Center(
                    child: QrImage(
                      data: uid!,
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text(lang(context, 'cancel')!, style: const TextStyle(color: Colors.white)),
                  color: kActiveBtnColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    changeProfilePic() {
      return showModalBottomSheet(
        isDismissible: true,
        backgroundColor: const Color(0x00ffffff),
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(15),
          decoration: containerDecoration(Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(lang(context, 'changePic')!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await getImage(ImageSource.gallery);
                  uploadPic(context);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: containerDecorationWithBorders(Colors.white),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: 30),
                      Text(lang(context, 'fromGallery')!),
                      const Icon(Icons.insert_photo, color: Colors.black),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await getImage(ImageSource.camera);
                  uploadPic(context);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: containerDecorationWithBorders(Colors.white),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: 30),
                      Text(lang(context, 'fromCamera')!),
                      const Icon(Icons.camera_alt, color: Colors.black),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return StreamBuilder<Model>(
      stream: DatabaseService(uid: userState.uid).currentUserData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.ratedMe!.isEmpty) {
            _rate = 0.0.toString();
          } else {
            _rate = (double.parse(snapshot.data!.rate!) / snapshot.data!.ratedMe!.length).toStringAsFixed(2);
          }
          return FadeX(
            reversed: true,
            duration: const Duration(milliseconds: 200),
            delay: 0.0,
            child: snapshot.data!.workImages != null
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
                    itemCount: snapshot.data!.workImages!.length + 1,
                    itemBuilder: (context, index) {
                      List imagesList = snapshot.data!.workImages!.reversed.toList();
                      if (index == 0) {
                        return Column(
                          children: <Widget>[
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                Container(height: 110, margin: const EdgeInsets.fromLTRB(0, 5, 0, 2), decoration: containerDecoration(Colors.white)),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(
                                      editUserData ? Icons.done : Icons.settings,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (editUserData == true) {
                                        DatabaseService(uid: userState.uid).updateUsersInfo(
                                          newName ?? snapshot.data!.name,
                                          newPhone2 ?? snapshot.data!.phone2,
                                          newStatus ?? true,
                                        );
                                      }
                                      setState(() {
                                        editUserData = !editUserData;
                                      });
                                    },
                                  ),
                                ),
                                snapshot.data!.type != null
                                    ? Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.add_photo_alternate,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            await getWorkImage();
                                            uploadWorkImage(context);
                                          },
                                        ),
                                      )
                                    : const SizedBox(),
                                snapshot.data!.type != null
                                    ? Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.comment,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            showCommentDialog(comments: snapshot.data!.ratedMe, context: context);
                                          },
                                        ))
                                    : const SizedBox(),
                                snapshot.data!.type != null
                                    ? Positioned(
                                        top: 0,
                                        left: 0,
                                        child: IconButton(
                                          icon: Image.asset('images/qr.png', scale: 2.4),
                                          onPressed: () async {
                                            _showQRDialog(snapshot.data!.myUID);
                                          },
                                        ),
                                      )
                                    : const SizedBox(),
                                Positioned(
                                  top: 10,
                                  child: GestureDetector(
                                    onTap: changeProfilePic,
                                    child: CircleAvatar(
                                      maxRadius: 45,
                                      child: snapshot.data!.picURL == null
                                          ? Image.asset('images/profilePic.png')
                                          : Image.network(
                                              snapshot.data!.picURL!,
                                              loadingBuilder: (context, child, progress) {
                                                return progress == null
                                                    ? const SizedBox()
                                                    : const CircularProgressIndicator(
                                                        backgroundColor: Colors.white70,
                                                      );
                                              },
                                            ),
                                      backgroundColor: kActiveBtnColor,
                                      backgroundImage: (snapshot.data!.picURL == null
                                          ? const AssetImage('images/profilePic.png')
                                          : NetworkImage(snapshot.data!.picURL!)) as ImageProvider<Object>?,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    top: 32,
                                    child: _wipUpload
                                        ? const CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                          )
                                        : const SizedBox()),
                                snapshot.data!.type != null
                                    ? Positioned(
                                        bottom: 10,
                                        child: Container(
                                          width: 55,
                                          height: 18,
                                          decoration: containerDecoration(Colors.black),
                                          padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                                size: 16,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 4, 3, 0),
                                                child: Text(
                                                  _rate,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            FadeX(
                              reversed: true,
                              duration: const Duration(milliseconds: 250),
                              delay: 0.1,
                              child: CustomTextField(
                                containerWidth: screenSize.width,
                                initialValue: snapshot.data!.name,
                                style: const TextStyle(fontSize: 16),
                                suffixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                                keyboardType: TextInputType.text,
                                editEnabled: editUserData,
                                validator: validateName,
                                onChange: (value) {
                                  setState(() {
                                    value.isEmpty ? validateName = true : validateName = false;
                                    validateName == false ? newName = value : newName = snapshot.data!.name;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 1),
                            snapshot.data!.phone2 != null || editUserData == true
                                ? FadeX(
                                    reversed: true,
                                    duration: const Duration(milliseconds: 250),
                                    delay: 0.2,
                                    child: CustomTextField(
                                      containerWidth: screenSize.width,
                                      style: const TextStyle(fontSize: 16),
                                      initialValue: snapshot.data!.phone2 ?? lang(context, 'phone2'),
                                      suffixIcon: const Icon(
                                        Icons.local_phone,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                      editEnabled: editUserData,
                                      keyboardType: TextInputType.phone,
                                      validator: validatePhone2,
                                      onChange: (value2) {
                                        setState(
                                          () {
                                            value2.isEmpty ? validatePhone2 = true : validatePhone2 = false;
                                            validatePhone2 == false ? newPhone2 = value2 : newPhone2 = null;
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 1),
                            FadeX(
                              reversed: true,
                              duration: const Duration(milliseconds: 250),
                              delay: 0.3,
                              child: Container(
                                decoration: containerDecoration(Colors.white),
                                padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                                height: 37,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const SizedBox(
                                      width: 0,
                                    ),
                                    Text('${snapshot.data!.phone}', style: const TextStyle(fontSize: 14)),
                                    const Icon(
                                      Icons.phone,
                                      size: 20,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            snapshot.data!.type != null
                                ? FadeX(
                                    reversed: true,
                                    duration: const Duration(milliseconds: 250),
                                    delay: 0.4,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            decoration: containerDecoration(Colors.white),
                                            padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
                                            height: 37,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                const SizedBox(),
                                                Text(lang(context, '${snapshot.data!.type}')!, style: const TextStyle(fontSize: 14)),
                                                const Icon(
                                                  Icons.work,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Expanded(
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),
                                            decoration: editUserData ? containerDecorationWithBorders(Colors.white) : containerDecoration(Colors.white),
                                            height: 37,
                                            curve: Curves.easeOut,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                editUserData
                                                    ? Switch(
                                                        onChanged: (value) => setState(() {
                                                          newStatus = value;
                                                        }),
                                                        value: newStatus ?? snapshot.data!.isAvailable!,
                                                        activeColor: kActiveBtnColor,
                                                      )
                                                    : const SizedBox(
                                                        width: 50,
                                                      ),
                                                Text(newStatus ?? snapshot.data!.isAvailable! ? lang(context, 'free')! : lang(context, 'notFree')!,
                                                    style: const TextStyle(fontSize: 16)),
                                                Image.asset('images/work.png', scale: 5.5),
                                              ],
                                            ),
                                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            snapshot.data!.workImages!.isEmpty && snapshot.data!.type != null
                                ? FadeX(
                                    reversed: true,
                                    duration: const Duration(milliseconds: 250),
                                    delay: 0.5,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await getWorkImage();
                                        uploadWorkImage(context);
                                      },
                                      child: Container(
                                        decoration: containerDecoration(Colors.white),
                                        height: 35,
                                        margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            const SizedBox(width: 50),
                                            Text(
                                              lang(context, 'postPics')!,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_photo_alternate,
                                                size: 20,
                                              ),
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 2),
                          ],
                        );
                      }
                      int nextIndex = index - 1;
                      return FadeX(
                        reversed: true,
                        duration: const Duration(milliseconds: 250),
                        delay: 0.6,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, pA, sA) {
                                      return FadeScaleTransition(
                                        animation: pA.drive(CurveTween(curve: Curves.easeOutCubic)),
                                        child: PhotoViewer(imageUrl: imagesList[nextIndex]),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                height: 300,
                                width: screenSize.width,
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.fromLTRB(5, 35, 5, 5),
                                decoration: containerDecoration(Colors.white),
                                child: CachedNetworkImage(
                                  imageUrl: imagesList[nextIndex],
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                onPressed: () {
                                  DatabaseService(uid: userState.uid).deleteUsersWorkImages(imagesList[nextIndex]);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                : const SizedBox(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
