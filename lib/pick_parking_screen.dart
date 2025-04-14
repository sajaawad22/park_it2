import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park_it2/payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PickParkingScreen extends StatefulWidget {
  final Map<String, dynamic> parkingData;
  final String? selectedVehicle;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double duration;
  final double totalPrice;


  const PickParkingScreen({
    super.key,
    required this.parkingData,
    this.selectedVehicle,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalPrice,
  });

  @override
  State<PickParkingScreen> createState() => _PickParkingScreenState();
}

class _PickParkingScreenState extends State<PickParkingScreen> {
  String? selectedSpotId;
  String? selectedSpotName;
  Future<List<Map<String, dynamic>>> fetchParkingSpots() async {
    final parkingLotName = widget.parkingData['name'];

    final parkingLotQuery = await FirebaseFirestore.instance
        .collection('parking_spots')
        .where('name', isEqualTo: parkingLotName)
        .get();

    if (parkingLotQuery.docs.isEmpty) {
      print('No parking lot found with name $parkingLotName');
      return [];
    }

    final parkingLotDoc = parkingLotQuery.docs.first;

    final snapshot = await FirebaseFirestore.instance
        .collection('parking_spots')
        .doc(parkingLotDoc.id)
        .collection('spots')
        .get();

    print('Fetched ${snapshot.docs.length} spots from Firestore.');

    return snapshot.docs.map((doc) {
      return {
        'spotId': doc.id,
        'occupied': doc['occupied'],
        'spotname': doc['spotname'],
      };
    }).toList();
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchParkingSpots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No parking spots available.'));
                    }

                    final spots = snapshot.data!;
                    final List<Widget> firstRow = List.generate(6, (index) {
                      final spot = index < spots.length ? spots[index] : null;
                      return buildParkingSpot(spot);
                    });

                    final List<Widget> secondRow = List.generate(6, (index) {
                      final spot = (index + 6) < spots.length ? spots[index + 6] : null;
                      return buildParkingSpot(spot);
                    });

                    return Column(
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: firstRow,
                        ),
                        SizedBox(height: 10),
                        Divider(thickness: 1, color: Colors.grey),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 40,
                          width: double.infinity,
                          child: Row(
                            children: [
                              SizedBox(width: 20),
                              Icon(Icons.arrow_forward_sharp, color: Colors.grey, size: 30),

                              // Small horizontal spacing
                              SizedBox(width: 5),

                              // Dashed line effect
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(6, (i) {
                                    return Container(
                                      width: 15,
                                      height: 2,
                                      color: Colors.grey,
                                    );
                                  }),
                                ),
                              ),

                              // Side margin to match indentation
                              SizedBox(width: 20),
                            ],
                          ),

                        ),
                        Divider(thickness: 1, color: Colors.grey),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: secondRow,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(),
              SizedBox(height: 10),


              ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User not logged in.')),
                    );
                    return;
                  }
                  try {
                    await FirebaseFirestore.instance.collection('bookings').add({
                      'userId': user.uid,
                      'vehicle': widget.selectedVehicle,
                      'selectedDate': widget.selectedDate,
                      'startTime': widget.startTime.format(context),
                      'endTime': widget.endTime.format(context),
                      'duration': widget.duration,
                      'totalPrice': widget.totalPrice,
                      'parkingName': widget.parkingData['name'],
                      'spotName': selectedSpotName,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    print('Booking saved successfully!');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentScreen(
                        parkingData: widget.parkingData,
                        selectedVehicle: widget.selectedVehicle,
                        selectedDate: widget.selectedDate,
                        startTime: widget.startTime,
                        endTime: widget.endTime,
                        duration: widget.duration,
                        totalPrice: widget.totalPrice,
                        selectedSpotName: selectedSpotName,
                      )),
                    );
                  } catch (e) {
                    print('Error saving booking: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save booking.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF5177),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Continue', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildParkingSpot(Map<String, dynamic>? spot) {
    if (spot == null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    final bool isOccupied = spot['occupied'];

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isOccupied ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(10),

      ),
        child: isOccupied
            ? Center(
          child: Image.network(
            'https://firebasestorage.googleapis.com/v0/b/park-it-db7e4.firebasestorage.app/o/icons8-car-48%20(1).png?alt=media&token=504bcee4-1bf8-4f30-9050-e9d0d6dafbb0',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        )
            : GestureDetector(
          onTap: () {
            setState(() {
              selectedSpotId = spot['spotId'];
              selectedSpotName = spot['spotname'];
            });
          },
          child:Center(
            child: Container(
              width: 80,
              height: 40,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: selectedSpotId == spot['spotId'] ? Color(0xFFFF5177) : Colors.pink[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                spot['spotname'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
    );
  }
}
