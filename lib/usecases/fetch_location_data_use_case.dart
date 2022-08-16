import 'package:dio/dio.dart';
import 'package:supercharger/tesla_location.dart';


class FetchLocationDataUseCase {
  static const _url =
      "https://www.tesla.com/cua-api/tesla-locations?translate=en_US&usetrt=true";

  Future<List<TeslaLocation>> fetchTeslaLocation() async {
    final dio = Dio();
    final response = await dio.get(_url);
    if (response.statusCode != 200) {
      return [];
    }

    return (response.data as List)
        .map((e) => TeslaLocation.fromJson(e))
        .toList();
  }
}
