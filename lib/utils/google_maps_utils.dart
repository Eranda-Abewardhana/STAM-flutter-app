import 'package:url_launcher/url_launcher.dart';

class GoogleMapsUtils {
  static Uri routeUri({
    required String originLabel,
    required String destinationLabel,
    String travelMode = 'driving',
  }) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(originLabel)}&destination=${Uri.encodeComponent(destinationLabel)}&travelmode=$travelMode',
    );
  }

  static Future<bool> openRoute({
    required String originLabel,
    required String destinationLabel,
    String travelMode = 'driving',
  }) async {
    final uri = routeUri(
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      travelMode: travelMode,
    );

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}