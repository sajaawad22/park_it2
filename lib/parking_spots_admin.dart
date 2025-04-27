import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_it2/access_screen.dart';
import 'admin_login_page.dart';
import 'admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpotsAdmin extends StatefulWidget {
  const ParkingSpotsAdmin({super.key});

  @override
  State<ParkingSpotsAdmin> createState() => _ParkingSpotsAdminState();
}

class _ParkingSpotsAdminState extends State<ParkingSpotsAdmin> {
CollectionReference spots= FirebaseFirestore.instance.collection('parking_spots');

Future <void> deleteSpot (String parkingLotId) async{
    final spotsSnapshot = await spots
        .doc(parkingLotId)
        .collection('spots')
        .get();

 showDialog(
     context: context ,
     builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Delete Spot"),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: spotsSnapshot.docs.length,
              itemBuilder: (context,index){
              final spot= spotsSnapshot.docs[index];
              return ListTile(
                title: Text(spot['spotname']),
                subtitle: Text("Occupied: ${spot['occupied'].toString()}"),
                trailing: IconButton(
                    onPressed: () async{
                  await spots.doc(parkingLotId).collection('spots').doc(spot.id).update({'occupied':true});
                  Navigator.pop(context);
                },
                    icon: Icon(Icons.change_circle, color: Color(0xFFFF5177),)),
              );
       },
        ),
        ),
      );
     }
 );
}

Future <void> editSpot(String parkingLotId) async{

  final spotsSnapshot = await spots
      .doc(parkingLotId)
      .collection('spots')
      .get();

  showDialog(
      context: context ,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Edit availability of Spot"),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ],
            ),
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: spotsSnapshot.docs.length,
              itemBuilder: (context,index){
                final spot= spotsSnapshot.docs[index];
                return ListTile(
                  title: Text(spot['spotname']),
                  subtitle: Text("Occupied: ${spot['occupied'].toString()}"),
                  trailing: IconButton(
                      onPressed: () async{
                        await spots.doc(parkingLotId).collection('spots').doc(spot.id).update({'occupied':false});
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.change_circle, color: Color(0xFFFF5177),)),
                );
              },
            ),
          ),
        );
      }
  );


}

Future <void> addSpot (String parkingLotId) async {
  String spotname ='';
  bool occupied= false;

  showDialog(
      context: context ,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Add Spot"),
          content: Column(
          children: [
            TextField(
              cursorColor: Color(0xFFFF5177),
              decoration: InputDecoration(
                labelText: 'Spot Name ',
              ),
              onChanged: (value){
                spotname=value;
              },
            ),
            Row(
              children: [
                Text("Occupied"),
                Switch(
                  activeColor: Color(0xFFFF5177),
                  value: occupied, onChanged: (value){
                  setState(() {
                    occupied = value;
                  });
                },
                ),
              ],
            )
          ],
          ),
          actions: [
            TextButton(onPressed: () async {
              await spots.doc(parkingLotId).collection('spots').add({
                'spotname': spotname,
                'occupied' : occupied,


              });
              Navigator.pop(context);
            },

                child: Text('Add Spot', style: TextStyle(color: Color(0xFFFF5177)),))
          ],
        );
      }
  );

}


  void showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                "Logout",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                "Are you sure you want to log out?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await logoutUser();
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AdminLoginPage()),
                    );// Navigate to Login Screen
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFFF5177),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Yes, Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFFFDCE4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Cancel", style: TextStyle(color: Color(0xFFFF5177), fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> logoutUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      if (_auth.currentUser != null) {
        await _auth.signOut(); // Sign out from Firebase
      }
    } catch (e) {
      print("Error logging out: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar(
      title: Text("Manage Parking Spots", style: TextStyle(fontWeight: FontWeight.bold),),
      elevation: 0,
      backgroundColor: Colors.white,
    ),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
                child: Padding(
                  padding: const EdgeInsets.only(left: 3,top: 50),
                  child: Text("Admin Menu", style: TextStyle(fontSize: 30),),
                )),
            ListTile(
              leading: Icon(Icons.dashboard_outlined,color: Color(0xFFFF5177),),
              title: Text("Bookings Dashboard",style: TextStyle(fontSize: 19)),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AdminDashboard()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.local_parking_outlined, color: Color(0xFFFF5177),),
              title: Text("Parking Spots",style: TextStyle(fontSize: 19)),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ParkingSpotsAdmin()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code_scanner,color: Color(0xFFFF5177),),
              title: Text("Access",style: TextStyle(fontSize: 19)),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AccessScreen()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFFFF5177),),
              title: Text("Logout", style: TextStyle(fontSize: 19, color: Colors.red),
              ),
              onTap: (){
                showLogoutBottomSheet(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: StreamBuilder(
     stream: spots.snapshots(),
     builder: (context, snapshot) {
     if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
     final data = snapshot.data!.docs;

     return ListView.builder(
        itemCount: data.length,
       itemBuilder: (context, index) {
        final item = data[index];
         return Container(
           margin: EdgeInsets.symmetric(vertical: 8),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                   offset: Offset(0, 2),
                 ),
               ],
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     ClipRRect(
                       borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                       child: Image.network(
                         item['imageUrl'],
                         width: 120,
                         height: 100,
                         fit: BoxFit.cover,
                       ),
                     ),
                     Expanded(
                       child: ListTile(
                         title: Text(item['name']),
                         subtitle: Text(item['address'] ?? ''),
                         trailing: IconButton(onPressed: (){
                           editSpot(item.id);
                         }, icon: Icon(Icons.edit)),
                       ),
                     ),
                   ],
                 ),
                       Divider(),

                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                       child: Row(
                         children: [
                           Expanded(
                             child: ElevatedButton(
                                 onPressed: (){
                                   deleteSpot(item.id);

                                 },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Color(0xFFFFEEF2),
                               minimumSize: Size(double.infinity, 50),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                             ),
                             child: Text("Delete Spot", style: TextStyle(color: Colors.red),)),
                           ),
                           SizedBox(width: 8),
                           Expanded(
                             child: ElevatedButton(
                                 onPressed: (){
                                   addSpot(item.id);

                                 },
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Color(0xFFFF5177),
                                   minimumSize: Size(double.infinity, 50),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                 ),
                                 child: Text("Add Spot", style: TextStyle(color: Colors.white),)),
                           )

                         ],
                       ),
                       ),
                     ],
                   ),
                 );
         },
       );
     },
    ),
    ),

    );
  }
}

