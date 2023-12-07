import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePageAdmin extends StatefulWidget {
  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: _getBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Ride Shared',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
        ],
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return _buildRideSharedTab();
      case 1:
        return _buildFeedbackTab();
      default:
        return Container();
    }
  }

  Widget _buildRideSharedTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Profile').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> profiles = snapshot.data!.docs;

          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> userData = profiles[index].data() as Map<String, dynamic>;
              String uid = userData['uid'];
              String name = userData['basicInfo']['name'];
              List<String> sharedTravel = List<String>.from(userData['SharedTravel'] ?? []);

              if (sharedTravel.isNotEmpty) {
                return ListTile(
                  title: Text('User: $name ($uid)'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sharedTravel.map((travelDetails) {
                      return Text('Shared Ride: $travelDetails');
                    }).toList(),
                  ),
                );
              } else {
                return SizedBox.shrink(); // If no shared rides, show an empty SizedBox
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildFeedbackTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('UserFeedback').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> feedbackDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> feedbackData = feedbackDocs[index].data() as Map<String, dynamic>;
              String userUid = feedbackData['userUid'];
              String feedback = feedbackData['feedback'];

              return ListTile(
                title: Text('User UID: $userUid'),
                subtitle: Text('Feedback: $feedback'),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
