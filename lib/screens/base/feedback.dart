import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _tripIdController = TextEditingController();
  final int maxWordLimit = 300;

  String _phoneNumber = '';
  String _email = '';
  String _instagram = '';
  String _facebook = '';

  @override
  void initState() {
    super.initState();
    _fetchContactInfo(); // Fetch contact information when the widget initializes
  }

  Future<void> _fetchContactInfo() async {
    try {
      DocumentSnapshot contactInfoDoc = await FirebaseFirestore.instance
          .collection('ContactUs')
          .doc('contactInfo')
          .get();

      if (contactInfoDoc.exists) {
        setState(() {
          _phoneNumber = contactInfoDoc['phone'];
          _email = contactInfoDoc['mail'];
          _instagram = contactInfoDoc['instagram'];
          _facebook = contactInfoDoc['facebook'];
        });
      }
    } catch (error) {
      print('Error fetching contact information: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Give Feedback"),
        backgroundColor: Color.fromRGBO(17, 86, 149, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Feedback:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          TextField(
                            controller: _feedbackController,
                            maxLines: 5,
                            maxLength: maxWordLimit,
                            decoration: InputDecoration(
                              hintText: "Write your feedback here...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: TextField(
                                controller: _tripIdController,
                                decoration: InputDecoration(
                                  hintText: "Trip ID",
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _submitFeedback();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(17, 86, 149, 1),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height:40),// Spacer to push icons to the bottom
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _launchURL(_instagram);
                          },
                          child: FaIcon(
                            FontAwesomeIcons.instagram,
                            size: 30,
                            color: Color.fromRGBO(17, 86, 149, 1),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            _launchURL(_facebook);
                          },
                          child: FaIcon(
                            FontAwesomeIcons.facebook,
                            size: 30,
                            color: Color.fromRGBO(17, 86, 149, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    String feedback = _feedbackController.text.trim();
    String tripId = _tripIdController.text.trim();
    if (feedback.isNotEmpty) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DateTime now = DateTime.now();

      Map<String, dynamic> feedbackData = {
        'userUid': uid,
        'feedback': feedback,
        'tripId': tripId, // Store tripId along with feedback
        'timestamp': now,
      };

      await FirebaseFirestore.instance.collection("UserFeedback").add(feedbackData);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Feedback Submitted"),
            content: Text("Thank you for your feedback!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Close the Contact Us page
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please provide your feedback before submitting."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (error) {
      print('Error launching URL: $error');
      // If the component name is null, try opening the URL in a web browser
      if (url.startsWith('https://')) {
        await launch(url, forceSafariVC: false);
      }
    }
  }
}
