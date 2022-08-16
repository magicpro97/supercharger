import 'package:supercharger/tesla_location.dart';
import 'package:supercharger/tesla_location_entity.dart';

import '../objectbox.g.dart';

class GetLocationDataUseCase {
  Future<List<TeslaLocation>> getTeslaLocation() async {
    final store = await openStore();
    final box = store.box<TeslaLocationEntity>();

    final entities = box.getAll();

    store.close();
    return entities
        .map((e) => TeslaLocation(
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
        .toList();
  }
}
