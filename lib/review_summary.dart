import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';



class ReviewSummary extends StatefulWidget {
  final Map<String, dynamic> parkingData;
  final String? selectedVehicle;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double duration;
  final double totalPrice;
  final String? selectedSpotName;
  final String? selectedMethod;

  const ReviewSummary({
    Key? key,
    required this.parkingData,
    this.selectedVehicle,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalPrice,
    this.selectedSpotName,
    this.selectedMethod,
  }) : super(key: key);
  @override
  State<ReviewSummary> createState() => _ReviewSummaryState();
}

class _ReviewSummaryState extends State<ReviewSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        backgroundColor: Colors.white,
        title: Text("Review Summary",style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.grey)]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bookingRow("Parking Area", widget.parkingData['name']),
                  bookingRow("Address", widget.parkingData['address']),
                  bookingRow("Vehicle", widget.selectedVehicle),
                  bookingRow("Parking Spot", widget.selectedSpotName),
                  bookingRow("Date", DateFormat("MMMM d, yyyy").format(widget.selectedDate)),
                  bookingRow("Duration", "${widget.duration.toStringAsFixed(0)} hours"),
                  bookingRow("Hours", "${widget.startTime.format(context)} - ${widget.endTime.format(context)}"),
                ],
              ),

              ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(blurRadius: 6, color: Colors.grey)]
              ),
              child: Column(
                children: [
                  paymentRow("Amount", '₺${widget.totalPrice.toStringAsFixed(0)} '),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(blurRadius: 6, color: Colors.grey)]
              ),
              child: Row(
                children: [
                  getPaymentIcon(widget.selectedMethod),
                  SizedBox(width: 10),
                  Text(widget.selectedMethod.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                  Spacer(),
                  TextButton(
                    onPressed: (){
                        Navigator.of(context).pop();
                    },
                      child: Text("Change", style: TextStyle(color: Color(0xFFFF5177)),
                      ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Divider(),
            SizedBox(height: 10,),

            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(child: CircularProgressIndicator()),
                );

                String usedCardNumber = widget.selectedMethod?.replaceAll(RegExp(r'[^0-9]'), '') ?? "1234567890123456";
                bool success = await MockPaymentGateway.processPayment(usedCardNumber);

                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => Center(
                    child: AlertDialog(
                      backgroundColor: Colors.white,
                      icon: Image.asset('images/checkforpayment.png'),
                      title: Text(success ? "Successful!" : "Payment Failed", style: TextStyle(color: Color(0xFFFF5177)),),
                      content: Text(success
                          ? "Successfully made payment for your parking"
                          : "Your payment was declined. Please try a different card.", textAlign: TextAlign.center,),
                      actions: [
                        ElevatedButton(
                          onPressed: () {

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF5177),
                            minimumSize: Size(double.infinity,50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text("View Parking Ticket", style: TextStyle(color: Colors.white),),
                        ),
                        SizedBox(height: 10),

                        ElevatedButton(onPressed: (){
                          Navigator.of(context).pop();
                          if (success) Navigator.pop(context);
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFF0F3),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ), child:Text("Cancel", style: TextStyle(color: Color(0xFFFF5177)),),
                ),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5177),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Confirm Payment", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
          
        ),
      ),

    );

  }
  Widget getPaymentIcon(String? method){
    switch(method){
      case 'paypal':
        return Image.asset("images/icons8-paypal-24.png");
      case 'google':
        return Image.asset("images/icons8-google-48.png", scale: 1.5);
      case 'apple':
        return Image.asset("images/icons8-apple-30.png");
      default:
        return Icon(Icons.payment);

    }
  }
  Widget bookingRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700]))),
          Expanded(child: Text(value!, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
  Widget paymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label,
              style: TextStyle(color: Colors.grey[700])),),
          Text(value, style: TextStyle(fontWeight:  FontWeight.bold)),
        ],
      ),
    );
  }
}
class MockPaymentGateway {
  static Future<bool> processPayment(String cardNumber) async {
    await Future.delayed(Duration(seconds: 2));
    return !cardNumber.trim().startsWith('1');
  }
}
