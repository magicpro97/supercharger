class TeslaLocation {
  final List<String> locationType;
  final String locationId;
  final double latitude;
  final double longitude;
  final String openSoon;
  final String title;
  final String? directionsLink;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? provinceState;
  final String? postalCode;

  TeslaLocation({
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

  factory TeslaLocation.fromJson(Map<String, dynamic> json) => TeslaLocation(
        locationType: List<String>.from(json["location_type"].map((x) => x)),
        locationId: json["location_id"],
        latitude: double.parse(json["latitude"].toString()),
        longitude: double.parse(json["longitude"].toString()),
        openSoon: json["open_soon"],
        title: json["title"],
        directionsLink: json["directions_link"],
        addressLine1: json["address_line_1"],
        addressLine2: json["address_line_2"],
        city: json["city"],
        provinceState: json["province_state"],
        postalCode: json["postal_code"],
      );
}
