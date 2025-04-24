import 'package:flutter/material.dart';
import 'package:park_it2/login_password_screen.dart';
import 'package:park_it2/login_screen.dart';
import 'admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  bool _obscurePassword = true;
  bool _isChecked = false;
  bool ? _isAdmin;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  Future<void> _signInAdmin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc['isAdmin'] == true) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Access denied. Not an admin.")));
          await FirebaseAuth.instance.signOut();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
    backgroundColor: Colors.white,
      body: Column(
          children: [
      Expanded(
      child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 90.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Admin Login",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40),

          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color:  Color(0xFFFF5177),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFFF5177),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
            ),
          ),
          SizedBox(height: 20),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.key_sharp, color: Colors.grey),
              suffixIcon: IconButton(
                onPressed: (){
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Color(0xFFFF5177),
                  size: 21,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFFF5177),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFFF5177), // Border color when focused
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
            ),
          ),
          SizedBox(height: 10),

          // Remember Me Checkbox
          // Remember Me Checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 0.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Color(0xFFFF5177),
                  ),
                  child: Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    side: MaterialStateBorderSide.resolveWith(
                          (states) => BorderSide(width: 1.5, color: Color(0xFFFF5177)),
                    ),
                    value: _isChecked,
                    onChanged: (bool? value) async {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                    activeColor: Color(0xFFFF5177),
                  ),
                ),
              ),
              Text(
                "Remember me",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 10),

          // Sign Up Button
          SizedBox(
            width: 360,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5177),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _signInAdmin,
              child: Text(
                "Sign in",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          SizedBox(height: 20),

          GestureDetector(
            onTap: (){
            },
            child: Text("Forgot password?",
              style: TextStyle(color: Color(0xFFFF5177), fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          SizedBox(height: 60),



        ],
      ),
      ),
    ),
    ],
    ),
    );
  }
}
