import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../service/database_service.dart';

class NumberPadBottomSheet extends StatefulWidget {
  final DateTime selectedDay;

  NumberPadBottomSheet({required this.selectedDay});

  @override
  _NumberPadBottomSheetState createState() => _NumberPadBottomSheetState();
}

class _NumberPadBottomSheetState extends State<NumberPadBottomSheet> {
  final DatabaseService _databaseService = DatabaseService();
  String amount = "0";
  TextEditingController _moneyController = TextEditingController();
  int? selectedIcon;
  String? selectedCategory;
  final _formNumberkey = GlobalKey<FormState>();

  List<Map<String, dynamic>> expenseCategories = [
    {"name": "Food", "icon": Icons.fastfood},
    {"name": "Daily", "icon": Icons.local_cafe},
    {"name": "Transport", "icon": Icons.directions_bus},
    {"name": "Housing", "icon": Icons.home},
    {"name": "Gifts", "icon": Icons.card_giftcard},
    {"name": "Clothing", "icon": Icons.shopping_bag},
    {"name": "Entertainment", "icon": Icons.movie},
    {"name": "Plan Future", "icon": Icons.star},
  ];

  void _onIconTap(int index) {
    setState(() {
      selectedIcon = index; // อัปเดต index ที่ถูกเลือก
    });

    selectedCategory = expenseCategories[index]["name"];
    print("Selected Category: $selectedCategory"); // แสดงชื่อหมวดหมู่ที่เลือก
  }

  void _showTopSnackBar(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // ตั้งค่าให้แสดงจากขอบบน
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              'Please select a category',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _onKeyTap(String value) {
    setState(() {
      if (amount == "0") {
        amount = value;
      } else {
        amount += value;
      }
      _moneyController.text = amount;
    });
  }

  void _clearAmount() {
    setState(() {
      amount = "0";
    });
    _moneyController.text = amount;
  }

  void _submit() {
    print("Submitted Amount: THB $amount");
    print("Submitted Type: $selectedCategory");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("${DateFormat('dd MMM yyyy').format(widget.selectedDay)}",
              style: TextStyle(
                  color: Color(0xFF534684),
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
          Form(
            key: _formNumberkey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _moneyController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixText: "THB ",
                    ),
                    style: TextStyle(fontSize: 20),
                    validator: (value) {
                      if (value!.isEmpty || value == '0')
                        return 'Please, input number';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formNumberkey.currentState!.validate()) {
                      if (selectedCategory == null) {
                        _showTopSnackBar(context);
                        return;
                      }
                      _databaseService.addExpense(selectedCategory,
                          int.parse(amount), _getDateOnly(widget.selectedDay));
                      _submit();
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: GridView.builder(
                padding: EdgeInsets.all(5),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: expenseCategories.length,
                itemBuilder: (context, index) {
                  return CategoryItem(
                    category: expenseCategories[index],
                    isSelected: selectedIcon == index,
                    onTap: () => _onIconTap(index),
                  );
                },
              ),
            ),
          ),
          Container(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              children: [
                ...List.generate(9, (index) {
                  return NumberButton(
                    number: (index + 1).toString(),
                    onTap: () => _onKeyTap((index + 1).toString()),
                  );
                }),
                NumberButton(number: ".", onTap: () => _onKeyTap(".")),
                NumberButton(number: "0", onTap: () => _onKeyTap("0")),
                IconButton(
                  icon: Icon(Icons.backspace, color: Colors.black),
                  onPressed: _clearAmount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onTap;

  NumberButton({required this.number, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFFB3E680),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(fontSize: 24, color: Color(0xFF534684)),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;

  CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap, // เรียกใช้ฟังก์ชันเมื่อกดไอคอน
          child: Icon(
            category['icon'],
            size: 32,
            color: isSelected
                ? Color(0xFF534684)
                : Color(0xFFFEB0B9), // เปลี่ยนสีเมื่อเลือก
          ),
        ),
        Text(
          category['name'],
          style: TextStyle(
            color: Color(0xFF534684),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

DateTime _getDateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}
