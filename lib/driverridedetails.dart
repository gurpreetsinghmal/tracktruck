import 'dart:async';
import 'dart:convert';

import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DriverRideDetails extends StatefulWidget {
  String id,status;
  DriverRideDetails({super.key,required this.id,required this.status});

  @override
  State<DriverRideDetails> createState() => _DriverRideDetailsState(this.id,this.status);
}

class _DriverRideDetailsState extends State<DriverRideDetails> {
  String? id;
  String? status;
  Location location = Location();
  LatLng? _currentLocation;
  LatLng? _startingPoint;
  LatLng? _endingPoint;
  Timer? _timer;

  _DriverRideDetailsState(String id,String status){
    this.id=id;
    this.status=status;
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(status=='started')
      { getlocation(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ride Detail"),),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            createdropdown()
          ],
        ),
      ),
    );
  }

  createdropdown() {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Rides').doc(id).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return Container(
              height:500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text("Ride ID : "+snapshot.data!['Id'].toString()),
                SizedBox(height: 10,),
                Text("Status : "+snapshot.data!['status'].toString()),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    snapshot.data!['status']=='waiting'? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed:()=>Rideaccepted(), child: Text("Accept")):SizedBox(),

                    snapshot.data!['status']=='waiting'?ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed:()=>Riderejected(), child: Text("Reject")):SizedBox(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    snapshot.data!['status']=='accepted'? ElevatedButton(
            style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
                        onPressed:()=>StartRide(), child: Text("Start Ride")):SizedBox(),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    snapshot.data!['status']=='started'? ElevatedButton(
            style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
                        onPressed:()=>EndRide(), child: Text("End Ride")):SizedBox(),
                  ],
                ),


                // snapshot.data['status']=='created'?assignRideButton():SizedBox(),
              ],),
            );
          })
      )
    );


  }

  Rideaccepted() async{
    await FirebaseFirestore.instance.collection('Rides').doc(id).update({'status':'accepted'}).then((v){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride Accepted Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Riderejected() async{
    await FirebaseFirestore.instance.collection('Rides').doc(id).update(
        { 'driverid':null,
          'status':'created',
        }).then((v){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride Rejected'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    });
  }

  StartRide() async{

    await getlocation();
    await FirebaseFirestore.instance.collection('Rides').doc(id).update(
        { 'start':"${_startingPoint!.latitude},${_startingPoint!.longitude}",
          'starttime': DateTime.now(),
          'status':'started',
        }).then((v){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride Started'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        status='started';
      });
      // Navigator.pop(context);
    });
  }

  getlocation() async{
    var _locationData = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
      _startingPoint = _currentLocation;
    });

    _timer=Timer.periodic(Duration(seconds: 5), (timer) {

      if(status=='started') {
        setcurrentlocation(_currentLocation!);
      }


     });

    if(status=='ended'){
      if (_timer != null) {
        _timer!.cancel();
        _timer = null; // Reset the timer variable
      }
      else{
        print("timer null");
      }
    }
    else{

    }


    }

  setcurrentlocation(LatLng current) async{

      print("$status - ${current.latitude},${current.longitude}");
      if(status=='started') {
        await FirebaseFirestore.instance.collection('Rides').doc(id).update(
            {
              'lastupdate': DateTime.now(),
              'current': "${current.latitude},${current.longitude}"
            });
      }


  }

  EndRide() async{
    await getlocation();
    await FirebaseFirestore.instance.collection('Rides').doc(id).update(
        { 'end':"${_currentLocation!.latitude},${_currentLocation!.longitude}",
          'endtime': DateTime.now(),
          'status':'ended',
        }).then((v){

      setState(() {
        status='ended';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride Ended'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    });
  }


}
