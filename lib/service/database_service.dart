import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //สร้างตัวแปรเชื่อม Firestore
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // บันทึกหนังสือ
  Future<void> addBook(String title, int totalPages, int readPages,
      DateTime? startDate, DateTime? endDate, String status) async {
    try {
      if (uid != null) {
        DateTime? startDateWithoutTime = startDate != null
            ? DateTime(startDate.year, startDate.month, startDate.day)
            : null;
        DateTime? endDateWithoutTime = endDate != null
            ? DateTime(endDate.year, endDate.month, endDate.day)
            : null;

        await _firestore.collection("users").doc(uid).collection("books").add({
          'title': title,
          'totalPages': totalPages,
          'readPages': readPages,
          'startDate': startDateWithoutTime != null
              ? Timestamp.fromDate(startDateWithoutTime)
              : null,
          'endDate': endDateWithoutTime != null
              ? Timestamp.fromDate(endDateWithoutTime)
              : null,
          'status': status,
          'createdAt': FieldValue.serverTimestamp(), // เพิ่ม timestamp
        });
      } else {
        print('Error: User ID is null');
      }
    } catch (e) {
      print('Error adding book: $e');
    }
  }

  // อัปเดตหนังสือ
  Future<void> updateBook(
      String bookId,
      String title,
      int totalPages,
      int readPages,
      DateTime? startDate,
      DateTime? endDate,
      String bookStatus) async {
    try {
      if (uid != null) {
        DateTime? startDateWithoutTime = startDate != null
            ? DateTime(startDate.year, startDate.month, startDate.day)
            : null;
        DateTime? endDateWithoutTime = endDate != null
            ? DateTime(endDate.year, endDate.month, endDate.day)
            : null;

        await _firestore
            .collection("users")
            .doc(uid)
            .collection("books")
            .doc(bookId)
            .update({
          "title": title,
          "totalPages": totalPages,
          "readPages": readPages,
          "startDate": startDateWithoutTime != null
              ? Timestamp.fromDate(startDateWithoutTime)
              : null,
          "endDate": endDateWithoutTime != null
              ? Timestamp.fromDate(endDateWithoutTime)
              : null,
          "status": bookStatus,
        });
      }
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  // ลบหนังสือ
  Future<void> deleteBook(String bookId) async {
    try {
      if (uid != null) {
        await _firestore
            .collection("users")
            .doc(uid)
            .collection("books")
            .doc(bookId)
            .delete();
      }
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

  // เพิ่มข้อมูลรายจ่าย
  Future<void> addExpense(
    String? typeAmount,
    int amount,
    DateTime? dateAmount,
  ) async {
    try {
      if (uid != null) {
        DateTime? dateWithoutTime = dateAmount != null
            ? DateTime(dateAmount.year, dateAmount.month, dateAmount.day)
            : null;

        await _firestore
            .collection("users")
            .doc(uid)
            .collection("expenses")
            .add({
          'typeAmount': typeAmount,
          'amount': amount,
          'Date': dateWithoutTime != null
              ? Timestamp.fromDate(dateWithoutTime)
              : null,
        });
      } else {
        print('Error: User ID is null');
      }
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  // ดึงข้อมูลหนังสือ
  Stream<QuerySnapshot> getExpenses() {
    if (uid != null) {
      return _firestore
          .collection("users")
          .doc(uid)
          .collection("expenses")
          .orderBy("Date",
              descending:
                  true) //ดึงข้อมูลจากคอลเลคชั่น books และเรียง doc ตามฟิล ที่ createAt ใหม่ไปเก่าที่สุด
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  // ลบรายจ่าย
  Future<void> deleteExpense(String expenseId) async {
    try {
      if (uid != null) {
        await _firestore
            .collection("users")
            .doc(uid)
            .collection("expenses")
            .doc(expenseId)
            .delete();
      }
    } catch (e) {
      print('Error deleting expenses: $e');
    }
  }

//เพิ่มอารมณ์
  // Future<void> addMoods({
  //   String? moodAboutDay,
  //   String? status,
  //   String? note, // เพิ่ม field สำหรับบันทึกข้อความเพิ่มเติม
  // }) async {
  //   try {
  //     // ตรวจสอบว่า uid มีค่า
  //     if (uid != null) {
  //       // เพิ่มข้อมูลเข้า Firestore
  //       await _firestore
  //           .collection('users') // ใช้ collection ชื่อ 'users'
  //           .doc(uid) // ใช้ UID ของผู้ใช้
  //           .collection('dailyMoods') // ใช้ subcollection 'dailyMoods'
  //           .add({
  //         'moodAboutDay': moodAboutDay, // ส่งข้อความจาก mood
  //         'status': status, // บันทึกสถานะ
  //         'note': note, // เพิ่มข้อความเพิ่มเติม
  //         'timestamp':
  //             FieldValue.serverTimestamp(), // ใช้เวลาของอุปกรณ์เป็นค่าเริ่มต้น
  //       });

  //       print("Mood data successfully added!");
  //     } else {
  //       print("No user UID found.");
  //     }
  //   } catch (e) {
  //     print("Error adding mood data: $e");
  //   }
  // }

// เพิ่มอารมณ์
Future<void> addMoods({
  required DateTime selectedDay,
  String? emoji,         // เพิ่ม emoji
  String? moodAboutDay,
  String? status,
  String? note,
}) async {
  try {
    if (uid != null) {
      String formattedDate = selectedDay.toIso8601String().split("T")[0];

      // ใช้ .doc(formattedDate).set() เพื่อให้ document ID เป็นวันที่
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('moods')
          .doc(formattedDate) // ใช้วันที่เป็น document ID
          .set({
        'emoji': emoji,
        'moodAboutDay': moodAboutDay,
        'status': status,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Mood data successfully added for date: $formattedDate");
    } else {
      print("No user UID found.");
    }
  } catch (e) {
    print("Error adding mood data: $e");
  }
}

// ดึงอารมณ์
Future<Map<String, dynamic>?> loadMood(DateTime selectedDay) async {
  try {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      String formattedDate = selectedDay.toIso8601String().split("T")[0];

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('moods')
          .doc(formattedDate) // ค้นหาด้วย formattedDate ที่เป็น document ID
          .get();

      if (doc.exists) {
        return {
          "emoji": doc["emoji"] ?? "",
          "note": doc["note"] ?? "",
          "status": doc["status"] ?? "",
          "moodAboutDay": doc["moodAboutDay"] ?? "",
        };
      } else {
        print("No mood data found for $formattedDate");
        return null;
      }
    } else {
      print("No user UID found.");
    }
  } catch (e) {
    print("Error loading mood data: $e");
  }
  return null;
}


}
