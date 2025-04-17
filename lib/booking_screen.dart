import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();

    if (!mounted) return;


    setState(() {
      bookings = List<Map<String, dynamic>>.from(data);
      print(bookings);
      print(snapshot.docs.length);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset("images/parkitlogo2.png" , scale: 2,),
            SizedBox(width: 10),
            Text("My Parking", style: TextStyle(fontSize: 23.0),)
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey, size: 33,),
            onPressed: () {},
          ),
        ],
        elevation: 0,


      ),
      body: bookings.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final DateTime? selectedDate = booking['selectedDate'] != null
              ? (booking['selectedDate'] as Timestamp).toDate()
              : null;

          final DateTime? createdAt = booking['createdAt'] != null
              ? (booking['createdAt'] as Timestamp).toDate()
              : null;

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFEEF2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFFF5177), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 ${booking['parkingName']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text("🗓️ ${selectedDate?.toLocal().toString().split(' ')[0]}"),
                Text("🕒 ${booking['startTime']} - ${booking['endTime']}"),
                SizedBox(height: 6),
                Text("💰 Total: ${booking['totalPrice'].toStringAsFixed(2)} Turkish Liras"),
                Text("🕗 Booked on: ${createdAt?.toLocal().toString().split('.')[0]}"),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF5177),
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => HomeScreen()));
          },
              icon: Icon(Icons.home_filled)),
              label: 'Home'
          ),
          BottomNavigationBarItem(icon: IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => SavedScreen()));
          }, icon: Icon(Icons.bookmark)),
              label: 'Saved'
          ),
          BottomNavigationBarItem(icon: IconButton(onPressed: (){
            Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) => BookingScreen()),
            );
          }, icon: Icon(Icons.list_alt)),
            label: 'Booking',
          ),
          BottomNavigationBarItem(icon: IconButton(onPressed: (){
            Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen()),
            );
          }, icon: Icon(Icons.account_box)),
              label: 'Profile'
          ),
        ],
      ),

    );
  }
}
