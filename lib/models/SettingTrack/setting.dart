import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_anne/screen/auth/loginpage.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isEditing = false;
  String fullName = '';
  String email = '';
  int selectedIconIndex = 0;
  List<IconData> availableIcons = [
    // คน
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
    // สัตว์
    Icons.pets,
    Icons.bug_report,
    Icons.android,
    // อารมณ์
    Icons.emoji_emotions,
    Icons.emoji_nature,
    Icons.emoji_food_beverage,
    Icons.emoji_transportation,
    // อื่นๆ
    Icons.star,
    Icons.favorite,
    Icons.cake,
    Icons.celebration,
    Icons.palette,
  ];

  TextEditingController fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String uid = user.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection("users").doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        setState(() {
          fullName = data?['fullName'] ?? 'No Name';
          email = data?['email'] ?? '';
          selectedIconIndex = (data != null && data.containsKey('profileIcon'))
              ? data['profileIcon'] as int
              : 0;

          fullNameController.text = fullName;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String uid = user.uid;
      await _firestore.collection("users").doc(uid).update({
        'fullName': fullNameController.text,
      });

      setState(() {
        fullName = fullNameController.text;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data updated successfully")),
      );
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> _saveProfileIcon(int index) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        await _firestore.collection("users").doc(uid).update({
          'profileIcon': index,
        });

        setState(() {
          selectedIconIndex = index;
        });
      }
    } catch (e) {
      print("Error updating profile icon: $e");
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 450,
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              return IconButton(
                icon: Icon(availableIcons[index],
                    size: 40, color: Color(0XFFB3E680)),
                onPressed: () {
                  _saveProfileIcon(index);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF9F0),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 150,
                          backgroundColor: Color(0XFFB3E680),
                          child: Icon(
                            availableIcons[selectedIconIndex],
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 20,
                          child: GestureDetector(
                            onTap: _showIconPicker,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              child: Icon(Icons.edit,
                                  color: Color(0XFFB3E680), size: 25),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // กล่อง Full Name & Email
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: !isEditing
                                    ? Center(
                                        child: Text(
                                          'Full Name: $fullName',
                                          style: TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : TextField(
                                        controller: fullNameController,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          labelText: 'Full Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.edit, color: Colors.green[700]),
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                              ),
                            ],
                          ),
                          Divider(),
                          Text(
                            'Email: $email',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    if (isEditing)
                      ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0XFFB3E680),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text('Save'),
                      ),
                    SizedBox(height: 30),

                    // Logout Button
                    ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Log Out',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
