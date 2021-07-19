import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifehacks/Services/SqlServices.dart';
import 'package:provider/provider.dart';
import 'Services/DatabaseHelper.dart';
import 'View/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  databaseHelper.getDatabase;
  SqlServices().mopubInit();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((context) => runApp(LifeHacksApp()));
}

class LifeHacksApp extends StatefulWidget {
  @override
  _LifeHacksAppState createState() => _LifeHacksAppState();
}

class _LifeHacksAppState extends State<LifeHacksApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SqlServices>(
      create: (context) => SqlServices(),
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'Life Hacks',
          theme: ThemeData(primaryColor: Colors.white),
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        );
      },
    );
  }
}
