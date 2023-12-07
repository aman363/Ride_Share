import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetTravelDetailsPage extends StatefulWidget {
  const SetTravelDetailsPage({Key? key}) : super(key: key);

  @override
  _SetTravelDetailsPageState createState() => _SetTravelDetailsPageState();
}

class _SetTravelDetailsPageState extends State<SetTravelDetailsPage> {
  final TextEditingController _tripIdController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();
  final TextEditingController _cabNumberController = TextEditingController();

  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _tripIdController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _cabNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Travel Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tripIdController,
              decoration: InputDecoration(labelText: 'Trip ID'),
            ),
            TextField(
              controller: _driverNameController,
              decoration: InputDecoration(labelText: 'Driver Name'),
            ),
            TextField(
              controller: _driverPhoneController,
              decoration: InputDecoration(labelText: 'Driver Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _cabNumberController,
              decoration: InputDecoration(labelText: 'Cab Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveTravelDetails();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveTravelDetails() async {
    final String tripId = _tripIdController.text.trim();
    final String driverName = _driverNameController.text.trim();
    final String driverPhone = _driverPhoneController.text.trim();
    final String cabNumber = _cabNumberController.text.trim();

    try {
      // Create the travel details map
      Map<String, String> travelDetails = {
        'tripId': tripId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'cabNumber': cabNumber,
      };

      // Update the user's document in the Profile collection
      await FirebaseFirestore.instance
          .collection('Profile')
          .doc(currentUserUid)
          .update({'TravelDetails': travelDetails});

      // Show a success SnackBar or perform any other action upon successful completion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Travel details saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Handle any errors that occur during the update
      print('Error saving travel details: $error');
      // Show an error SnackBar or perform any other action upon error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save travel details. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
