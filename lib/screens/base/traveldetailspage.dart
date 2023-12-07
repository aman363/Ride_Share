import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TravelDetailsPage extends StatefulWidget {
  const TravelDetailsPage({Key? key}) : super(key: key);

  @override
  State<TravelDetailsPage> createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color.fromRGBO(17, 86, 149, 1), // Set the color of the TabBar
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white, // Set the color of the indicator
              tabs: [
                Tab(text: 'Shared by Me'),
                Tab(text: 'Shared by Others'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSharedByMeTab(),
                _buildSharedByOthersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedByMeTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Profile')
          .doc(currentUserUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> userData =
          snapshot.data!.data() as Map<String, dynamic>;
          List<String> history = List<String>.from(userData['History'] ?? []);

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              // Parse and display travel details in history
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    history[index],
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSharedByOthersTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Profile')
          .doc(currentUserUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> userData =
          snapshot.data!.data() as Map<String, dynamic>;
          List<String> sharedTravel =
          List<String>.from(userData['SharedTravel'] ?? []);

          return ListView.builder(
            itemCount: sharedTravel.length,
            itemBuilder: (context, index) {
              // Parse and display travel details in SharedTravel
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    sharedTravel[index],
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
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
