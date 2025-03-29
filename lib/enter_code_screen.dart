import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'create_new_pass_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnterCodeScreen extends StatefulWidget {
  final String verificationId; // For SMS verification
  final String? correctOTP;     // For email verification
  final bool isEmail;           // To decide which method to verify

  const EnterCodeScreen({
    super.key,
    required this.verificationId,
    this.correctOTP,
    required this.isEmail,
  });


  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int resendSeconds = 60;
  Timer? _timer;


  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    _timer?.cancel();
    resendSeconds = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          resendSeconds--;
        });
      }
    });
  }

  void verifySMSCode() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpController.text,
      );
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateNewPassScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid OTP")));
    }
  }

  void verifyEmailCode() {
    if (otpController.text == widget.correctOTP) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateNewPassScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid Code")));
    }
  }
  @override

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          "Forgot password",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Image.asset("images/entercodescreen.png", width: 250,),
              SizedBox(height: 20),
              Text("Code has been sent to +90 0000", style: TextStyle(fontSize: 16.0),),
              SizedBox(height: 40),
              PinCodeTextField(appContext: context,
                  length: 4,
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(

                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 60,
                fieldWidth: 70,
                activeFillColor: Color(0xFFFF5177), // Color when the pin field is active
                inactiveFillColor: Colors.white, // Color when the pin field is inactive
                selectedFillColor: Color(0xFFFF5177), // Color when the pin field is selected
                activeColor: Color(0xFFFF5177), // Border color when the field is active
                inactiveColor: Colors.grey, // Border color when the field is inactive
                selectedColor: Color(0xFFFF5177),

              ),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                boxShadows: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    color: Color(0xFFfcecf0),
                    blurRadius: 50,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Resend code in $resendSeconds seconds", textAlign: TextAlign.center),

                ],
              ),
              SizedBox(height: 216),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF5177),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (widget.isEmail) {
                      verifyEmailCode();
                    } else {
                      verifySMSCode();
                    }
                  },
                  child: Text(
                    "Verify",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],

          ),
        ),

      ),

    );
  }
}
