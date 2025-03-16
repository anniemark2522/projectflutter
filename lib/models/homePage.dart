import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: const BoxDecoration(color: Color(0xFFEFF9F0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome To Daily Track',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF534684),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your All-in-One Lifestyle',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF534684),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CarouselSlider(
              items: [
                _buildImage("assets/images/book.jpg"),
                _buildImage("assets/images/expense2.jpg"),
                _buildImage("assets/images/mood.webp"),
              ],
              options: CarouselOptions(
                height: 150,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildListItem(
                      Icons.book, "Book Track", "Track your reading progress"),
                  _buildListItem(Icons.attach_money, "Expense Track",
                      "Track your daily spending"),
                  _buildListItem(
                      Icons.mood, "Mood Track", "Log your daily mood"),
                  _buildListItem(Icons.settings, "Setting", "Change your name"),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Tap below to log your daily progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF534684),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 40,
                      color: Color(0xFF534684),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF534684)),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF534684),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF534684),
            ),
          ),
        ),
      ),
    );
  }
}
