import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sanai3i/files/database.dart';
import 'package:sanai3i/files/profile_browser.dart';
import 'package:sanai3i/files/reusable.dart';
import 'dart:async';

import 'package:sanai3i/files/settings.dart';

LocationData? _myLocation;

class ResultsInMaps extends StatefulWidget {
  final jopOrShop;
  final JopShopTile? jopShopTile;
  const ResultsInMaps({required this.jopOrShop, required this.jopShopTile});

  @override
  _ResultsInMapsState createState() => _ResultsInMapsState();
}

class _ResultsInMapsState extends State<ResultsInMaps> {
  late GoogleMapController _mapController;
  List<Marker> allMarkers = [];
  BehaviorSubject<double> radius = BehaviorSubject.seeded(40);
  Stream<dynamic>? query;
  late StreamSubscription _subscription;
  List<Widget> tapedMarker = [];
  List tapedMarkerUid = [];
  bool searchRadiusOpened = false;

  double sliderPos = -200.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _myCurrentLocation();
  }

  @override
  void dispose() {
    supCancel();
    super.dispose();
  }

  supCancel() async {
    await _subscription.cancel();
  }

  _myCurrentLocation() async {
    final myLocation = await Location().getLocation();
    setState(() {
      _myLocation = myLocation;
    });
  }

  animateToMyLocation() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_myLocation!.latitude!, _myLocation!.longitude!),
          zoom: 12,
        ),
      ),
    );
  }

  void onMapCreated(controller) {
    _startQuery();
    setState(() {
      _mapController = controller;
    });
    print('map ************************************************************');
  }

  _updateQuery(value) {
    final zoomMap = {40: 12, 60: 11.2, 80: 10.4, 100: 9.6, 120: 8.8};
    final zoom = zoomMap[value]!.toDouble();
    _mapController.moveCamera(CameraUpdate.zoomTo(zoom));
    setState(() => radius.add(value));
  }

  _startQuery() async {
    var myPos = await Location.instance.getLocation();
    double? lat = myPos.latitude, lon = myPos.longitude;
    var usersRef = FirebaseFirestore.instance.collection('Users').where('Type', isEqualTo: widget.jopOrShop);
    GeoFirePoint center = GeoFirePoint(lat!, lon!);
    _subscription = radius.switchMap((rad) {
      return GeoFireCollectionRef(usersRef).within(center: center, radius: rad, field: 'MyLocation', strictMode: true);
    }).listen(updateMarkers);
  }

  void updateMarkers(List<DocumentSnapshot<Map<String, dynamic>>> docList) async {
    //to ensure the current user won't appear on the map
    final user = FirebaseAuth.instance.currentUser;

    for (var doc in docList) {
      GeoPoint geoPoint = doc.get('MyLocation');
      var marker = Marker(
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          markerId: MarkerId(doc.get('UID')),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: doc.get('Name'),
          ),
          onTap: () {
            setState(() {
              getUserInfo(doc.get('UID'));
            });
          });
      if (doc.get('UID') != user!.uid) {
        setState(() {
          allMarkers.add(marker);
        });
      }
    }
  }

  getUserInfo(String? uid) async {
    Model model;
    model = await DatabaseService(uid: uid).infoTileDetails();
    if (tapedMarkerUid.contains(model.myUID)) {
      for (int index = 0; index <= tapedMarkerUid.length - 1; index++) {
        if (tapedMarkerUid[index] == uid) {
          _scrollController.animateTo(
            index * MediaQuery.of(context).size.width - 20,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    } else {
      if (tapedMarker.isEmpty) {
        setState(() {
          tapedMarker.add(MyCustomTile(modelDetails: model));
          tapedMarkerUid.add(model.myUID);
        });
      } else {
        setState(() {
          tapedMarker.add(MyCustomTile(modelDetails: model));
          tapedMarkerUid.add(model.myUID);
        });
        _scrollController.animateTo(
          tapedMarkerUid.length * MediaQuery.of(context).size.width - 20,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE4E6EB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: kActiveBtnColor,
          title: Text(
            langCode(context) == 'ar' ? widget.jopShopTile!.nameAr! : widget.jopShopTile!.nameEn!,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _myLocation != null
              ? GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(30.5694305, 31.3649991), zoom: 11),
                  onMapCreated: onMapCreated,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: true,
                  markers: Set.from(allMarkers),
                  myLocationButtonEnabled: false,
                  buildingsEnabled: false,
                  indoorViewEnabled: false,
                  trafficEnabled: false,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(lang(context, 'gettingLocation')!),
                        ),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
          Positioned(
            bottom: 80,
            right: 8,
            child: PositionedBtn(
              icon: Icons.location_on,
              onPressed: () {
                animateToMyLocation();
              },
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: 80,
            left: sliderPos,
            child: Container(
              width: 240,
              height: 50,
              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(30)), color: kActiveBtnColor),
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(height: 5),
                      Text(lang(context, 'expandSearch')!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(
                        height: 30,
                        child: Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.transparent,
                          max: 120,
                          min: 40,
                          divisions: 4,
                          value: radius.value,
                          onChanged: _updateQuery,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        sliderPos = sliderPos == -200 ? 5.0 : -200;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          tapedMarker.isEmpty
              ? const SizedBox(
                  height: 0,
                  width: 0,
                )
              : Positioned(
                  top: 5,
                  child: SizedBox(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      itemCount: tapedMarker.length,
                      itemBuilder: (context, index) {
                        return OpenContainer(
                          closedElevation: 0,
                          closedColor: Colors.transparent,
                          openElevation: 0,
                          openColor: Colors.transparent,
                          closedBuilder: (context, action) {
                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  tapedMarker.removeAt(index);
                                  tapedMarkerUid.removeAt(index);
                                });
                              },
                              child: tapedMarker[index],
                            );
                          },
                          openBuilder: (context, action) {
                            return ProfileBrowser(userUID: tapedMarkerUid[index]);
                          },
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
