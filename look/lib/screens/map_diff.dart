import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
    databaseURL:
        'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
  ).ref();

  late DateTime _lastSeenTimestamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentLocation = LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0});
    _userRef = databaseRef.child('users').child(widget.userId);
    _initializeContactList();
    _getUserLocationFromDatabase();
  }

  Future<void> _initializeContactList() async {
    await _getContactList();
    _checkIfContactExists();
  }

  Future<void> _getUserLocationFromDatabase() async {
    _userRef.once().asStream().listen((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      if (values.containsKey('latitude') && values.containsKey('longitude')) {
        setState(() {
          _currentLocation = LocationData.fromMap({
            'latitude': values['latitude']!,
            'longitude': values['longitude']!,
          });
          _markers.add(
            Marker(
              markerId: MarkerId('userMarker'),
              position: LatLng(_currentLocation.latitude!,
                  _currentLocation.longitude!),
              infoWindow: InfoWindow(title: 'User Location'),
            ),
          );
        });
      }
      if (values.containsKey('timestamp')) {
        int timestampMilliseconds = values['timestamp'];
        _lastSeenTimestamp =
            DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
      }
    });
  }

  late bool _isContact;
  List<Object> _contactList = [];

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );

    if (_currentLocation != LocationData.fromMap(
        {'latitude': 0.0, 'longitude': 0.0})) {
      initialCameraPosition = CameraPosition(
        target: LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
        zoom: 18.0,
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          if (_isContact)
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
              child: Text('User is not in contacts'),
            ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01, 
              left:MediaQuery.of(context).size.width * 0.25, 
              right: MediaQuery.of(context).size.width * 0.3),
              child: FloatingActionButton.extended(
                onPressed: () {
                  _goToContactLocation();
                },
                label: Text('Contact location'),
                icon: Icon(Icons.location_on),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.06,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Last Seen: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(_lastSeenTimestamp)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getContactList() async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final snapshot = await userDocRef.get();
    final contacts = List<String>.from(snapshot.get('contacts'));
    print(contacts);
    setState(() {
      _contactList = contacts;
    });
  }

  Future<void> _checkIfContactExists() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        print(userId);
        print(widget.userId);
        print(_contactList);
        _isContact = _contactList.contains(userId);
        if (_isContact) {
          _getUserLocationFromDatabase();
        } else {
          print('User is not in contacts');
        }
      }
    } catch (e) {
      print('Error checking if contact exists: $e');
    }
  }

  Future<void> _goToContactLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentLocation.latitude!, _currentLocation.longitude!)));
  }
}
