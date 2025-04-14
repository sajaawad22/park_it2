import 'dart:async';
import 'package:flutter/material.dart';
import 'package:park_it2/pick_parking_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class BookParkingScreen extends StatefulWidget {
  const BookParkingScreen({Key? key, required this.parkingData, this.selectedVehicle}) : super(key: key);
  final Map<String, dynamic> parkingData;
  final String? selectedVehicle;


  @override
  State<BookParkingScreen> createState() => _BookParkingScreenState();
}

class _BookParkingScreenState extends State<BookParkingScreen> {

  late User? user;
  late String userId;
  late double _selectedHours=1.0;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay _startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 10, minute: 0);

  @override

  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';

  }

  Future<double> getPricePerHour() async {
    return (widget.parkingData['priceperhour'] as num).toDouble();

  }

  double calculateTotalPrice() {
    final pricePerHour = widget.parkingData['priceperhour'] ?? 0.0;
    print("Price per hour: $pricePerHour");
    return pricePerHour * _selectedHours;
  }

  Future<void> saveBookingDetails(String userId, DateTime selectedDate,
      TimeOfDay startTime, TimeOfDay endTime, double duration, String parkingName) async {
    try {
      double pricePerHour = await getPricePerHour();

      double totalPrice = pricePerHour * duration;

      CollectionReference bookings = FirebaseFirestore.instance.collection('bookings');

      await bookings.add({
        'userId': userId,
        'selectedDate': selectedDate,
        'startTime': startTime.format(context),
        'endTime': endTime.format(context),
        'duration': duration,
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'parkingName': parkingName,
      });

      print('Booking saved successfully!');
    } catch (e) {
      print('Error saving booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Book Parking Details", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFFF5177),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text("Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Slider(
                    value: _selectedHours,
                    min: 1.0,
                    max: 12.0,
                    label: '${_selectedHours.toInt()} hrs',
                    activeColor: Color(0xFFFF5177),
                    onChanged: (value) {
                      setState(() {
                        _selectedHours = value;
                        final endHour = (_startTime.hour + _selectedHours.toInt()) % 24;
                        _endTime = TimeOfDay(hour: endHour, minute: _startTime.minute);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Start Hour", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          TextButton(
                            onPressed: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                              );

                              if (picked != null && picked != _startTime) {
                                setState(() {
                                  _startTime = picked;
                                  final endHour = (_startTime.hour + _selectedHours.toInt()) % 24;
                                  _endTime = TimeOfDay(hour: endHour, minute: _startTime.minute);
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFFCECF0),
                              foregroundColor: Color(0xFFFF5177),
                            ),
                            child: Text(_startTime.format(context)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Icon(Icons.arrow_forward_sharp, color: Colors.black),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("End Hour", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          TextButton(
                            onPressed: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime,
                              );
                              if (picked != null && picked != _endTime) {
                                setState(() {
                                  _endTime = picked;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFFCECF0),
                              foregroundColor: Color(0xFFFF5177),
                            ),
                            child: Text(_endTime.format(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                        "Total: \₺${(calculateTotalPrice()).toStringAsFixed(2)}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Divider(),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final parkingName = widget.parkingData['name'];  // Fetch parking name instead of spotId
                    if (parkingName == null || parkingName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: Parking spot not selected!')),
                      );
                      return;
                    }

                    if (_selectedDay == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date!')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PickParkingScreen(
                        parkingData: widget.parkingData,
                        selectedVehicle: widget.selectedVehicle,
                        selectedDate: _selectedDay!,
                        startTime: _startTime,
                        endTime: _endTime,
                        duration: _selectedHours,
                        totalPrice: calculateTotalPrice(),
                      ),
                      ),
                    );
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
      ),
    );
  }
}




