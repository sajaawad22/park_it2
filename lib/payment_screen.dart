import 'package:flutter/material.dart';
import 'package:park_it2/add_card_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'review_summary.dart';
import 'add_card_screen.dart';

class PaymentScreen extends StatefulWidget {

  final Map<String, dynamic> parkingData;
  final String? selectedVehicle;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double duration;
  final double totalPrice;
  final String? selectedSpotName;

  const PaymentScreen({
    Key? key,
    required this.parkingData,
    this.selectedVehicle,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalPrice,
    this.selectedSpotName,
  }) : super(key: key);
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? savedCard;
  String ? selectedMethod;
  List<Map<String, dynamic>> savedCards = [];

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'Paypal', 'value': 'paypal', 'icon': 'images/icons8-paypal-24.png'},
    {'name': 'Google Pay', 'value': 'google', 'icon': 'images/icons8-google-48.png'},
    {'name': 'Apple Pay', 'value': 'apple', 'icon': 'images/icons8-apple-30.png'},
  ];
  @override
  void initState() {
    super.initState();
    fetchSavedCards();
  }
  void fetchSavedCards() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .get();
      setState(() {
        savedCards = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () {
          Navigator.pop(context);
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choose Payment Methods", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 20),
            if (savedCard != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMethod = 'card';
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: selectedMethod == 'card'
                          ? Color(0xFFFF5177)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.black),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          savedCard!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(
                        selectedMethod == 'card'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selectedMethod == 'card'
                            ? Color(0xFFFF5177)
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ...savedCards.map((card) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedMethod = card['cardNumber'];
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: selectedMethod == card['cardNumber']
                        ? Color(0xFFFF5177)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Image.asset('images/creditcard.png', scale: 30,),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Card ending in ${card['cardNumber'] != null ? card['cardNumber'].toString().substring(card['cardNumber'].toString().length - 4) :''}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(
                      selectedMethod == card['cardNumber']
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selectedMethod == card['cardNumber']
                          ? Color(0xFFFF5177)
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            )),
            ...paymentMethods.map((method) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedMethod = method['value'] as String;
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: selectedMethod == method['value'] ? Color(0xFFFF5177) : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                  method['icon'] is String
                      ? Image.asset(method['icon'] as String, height: 26)
                     : Icon(method['icon'] as IconData, color: Colors.black),
                    SizedBox(width: 16),
                    Expanded(child: Text(method['name'] as String, style: TextStyle(fontSize: 16))),

                    Icon(
                      selectedMethod == method['value']
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selectedMethod == method['value'] ? Color(0xFFFF5177) : Colors.grey,
                    ),
                  ],

                ),
              ),
            )),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed:  () async {
                final result= await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddCardScreen()),
                );
                if (result != null && mounted) {
                  setState(() {
                    savedCard = result;
                  });
                }
              },
              icon: Icon(Icons.add, color: Color(0xFFFF5177)),
              label: Text("Add New Card", style: TextStyle(color: Color(0xFFFF5177))),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFFFF0F3),
                padding: EdgeInsets.symmetric(horizontal: 113, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Spacer(),
            Divider(),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                if(selectedMethod ==null){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a payment method')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewSummary(
                    parkingData: widget.parkingData,
                    selectedVehicle: widget.selectedVehicle,
                    selectedDate: widget.selectedDate,
                    startTime: widget.startTime,
                    endTime: widget.endTime,
                    duration: widget.duration,
                    totalPrice: widget.totalPrice,
                    selectedSpotName: widget.selectedSpotName,
                    selectedMethod: selectedMethod,
                  ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5177),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}