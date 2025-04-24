import 'package:flutter/material.dart';
import 'package:park_it2/admin_login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:park_it2/parking_spots_admin.dart';
import 'access_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<List<Map<String, dynamic>>> fetchUsersWithBookings() async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isAdmin', isEqualTo: false)
        .get();

    List<Map<String, dynamic>> usersWithBookings = [];

    for (var userDoc in usersSnapshot.docs) {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userDoc.id)
          .get();

      usersWithBookings.add({
        'user': userDoc.data(),
        'bookings': bookingsSnapshot.docs.map((doc) => doc.data()).toList(),
      });
    }

    return usersWithBookings;
  }


  void showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                "Logout",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                "Are you sure you want to log out?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await logoutUser();
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AdminLoginPage()),
                    );// Navigate to Login Screen
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFFF5177),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Yes, Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFFFDCE4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Cancel", style: TextStyle(color: Color(0xFFFF5177), fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> logoutUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      if (_auth.currentUser != null) {
        await _auth.signOut(); // Sign out from Firebase
      }
    } catch (e) {
      print("Error logging out: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookings Dashboard", style: TextStyle(fontWeight: FontWeight.bold),),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
                child: Padding(
                  padding: const EdgeInsets.only(left: 3,top: 50),
                  child: Text("Admin Menu", style: TextStyle(fontSize: 30),),
                )),
            ListTile(
              leading: Icon(Icons.dashboard_outlined,color: Color(0xFFFF5177),),
              title: Text("Bookings Dashboard",style: TextStyle(fontSize: 19)),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AdminDashboard()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.local_parking_outlined, color: Color(0xFFFF5177),),
              title: Text("Parking Spots",style: TextStyle(fontSize: 19)),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ParkingSpotsAdmin()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code_scanner,color: Color(0xFFFF5177),),
              title: Text("Access",style: TextStyle(fontSize: 19)),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AccessScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFFFF5177),),
              title: Text("Logout", style: TextStyle(fontSize: 19, color: Colors.red),
                ),
              onTap: (){
                showLogoutBottomSheet(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchUsersWithBookings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No users or bookings found.'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var user = snapshot.data![index]['user'];
                      var bookings = snapshot.data![index]['bookings'] as List;

                      return ExpansionTile(
                        title: Text(user['email'] ?? 'Unknown User'),
                        children: bookings.map<Widget>((booking) {
                          DateTime date = (booking['selectedDate'] as Timestamp).toDate();
                          String formattedDate = DateFormat('dd/MM/yyyy').format(date);
                          return ListTile(
                            title: Text('Booking: ${booking['parkingName']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parking Spot: ${booking['spotName'] ?? 'N/A'}'),
                                Text('Selected Date: $formattedDate'),
                                Text('Duration: ${booking['startTime']} - ${booking['endTime']}'),
                                Text('Total Price: ₺${booking['totalPrice'].toStringAsFixed(0)}')

                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                );
              }
            },
          )
        ],

      ),
    );
  }
}
