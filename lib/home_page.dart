import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as lc;
import 'package:supercharger/generated/assets.dart';
import 'package:supercharger/tesla_location.dart';
import 'package:supercharger/usecases/get_charger_location_data_use_case.dart';
import 'package:supercharger/usecases/launch_map_use_case.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GoogleMapController _mapController;
  final _location = lc.Location();

  late bool _serviceEnabled;
  late lc.PermissionStatus _permissionGranted;

  var _searchLocation = 'Search something';
  Set<Marker> _markers = {};
  var _currentLatLng = const LatLng(0, 0);
  var _currentCountryCode = '';
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.wait([
        _initLocation(),
        _getMarkers(MediaQuery.of(context).devicePixelRatio),
        _getCurrentCountryCode(),
      ]).then((data) {
        setState(() {
          _currentLatLng = data[0] as LatLng;
          _markers = data[1] as Set<Marker>;
          _currentCountryCode = data[2] as String;
          _isLoading = false;
        });

        _mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLatLng, zoom: 12),
          ),
        );
      });
    });
  }

  Future<String> _getCurrentCountryCode() async {
    final response = await Dio().get('http://ip-api.com/json');

    if (response.statusCode == 200) {
      return response.data['countryCode'];
    }

    return '';
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

  Future<Set<Marker>> _getMarkers(double devicePixelRatio) async {
    var data = await GetChargerLocationDataUseCase().getTeslaChargerLocation();

    var icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: devicePixelRatio,
        size: const Size(24, 24),
      ),
      Assets.iconsElectricCharge,
    );

    return data
        .map(
          (location) => Marker(
              markerId: MarkerId(location.locationId),
              position: LatLng(
                location.latitude,
                location.longitude,
              ),
              icon: icon,
              onTap: () => _onTapLocation(location)),
        )
        .toSet();
  }

  void _onTapLocation(TeslaLocation location) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 100,
        child: ListTile(
          leading: Image.asset(Assets.iconsElectricCharge),
          title: Text(location.locationType.first.capitalize()),
          subtitle: Text('${location.latitude}, ${location.longitude}'),
          trailing: IconButton(
              onPressed: () =>
                  _launchMaps(location.latitude, location.longitude),
              icon: const Icon(
                Icons.directions,
                color: Colors.blue,
              )),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _animateToCurrentPosition() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLatLng, zoom: 12),
      ),
    );
  }

  void _launchMaps(double latitude, double longitude) {
    LaunchMapUseCase().launchMap(latitude, longitude);
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
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
            ),
            Positioned(
              bottom: 20,
              left: 10,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(.5, .5),
                      blurRadius: .5,
                      spreadRadius: .3,
                    )
                  ],
                ),
                child: IconButton(
                  onPressed: _animateToCurrentPosition,
                  icon: const Icon(
                    Icons.my_location,
                    color: Colors.black54,
                  ),
                ),
              ),
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
                      components: _currentCountryCode.isNotEmpty
                          ? [
                              Component(Component.country, _currentCountryCode),
                            ]
                          : null,
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
            Visibility(
              visible: _isLoading,
              child: Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.7),
                  child: const SizedBox(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
