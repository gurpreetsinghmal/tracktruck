import 'dart:convert';

import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracktruck/mapscreen.dart';

class RideDetails extends StatefulWidget {
  DocumentSnapshot details;
  RideDetails({super.key,required this.details});

  @override
  State<RideDetails> createState() => _RideDetailsState(this.details);
}

class _RideDetailsState extends State<RideDetails> {
  DocumentSnapshot? details;
  String? selecteddriver;
  _RideDetailsState(DocumentSnapshot details){
    this.details=details;
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ride Detail"),),
      body: Container(
        width: double.infinity,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Ride ID : "+details!['Id'].toString()),SizedBox(height: 20,),
            Text("Status : "+details!['status'].toString()),SizedBox(height: 20,),
            details!['status']=='created'?createdropdown():SizedBox(),
            details!['status']=='created'?assignRideButton():SizedBox(),
            details!['status']=='started'?ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      MapScreen(id:details!['Id'].toString()),
                ));
              },
              child: Text('View Location on Map'),
            ):SizedBox(),

          ],
        ),
      ),
    );
  }






  createdropdown() {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Drivers').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            List<DropdownMenuItem<String>> dropdownItems = [];
            snapshot.data!.docs.forEach((doc) {
              String category = doc['Name'];
              String Id = doc['email'];// Assuming 'name' is the field in Firestore
              dropdownItems.add(
                DropdownMenuItem(
                  value: Id,
                  child: Text(category),
                ),
              );
            });

            return DropdownButton<String>(
              items: dropdownItems,
              onChanged: (String? newValue) {
                setState(() {
                  selecteddriver=newValue;

                });
              },
              hint: Text('Select Driver'), // Optional
              value: selecteddriver,
              // Optional: Allows the dropdown to expand to fit its parent
            );
          },
        ),

      ),
    );
  }

  assignRideButton() {
    return ElevatedButton(onPressed: ()=>_saveToFirestore(), child: Text("Assign Ride"));
  }

  _saveToFirestore() async {

    try {
      // Define the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define the collection and document reference
      CollectionReference ridesRef = firestore.collection('Rides');
      DocumentReference rideDocRef = ridesRef.doc(details!['Id']);

      // Prepare data to be saved
      Map<String, dynamic> data = {
        'driverid': selecteddriver,
        'status': 'waiting',
      };

      // Perform the write operation
      await rideDocRef.update(data);

      // Show success message if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data saved Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      // Show error message if there's an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


}
