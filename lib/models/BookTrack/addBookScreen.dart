import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../service/database_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController readPagesController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String bookStatus = 'Reading';
  bool isSaving = false;

  final DatabaseService _databaseService = DatabaseService();

  bool isFormValid() {
    int totalPages = int.tryParse(totalPagesController.text) ?? 0;
    int readPages = int.tryParse(readPagesController.text) ?? 0;

    return titleController.text.isNotEmpty &&
        totalPages > 0 &&
        readPages > 0 &&
        readPages <= totalPages &&
        startDate != null &&
        (bookStatus != 'Finished Reading' ||
            (endDate != null && readPages == totalPages));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveBook() async {
    if (!isFormValid()) {
      _showSnackBar("Please fill all fields correctly.");
      return;
    }
    setState(() => isSaving = true);
    try {
      await _databaseService.addBook(
        titleController.text,
        int.parse(totalPagesController.text),
        int.parse(readPagesController.text),
        startDate,
        endDate,
        bookStatus,
      );
      _showSnackBar("Book saved successfully!");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error saving book: ${e.toString()}");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF9F0),
      appBar: AppBar(
          title: Text('Add New Book',
              style: TextStyle(
                  color: Color(0XFF534684), fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(titleController, '📖 Book Name'),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildNumberTextField(
                        totalPagesController, '📄 Total Pages')),
                SizedBox(width: 12),
                Expanded(
                    child: _buildNumberTextField(
                        readPagesController, '📑 Pages Read')),
              ],
            ),
            SizedBox(height: 20),
            _buildDatePickerRow(),
            SizedBox(height: 20),
            _buildDropdown(),
            Spacer(),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberTextField(TextEditingController controller, String label) {
    return _buildTextField(controller, label, isNumber: true);
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePickerRow() {
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
        subtitle: Text(date == null
            ? 'Select Date'
            : DateFormat('dd/MM/yyyy').format(date)),
        trailing: Icon(Icons.calendar_today, color: Colors.blueGrey),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) onSelect(pickedDate);
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: bookStatus,
        items: ['Reading', 'Finished Reading']
            .map((status) =>
                DropdownMenuItem(value: status, child: Text(status)))
            .toList(),
        onChanged: (value) => setState(() => bookStatus = value!),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12)),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton('Cancel', Color(0XFFFEB0B9), () => Navigator.pop(context)),
        _buildButton(
            'Save', isFormValid() ? Color(0XFFB3E680) : Colors.grey, _saveBook),
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
}
