
import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/base/homescreentraveler.dart';
import 'package:iitj_travel/screens/base/traveldetailspage.dart';
import './mypage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class BottomNavigationScreen extends StatefulWidget {
  final bool clearButton;
  final int selectedIndex; // Add this parameter
  BottomNavigationScreen({required this.clearButton, required this.selectedIndex});
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();

}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late final String currentUserUid;
  bool clearButton=false;
  late int selectedIndex;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    this.clearButton = widget.clearButton;
    currentUserUid = FirebaseAuth.instance.currentUser!.uid; // Assign it here
    this.selectedIndex = widget.selectedIndex;
    _widgetOptions = <Widget>[
      HomeScreenTraveler(),
      TravelDetailsPage(),
      MyPage(),
    ];
  }

  static final List<String> _appBarTitles = <String>[
    'All Travelers',
    'Travel Details',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void clearFilters() {
    setState(() {
      _widgetOptions[0] = HomeScreenTraveler();
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavigationScreen(clearButton: false,selectedIndex: 0),
      ),
    );
  }

  String? selectedSource;
  String? selectedDestination;
  DateTime selectedDate = DateTime.now();
  bool isDateSelected = false;

  // Add this method to show a filter dialog
  void _showFilterDialog() {
    // Define variables to store selected values


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text('Source'),
                    value: selectedSource,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSource = newValue;
                      });
                    },
                    items: ['IIT Jodhpur', 'NIFT','Ayurveda', 'Station', 'Airport', 'City']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    hint: Text('Destination'),
                    value: selectedDestination,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDestination = newValue;
                      });
                    },
                    items: ['IIT Jodhpur','NIFT','Ayurveda', 'Station', 'Airport', 'City']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          isDateSelected = true;
                        });
                      }
                    },
                    child: Text(
                      isDateSelected ? "${selectedDate?.day.toString().padLeft(
                          2, '0')}-${selectedDate?.month.toString().padLeft(
                          2, '0')}-${selectedDate?.year}" : 'Select Date',
                      style: TextStyle(
                        color: Colors.white, // Text color
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(17, 86, 149, 1), // Button color
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Color.fromRGBO(17, 86, 149, 1), // Text color
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Use the selected values as needed
                    // Pass the selected filter values to the HomeScreen
                    print('Selected Source: $selectedSource');
                    print('Selected Destination: $selectedDestination');
                    if (isDateSelected) {
                      print('Selected Date: $selectedDate');
                    } else {
                      print('Date not selected');
                    }
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavigationScreen(clearButton:true,selectedIndex: 0),
                      ),
                    );

                    // Close the dialog
                  },
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: Color.fromRGBO(17, 86, 149, 1), // Text color
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          // If not in the "Commuters" tab, navigate to the "Commuters" tab
          setState(() {
            selectedIndex = 0;
          });
          return false; // Prevent default back button behavior
        }else {
          SystemNavigator.pop();
          return true;
        }
         // Allow default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable back button
          title: Text(_appBarTitles[selectedIndex]),
          backgroundColor: Color.fromRGBO(17, 86, 149, 1),
          actions: [
            if (selectedIndex == 0)
              if (clearButton == true)
                  ElevatedButton.icon(
                    onPressed: clearFilters,
                    icon: Icon(Icons.clear, color: Colors.white),
                    label: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(10, 66, 121, 1.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 1,
                        vertical: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      shadowColor: Colors.black26,
                      elevation: 4, // Shadow elevation
                    ),
                  )
              else
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: Icon(Icons.filter_list),
                ),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(selectedIndex),
        ),


        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Travelers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mark_email_read_sharp),
              label: 'Travel Details',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Color.fromRGBO(17, 86, 149, 1),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
