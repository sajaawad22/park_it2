import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';




class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> allSpots = [];
  List<Map<String, dynamic>> filteredSpots = [];
  List<String> recentSearches = [];
  double userLat = 0.0;
  double userLng = 0.0;

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double distance = 10;
        bool valetParking = false;
        List<String> sortOptions = ['Distance', 'Slots Available', 'Lower Price'];
        String selectedSort = 'Distance';

        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Filter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

                SizedBox(height: 10),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Sort by", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("See All", style: TextStyle(color: Color(0xFFFF5177))),
                  ],
                ),
                Wrap(
                  spacing: 7,
                  children: sortOptions.map((option) {
                    bool isSelected = selectedSort == option;
                    return ChoiceChip(

                      backgroundColor: Colors.white,
                      label: Text(
                          option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFFFF5177),
                        ),

                      ),
                      selected: isSelected,
                      selectedColor: Color(0xFFFF5177),
                      onSelected: (_) => setState(() => selectedSort = option),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        side: BorderSide(
                          color: isSelected ? Color(0xFFFF5177) : Color(0xFFFF5177),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Distance", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  ],
                ),
                Slider(
                  activeColor: Color(0xFFFF5177),
                  value: distance,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${distance.toInt()} km',
                  onChanged: (val) => setState(() => distance = val),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Valet Parking", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    Switch(
                      value: valetParking,
                      onChanged: (val) => setState(() => valetParking = val),
                      activeColor: Color(0xFFFF5177),
                      inactiveTrackColor: Color(0xFFFCECF0),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Divider(),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedSort = 'Distance';
                            distance = 10;
                            valetParking = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFCECF0),

                      ),
                        child: Text("Reset", style: TextStyle(color: Color( 0xFFFF5177)),),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await getUserLocation();
                         List<Map<String, dynamic>> updatedSpots = allSpots;

        // Filter by valet
                         if (valetParking) {
                           updatedSpots = updatedSpots.where((spot) => spot['valet'] == true).toList();
                         }
                         updatedSpots = updatedSpots.where((spot) {
                           double? lat = spot['lat'];
                           double? lng = spot['lng'];
                           if (lat == null || lng == null) return false;
                           double dx = lat - userLat;
                           double dy = lng - userLng;
                           double dist = sqrt(dx * dx + dy * dy) * 111; // Approx conversion to km
                           spot['distance'] = dist;
                           return dist <= distance;
                         }).toList();
                         if (selectedSort == 'Distance') {
                           updatedSpots.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
                         } else if (selectedSort == 'Lower Price') {
                           updatedSpots.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        } /*else if (selectedSort == 'Slots Available') {
                            updatedSpots.sort((a, b) => (b['slots'] as int).compareTo(a['slots'] as int));
                          }*/
                          setState(() {
                            filteredSpots = updatedSpots;
                          });
                          Navigator.pop(context);

                          Future.microtask(() {
                            if (!mounted) return;
                            if (filteredSpots.isNotEmpty) {
                              final firstSpot = filteredSpots.first;
                              final lat = firstSpot['lat'];
                              final lng = firstSpot['lng'];
                              if (lat != null && lng != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(initialLocation: GeoPoint(lat, lng)),
                                  ),
                                );
                              }
                            }
                          });
                          },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF5177),
                        ),
                        child: Text("Apply Filter", style: TextStyle(color: Colors.white),),
                      ),

                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('parking_spots').get().then((snapshot) {
      setState(() {
        allSpots = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        filteredSpots = allSpots;
      });
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('recent_searches')
          .where('userEmail', isEqualTo: user.email)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get()
          .then((snapshot) {
        setState(() {
          recentSearches = snapshot.docs.map((doc) => doc['query'].toString()).toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xFFFFF0F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFFF5177),
                width: 1.0,
              ),

            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Color(0xFFFF5177), size: 28,),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.all(15),

                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredSpots = allSpots.where((spot) =>
                        spot['name'] != null &&
                            spot['location'] != null
                        ).toList();
                      });
                    },
                  ),
                ),
                IconButton(
                  color: Color(0xFFFF5177),
                  icon: Icon(Icons.tune),
                  onPressed: () {
                    showFilterSheet(context);

                  },
                ),
              ],
            ),
              ),
              SizedBox(height: 20),
              Divider(),
              Text(
                'Recent',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredSpots.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(filteredSpots[index]['name']),
                      onTap: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          FirebaseFirestore.instance.collection('recent_searches').add({
                            'query': filteredSpots[index]['name'],
                            'timestamp': FieldValue.serverTimestamp(),
                            'userEmail': user.email,
                          });
                        }
                        final lat = filteredSpots[index]['lat'];
                        final lng = filteredSpots[index]['lng'];


                        if (lat != null && lng != null) {
                          print("Navigating to : lat = $lat, lng = $lng");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                initialLocation: GeoPoint(lat, lng),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Location data is missing for this spot.')),
                          );
                        }},
                    );
                  },
                ),
              )
            ],
          ),
          ),
      ),
    );
  }
}
