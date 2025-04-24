import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:park_it2/profile_screen.dart';
import 'home_screen.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFFF5177),
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
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () =>
              Navigator.pop(context, MaterialPageRoute(builder: (context)=> ProfileScreen())),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          "Fill your information",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              SizedBox(height: 20),

              // Full name
              TextFormField(
                decoration: _inputDecoration("Full name"),
              ),
              SizedBox(height: 20),

              // Nickname
              TextFormField(
                decoration: _inputDecoration("Nickname"),
              ),
              SizedBox(height: 20),

              // Date of birth field with a date picker
              TextFormField(
                decoration: _inputDecoration("Date of birth").copyWith(
                  suffixIcon: Icon(Icons.calendar_today_rounded, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),

              // Email
              TextFormField(
                decoration: _inputDecoration("Email").copyWith(
                  suffixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),

              IntlPhoneField(
                decoration: _inputDecoration("Phone number"),
                initialCountryCode: 'TR',
                onChanged: (phone) {
                  print(phone.completeNumber);
                },
              ),
              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Gender"),
                dropdownColor: Colors.white,
                value: null,
                items: <String>["Male", "Female"].map((String gender) {
                  return DropdownMenuItem<String>(

                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  print("Selected gender: $newValue");
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),

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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Text(
                    "Sign up",
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
