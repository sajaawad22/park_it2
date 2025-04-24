import 'dart:io';

import 'package:flutter/material.dart';
import 'admin_login_page.dart';
import 'admin_dashboard.dart';
import 'parking_spots_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';


class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
final GlobalKey qrKey =GlobalKey(debugLabel: 'QR');
QRViewController? controller;
String? qrText;

@override
@override
void reassemble() {
  super.reassemble();
  if (controller != null) {
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }
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
        title: Text("Access Control", style: TextStyle(fontWeight: FontWeight.bold),),
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
        children: <Widget>[
        Expanded(
          flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated,))
      ],),
    );
  }
void _onQRViewCreated(QRViewController controller) {
  this.controller = controller;
  controller.scannedDataStream.listen((scanData) {
    setState(() {
      qrText = scanData.code;
    });
    controller.pauseCamera();  // Pause after scanning
  });
}

@override
void dispose() {
  controller?.dispose();
  super.dispose();
}
}
