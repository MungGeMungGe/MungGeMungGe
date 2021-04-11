import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyGoogleMap extends StatefulWidget {
  @override
  _MyGoogleMapState createState() => _MyGoogleMapState();
}

class _MyGoogleMapState extends State<MyGoogleMap> {
  late Future<Position> _currentPosition;
  late Future<BitmapDescriptor> _bitmapDescriptor;
  late Future<List<Map>> _locations;
  Map<MarkerId, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = getCurrentPosition();
    _bitmapDescriptor = getSmokingAreaBitmap();
    _locations = getLocations();
  }

  Future<BitmapDescriptor> getSmokingAreaBitmap() async {
    BitmapDescriptor bitmapDescriptor = await MarkerGenerator(96).createBitmapDescriptorFromIconData(Icons.smoking_rooms, Colors.black, Colors.blueAccent, Colors.white);
    return bitmapDescriptor;
  }

  Future<Position> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    return position;
  }

  Future<List<Map>> getLocations() async {
    String dbPath = join(await getDatabasesPath(), 'localdb');
    ByteData data = await rootBundle.load(join('assets','database','localdb.sqlite'));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes);

    Database database = await openDatabase(dbPath, version: 1);
    List<Map> locations = await database.rawQuery('SELECT name, latitude, longitude FROM mg_location');
    return locations;
  }

  void _addMarker(LatLng position, String name, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(name);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(
        title: '$name',
      ),
    );
    _markers[markerId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('내 주변의 흡연장소'),
        ),
        body: Center(
          child: FutureBuilder(
            future: Future.wait([_currentPosition, _bitmapDescriptor, _locations]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                List<dynamic> data = snapshot.data!;
                Position currentPosition = data[0];
                BitmapDescriptor bitmapDescriptor = data[1];
                List<Map> locations = data[2];

                LatLng currentLatlng = LatLng(currentPosition.latitude, currentPosition.longitude);
                locations.forEach((element) {
                  _addMarker(LatLng(element['latitude'], element['longitude']), element['name'], bitmapDescriptor);
                });
                _addMarker(currentLatlng, 'origin', BitmapDescriptor.defaultMarker);

                return GoogleMap(
                  markers: Set<Marker>.of(_markers.values),
                  initialCameraPosition: CameraPosition(
                    target: currentLatlng,
                    zoom: 16.0,
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class MarkerGenerator {
  final _markerSize;
  double _circleStrokeWidth = 0;
  double _circleOffset = 0;
  double _outlineCircleWidth = 0;
  double _fillCircleWidth = 0;
  double _iconSize = 0;
  double _iconOffset = 0;

  MarkerGenerator(this._markerSize) {
    _circleStrokeWidth = _markerSize / 10.0;
    _circleOffset = _markerSize / 2;
    _outlineCircleWidth = _circleOffset - (_circleStrokeWidth / 2);
    _fillCircleWidth = _markerSize / 2;
    final outlineCircleInnerWidth = _markerSize - (2 * _circleStrokeWidth);
    _iconSize = sqrt(pow(outlineCircleInnerWidth, 2) / 2);
    final rectDiagonal = sqrt(2 * pow(_markerSize, 2));
    final circleDistanceToCorners = (rectDiagonal - outlineCircleInnerWidth) / 2;
    _iconOffset = sqrt(pow(circleDistanceToCorners, 2) / 2);
  }

  Future<BitmapDescriptor> createBitmapDescriptorFromIconData(IconData iconData, Color iconColor, Color circleColor, Color backgroundColor) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    _paintCircleFill(canvas, backgroundColor);
    _paintCircleStroke(canvas, circleColor);
    _paintIcon(canvas, iconColor, iconData);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(_markerSize.round(), _markerSize.round());
    final bytes = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  void _paintCircleFill(Canvas canvas, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(Offset(_circleOffset, _circleOffset), _fillCircleWidth, paint);
  }

  void _paintCircleStroke(Canvas canvas, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = _circleStrokeWidth;
    canvas.drawCircle(Offset(_circleOffset, _circleOffset), _outlineCircleWidth, paint);
  }

  void _paintIcon(Canvas canvas, Color color, IconData iconData) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: _iconSize,
          fontFamily: iconData.fontFamily,
          color: color,
        ));
    textPainter.layout();
    textPainter.paint(canvas, Offset(_iconOffset, _iconOffset));
  }
}
