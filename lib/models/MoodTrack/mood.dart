import 'package:flutter/material.dart';
import 'package:project_anne/service/database_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodCalendar extends StatefulWidget {
  @override
  _MoodCalendarState createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; //ใช้เเค่เเช็คการลือกวันอย่างเดียว
  String _selectedMood = "";
  String _note = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSavedToday = false;

  final List<Map<String, String>> moods = [
    {
      "emoji": "🤩",
      "value": "excited",
      "message": "Today is awesome.! 🎉",
    },
    {
      "emoji": "🥰",
      "value": "loved",
      "message": "So happy💖",
    },
    {
      "emoji": "😎",
      "value": "cool",
      "message": "It's super cool! 😎",
    },
    {
      "emoji": "😭",
      "value": "crying",
      "message": "It's okay. 🤍",
    },
    {
      "emoji": "😴",
      "value": "sleepy",
      "message": "Take a little break.💤",
    },
    {
      "emoji": "😡",
      "value": "angry",
      "message": "Not ready to talk to anyone..💢",
    },
  ];

  String get _uid => _auth.currentUser?.uid ?? "";

  void _saveMood(String emoji, String moodValue, String message) async {
    if (_selectedDay != null) {
      String formattedDate = _selectedDay!.toIso8601String().split("T")[0];

      await DatabaseService().addMoods(
        selectedDay: _selectedDay!,
        emoji: emoji,
        moodAboutDay: message,
        status: moodValue,
        note: _note,
      );

      setState(() {
        _selectedMood = emoji;
        _isSavedToday = true;
      });
    }
  }

  void _loadMood() async {
    if (_selectedDay != null) {
      Map<String, dynamic>? moodData =
          await DatabaseService().loadMood(_selectedDay!);

      if (moodData != null) {
        setState(() {
          _selectedMood = moodData["emoji"] ?? "";
          _note = moodData["note"] ?? "";
          _isSavedToday = true;
        });
      } else {
        setState(() {
          _selectedMood = "";
          _note = "";
          _isSavedToday = false;
        });
      }
    }
  }

  void _showMoodPicker(DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: _getMoodStream(selectedDay),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("No mood data found."));
            }

            var moodData = snapshot.data!.data() as Map<String, dynamic>;

            return Container(
              padding: EdgeInsets.all(20),
              height: 800,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color.fromARGB(255, 210, 224, 190)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text("Select a note:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _note = "Feeling great today! 😊";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _note == "Feeling great today! 😊"
                                ? Color.fromARGB(255, 255, 218, 238)
                                : Colors.white,
                            foregroundColor: _note == "Feeling great today! 😊"
                                ? Color.fromARGB(255, 61, 39, 39)
                                : Colors.black,
                          ),
                          child: Text("Feeling great! 😊"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _note = "Not my best day 😔";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _note == "Not my best day 😔"
                                ? Color.fromARGB(255, 255, 218, 238)
                                : Colors.white,
                            foregroundColor: _note == "Not my best day 😔"
                                ? Color.fromARGB(255, 61, 39, 39)
                                : Colors.black,
                          ),
                          child: Text("Not my best 😔"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _note = "Excited for something new! 🎉";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _note == "Excited for something new! 🎉"
                                    ? Color.fromARGB(255, 255, 218, 238)
                                    : Colors.white,
                            foregroundColor:
                                _note == "Excited for something new! 🎉"
                                    ? Color.fromARGB(255, 61, 39, 39)
                                    : Colors.black,
                          ),
                          child: Text("Excited! 🎉"),
                        ),
                      ],
                    ),
                    Text("Mood About Day?",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: moods.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        bool isSelected = _selectedMood == mood["emoji"]!;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood["emoji"]!;
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            color: isSelected
                                ? Color.fromARGB(255, 255, 218, 238)
                                : Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(mood["emoji"]!,
                                    style: TextStyle(fontSize: 40)),
                                SizedBox(height: 5),
                                Text(mood["value"]!,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedMood.isNotEmpty && _note.isNotEmpty) {
                          _saveMood(
                              _selectedMood,
                              moods.firstWhere((mood) =>
                                  mood["emoji"] == _selectedMood)["value"]!,
                              moods.firstWhere((mood) =>
                                  mood["emoji"] == _selectedMood)["message"]!);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Please select both mood and note.")),
                          );
                        }
                      },
                      child: Text("Save Mood & Note"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stream<DocumentSnapshot> _getMoodStream(DateTime selectedDay) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String formattedDate = selectedDay.toIso8601String().split("T")[0];

      return _firestore
          .collection('users')
          .doc(uid)
          .collection('moods')
          .doc(formattedDate)
          .snapshots();
    }
    return Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF9F0),
      body: Column(
        children: [
          // TableCalendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadMood();
            },
            calendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFAACD), Color(0xFFF38CA6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 6,
                      spreadRadius: 2)
                ],
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFFFFCC6C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 6, spreadRadius: 2)
                ],
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: Color(0xFF4B3B68)),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: Color(0xFF4B3B68)),
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B3B68),
              ),
            ),
          ),
          SizedBox(height: 10),
          _selectedMood.isNotEmpty
              ? Column(
                  children: [
                    Text("Your Mood: $_selectedMood",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    if (_note.isNotEmpty)
                      Card(
                        color: Colors.blue.shade50,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Text("📖 $_note",
                              style: TextStyle(
                                  fontSize: 18, fontStyle: FontStyle.italic)),
                        ),
                      ),
                  ],
                )
              : Text("Please Tell Something about Your Mood...",
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _selectedDay != null &&
                _selectedDay!.year == DateTime.now().year &&
                _selectedDay!.month == DateTime.now().month &&
                _selectedDay!.day == DateTime.now().day
            ? (_isSavedToday ? Colors.grey : Color.fromARGB(255, 247, 167, 187))
            : Colors.grey,
        onPressed: () {
          if (_selectedDay != null &&
              _selectedDay!.year == DateTime.now().year &&
              _selectedDay!.month == DateTime.now().month &&
              _selectedDay!.day == DateTime.now().day) {
            if (!_isSavedToday) {
              _showMoodPicker(_selectedDay!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You can only save mood once per day!")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("You can only save mood for today!")),
            );
          }
        },
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 25, color: Colors.white),
      ),
    );
  }
}
