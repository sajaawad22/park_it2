import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park_it2/payment_screen.dart';

class PickParkingScreen extends StatefulWidget {
  const PickParkingScreen({super.key});

  @override
  State<PickParkingScreen> createState() => _PickParkingScreenState();
}

class _PickParkingScreenState extends State<PickParkingScreen> {
  int selectedFloor = 1;

  Future<List<Map<String, dynamic>>> fetchParkingSpots(int floor) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('parking_spots')
        .doc('hzYQG3MQjo1lg13fwFnf')
        .collection('spots')
        //.where('floor', isEqualTo: floor)
        .get();

    return snapshot.docs.map((doc) => {
      'spotId': doc.id,
      'occupied': doc['occupied'],
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

        child: Column(

          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ChoiceChip(
                    backgroundColor: Colors.white,
                    label: Text('1st Floor', style: TextStyle(
                      color: selectedFloor ==1 ? Colors.white : Color(0xFFFF5177),
                    ),),
                    selectedColor: Color(0xFFFF5177),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(
                        color: selectedFloor==1 ? Color(0xFFFF5177) : Color(0xFFFF5177),
                      ),
                    ),
                    selected: selectedFloor==1,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          selectedFloor = 1;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    backgroundColor: Colors.white,
                    label: Text('2nd Floor',style: TextStyle(
                      color: selectedFloor ==2 ? Colors.white : Color(0xFFFF5177),
                    ), ),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(
                        color: selectedFloor==2 ? Color(0xFFFF5177) : Color(0xFFFF5177),
                      ),
                    ),
                    selectedColor: Color(0xFFFF5177),
                    selected: selectedFloor==2,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          selectedFloor = 2;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    backgroundColor: Colors.white,
                    label: Text('3rd Floor',style: TextStyle(
                      color: selectedFloor ==3 ? Colors.white : Color(0xFFFF5177),
                    ), ),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(
                        color: selectedFloor==3 ? Color(0xFFFF5177) : Color(0xFFFF5177),
                      ),
                    ),
                    selectedColor: Color(0xFFFF5177),
                    selected: selectedFloor ==3,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          selectedFloor = 3;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchParkingSpots(selectedFloor),
            builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No spots available.'));
            };
            final spots = snapshot.data!;
            print("Loaded ${snapshot.data!.length} spots");
            for (var doc in snapshot.data!) {
        print(doc['spotId']);
            }
            return GridView.count(
            crossAxisCount: 3,
            padding: EdgeInsets.all(16),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: spots.map((spot) {
            return GestureDetector(
            onTap: () {
            // handle selection
            },
            child: Container(
            decoration: BoxDecoration(
            color: spot['occupied'] ? Colors.grey : Colors.pink[100],
            borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
            child: Text(
            spot['spotId'],
            style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            ),
            ),
            ),
            ),
            );
            }).toList(),
            );
            },
            ),
            ),
            Divider(),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PaymentScreen()),
                );
              } ,
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
    );
  }
}
