import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginPasswordScreen extends StatefulWidget {
  const LoginPasswordScreen({super.key});
  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isChecked = false;
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _obscurePassword = true;
  String? _errorMessage;


  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await _auth.signInWithCredential(credential);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('Google Sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-in failed')));
    }
  }
  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && user.email != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User not found in the database.';
          });
          await _auth.signOut();
          return;
        }
        if (userDoc['isAdmin'] == true) {
          setState(() {
            _errorMessage = 'Admins cannot log in from this screen.';
          });
          await _auth.signOut();
          setState(() {
            _isLoading = false;
          });
          return;
        }
        // Continue saving user info if Remember Me is checked
        if (_isChecked) {
          await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
            "uid": user.uid,
            "email": user.email,
            "rememberMe": true, // Save remember me status
          }, SetOptions(merge: true));

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', _emailController.text.trim());
          await prefs.setString('password', _passwordController.text.trim());
          await prefs.setBool('rememberMe', true);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to retrieve user details.';
        });
        await _auth.signOut();
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  Future<void> _checkRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');

      if (savedEmail != null && savedPassword != null) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: savedEmail,
            password: savedPassword,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } catch (e) {
          print("Auto login failed: $e");
        }
      }
    }
  }
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }

    String emailPattern =
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    RegExp regex = RegExp(emailPattern);

    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    // Password must be at least 6 characters long
    if (value.length < 6) {
      return 'Password should be at least 6 characters';
    }

    String passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
    RegExp regex = RegExp(passwordPattern);

    if (!regex.hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 90.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Login to",
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
                      validator: validateEmail,
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
                      validator: validatePassword,
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 10),
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                    ],

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

                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('rememberMe', _isChecked);
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
                        onPressed: _isLoading
                              ? null
                              : () {
                            if (_formKey.currentState != null) {
                              if (_formKey.currentState!.validate()) {
                                _signInWithEmailAndPassword();
                              }
                            }
                          },
                        child: Text(
                          "Sign in",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text("Forgot password?",
                        style: TextStyle(color: Color(0xFFFF5177), fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "or continue with",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Google Sign-In Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: _signInWithGoogle,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Image.asset(
                              'images/icons8-google-48.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      color: Color(0xFF838AE0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

