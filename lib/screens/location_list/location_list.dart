import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/mgFavorite.dart';
import 'package:mung_ge_mung_ge/models/mgLocation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocationList extends StatefulWidget {
  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  late Future<Database> database;
  List<MgLocation> locations = [];
  List<MgFavorite> favorites = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'mung_ge_mung_ge.db'),
      version: 1,
    );

    // Table 생성
    try {
      final Database db = await database;
      await db.execute('CREATE TABLE mg_favorite(user_seq INT, location_seq INT)');
      await db.execute('CREATE TABLE mg_location(seq INT PRIMARY KEY, name VARCHAR, detail VARCHAR, latitude FLOAT, longitude FLOAT, institution VARCHAR, capacity INT, is_wifi BOOLEAN, is_charge BOOLEAN, is_vantilation BOOLEAN, place_class VARCHAR, address_jibun VARCHAR, address_road VARCHAR)');
    } catch (err) { print(err); }

    try {
      setState(() async {
        locations = await _getLocations();
        favorites = await _getFavorites();
      });
    } catch (_) {}

    favorites.forEach((favorite) {
      for (int index = 0; index < locations.length; index++) {
        if (favorite.location_seq == locations[index].seq) {
          locations[index].favorite = true;
          break;
        }
      }
    });
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

  Future<List<MgFavorite>> _getFavorites() async {
    final Database db = await database;
    // TODO: 현재 로그인 한 유저의 user_key로 query를 짜서 보내야 함.
    final List<Map<String, dynamic>> maps = await db.query('mg_favorite');

    return List.generate(maps.length, (index) {
      return MgFavorite(
        user_seq: maps[index]['user_seq'],
        location_seq: maps[index]['location_seq'],
      );
    });
  }

  Future<void> _clickFavorite(MgLocation location) async {
    if (location.favorite == true) {
      try {
        await _deleteFavorite(location.seq);
        setState(() {
          location.favorite = false;
        });
      } catch (err) { print(err); }
    } else {
      try {
        // TODO: user_seq: 실제 로그인한 유저의 user_seq로 변
        await _insertFavorite(MgFavorite(user_seq: 0, location_seq: location.seq));
        setState(() {
          location.favorite = true;
        });
      } catch (err) { print(err); }
    }
  }

  Future<void> _insertFavorite(MgFavorite favorite) async {
    final Database db = await database;
    await db.insert('mg_favorite', favorite.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _deleteFavorite(int locationSeq) async {
    final Database db = await database;
    await db.delete('mg_favorite', where: 'location_seq = ?', whereArgs: [locationSeq]);
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
                    child: GestureDetector(
                      onTap: () => _clickFavorite(locations[index]),
                      child: Icon(locations[index].favorite == true ? Icons.star : Icons.star_border),
                    ),
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
