import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enter_code_screen.dart';
import 'dart:math';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String? selectedContact;
  String userEmail = "saj****d2003@gmail.com"; // Replace with actual user email
  String userPhone = "+90 543 6** **90"; // Replace with actual user phone number
  String generatedOTP = ""; // Store OTP for email method

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String generateOTP() {
    var rng = Random();
    return (rng.nextInt(9000) + 1000).toString(); // Generates 6-digit number
  }

  Future<void> _sendOTPviaSMS() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: userPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("SMS Verification Failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterCodeScreen(
              verificationId: verificationId,
              isEmail: false,
              correctOTP: "", // Not needed for SMS
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _sendOTPviaEmail() async {
    generatedOTP = generateOTP();
    // Ideally, you send this OTP via an email service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("OTP sent to email: $generatedOTP")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterCodeScreen(
          verificationId: "",
          isEmail: true,
          correctOTP: generatedOTP,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserContacts();
  }

  Future<void> _loadUserContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      setState(() {
        userEmail = doc['email'];
        userPhone = doc['phone'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User info not found")));
    }
  }
  String getObscuredEmail(String email) {
    final parts = email.split("@");
    if (parts[0].length <= 2) return "****@${parts[1]}";
    return "${parts[0].substring(0, 2)}****@${parts[1]}";
  }

  String getObscuredPhone(String phone) {
    if (phone.length <= 4) return "****";
    return phone.replaceRange(4, phone.length - 2, "*" * (phone.length - 6));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text("Forgot password", style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Image.asset('images/forgotpasswordpicture.png', width: 275, height: 188, fit: BoxFit.contain),
            SizedBox(height: 40),
            Text("Select which contact details should we use to reset your password",
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            SizedBox(height: 30),
            _contactOption("via SMS", getObscuredPhone(userPhone), 'images/sms.png', "sms"),
            SizedBox(height: 20),
            _contactOption("via Email", getObscuredEmail(userEmail), 'images/email.png', "email"),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF5177),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  if (selectedContact == "sms") {
                    _sendOTPviaSMS();
                  } else if (selectedContact == "email") {
                    _sendOTPviaEmail();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a contact method")),
                    );
                  }
                },
                child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactOption(String label, String contact, String imagePath, String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedContact = type;
        });
      },
      child: Container(
        height: 109,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedContact == type ? Color(0xFFFF5177) : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Image.asset(imagePath, width: 60, height: 60),
            ),
            SizedBox(width: 20),
            Expanded(child: Text(contact)),
          ],
        ),
      ),
    );
  }
}