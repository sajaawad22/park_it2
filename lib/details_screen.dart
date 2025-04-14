import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_vehicle_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> parkingData;

  const DetailsScreen({Key? key, required this.parkingData}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Widget _buildTag (IconData icon, String label){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFF5177),width: 2.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Color(0xFFFF5177)),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Color(0xFFFF5177), fontSize: 15),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        title: Text("Parking Details", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(widget.parkingData['imageUrl'] !=null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    widget.parkingData['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 15),
              Text(
                widget.parkingData['name'] ?? "No name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                widget.parkingData['address'] ?? "No address",
                style: TextStyle(fontSize: 16, color: Colors.grey),
        
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  _buildTag(Icons.access_time, widget.parkingData['hours'] ?? 'N/A'),
                  SizedBox(width: 8),
                  _buildTag(Icons.directions_car_filled, widget.parkingData['valet'] == true ? 'Valet' : 'Self-Park'),
                ],
              ),
        
              SizedBox(height: 10),
              Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(height: 10),
              Text(
                widget.parkingData['description'] ?? "No description",
                style: TextStyle(fontSize: 15, color: Colors.grey),
        
              ),
              SizedBox(height: 15),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 140),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.parkingData['priceperhour'] != null
                            ? '₺${widget.parkingData['priceperhour']}'
                            : 'No price',
                        style: TextStyle(fontSize: 25, color: Color(0xFFFF5177), fontWeight: FontWeight.bold),
        
                      ),
                      Text("per hour",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
        
                      ),
        
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 5),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Color(0xFFFF5177))),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectVehicleScreen(
                                parkingData: widget.parkingData,
                              ),
                            ),
                          );

                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF5177)),
                      child: Text('Book Parking',
                          style: TextStyle(color: Colors.white)),
        
                    ),
                  ),
                ],
        
              ),
            ],
          ),
        ),
      ),
    );
  }
}

