import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../service/database_service.dart';

class EditBookScreen extends StatefulWidget {
  final String bookId;
  final String uid;

  const EditBookScreen({super.key, required this.bookId, required this.uid});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController readPagesController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String bookStatus = 'Reading';
  bool isLoading = true;
  String errorMessage = '';

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
  }

  Future<void> fetchBookDetails() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .collection("books")
          .doc(widget.bookId)
          .get();

      if (doc.exists) {
        var data = doc.data()!;
        setState(() {
          titleController.text = data['title'] ?? '';
          totalPagesController.text = (data['totalPages'] ?? '').toString();
          readPagesController.text = (data['readPages'] ?? '').toString();
          bookStatus = data['status'] ?? 'Reading';
          startDate = (data['startDate'] as Timestamp?)?.toDate();
          endDate = (data['endDate'] as Timestamp?)?.toDate();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching book details.";
        isLoading = false;
      });
    }
  }

  Future<void> saveBookDetails() async {
    setState(() {
      errorMessage = '';
    });

    if (titleController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Book title cannot be empty.";
      });
      return;
    }

    int? totalPages = int.tryParse(totalPagesController.text);
    int? readPages = int.tryParse(readPagesController.text);

    if (totalPages == null || readPages == null) {
      setState(() {
        errorMessage = "Please enter valid numbers for pages.";
      });
      return;
    }

    if (readPages > totalPages) {
      setState(() {
        errorMessage = "Read pages cannot be more than total pages.";
      });
      return;
    }
    if (bookStatus == 'Finished Reading') {
      if (readPages != totalPages) {
        setState(() {
          errorMessage =
              "Read pages must be equal to total pages when the book status is 'Finished Reading'.";
        });
        return;
      }
    }

    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      setState(() {
        errorMessage = "End date cannot be before start date.";
      });
      return;
    }

    try {
      await _databaseService.updateBook(
        widget.bookId,
        titleController.text,
        totalPages,
        readPages,
        startDate,
        endDate,
        bookStatus,
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = "Failed to update book: ${e.toString()}";
      });
    }
  }
  // }

  bool get isFormValid {
    return titleController.text.isNotEmpty &&
        totalPagesController.text.isNotEmpty &&
        readPagesController.text.isNotEmpty &&
        int.tryParse(totalPagesController.text) != null &&
        int.tryParse(readPagesController.text) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF9F0),
      appBar: AppBar(
        title: Text('Edit Book',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0XFF534684))),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  _buildTextField(titleController, '📖 Book Name'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              totalPagesController, '📄 Total Pages')),
                      SizedBox(width: 12),
                      Expanded(
                          child: _buildTextField(
                              readPagesController, '📑 Pages Read')),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildDatePickerRow(context),
                  SizedBox(height: 20),
                  _buildDropdown(),
                  Spacer(),
                  _buildButtonRow(),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        keyboardType:
            label.contains('Pages') ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton('Back', Color(0XFFFEB0B9), () {
          Navigator.pop(context);
        }),
        _buildButton('Save', Color(0XFFB3E680), () {
          if (isFormValid) {
            saveBookDetails(); // Save to Firestore
          }
        }),
      ],
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildDatePickerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildDateCard('📅 Start', startDate,
                (date) => setState(() => startDate = date))),
        SizedBox(width: 12),
        Expanded(
            child: _buildDateCard('📖 Finished', endDate,
                (date) => setState(() => endDate = date))),
      ],
    );
  }

  Widget _buildDateCard(
      String title, DateTime? date, Function(DateTime) onSelect) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        dense: true,
        title: Text(title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: FittedBox(
          child: Text(
            date == null
                ? 'Selected Date'
                : DateFormat('dd/MM/yyyy').format(date),
          ),
        ),
        trailing: Icon(Icons.calendar_today, color: Colors.blueGrey),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 365)),
          );
          if (pickedDate != null) {
            onSelect(pickedDate);
          }
        },
      ),
    );
  }

  Widget _buildDropdown() {
    List<String> bookStatusOptions = ['Reading', 'Finished Reading'];

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: bookStatusOptions.contains(bookStatus) ? bookStatus : null,
        items: bookStatusOptions
            .map((status) =>
                DropdownMenuItem(value: status, child: Text(status)))
            .toList(),
        onChanged: (value) {
          setState(() {
            bookStatus = value!;
            if (bookStatus == 'Finished Reading' && endDate == null) {
              endDate = DateTime.now();
            }
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
