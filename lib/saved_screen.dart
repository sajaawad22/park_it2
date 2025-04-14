import 'package:flutter/material.dart';
import 'package:park_it2/booking_screen.dart';
import 'package:park_it2/profile_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});


  @override
  State<SavedScreen> createState() => _SavedScreenState();
}



class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> saved = [];

  Future<void> fetchSaved() async{
    final snapshot = await FirebaseFirestore.instance
        .collection('saved_spots')
        .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();



    setState(() {
      saved = List<Map<String, dynamic>>.from(data);
      print(saved);
      print(snapshot.docs.length);
    });
  }
  void initState(){
    super.initState();
    fetchSaved();
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
        child: saved.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: saved.length,
          itemBuilder: (context, index) {
            final item = saved[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                    child: Image.network(
                      item['imageUrl'],
                      width: 120,
                      height: 100,
                      fit: BoxFit.cover,
                    ),),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: 4),
                          Text(
                            item['address'],
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark), color: Color(0xFFFF5177),
                    onPressed: () {},
                  ),
                ],
              ),
            );
            },
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
