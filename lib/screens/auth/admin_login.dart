
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/base/bottom_navigation_screen.dart';
import 'package:iitj_travel/screens/base/homescreenadmin.dart';
import 'package:iitj_travel/screens/onboarding/onboarding.dart';
import '../reusable_widgets.dart';
import './signup_screen.dart';
import './reset_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/shared_preference_services.dart';

enum _LoginStatus {
  Initial,
  LoggingIn,
  LoggedIn,
  Error,
}

class AdminSignInScreen extends StatefulWidget {
  const AdminSignInScreen({Key? key}) : super(key: key);

  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  _LoginStatus loginStatus = _LoginStatus.Initial;
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  String sr = "";

  Map<String, dynamic>? fetchedData;
  bool flag = false;

  Future<bool> checkAdminEmail(String email) async {
    bool isAdmin = false;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("Admin")
          .doc("Info")
          .get();

      if (snapshot.exists) {
        // Assuming 'email' is the field name in the 'Info' document
        List<dynamic> adminEmails = snapshot.get('email');
        print(adminEmails);
        isAdmin = adminEmails.contains(email);
      }
    } catch (e) {
      print("Error fetching admin emails: $e");
    }
    return isAdmin;
  }

  // @override
  // void initState() {
  //   String uid = getCurrentUID();
  //   if (uid != ""){
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => flag
  //                 ? const SignUpOnboard()
  //                 : HomeScreen(
  //               uid: uid,
  //             )));
  //   }
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 80,
                    ),
                    Center(

                      child: Text(
                        "Enter login Info",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),

                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Email Address",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    reusableTextField("Enter Email Address",
                        Icons.person_outline, false, _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Password",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    reusableTextField("Enter Password", Icons.lock_outline, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        sr,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          // fontFamily: 'Arial',
                          // fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          // height: 0,
                          // textAlign:
                        ),
                      ),
                    ),

                    forgetPassword(context),
                    const SizedBox(height: 10),


                    firebaseUIButton(context, "Login", ()  async{
                      setState(() {
                        loginStatus = _LoginStatus.LoggingIn;
                      });

                      String username = _emailTextController.text;
                      String password = _passwordTextController.text;
                      bool isAdmin = await checkAdminEmail(username);
                      if(isAdmin){
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                          email: username, password: password)
                          .then((value) async {
                        if (!FirebaseAuth.instance.currentUser!.emailVerified) {
                          var snackBar = SnackBar(
                            content: Text("Email not verified"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          FirebaseAuth.instance.signOut();
                        }

                        if (FirebaseAuth.instance.currentUser!.emailVerified) {
                          SharedPreferencesService.updateBoolValue(true);
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          final User? user = auth.currentUser;
                          final uid = user?.uid;
                          DocumentSnapshot snapshot = await FirebaseFirestore
                              .instance
                              .collection("Profile")
                              .doc(uid)
                              .get();
                          if (snapshot.exists) {
                            setState(() {
                              fetchedData =
                              snapshot.data() as Map<String, dynamic>?;
                            });
                          }
                          if(fetchedData!['basicInfo']['name'].isEmpty){
                            flag=true;
                          }
                          setState(() {
                            loginStatus = _LoginStatus.LoggedIn;
                          });
                          // ignore: use_build_context_synchronously
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => flag
                                      ? OnboardingScreen() : HomePageAdmin()));
                        }
                      }).onError((error, stackTrace) {
                        print(error.toString());
                        if (error.toString() ==
                            "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
                          setState(() {
                            sr = "*Password does not match";
                          });
                          setState(() {
                            loginStatus = _LoginStatus.Initial;
                          });
                        }
                        if (error.toString() ==
                            "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
                          setState(() {
                            sr = "*User Not Found";
                          });
                          setState(() {
                            loginStatus = _LoginStatus.Initial;
                          });
                        }
                        else if (error.toString() =="[firebase_auth/invalid-email] The email address is badly formatted."){
                          setState(() {
                            sr = "*The email address is badly formatted";
                          });
                          setState(() {
                            loginStatus = _LoginStatus.Initial;
                          });
                        }
                      });
                    }
                    else{
                        setState(() {
                          loginStatus = _LoginStatus.Error;
                          sr = "*You are not authorized as an admin";
                        });
                    }
                    }),
                    const SizedBox(height: 5),
                    signUpOption()
                  ],
                ),
              ),
            ),
          ),
          if (loginStatus == _LoginStatus.LoggingIn)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5), // Translucent background color
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      "Logging In...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't Have Account?",
            style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: Text(
            " Sign Up",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomLeft,
      child: TextButton(
        child: Text(
          "Forget Password",
          style: const TextStyle(color: Colors.black87),
          textAlign: TextAlign.left,
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResetPassword())),
      ),
    );
  }
}



