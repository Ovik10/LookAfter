import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class MapDiff extends StatefulWidget {
  final String userId;
  const MapDiff({required this.userId, Key? key}) : super(key: key);

  @override
  State<MapDiff> createState() => MapDiffState();
}

class MapDiffState extends State<MapDiff> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  late LocationData _currentLocation;
  late DatabaseReference _userRef;
  final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
).ref();

  @override
  void initState() {
    super.initState();
    _currentLocation = LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0});
    _userRef = databaseRef.child('users').child(widget.userId);
    _getUserLocationFromDatabase();

  }

  Future<void> _getUserLocationFromDatabase() async {
    _userRef.once().asStream().listen((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> values =
          snapshot.value as Map<dynamic, dynamic>;
      if (values.containsKey('latitude') && values.containsKey('longitude')) {
        setState(() {
          print("ahohj");
          _currentLocation = LocationData.fromMap({
            'latitude': values['latitude']!,
            'longitude': values['longitude']!,
          });
          _markers.add(
            Marker(
              markerId: MarkerId('userMarker'),
              position:
                  LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
              infoWindow: InfoWindow(title: 'User Location'),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );

    if (_currentLocation != LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0})) {
      initialCameraPosition = CameraPosition(
        target: LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
        zoom: 18.0,
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation != LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0}))
            GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              markers: _markers,
            )
          else
            Center(
              child: Text('User has no coordinates'),
            )
        ],
      ),
    );
  }
}
