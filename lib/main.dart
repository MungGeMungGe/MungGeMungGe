import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/screens/google_map.dart';
import 'package:mung_ge_mung_ge/screens/location_list/location_list.dart';
// import 'package:mung_ge_mung_ge/screens/auth/auth_screen.dart';
import 'package:mung_ge_mung_ge/screens/todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                text: 'List',
                icon: Icon(Icons.home),
              ),
              Tab(
                text: 'Map',
                icon: Icon(Icons.map),
              ),
              Tab(
                text: 'Todo',
                icon: Icon(Icons.check_box),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            LocationList(),
            MyGoogleMap(),
            TodoScreen(),
          ],
        ),
      ),
    );
  }
}
