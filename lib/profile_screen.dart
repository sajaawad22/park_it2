import 'package:flutter/material.dart';
import 'saved_screen.dart';
import 'booking_screen.dart';
import 'home_screen.dart';
import 'profile_management_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? _userName;
  String? _userEmail;


  @override
  void initState (){
    super.initState();
    _loadUserData();
  }

  void _loadUserData(){
    final user= FirebaseAuth.instance.currentUser;
    setState(() {
      _userName= user?.displayName ?? "No name";
      _userEmail= user?.email ?? "No Email";
    });
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
                    await logoutUser(); // Calls the logout function
                    Navigator.of(context).pop(); // Close bottom sheet
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
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
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      if (_auth.currentUser != null) {
        if (_auth.currentUser!.providerData.any((info) => info.providerId == 'google.com')) {
          await _googleSignIn.signOut(); // Sign out from Google
        }
        await _auth.signOut(); // Sign out from Firebase
      }
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
            Text("Profile", style: TextStyle(fontSize: 23.0),)
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
      body: SafeArea(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(
                      Icons.account_circle_outlined,
                      size: 120,
                      color: Colors.grey,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF5177),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
             SizedBox(height: 10),
              Text(_userName ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Text(_userEmail ?? '', style: TextStyle(fontSize: 16, ),),
              SizedBox(height: 10),
              Divider(color: Colors.grey, indent: 20, endIndent: 20,),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileManagementScreen()));
                }, child: Row(
                    mainAxisSize: MainAxisSize.min,  // Makes the row take only as much space as needed
                    children: [
                    Icon(Icons.person_outline, size: 30,color: Colors.black,),  // Replace with your desired icon
                  SizedBox(width: 15),  // Add some space between the icon and the text
                  Text('Edit Profile', style: TextStyle(fontSize: 19, color: Colors.black),),
                  ],
                )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: (){
                }, child: Row(
                  mainAxisSize: MainAxisSize.min,  // Makes the row take only as much space as needed
                  children: [
                    Icon(Icons.wallet_outlined, size: 30,color: Colors.black,),  // Replace with your desired icon
                    SizedBox(width: 15),  // Add some space between the icon and the text
                    Text('Payment', style: TextStyle(fontSize: 19, color: Colors.black),),
                  ],
                )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: (){
                }, child: Row(
                  mainAxisSize: MainAxisSize.min,  // Makes the row take only as much space as needed
                  children: [
                    Icon(Icons.notifications_none_outlined, size: 30,color: Colors.black,),  // Replace with your desired icon
                    SizedBox(width: 15),  // Add some space between the icon and the text
                    Text('Notifications', style: TextStyle(fontSize: 19, color: Colors.black),),
                  ],
                )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: (){
                }, child: Row(
                  mainAxisSize: MainAxisSize.min,  // Makes the row take only as much space as needed
                  children: [
                    Icon(Icons.security_outlined, size: 30,color: Colors.black,),  // Replace with your desired icon
                    SizedBox(width: 15),  // Add some space between the icon and the text
                    Text('Security', style: TextStyle(fontSize: 19, color: Colors.black),),
                  ],
                )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: (){
                }, child: Row(
                  mainAxisSize: MainAxisSize.min,  // Makes the row take only as much space as needed
                  children: [
                    Icon(Icons.help_outline, size: 30,color: Colors.black,),  // Replace with your desired icon
                    SizedBox(width: 15),  // Add some space between the icon and the text
                    Text('Help', style: TextStyle(fontSize: 19, color: Colors.black),),
                  ],
                )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: (){
                      showLogoutBottomSheet(context);
                    },
                    child: Row(
                  mainAxisSize: MainAxisSize.min,  // Makes the row take only as much space as needed
                  children: [
                    Icon(Icons.logout_outlined, size: 30,color: Colors.red,),  // Replace with your desired icon
                    SizedBox(width: 15),  // Add some space between the icon and the text
                    Text('Logout', style: TextStyle(fontSize: 19, color: Colors.red),),
                  ],
                )),
              ),
            ],
          ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 3,
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
