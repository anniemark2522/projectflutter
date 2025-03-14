import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addBookScreen.dart';
import 'editBookScreen.dart';

class BookPage extends StatelessWidget {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF9F0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📖 Currently Reading',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700])),
            SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .collection("books")
                    .where('status', isEqualTo: 'Reading')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No book found'));
                  }

                  var books = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;

                    int readPage = data['readPages'] != null
                        ? (data['readPages'] as num).toInt()
                        : 0;
                    int totalPages = data['totalPages'] != null
                        ? (data['totalPages'] as num).toInt()
                        : 1;

                    double progress =
                        (totalPages > 0) ? (readPage / totalPages) : 0.0;
                    print("Book Progress: $progress");

                    return Book(
                      id: doc.id,
                      title: data['title'] ?? 'Untitled',
                      progress: progress,
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return BookCard(
                        book: book,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBookScreen(
                                bookId: book.id,
                                uid: FirebaseAuth.instance.currentUser?.uid ??
                                    "",
                              ),
                            ),
                          );
                        },
                        onDelete: () async {
                          await deleteBook(book.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text('📚 Finished Reading',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700])),
            SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .collection("books")
                    .where('status', isEqualTo: 'Finished Reading')
                    .where('endDate', isNotEqualTo: null)
                    .orderBy('endDate', descending: true)
                    .snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                    print("No finished books found.");
                    return Center(child: Text('No finished books yet'));
                  }
                  print("Found ${snapshots.data!.docs.length} finished books.");

                  var finishBooks = snapshots.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;

                    Timestamp? endDateTimestamp = data['endDate'] as Timestamp?;
                    String formattedEndDate = endDateTimestamp != null
                        ? "${endDateTimestamp.toDate().toLocal().day}/${endDateTimestamp.toDate().toLocal().month}/${endDateTimestamp.toDate().toLocal().year}"
                        : 'No end date';
                    print('EndDate: $formattedEndDate');

                    return FinishedBook(
                      title: data['title'] ?? 'Untitled',
                      date: formattedEndDate,
                    );
                  }).toList();

                  return FinishedBookTimeLine(finishBooks: finishBooks);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_book_fab",
        backgroundColor: Color(0xFFFEB0B9),
        child: const Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
        },
      ),
    );
  }

  Future<void> deleteBook(String bookId) async {
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("books")
          .doc(bookId)
          .delete();
    }
  }
}

class Book {
  final String id;
  final String title;
  final double progress;

  Book({required this.id, required this.title, required this.progress});
}

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditBookScreen(
                            bookId: book.id,
                            uid: FirebaseAuth.instance.currentUser?.uid ?? "",
                          ),
                        ),
                      );
                    },
                    child: Text(book.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ),
                  SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: book.progress,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: book.progress < 0.5
                                ? Colors.red
                                : Color(0XFFB3E680),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('${(book.progress * 100).toInt()}% completed',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.green[700]),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[700]),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class FinishedBookTimeLine extends StatelessWidget {
  final List<FinishedBook> finishBooks;

  const FinishedBookTimeLine({super.key, required this.finishBooks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: finishBooks.length,
      itemBuilder: (context, index) {
        final book = finishBooks[index];
        return ListTile(
          leading: Icon(Icons.calendar_today, color: Colors.blue[400]),
          title: Text(book.title),
          subtitle: Text(book.date),
        );
      },
    );
  }
}

class FinishedBook {
  final String title;
  final String date;

  FinishedBook({required this.title, required this.date});
}
