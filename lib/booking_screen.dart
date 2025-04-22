import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'parking_ticket.dart';

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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('selectedDate', descending: true).get();


    if (!mounted) return;
    setState(() {
      bookings = snapshot.docs.map((doc) {
        final data = doc.data();
        data['bookingId'] = doc.id;
        return data;
      }).toList();
    });
  }

  void _showCancelBottomSheet(BuildContext context, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        "Cancel Booking",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      "Are you sure you want to cancel this booking?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Only 80% of your money will be refunded according to our policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    SizedBox(height: 20),

                    Row(
                      children: [

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFEEF2),
                              minimumSize: Size(0, 50),
                            ),
                            child: Text("Nevermind", style: TextStyle(color: Color(0xFFFF5177))),
                          ),
                        ),
                        SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('bookings')
                                  .doc(booking['bookingId']).delete();

                              Navigator.pop(context);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                fetchBookings();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF5177),
                              minimumSize: Size(0, 50),
                            ),
                            child: Text("Yes, Cancel", style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: bookings.isEmpty
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

                      return GestureDetector(
                        onTap: ()=> _showCancelBottomSheet(context, booking),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(" ${booking['parkingName']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              Text("Date: ${selectedDate?.toLocal().toString().split(' ')[0]}"),
                              Text("Duration: ${booking['startTime']} - ${booking['endTime']}"),
                              SizedBox(height: 6),
                              Text("Total: ${booking['totalPrice'].toStringAsFixed(2)} Turkish Liras"),
                              Text("Booked on: ${createdAt?.toLocal().toString().split('.')[0]}",),
                              Divider(),
                              SizedBox(height: 10),
                              ElevatedButton(
                                  onPressed: () async{
                                      final ticket = booking['ticket'];
                                      if (ticket != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ParkingTicket(
                                              parkingData: {
                                                'name': ticket['parkingLot'],
                                                'address': ticket['address'],
                                                'lat': booking['lat'], // Make sure lat/lng are stored in booking
                                                'lng': booking['lng'],
                                              },
                                              selectedVehicle: ticket['vehicle'],
                                              selectedDate: DateFormat("yyyy-MM-dd").parse(ticket['date']),
                                              startTime: TimeOfDay(hour: 0, minute: 0),
                                              endTime: TimeOfDay(hour: 0, minute: 0),
                                              duration: double.tryParse(ticket['duration']) ?? 0,
                                              totalPrice: booking['totalPrice'],
                                              selectedSpotName: ticket['spot'],
                                              selectedMethod: ticket['paymentMethod'],
                                            ),
                                          ),
                                        );
                                      }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFFEEF2),
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: Text("View Parking Ticket", style: TextStyle(color: Color(0xFFFF5177)),))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
