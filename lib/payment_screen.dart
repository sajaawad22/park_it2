import 'package:flutter/material.dart';
import 'package:park_it2/add_card_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String ? selectedMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'Paypal', 'value': 'paypal', 'icon': 'images/icons8-paypal-24.png'},
    {'name': 'Google Pay', 'value': 'google', 'icon': 'images/icons8-google-48.png'},
    {'name': 'Apple Pay', 'value': 'apple', 'icon': 'images/icons8-apple-30.png'},
  ];



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
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddCardScreen()),
                );
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
            ElevatedButton(
              onPressed: () {
                // Handle continue
              },
              child: Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5177),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}