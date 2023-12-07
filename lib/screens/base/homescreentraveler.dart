import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreenTraveler extends StatefulWidget {
  const HomeScreenTraveler({Key? key}) : super(key: key);

  @override
  State<HomeScreenTraveler> createState() => _HomeScreenTravelerState();
}

class _HomeScreenTravelerState extends State<HomeScreenTraveler> {
  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Profile").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> users = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  title: Text(user['basicInfo']['name']),
                  subtitle: Text("UID: ${user['uid']}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (user['requestEstablished'] != null &&
                          user['requestEstablished'].contains(currentUserUid)) {
                        shareTravelDetails(currentUserUid, user['uid']);
                      } else {
                        makeCompanion(currentUserUid, user['uid']);
                      }
                    },
                    child: Text(
                      user['requestEstablished'] != null &&
                          user['requestEstablished'].contains(currentUserUid)
                          ? 'Share Travel Details'
                          : 'Make Companion',
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(), // Loading indicator
            );
          }
        },
      ),
    );
  }

  Future<void> makeCompanion(String yourUid, String companionUid) async {
    try {
      // Update requestEstablished array for the selected user
      await FirebaseFirestore.instance
          .collection('Profile')
          .doc(companionUid)
          .update({
        'requestEstablished': FieldValue.arrayUnion([yourUid])
      });

      // Update requestEstablished array for the current user
      await FirebaseFirestore.instance
          .collection('Profile')
          .doc(yourUid)
          .update({
        'requestEstablished': FieldValue.arrayUnion([companionUid])
      });

      // Show a confirmation SnackBar or perform any other action upon successful completion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now companions with ${yourUid}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Handle any errors that occur during the update
      print('Error making companion: $error');
      // Show an error SnackBar or perform any other action upon error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to make companion. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> shareTravelDetails(String yourUid, String companionUid) async {
    try {
      // Retrieve the travel details of the current user
      DocumentSnapshot travelDetailsDoc =
      await FirebaseFirestore.instance.collection('Profile').doc(yourUid).get();
      Map<String, dynamic> travelDetailsData =
      travelDetailsDoc.data() as Map<String, dynamic>;

      // Extract and format the travel details
      String tripId = travelDetailsData['TravelDetails']['tripId'];
      String driverName = travelDetailsData['TravelDetails']['driverName'];
      String driverPhone = travelDetailsData['TravelDetails']['driverPhone'];
      String cabNumber = travelDetailsData['TravelDetails']['cabNumber'];
      String formattedTravelDetails =
          'tripId: $tripId, driverName: $driverName, driverPhone: $driverPhone, cabNumber: $cabNumber';

      // Update the shared travel details in the companion's profile
      await FirebaseFirestore.instance
          .collection('Profile')
          .doc(companionUid)
          .update({
        'SharedTravel': FieldValue.arrayUnion([formattedTravelDetails])
      });

      // Update the history of the current user
      await FirebaseFirestore.instance
          .collection('Profile')
          .doc(yourUid)
          .update({
        'History': FieldValue.arrayUnion([formattedTravelDetails])
      });

      // Show a confirmation SnackBar or perform any other action upon successful completion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Travel details shared with ${companionUid}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Handle any errors that occur during the update
      print('Error sharing travel details: $error');
      // Show an error SnackBar or perform any other action upon error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share travel details. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
