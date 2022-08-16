import 'package:url_launcher/url_launcher_string.dart';

class LaunchMapUseCase {
  static const _googleUrl = 'comgooglemaps://';
  static const _appleUrl = 'https://maps.apple.com/';

  Future<void> launchMap(double latitude, double longitude) async {
    if (await canLaunchUrlString(_googleUrl)) {
      String googleUrl = '$_googleUrl?center=$latitude,$longitude';
      await launchUrlString(googleUrl);
    } else if (await canLaunchUrlString(_appleUrl)) {
      String appleUrl = '$_appleUrl?sll=$latitude,$longitude';
      await launchUrlString(appleUrl);
    }
  }
}
