class TeslaLocationDetail {
  TeslaLocationDetail({
    this.slTranslate,
    this.addressLine1,
    this.addressLine2,
    this.addressNotes,
    required this.address,
    this.amenities,
    this.baiduLat,
    this.baiduLng,
    this.chargers,
    this.city,
    this.commonName,
    this.country,
    this.destinationChargerLogo,
    this.destinationWebsite,
    this.directionsLink,
    this.emails,
    this.geocode,
    this.hours,
    this.isGallery,
    this.kioskPinX,
    this.kioskPinY,
    this.kioskZoomPinX,
    this.kioskZoomPinY,
    required this.latitude,
    required this.locationId,
    required this.locationType,
    required this.longitude,
    this.nid,
    this.openSoon,
    this.path,
    this.postalCode,
    this.provinceState,
    this.region,
    this.salesPhone,
    this.salesRepresentative,
    this.subRegion,
    required this.title,
    this.trtId,
  });

  final String? slTranslate;
  final String? addressLine1;
  final String? addressLine2;
  final String? addressNotes;
  final String address;
  final String? amenities;
  final String? baiduLat;
  final String? baiduLng;
  final String? chargers;
  final String? city;
  final String? commonName;
  final String? country;
  final String? destinationChargerLogo;
  final String? destinationWebsite;
  final String? directionsLink;
  final List<dynamic>? emails;
  final String? geocode;
  final String? hours;
  final bool? isGallery;
  final String? kioskPinX;
  final String? kioskPinY;
  final String? kioskZoomPinX;
  final String? kioskZoomPinY;
  final String latitude;
  final String locationId;
  final List<String> locationType;
  final String longitude;
  final String? nid;
  final String? openSoon;
  final String? path;
  final String? postalCode;
  final String? provinceState;
  final String? region;
  final List<SalesPhone>? salesPhone;
  final bool? salesRepresentative;
  final String? subRegion;
  final String title;
  final String? trtId;

  factory TeslaLocationDetail.fromJson(Map<String, dynamic> json) =>
      TeslaLocationDetail(
        slTranslate: json["sl_translate"],
        addressLine1: json["address_line_1"],
        addressLine2: json["address_line_2"],
        addressNotes: json["address_notes"],
        address: json["address"],
        amenities: json["amenities"],
        baiduLat: json["baidu_lat"],
        baiduLng: json["baidu_lng"],
        chargers: json["chargers"],
        city: json["city"],
        commonName: json["common_name"],
        country: json["country"],
        destinationChargerLogo: json["destination_charger_logo"],
        destinationWebsite: json["destination_website"],
        directionsLink: json["directions_link"],
        emails: List<dynamic>.from(json["emails"].map((x) => x)),
        geocode: json["geocode"],
        hours: json["hours"],
        isGallery: json["is_gallery"],
        kioskPinX: json["kiosk_pin_x"],
        kioskPinY: json["kiosk_pin_y"],
        kioskZoomPinX: json["kiosk_zoom_pin_x"],
        kioskZoomPinY: json["kiosk_zoom_pin_y"],
        latitude: json["latitude"],
        locationId: json["location_id"],
        locationType: List<String>.from(json["location_type"].map((x) => x)),
        longitude: json["longitude"],
        nid: json["nid"],
        openSoon: json["open_soon"],
        path: json["path"],
        postalCode: json["postal_code"],
        provinceState: json["province_state"],
        region: json["region"],
        salesPhone: List<SalesPhone>.from(
            json["sales_phone"].map((x) => SalesPhone.fromJson(x))),
        salesRepresentative: json["sales_representative"],
        subRegion: json["sub_region"],
        title: json["title"],
        trtId: json["trt_id"],
      );
}

class SalesPhone {
  SalesPhone({
    this.label,
    this.number,
    this.lineBelow,
  });

  final String? label;
  final String? number;
  final String? lineBelow;

  factory SalesPhone.fromJson(Map<String, dynamic> json) => SalesPhone(
        label: json["label"],
        number: json["number"],
        lineBelow: json["line_below"],
      );
}
