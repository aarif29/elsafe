import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapUtils {
  static (LatLng center, double zoom) fitMarkers(List<Marker> markers) {
    if (markers.isEmpty) {
      return (LatLng(-7.9666, 112.6326), 13);
    }
    if (markers.length == 1) {
      return (markers.first.point, 17);
    }
    double minLat = markers.first.point.latitude;
    double maxLat = markers.first.point.latitude;
    double minLng = markers.first.point.longitude;
    double maxLng = markers.first.point.longitude;

    for (final m in markers) {
      if (m.point.latitude < minLat) minLat = m.point.latitude;
      if (m.point.latitude > maxLat) maxLat = m.point.latitude;
      if (m.point.longitude < minLng) minLng = m.point.longitude;
      if (m.point.longitude > maxLng) maxLng = m.point.longitude;
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final span = [
      (maxLat - minLat).abs(),
      (maxLng - minLng).abs(),
    ].reduce((a, b) => a > b ? a : b);

    double zoom;
    if (span < 0.0008) zoom = 19;
    else if (span < 0.0015) zoom = 18;
    else if (span < 0.003) zoom = 17;
    else if (span < 0.006) zoom = 16;
    else if (span < 0.012) zoom = 15;
    else if (span < 0.025) zoom = 14;
    else if (span < 0.05) zoom = 13;
    else if (span < 0.1) zoom = 12;
    else zoom = 11;

    return (center, zoom);
  }
}
