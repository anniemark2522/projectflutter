import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_anne/models/ExpenseTrack/numberPad.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SavingPage extends StatefulWidget {
  const SavingPage({super.key});

  @override
  State<SavingPage> createState() => _SavingPageState();
}

class _SavingPageState extends State<SavingPage> {
  final DatabaseService _databaseService = DatabaseService();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    if (_selectedDay == null) {
      _selectedDay = DateTime.now();
    }
  }

  final descriptionController = TextEditingController();
  final moneyController = TextEditingController();

  int money = 0;
  String name = "";
  String amount = "0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF9F0),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            calendarFormat: CalendarFormat.week,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return _selectedDay != null &&
                  day.year == _selectedDay!.year &&
                  day.month == _selectedDay!.month &&
                  day.day == _selectedDay!.day;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0XFFB3E680),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(
                  color: Color(0XFFFEB0B9),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                    color: Color(0xFF534684),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                weekendTextStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: TextStyle(
                    color: Color(0xFF534684),
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('expenses')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No expenses found'));
              }

              List<Map<String, dynamic>> expenses = snapshot.data!.docs
                  .map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    // เพิ่ม ID ของเอกสารเข้าไปในข้อมูลของ expense
                    data['id'] = doc.id;
                    return data;
                  })
                  .where((expense) =>
                      expense.containsKey('Date') && expense['Date'] != null)
                  .toList();

              // สร้าง Map โดยใช้วันที่เป็น key
              Map<String, List<Map<String, dynamic>>> expensesByDate = {};
              for (var expense in expenses) {
                try {
                  // ตรวจสอบชื่อฟิลด์ว่า "Date" หรือ "date"
                  Timestamp timestamp = expense['Date']; // ใช้ "Date" (D ใหญ่)
                  String dateKey =
                      DateFormat('yyyy-MM-dd').format(timestamp.toDate());

                  if (!expensesByDate.containsKey(dateKey)) {
                    expensesByDate[dateKey] = [];
                  }
                  expensesByDate[dateKey]!.add(expense);
                } catch (e) {
                  print('Error แปลงวันที่: $e, expense: $expense');
                }
              }

              // Debug ค่า `_selectedDay`
              print('Selected day: ${_selectedDay}');
              print(expensesByDate);
              print('Selected day: ${_selectedDay}');
              print('Formatted selected day: ${_getDateOnly(_selectedDay!)}');
              print(
                  'Available dates in expensesByDate: ${expensesByDate.keys.toList()}');

              return Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white),
                  child: _selectedDay == null ||
                          !expensesByDate
                              .containsKey(_getDateOnly(_selectedDay!))
                      ? Center(
                          child: Text(
                              'No expenses for this date ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                              style: TextStyle(
                                  color: Color(0xFF534684),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)))
                      : ListView.builder(
                          itemCount: expensesByDate[_getDateOnly(_selectedDay!)]
                                  ?.length ??
                              0,
                          itemBuilder: (context, index) {
                            var expense = expensesByDate[
                                _getDateOnly(_selectedDay!)]![index];
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      String expenseId = expense['id'];
                                      _databaseService.deleteExpense(expenseId);
                                    },
                                    icon: Icons.delete,
                                    backgroundColor: Color(0XFFFEB0B9),
                                    foregroundColor: Color(0xFF534684),
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                child: ListTile(
                                  trailing: Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF534684),
                                  ),
                                  leading: Icon(Icons.monetization_on,
                                      color: Color(0XFFFEB0B9)),
                                  title: Text(
                                    'Amount: ${expense['amount'].toString()} THB',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF534684),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Category: ${expense['typeAmount']}',
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFF534684)),
                                  ),
                                ),
                              ),
                            );
                          }),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay == null) {
            setState(() {
              _selectedDay = DateTime.now();
            });
          }
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              context: context,
              builder: (
                context,
              ) =>
                  NumberPadBottomSheet(
                    selectedDay: _selectedDay!,
                  ));
        },
        backgroundColor: Color(0XFFFEB0B9),
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

String _getDateOnly(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
