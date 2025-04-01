import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookParkingScreen extends StatefulWidget {
  const BookParkingScreen({super.key});

  @override
  State<BookParkingScreen> createState() => _BookParkingScreenState();
}

class _BookParkingScreenState extends State<BookParkingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back),
        title: Text("Book Parking Details", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Column(

      ),
    );
  }
}
