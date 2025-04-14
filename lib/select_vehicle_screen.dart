import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park_it2/book_parking_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SelectVehicleScreen extends StatefulWidget {
  const SelectVehicleScreen({Key? key, required this.parkingData}) : super(key: key);
  final Map<String, dynamic> parkingData;


  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  String? selectedVehicle;
  List<Map<String, dynamic>> vehicles = [];

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    final snapshot = await FirebaseFirestore.instance.collection('vehicles').get();
    setState(() {
      vehicles = snapshot.docs.map((doc) => doc.data()).cast<Map<String, dynamic>>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Select Your Vehicle', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: vehicles.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedVehicle == vehicle['name']
                            ? Color(0xFFFF5177)
                            : Colors.grey.shade300,
                        width: selectedVehicle == vehicle['name'] ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: RadioListTile<String>(
                      value: vehicle['name'],
                      groupValue: selectedVehicle,
                      onChanged: (value) {
                        setState(() {
                          selectedVehicle = value;
                        });
                      },
                      activeColor: Color(0xFFFF5177),
                      contentPadding: EdgeInsets.all(12),
                      title: Text(vehicle['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(vehicle['plate']),
                      secondary: (vehicle['image'] != null && vehicle['image'].toString().isNotEmpty)
                          ? Image.network(
                        vehicle['image'],
                        width: 40,
                        height: 40,
                      )
                          : Icon(Icons.directions_car, size: 40, color: Colors.grey),
                    ),
                  );
                },

              ),

            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                String name = '';
                String plate = '';
                String defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/park-it-db7e4.appspot.com/o/icons8-car-48%20(1).png?alt=media';

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text('Add New Vehicle'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            fillColor: Color(0xFFFF5177),
                              labelText: 'Vehicle Name',
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
                          ),
                          onChanged: (value) => name = value,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
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
                            labelText: 'Plate Number',

                          ),
                          onChanged: (value) => plate = value,
                        ),
                      ],
                    ),
                    actions: [
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFF0F3),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('Cancel', style: TextStyle(color: Color(0xFFFF5177)),),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (name.isNotEmpty && plate.isNotEmpty) {
                              await FirebaseFirestore.instance.collection('vehicles').add({
                                'name': name,
                                'plate': plate,
                                'image': defaultImageUrl,
                              });
                              Navigator.pop(context);
                              fetchVehicles();
                            }
                          },
                          child: Text('Add', style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF5177),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                  ],

                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFFFF0F3),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('Add New Vehicle', style: TextStyle(color: Color(0xFFFF5177))),
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectedVehicle != null ? () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BookParkingScreen(
                    parkingData: widget.parkingData,
                  selectedVehicle: selectedVehicle,
                  )),
                );

              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5177),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
