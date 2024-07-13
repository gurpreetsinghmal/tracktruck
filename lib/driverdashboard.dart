import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracktruck/driverridedetails.dart';
import 'package:tracktruck/login.dart';

class Driverdashboard extends StatefulWidget {
  const Driverdashboard({super.key});

  @override
  State<Driverdashboard> createState() => _DriverdashboardState();
}

class _DriverdashboardState extends State<Driverdashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Rides"),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((v) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                });
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: loadRidesList(),
    );
  }

  loadRidesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Rides')
          .where('driverid',
              isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Extract the list of documents from snapshot
        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return documents.length == 0
            ? Center(child: Text("No Rides for you"))
            : ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  // Extract fields from documents[index] data
                  final rideid = documents[index].id;
                  final rideNumber = index + 1;

                  return ListTile(
                    title: Text("Ride : $rideNumber"),
                    subtitle: Text(documents[index]['status']+"-"+timeAgo(documents[index]['lastupdate']),style: TextStyle(color: getcolor(documents[index]['status'])),),
                    trailing: IconButton(
                      icon: Icon(Icons.info,color: getcolor(documents[index]['status']),),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverRideDetails(
                                  id: documents[index]['Id'],
                                  status: documents[index]['status'])
                          ),
                        );
                      },
                    ),
                  );
                },
              );
      },
    );
  }

  String timeAgo(Timestamp timestamp) {
    if(timestamp==null){
      return 'Not yet set';
    }

    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    var difference = now.difference(date);

    if (difference.inSeconds < 5) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'calculating';
    }
  }

  getcolor(text) {
    switch(text){
      case 'waiting': return Colors.amber;
      case 'accepted': return Colors.green;
      case 'started': return Colors.blue;
      case 'rejected': return Colors.red;
      case 'ended': return Colors.purple;

    }
  }
}
