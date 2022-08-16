import 'package:shared_preferences/shared_preferences.dart';
import 'package:supercharger/tesla_location.dart';
import 'package:supercharger/tesla_location_entity.dart';

import '../objectbox.g.dart';

class SaveLocationDataUseCase {
  Future<void> saveTeslaLocation(List<TeslaLocation> locations) async {
    final store = await openStore();
    final box = store.box<TeslaLocationEntity>();

    box.putMany(locations
        .map((e) => TeslaLocationEntity(
              addressLine2: e.addressLine2,
              city: e.city,
              openSoon: e.openSoon,
              locationId: e.locationId,
              provinceState: e.provinceState,
              title: e.title,
              postalCode: e.postalCode,
              longitude: e.longitude,
              latitude: e.latitude,
              locationType: e.locationType,
              addressLine1: e.addressLine1,
              directionsLink: e.directionsLink,
            ))
        .toList());

    store.close();

    final sharePreferences = await SharedPreferences.getInstance();
    sharePreferences.setInt(
      "LAST_UPDATED",
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
