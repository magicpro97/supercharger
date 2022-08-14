import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GoogleMapController _mapController;
  final _location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
    _initLocation().then((location) =>
        _mapController.animateCamera(CameraUpdate.newLatLng(location)));
  }

  Future<LatLng> _initLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return const LatLng(0, 0);
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return const LatLng(0, 0);
      }
    }

    final location = await _location.getLocation();

    return LatLng(location.latitude!, location.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: const CameraPosition(target: LatLng(0, 0)),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
