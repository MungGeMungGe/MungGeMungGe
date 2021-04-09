import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyGoogleMap extends StatefulWidget {
  @override
  _MyGoogleMapState createState() => _MyGoogleMapState();
}

class _MyGoogleMapState extends State<MyGoogleMap> {
  Future<Position> currentPosition;
  Future<BitmapDescriptor> bitmapDescriptor;
  Map<MarkerId, Marker> markers = {};

  @override
  void initState() {
    super.initState();
    currentPosition = getLocation();
    bitmapDescriptor = getSmokingAreaBitmap();
  }

  Future<BitmapDescriptor> getSmokingAreaBitmap() async {
    BitmapDescriptor bitmapDescriptor = await MarkerGenerator(96).createBitmapDescriptorFromIconData(Icons.smoking_rooms, Colors.black, Colors.blueAccent, Colors.white);
    return bitmapDescriptor;
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    return position;
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(
        title: '등록된 흡연장소: $id',
        snippet: '★★★★☆/⚡🗑',
      ),
    );
    markers[markerId] = marker;
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
            future: Future.wait([currentPosition, bitmapDescriptor]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                Position currentPosition = snapshot.data[0];
                BitmapDescriptor bitmapDescriptor = snapshot.data[1];
                LatLng currentLatlng = LatLng(currentPosition.latitude, currentPosition.longitude);
                LatLng smokingArea1Latlng = LatLng(currentPosition.latitude + (Random().nextInt(5) * 0.001), currentPosition.longitude + (Random().nextInt(5) * 0.001)); //TODO: 위치는 추후 데이터베이스 값으로 교체
                LatLng smokingArea2Latlng = LatLng(currentPosition.latitude + (Random().nextInt(5) * 0.001), currentPosition.longitude + (Random().nextInt(5) * 0.001));
                _addMarker(currentLatlng, 'origin', BitmapDescriptor.defaultMarker);
                _addMarker(smokingArea1Latlng, 'area1', bitmapDescriptor);
                _addMarker(smokingArea2Latlng, 'area2', bitmapDescriptor);

                return GoogleMap(
                  markers: Set<Marker>.of(markers.values),
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
  double _circleStrokeWidth;
  double _circleOffset;
  double _outlineCircleWidth;
  double _fillCircleWidth;
  double _iconSize;
  double _iconOffset;

  MarkerGenerator(this._markerSize) {
    // calculate marker dimensions
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

  /// Creates a BitmapDescriptor from an IconData
  Future<BitmapDescriptor> createBitmapDescriptorFromIconData(IconData iconData, Color iconColor, Color circleColor, Color backgroundColor) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    _paintCircleFill(canvas, backgroundColor);
    _paintCircleStroke(canvas, circleColor);
    _paintIcon(canvas, iconColor, iconData);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(_markerSize.round(), _markerSize.round());
    final bytes = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }

  /// Paints the icon background
  void _paintCircleFill(Canvas canvas, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(Offset(_circleOffset, _circleOffset), _fillCircleWidth, paint);
  }

  /// Paints a circle around the icon
  void _paintCircleStroke(Canvas canvas, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = _circleStrokeWidth;
    canvas.drawCircle(Offset(_circleOffset, _circleOffset), _outlineCircleWidth, paint);
  }

  /// Paints the icon
  void _paintIcon(Canvas canvas, Color color, IconData iconData) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: _iconSize,
          fontFamily: iconData.fontFamily,
          color: color,
        )
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(_iconOffset, _iconOffset));
  }
}
