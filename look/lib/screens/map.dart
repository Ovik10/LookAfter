import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  late LocationData _currentLocation;
  late final Location location;
  StreamSubscription<LocationData>? locationSubscription;

final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
).ref();


 @override
  void initState() {
    super.initState();
    location = Location();

    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      if (!mounted) return;
      setState(() {
        _currentLocation = currentLocation;
        _markers.add(
          Marker(
            markerId: MarkerId('myMarker'),
            position: LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
            infoWindow: InfoWindow(title: 'Current Location'),
          ),
        );
      });
      _updateDatabaseWithLocation(currentLocation);
    });
  }
  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void _getCurrentLocation() async {
  try {
    final location = Location();
    final LocationData locationData = await location.getLocation();
    if (!mounted) return;  
    setState(() {
      _currentLocation = locationData;
      _markers.add(
        Marker(
          markerId: MarkerId('myMarker'),
          position: LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
          infoWindow: InfoWindow(title: 'You are here'),
        ),
      );
      _updateDatabaseWithLocation(_currentLocation);
    });
  } catch (e) {
    print('Error getting current location: $e');
  }
}
 void _updateDatabaseWithLocation(LocationData location) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final currentTime = DateTime.now().toUtc().millisecondsSinceEpoch;
      databaseRef.child('users/$userId').update({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': currentTime,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );

    if (_currentLocation != null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
        zoom: 18.0,
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            markers: _markers,
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
                  _goToMyLocation();
                },
                label: Text('My Location'),
                icon: Icon(Icons.my_location),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(_currentLocation.latitude!, _currentLocation.longitude!),
        zoom: 18.0,
      ),
    ));
  }
}
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;

  void startTracking() {
    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      _updateDatabaseWithLocation(currentLocation);
    });
  }

  void stopTracking() {
    locationSubscription?.cancel();
  }

  void _updateDatabaseWithLocation(LocationData location) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final currentTime = DateTime.now().toUtc().millisecondsSinceEpoch;
      final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
      ).ref();

      databaseRef.child('users/$userId').update({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': currentTime,
      });
    }
  }
  Future<void> initialize() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    startTracking();
  }
}