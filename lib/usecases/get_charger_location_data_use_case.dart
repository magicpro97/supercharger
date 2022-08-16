import 'package:supercharger/tesla_location.dart';
import 'package:supercharger/tesla_location_entity.dart';

import '../objectbox.g.dart';

class GetChargerLocationDataUseCase {
  Future<List<TeslaLocation>> getTeslaChargerLocation() async {
    final store = await openStore();
    final box = store.box<TeslaLocationEntity>();

    final entities = box
        .query(TeslaLocationEntity_.locationType.contains('supercharger').or(
            TeslaLocationEntity_.locationType
                .contains('destination charger')
                .or(TeslaLocationEntity_.locationType
                    .contains('standard charger'))))
        .build()
        .find();

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
