import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
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
