import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracktruck/login.dart';
import 'package:tracktruck/ridedetails.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          actions: [
            IconButton(onPressed: () {
              FirebaseAuth.instance.signOut().then((v) {
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), (
                      Route<dynamic> route) => false,);
              });
            }, icon: Icon(Icons.logout))
          ],),

        body: loadRidesList(),
        floatingActionButton: FloatingActionButton.extended(
           backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            onPressed: () => addNewride(), label: Text("+"))
    );
  }

  loadDriverList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Drivers').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Extract the list of documents from snapshot
        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            // Extract fields from documents[index] data
            final driverId = documents[index].id;
            final driverName = documents[index]['Name'];
            final driverPhone = documents[index]['Phone'];

            return ListTile(
              title: Text(driverName),
              subtitle: Text(driverPhone),
              trailing: IconButton(
                icon: Icon(Icons.assignment),
                onPressed: () {

                },
              ),
              onTap: () {

              },
            );
          },
        );
      },
    );
  }

  loadRidesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Rides').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Extract the list of documents from snapshot
        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            // Extract fields from documents[index] data
            final rideid = documents[index].id;
            final rideNumber = index + 1;
            final ridestatus=documents[index]['status'];


            return ListTile(
              title: Text("Ride : $rideNumber"),
              subtitle: Text(ridestatus,style: TextStyle(color: getcolor(ridestatus)),),
              trailing: IconButton(
                icon: Icon(Icons.assignment),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        RideDetails(details: documents[index])),
                  );
                },
              ),
              onTap: () {

              },
            );
          },
        );
      },
    );
  }

  getcolor(text) {
    switch(text){
      case 'waiting': return Colors.amber;
      case 'accepted': return Colors.green;
      case 'started': return Colors.blue;
      case 'rejected': return Colors.red;
      case 'ended': return Colors.purple;
      case 'created': return Colors.pink;

    }
  }
  addNewride() async {

    Map<String, dynamic> rideData = {
      'current': null,
      'driverid': null,
      'endtime': null,
      'start': null,
      'starttime': null,
      'status': 'created',
    };
    DocumentReference docRef=await FirebaseFirestore.instance.collection('Rides').add(rideData);

    // Get the auto-generated document ID
    String docId = docRef.id;

    // Optionally, store the document ID along with other data
    Map<String, dynamic> dataWithId = {
      'Id': docId,
      ...rideData, // Spread operator (...) to include all fields from rideData
    };

    // Update the document with the generated ID
    await docRef.update(dataWithId);

  }
}
