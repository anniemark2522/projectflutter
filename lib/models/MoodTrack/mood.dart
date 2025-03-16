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
  DateTime? _selectedDay;
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

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20),
              height: 800,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.white,
                  const Color.fromARGB(255, 210, 224, 190)
                ]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Select a note:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                                ? const Color.fromARGB(255, 255, 218, 238)
                                : const Color.fromARGB(255, 255, 255, 255),
                            foregroundColor: _note == "Feeling great today! 😊"
                                ? const Color.fromARGB(255, 61, 39, 39)
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
                                ? const Color.fromARGB(255, 255, 218, 238)
                                : const Color.fromARGB(255, 255, 255, 255),
                            foregroundColor: _note == "Not my best day 😔"
                                ? const Color.fromARGB(255, 61, 39, 39)
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
                                    ? const Color.fromARGB(255, 255, 218, 238)
                                    : const Color.fromARGB(255, 255, 255, 255),
                            foregroundColor:
                                _note == "Excited for something new! 🎉"
                                    ? const Color.fromARGB(255, 61, 39, 39)
                                    : Colors.black,
                          ),
                          child: Text("Excited! 🎉"),
                        ),
                      ],
                    ),
                    Text(
                      "Mood About Day?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 67, 53, 92),
                      ),
                    ),
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
                                ? const Color.fromARGB(255, 255, 218, 238)
                                : const Color.fromARGB(255, 255, 255, 255),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mood["emoji"]!,
                                  style: TextStyle(
                                      fontSize: 40,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  mood["value"]!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? const Color.fromARGB(255, 61, 39, 39)
                                        : Colors.black,
                                  ),
                                ),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
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
                _loadMood(); // Load mood for the selected day
              },
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFAACD), // Light pink
                      Color(0xFFF38CA6), // Deep pink
                    ],
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
                  color: Color(0xFFFFCC6C), // Warm orange
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26, blurRadius: 6, spreadRadius: 2)
                  ],
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: TextStyle(
                  color: Color(0xFF534684),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                outsideDaysVisible: false, // Hide outside month days
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
                  letterSpacing: 1.2,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Color(0xFF4B3B68),
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
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
        Positioned(
  bottom: 18,
  right: 15,
  child: FloatingActionButton(
    backgroundColor: _selectedDay != null &&
            _selectedDay!.year == DateTime.now().year &&
            _selectedDay!.month == DateTime.now().month &&
            _selectedDay!.day == DateTime.now().day
        ? (_isSavedToday
            ? const Color.fromARGB(255, 168, 168, 168) // สีเทาหากบันทึกแล้ว
            : const Color.fromARGB(255, 247, 167, 187)) // สีปกติหากยังไม่ได้บันทึก
        : const Color.fromARGB(255, 168, 168, 168), // สีเทาหากไม่ใช่วันปัจจุบัน
    onPressed: () {
      if (_selectedDay != null &&
          _selectedDay!.year == DateTime.now().year &&
          _selectedDay!.month == DateTime.now().month &&
          _selectedDay!.day == DateTime.now().day) {
        // ตรวจสอบว่ายังไม่ได้บันทึกในวันปัจจุบัน
        if (!_isSavedToday) {
          _showMoodPicker(); // เปิดตัวเลือกอารมณ์
        } else {
          // หากบันทึกข้อมูลแล้วในวันปัจจุบัน
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You can only save mood once per day!"),
            ),
          );
        }
      } else {
        // แสดงข้อความถ้าไม่ใช่วันปัจจุบัน
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You can only save mood for today!"),
          ),
        );
      }
    },
    shape: CircleBorder(),
    child: Icon(
      Icons.add,
      size: 25,
      color: Colors.white,
    ),
  ),
)

      ],
    );
  }
}


// Positioned(
//           bottom: 18,
//           right: 15,
//           child: FloatingActionButton(
//             backgroundColor: _isSavedToday
//                 ? const Color.fromARGB(255, 168, 168, 168)
//                 : const Color.fromARGB(255, 247, 167, 187), // Normal color
//             onPressed: _isSavedToday ? null : _showMoodPicker,
//             shape: CircleBorder(), // Disable if saved
//             child: Icon(
//               Icons.add,
//               size: 25,
//               color: Colors.white,
//             ),
//           ),
//         ),
