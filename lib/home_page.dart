import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as lc;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GoogleMapController _mapController;
  final _location = lc.Location();

  late bool _serviceEnabled;
  late lc.PermissionStatus _permissionGranted;

  var _searchLocation = '';
  Set<Marker> _markers = {};
  var _currentLatLng = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    Future.wait([_initLocation(), _getMarkers()]).then((data) {
      setState(() {
        _currentLatLng = data[0] as LatLng;
        _markers = data[1] as Set<Marker>;
      });

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng, zoom: 12),
        ),
      );
    });
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
    if (_permissionGranted == lc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != lc.PermissionStatus.granted) {
        return const LatLng(0, 0);
      }
    }

    final location = await _location.getLocation();

    return LatLng(location.latitude!, location.longitude!);
  }

  Future<List<dynamic>?> _fetchData() async {
    final dio = Dio();
    final response = await dio.get(
        "https://www.tesla.com/cua-api/tesla-locations?translate=en_US&usetrt=true");
    if (response.statusCode != 200) {
      return null;
    }

    final shared = await SharedPreferences.getInstance();

    final teslaLocations = jsonEncode(response.data);
    shared.setString('TESLA_LOCATIONS', teslaLocations);

    return response.data as List;
  }

  Future<List<dynamic>?> _getData() async {
    final shared = await SharedPreferences.getInstance();

    final data = shared.getString('TESLA_LOCATIONS');
    if (data == null) {
      return null;
    }

    return jsonDecode(data) as List;
  }

  Future<Set<Marker>> _getMarkers() async {
    var data = await _getData() ?? await _fetchData();
    if (data == null) {
      return {};
    }

    return data
        .map(
          (location) => Marker(
            markerId: MarkerId(location['location_id']),
            position: LatLng(
              double.parse(location['latitude'].toString()),
              double.parse(location['longitude'].toString()),
            ),
          ),
        )
        .toSet();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(target: _currentLatLng),
              mapToolbarEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              onMapCreated: _onMapCreated,
            ),

            //search autoconplete input
            Positioned(
              //search input bar
              top: 10,
              child: InkWell(
                onTap: () async {
                  final location = await _location.getLocation();

                  var place = await PlacesAutocomplete.show(
                      context: context,
                      apiKey: kGoogleApiKey,
                      mode: Mode.overlay,
                      types: [],
                      strictbounds: false,
                      location: Location(
                        lat: location.latitude!,
                        lng: location.longitude!,
                      ),
                      hint: 'Searches for',
                      //google_map_webservice package
                      onError: (err) {
                        print(err);
                      });

                  if (place != null) {
                    setState(() {
                      _searchLocation = place.description.toString();
                    });

                    //form google_maps_webservice package
                    final plist = GoogleMapsPlaces(
                      apiKey: kGoogleApiKey,
                      apiHeaders: await const GoogleApiHeaders().getHeaders(),
                      //from google_api_headers package
                    );
                    final placeId = place.placeId ?? "0";
                    final detail = await plist.getDetailsByPlaceId(placeId);
                    final geometry = detail.result.geometry!;
                    final lat = geometry.location.lat;
                    final lang = geometry.location.lng;
                    var target = LatLng(lat, lang);

                    //move map camera to selected place with animation
                    _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: target, zoom: 12),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Card(
                    child: Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width - 40,
                        child: ListTile(
                          title: Text(
                            _searchLocation,
                            style: const TextStyle(fontSize: 18),
                          ),
                          trailing: const Icon(Icons.search),
                          dense: true,
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
