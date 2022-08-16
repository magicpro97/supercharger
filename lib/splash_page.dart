import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supercharger/tesla_location.dart';
import 'package:supercharger/usecases/fetch_location_data_use_case.dart';
import 'package:supercharger/usecases/get_location_data_use_case.dart';
import 'package:supercharger/usecases/save_location_data_use_case.dart';

import 'generated/assets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late Image _image;

  @override
  void initState() {
    super.initState();

    _initialize().then((_) {
      Navigator.pushReplacementNamed(context, '/home');
    });

    _image = Image.asset(Assets.iconsElectricCharge);
  }

  Future<void> _initialize() async {
    List<TeslaLocation> locations =
        await GetLocationDataUseCase().getTeslaLocation();

    if (locations.isEmpty && await shouldUpdate()) {
      final locations = await FetchLocationDataUseCase().fetchTeslaLocation();
      await SaveLocationDataUseCase().saveTeslaLocation(locations);

      final sharePreferences = await SharedPreferences.getInstance();
      sharePreferences.setInt(
        "LAST_UPDATED",
        DateTime.now().millisecondsSinceEpoch,
      );
    }
    FlutterNativeSplash.remove();
  }

  Future<bool> shouldUpdate() async {
    final sharePreferences = await SharedPreferences.getInstance();
    final lastUpdated = sharePreferences.getInt("LAST_UPDATED");
    if (lastUpdated != null) {
      DateTime lastUpdatedDate =
          DateTime.fromMillisecondsSinceEpoch(lastUpdated);

      if (lastUpdatedDate.difference(DateTime.now()).inDays < 0) {
        return true;
      }
    } else {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: _image,
      ),
    );
  }
}
