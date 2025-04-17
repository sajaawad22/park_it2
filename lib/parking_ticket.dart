import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'home_screen.dart';



class ParkingTicket extends StatefulWidget {
  final Map<String, dynamic> parkingData;
  final String? selectedVehicle;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double duration;
  final double totalPrice;
  final String? selectedSpotName;
  final String? selectedMethod;



  const ParkingTicket({
    super.key,
    required this.parkingData,
    this.selectedVehicle,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalPrice,
    this.selectedSpotName,
    this.selectedMethod,
  });

  @override
  State<ParkingTicket> createState() => _ParkingTicketState();
}



class _ParkingTicketState extends State<ParkingTicket> {
  String? userPhoneNumber;
  @override
  void initState() {
    super.initState();
    fetchUserPhone();
  }

  Future<void> fetchUserPhone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userPhoneNumber = doc.data()?['phonenumber']?.toString();
        });
      }
    }
  }

  String getQrData() {
    return '''
Booking ID: ${DateTime.now().millisecondsSinceEpoch}
User: ${widget.selectedVehicle ?? "Unknown"}
Parking Lot: ${widget.parkingData['name']}
Address: ${widget.parkingData['address']}
Spot: ${widget.selectedSpotName ?? "N/A"}
Date: ${DateFormat("yyyy-MM-dd").format(widget.selectedDate)}
Time: ${widget.startTime.format(context)} - ${widget.endTime.format(context)}
Duration: ${widget.duration.toStringAsFixed(1)} hours
Payment Method: ${widget.selectedMethod ?? "N/A"}
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        backgroundColor: Colors.white,
        title: Text("Parking Ticket",style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
              child: Column(
                children: [
                  Text("Scan this on the scanner machine when you are in the parking lot", textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 12),
                  QrImageView(
                  data: getQrData(),
                  size: 200.0,
                ),
                  Divider(height: 40),
                  _buildTicketInfoRow('Name', FirebaseAuth.instance.currentUser?.displayName ?? FirebaseAuth.instance.currentUser?.email ?? "Unknown", "Vehicle", widget.selectedVehicle.toString()),
                  _buildTicketInfoRow('Parking Area', widget.parkingData['name'], "Parking Spot", widget.selectedSpotName ?? "N/A"),
                  _buildTicketInfoRow('Duration',' ${widget.duration.toStringAsFixed(0)} hours', "Date",DateFormat("MMMM d, yyyy").format(widget.selectedDate)),
                  _buildTicketInfoRow('Hours', '${widget.startTime.format(context)} - ${widget.endTime.format(context)}', "Phone", '+${userPhoneNumber}'),

                ],
              ),
            ),
            Spacer(),
            Divider(),
            SizedBox(height: 10,),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        selectedParkingData: {
                          'lat': widget.parkingData['lat'],
                          'lng': widget.parkingData['lng'],
                        },
                      ),
                    ),
                  );
            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF5177),
                  minimumSize: Size(double.infinity,50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child:Text("Navigate to Parking Lot", style: TextStyle(color: Colors.white),)),
          ],

        ),
      ),
    );

  }
  Widget _buildTicketInfoRow(String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTicketColumn(label1, value1),
        SizedBox(width: 10),
        _buildTicketColumn(label2, value2),
      ],
    );
  }

  Widget _buildTicketColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
