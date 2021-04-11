import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/tables/mg_location.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocationList extends StatefulWidget {
  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  late Future<Database> database;
  List<MgLocation> locations = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'mung_ge_mung_ge.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE mg_location(seq INT PRIMARY KEY, name VARCHAR, detail VARCHAR, latitude FLOAT, longitude FLOAT, institution VARCHAR, capacity INT, is_wifi BOOLEAN, is_charge BOOLEAN, is_vantilation BOOLEAN, place_class VARCHAR, address_jibun VARCHAR, address_road VARCHAR)"
        );
      },
      version: 1,
    );

    try {
      setState(() async {
        locations = await _getLocations();
      });
    } catch (_) {}
  }

  Future<void> insertDog(MgLocation location) async {
    final Database db = await database;
    await db.insert('mg_location', location.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MgLocation>> _getLocations() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mg_location');

    return List.generate(maps.length, (index) {
      return MgLocation(
        seq: maps[index]['seq'],
        name: maps[index]['name'],
        detail: maps[index]['detail'],
        latitude: maps[index]['latitude'],
        longitude: maps[index]['longitude'],
        institution: maps[index]['institution'],
        capacity: maps[index]['capacity'],
        is_wifi: maps[index]['is_wifi'],
        is_charge: maps[index]['is_charge'],
        is_vantilation: maps[index]['is_vantilation'],
        place_class: maps[index]['place_class'],
        address_jibun: maps[index]['address_jibun'],
        address_road: maps[index]['address_road']
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          itemCount: locations.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        locations[index].name,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        locations[index].address_road,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      if (locations[index].capacity != null)
                        Text('${locations[index].capacity}명 수용 가능'),
                      if (locations[index].institution != null)
                        Text(locations[index].institution!),
                    ],
                  ),
                  Container(
                    child: Icon(Icons.star),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
