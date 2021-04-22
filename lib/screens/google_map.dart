import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mung_ge_mung_ge/utils/bitmap_descriptor_from_icon_data.dart';
import 'package:mung_ge_mung_ge/screens/components/google_map_dialog.dart';
import 'package:mung_ge_mung_ge/models/location.dart';

class MyGoogleMap extends StatefulWidget {
  @override
  _MyGoogleMapState createState() => _MyGoogleMapState();
}

class _MyGoogleMapState extends State<MyGoogleMap> {
  late Future<Position> _currentPosition;
  late Future<BitmapDescriptor> _bitmapDescriptor;
  late Future<List<Map>> _locations;
  late Database database;
  Map<MarkerId, Marker> _markers = {};

  @override
  initState() {
    super.initState();
    _currentPosition = getCurrentPosition();
    _bitmapDescriptor = getSmokingAreaBitmap();
    _locations = getLocations();
  }

  Future<BitmapDescriptor> getSmokingAreaBitmap() async {
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptorFromIconData(96).createBitmapDescriptorFromIconData(Icons.smoking_rooms, Colors.black, Colors.blueAccent, Colors.white);
    return bitmapDescriptor;
  }

  Future<Position> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    return position;
  }

  Future<List<Map>> getLocations() async {
    // 데이터베이스파일은 assets에 등록된 파일을 복사하여 활용
    String dbPath = join(await getDatabasesPath(), 'localdb');
    if (!await databaseExists(dbPath)) {
      ByteData data = await rootBundle.load(join('assets', 'database', 'localdb.sqlite'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }

    database = await openDatabase(dbPath, version: 1);
    List<Map> locations = await database.rawQuery('select seq, name, latitude, longitude, (select count(*) from mg_smokecount where location_seq = l.seq) as count from mg_location l');
    return locations;
  }

  _showDialog(BuildContext context, Location location) async {
    await showDialog(
      context: context,
      builder: (context) {
        return GoogleMapDialog(location: location, addSmokeCount: _addSmokeCount);
      },
    );
  }

  _addSmokeCount(int locationSeq, String smokeDate, String smokeTime) async {
    await database.rawInsert('insert into mg_smokecount(location_seq, smoke_date, smoke_time) values($locationSeq, "$smokeDate", "$smokeTime")');
    setState(() {
      _locations = getLocations();
    });
  }

  _addMarker(BuildContext context, Location location, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(location.name);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: location.latlng,
      infoWindow: InfoWindow(
        title: '${location.name}',
        snippet: location.seq > 0 ? '상세보기' : null,
        onTap: () {
          if (location.seq > 0) {
            _showDialog(context, location);
          }
        },
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
                Location myLocation = Location(seq: 0, name: '내 위치', latlng: currentLatlng, count: 0);
                _addMarker(context, myLocation, BitmapDescriptor.defaultMarker); // 현재 사용자 위치 삽입
                locations.forEach((element) {
                  _addMarker(
                    context,
                    Location(
                      seq: element['seq'],
                      name: element['name'],
                      latlng: LatLng(
                        element['latitude'],
                        element['longitude'],
                      ),
                      count: element['count'],
                    ),
                    bitmapDescriptor,
                  );
                }); // 흡연장소 위치 삽입

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
