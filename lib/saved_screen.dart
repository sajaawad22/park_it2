import 'package:flutter/material.dart';
import 'package:park_it2/booking_screen.dart';
import 'package:park_it2/profile_screen.dart';
import 'home_screen.dart';



class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
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
            Text("My Bookmark", style: TextStyle(fontSize: 23.0),)
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,


      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 29,),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],

        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
            currentIndex: 1,
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
