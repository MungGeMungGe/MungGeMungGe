import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  int seq;
  String name;
  LatLng latlng;
  int count;

  Location({
    required this.seq,
    required this.name,
    required this.latlng,
    required this.count,
  });
}
