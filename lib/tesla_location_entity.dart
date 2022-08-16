import 'package:objectbox/objectbox.dart';

@Entity()
class TeslaLocationEntity {
  TeslaLocationEntity({
    this.id = 0,
    required this.locationType,
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.openSoon,
    required this.title,
    this.directionsLink,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.provinceState,
    this.postalCode,
  });

  int id;
  List<String> locationType;
  String locationId;
  double latitude;
  double longitude;
  String openSoon;
  String title;
  String? directionsLink;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? provinceState;
  String? postalCode;
}
