import 'package:flutter/material.dart';


class PickParkingScreen extends StatefulWidget {
  const PickParkingScreen({super.key});

  @override
  State<PickParkingScreen> createState() => _PickParkingScreenState();
}

class _PickParkingScreenState extends State<PickParkingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon:
        Icon(Icons.arrow_back), onPressed: () {
          Navigator.pop(context);
        },),
        title: Text("Pick Parking Spot", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
    );
  }
}
