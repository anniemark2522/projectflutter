import 'package:flutter/material.dart';
import 'package:project_anne/models/ExpenseTrack/expense.dart';
import 'package:project_anne/models/MoodTrack/mood.dart';
import 'package:project_anne/models/SettingTrack/setting.dart';
import '../models/BookTrack/book_page.dart';
import '../models/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String uid;
  final int initialIndex;

  const HomePage({Key? key, required this.uid, this.initialIndex = 0})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int screenIndex = 0;
  int profileIcon = 0;

  final List<String> appBarTitles = [
    'Daily Track', // index 0 - HomePage
    'Book Track', // index 1 - Book
    'Expense Track', // index 2 - Expense
    'Mood Track', // index 3 - Mood
    'Settings', // index 4 - Settings
  ];

  List<IconData> availableIcons = [
    Icons.person,
    Icons.account_circle,
    Icons.emoji_people,
    Icons.face,
    Icons.sentiment_satisfied,
    Icons.mood,
    Icons.self_improvement,
    Icons.psychology,
    Icons.accessibility_new,
    Icons.boy,
    Icons.girl,
    Icons.man,
    Icons.woman,
    Icons.pets,
    Icons.bug_report,
    Icons.android,
    Icons.emoji_emotions,
    Icons.emoji_nature,
    Icons.emoji_food_beverage,
    Icons.emoji_transportation,
    Icons.star,
    Icons.favorite,
    Icons.cake,
    Icons.celebration,
    Icons.palette,
  ];
  @override
  void initState() {
    super.initState();
    screenIndex = widget.initialIndex;
    _fetchUserProfileIcon();
  }

  Future<void> _fetchUserProfileIcon() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(widget.uid)
        .get();

    if (snapshot.exists) {
      setState(() {
        profileIcon = snapshot.data()?['profileIcon'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF9F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Track (4)-Photoroom.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(width: 2),
            Text(
              appBarTitles[screenIndex],
              style: TextStyle(
                color: Color(0xFF534684),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundColor: Color(0XFFB3E680),
                      child: Icon(Icons.person, color: Colors.white, size: 25),
                    ),
                  );
                }
                Map<String, dynamic>? data =
                    snapshot.data!.data() as Map<String, dynamic>?;
                int profileIcon = 0;

                if (data != null &&
                    data.containsKey('profileIcon') &&
                    data['profileIcon'] is int) {
                  profileIcon = data['profileIcon'];
                }

                if (profileIcon < 0 || profileIcon >= availableIcons.length) {
                  profileIcon = 0;
                }
                return Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      print("Avatar");
                    },
                    child: CircleAvatar(
                      backgroundColor: Color(0XFFB3E680),
                      child: Icon(
                        availableIcons[profileIcon],
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                );
              })
        ],
      ),
      body: IndexedStack(
        index: screenIndex,
        children: [
          Home(),
          BookPage(),
          SavingPage(),
          MoodCalendar(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    screenIndex = 1;
                  });
                },
                icon: Icon(
                  Icons.book,
                  color: screenIndex == 1 ? Color(0xFFC5E1A5) : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    screenIndex = 2;
                  });
                },
                icon: Icon(
                  Icons.savings,
                  color: screenIndex == 2 ? Color(0xFFC5E1A5) : Colors.grey,
                ),
              ),
              SizedBox(width: 50),
              IconButton(
                onPressed: () {
                  setState(() {
                    screenIndex = 3;
                  });
                },
                icon: Icon(
                  Icons.emoji_emotions,
                  color: screenIndex == 3 ? Color(0xFFC5E1A5) : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    screenIndex = 4;
                  });
                },
                icon: Icon(
                  Icons.settings,
                  color: screenIndex == 4 ? Color(0xFFC5E1A5) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                screenIndex = 0;
              });
            },
            backgroundColor: Color(0xFFC5E1A5),
            shape: CircleBorder(),
            child: Icon(Icons.home, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }
}
