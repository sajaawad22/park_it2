import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park_it2/details_screen.dart';
import 'package:park_it2/saved_screen.dart';
import 'booking_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as gm_cluster;
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParkingSpot with gm_cluster.ClusterItem {
  final String id;
  final LatLng location;
  final String name;

  ParkingSpot({required this.id, required this.location, required this.name});

  @override
  LatLng get locationLatLng => location;
}
class HomeScreen extends StatefulWidget {
  final GeoPoint ? initialLocation;
  const HomeScreen({Key? key, this.initialLocation}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(0, 0);
  gm_cluster.ClusterManager<ParkingSpot>? _clusterManager;
  Set<Marker> _markers = {};
  bool _isSaved =false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initClusterManager();
  }

  void _initClusterManager() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('parking_spots').get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        print("Loading spot: ${data['name']}");
        return ParkingSpot(
          id: doc.id,
          name: data['name'],
          location: LatLng(data['lat'], data['lng']),
        );
      }).toList();

      _clusterManager = gm_cluster.ClusterManager<ParkingSpot>(
        items,
        _updateMarkers,
        markerBuilder: _markerBuilder,
        stopClusteringZoom: 17,
      );
    } catch (e) {
      print("Error loading cluster manager: $e");
    }
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  Future<BitmapDescriptor> _getCustomIcon() async {
    final ByteData byteData = await rootBundle.load('images/icons8-parking-64.png');
    final Uint8List imageData = byteData.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(imageData, targetWidth: 100, targetHeight: 100);
    final frameInfo = await codec.getNextFrame();
    final byteDataResized = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteDataResized!.buffer.asUint8List());
  }

  Future<Marker> Function(gm_cluster.Cluster<ParkingSpot>) get _markerBuilder => (cluster) async  {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      icon: await _getCustomIcon(),
      onTap: () async {
        if (!cluster.isMultiple) {
          final spotId = cluster.items.first.id;
          final doc = await FirebaseFirestore.instance
              .collection('parking_spots')
              .doc(spotId)
              .get();
          final data = doc.data();
          if (data != null && mounted) {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('Details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      Divider( thickness: 1,),
                      SizedBox(height: 12),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(data['imageUrl'],
                              height: 150, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            data['address'] ?? '',
                                            style: TextStyle(color: Colors.grey[600]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                          _isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
                                          color: Color(0xFFFF5177)),
                                      onPressed: () {
                                        final currentUser = FirebaseAuth.instance.currentUser;
                                        if (currentUser != null) {
                                          FirebaseFirestore.instance.collection('saved_spots').add({
                                            'userEmail': currentUser.email,
                                            'spotId': spotId,
                                            'name': data['name'],
                                            'address': data['address'],
                                            'imageUrl': data['imageUrl'],
                                            'lat': data['lat'],
                                            'lng': data['lng'],
                                            'timestamp': FieldValue.serverTimestamp(),
                                          });
                                        }

                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFFCECF0),
                              ),
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: Color(0xFFFF5177))),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final doc = await FirebaseFirestore.instance.collection("parking_spots").doc(spotId).get();
                                if(doc.exists && context.mounted){
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => DetailsScreen(parkingData: doc.data()!)
                                    ),
                                  );
                                }

                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF5177)),
                              child: Text('Details',
                                  style: TextStyle(color: Colors.white)),

                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  };

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (_mapController != null) {
        _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
      }
    } catch (e) {
      print('Error getting location: $e');
      // Handle error
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_clusterManager != null) {
      _clusterManager!.setMapId(controller.mapId);
      _clusterManager!.updateMap(); // force update markers
    }
    //_getCurrentLocation();
    if (widget.initialLocation != null) {
      _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                widget.initialLocation!.latitude,
                widget.initialLocation!.longitude,
              ),
              zoom: 17, // Zoomed-in view for selected parking spot
        ),
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
          _currentLocation.latitude == 0 && _currentLocation.longitude == 0
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 12.0,
            ),
            markers: _markers,
            onCameraMove: _clusterManager?.onCameraMove,
            onCameraIdle: _clusterManager?.updateMap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 40,
            left: 240,
            right: 16,
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(5),
                    child: IconButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    }, icon: Icon(Icons.search, color: Color(0xFF4810CF), size: 30,)) ,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(5),
                    child: IconButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsScreen()),
                      );

                    }, icon: Icon(Icons.notifications, color: Color(0xFF4810CF), size: 30,)) ,
                  ),

                ],

              ),
            ),

          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation, backgroundColor: Color(0xFF4810CF),
        child: Icon(Icons.my_location, color:Colors.white ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF5177),
          unselectedItemColor: Colors.black,
          items: [
            BottomNavigationBarItem(icon: IconButton(onPressed: (){

            },
                icon: Icon(Icons.home_filled)),
            label: 'Home'
            ),
            BottomNavigationBarItem(icon: IconButton(onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => SavedScreen()));
            }, icon: Icon(Icons.bookmark)),
              label: 'Saved'
            ),
            BottomNavigationBarItem(icon: IconButton(onPressed: (){
              Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (context) => BookingScreen()),
              );
            }, icon: Icon(Icons.list_alt)),
                label: 'Booking',
            ),
            BottomNavigationBarItem(icon: IconButton(onPressed: (){
              Navigator.pushReplacement(context,
                MaterialPageRoute(
                builder: (context) => ProfileScreen()),
              );
            }, icon: Icon(Icons.account_box)),
                label: 'Profile'
            ),

          ]),

    );

  }
}