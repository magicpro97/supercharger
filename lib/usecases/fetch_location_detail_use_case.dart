import 'package:dio/dio.dart';
import 'package:supercharger/tesla_location_detail.dart';

class FetchLocationDataDetailUseCase {
  static const _url =
      "https://www.tesla.com/cua-api/tesla-location?translate=en_US";

  Future<TeslaLocationDetail?> fetchTeslaLocationDetails(String id) async {
    final dio = Dio();
    var locationId = id;
    if (id.contains('_dcsc')) {
      locationId = id.substring(0, id.length - 5);
    }
    final response = await dio.get('$_url&id=$locationId');
    if (response.statusCode != 200) {
      return null;
    }

    return TeslaLocationDetail.fromJson(response.data);
  }
}
