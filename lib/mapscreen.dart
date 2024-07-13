import 'package:flutter/material.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key,required this.id});
  final String id;

  @override
  State<MapScreen> createState() => _MapScreenState(this.id);
}

class _MapScreenState extends State<MapScreen> {


  Location location = Location();
  GoogleMapController? _controller;
  LatLng? _currentLocation;
  LatLng? _startingPoint;
  LatLng? _endingPoint;
  LatLng? _camerview;
  bool _isTracking = false;
  String? id;

  _MapScreenState(String id){
    this.id=id;
  }


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Live Location Tracker'),
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Rides')
                .doc(id)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.data != null) {
                _currentLocation = getlatlngvalues(snapshot.data!['current']);
                _startingPoint = getlatlngvalues(snapshot.data!['start']);
                _endingPoint = getlatlngvalues(snapshot.data!['end']);

                if(_camerview==null){
                  _camerview=_currentLocation;
                }


                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _camerview!,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _controller = controller;
                        _controller!.animateCamera(
                            CameraUpdate.newLatLng(_camerview!));
                      },
                      markers: {
                        if (_startingPoint != null)
                          Marker(
                            markerId: MarkerId('start'),
                            position: _startingPoint!,
                            infoWindow: InfoWindow(title: 'Starting Point'),
                          ),
                        if (_endingPoint != null)
                          Marker(
                            markerId: MarkerId('end'),
                            position: _endingPoint!,
                            infoWindow: InfoWindow(title: 'Ending Point'),
                          ),
                        Marker(
                          markerId: MarkerId('current'),
                          position: _currentLocation!,
                          infoWindow: InfoWindow(title: 'Current Location'),
                        ),
                      },
                    ),
                    Positioned(
                      bottom: 50,
                      left: 10,
                      child: Column(
                        children: [
                          _startingPoint!=null?ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: () {
                              setState(() {
                                _camerview=_startingPoint;

                              });
                            },
                            child: Text('Move to  Starting Point'),
                          ):SizedBox(),
                          _endingPoint!=null?ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: () {
                              setState(() {
                                _camerview=_endingPoint;

                              });
                            },
                            child: Text('Move to Ending Point'),
                          ):SizedBox(),
                          _currentLocation!=null?ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: () {
                              setState(() {
                                _camerview=_currentLocation;
                              });
                            },
                            child: Text('Move to Current Point'),
                          ):SizedBox(),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return CircularProgressIndicator();
            }

        ));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getmap(String id) {
    return FirebaseFirestore.instance.collection('Rides').doc(id).snapshots();
  }

  LatLng? getlatlngvalues(String? str){
    if(str==null){
      return null;
    }
    List<String> val= str.split(',');
    return LatLng(double.parse(val[0]),double.parse(val[1]));
  }
}