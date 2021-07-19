import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lifehacks/Services/SqlServices.dart';
import 'package:lifehacks/View/BookMarks.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LifeHacksCategory.dart';
import 'LifeHacksImages.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SqlServices sqlServices = SqlServices();
  bool isConnection = true;
  checkConnectivity() async {
    try {
      final res = await InternetAddress.lookup('google.com');
      if (res.isNotEmpty && res.first.rawAddress.isNotEmpty)
        isConnection = true;
    } on SocketException catch (e) {
      print(e);
      isConnection = false;
    }
  }

  share() async {
    try {
      await launch('https://www.google.com/');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    checkConnectivity();
    sqlServices.checkDb().then((bool value) => sqlServices.fetchDb(value));
    super.initState();
    Future.delayed(Duration(seconds: 30), () {
      SqlServices.interstitialAd.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/title.jpg'),
          ),
        ),
        title: Text('Life Hacks'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookMarks()));
              },
              icon: Icon(Icons.bookmarks_outlined)),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/images/title.jpg"),
                      ),
                      Text('  Life Hacks')
                    ],
                  ),
                  content: Text(
                      'Enjoy the best collection\nof incredibly useful life hacks that you probably did not know!!\n-Supported by Manek Tech\n-Version 1.0'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Share.share('https://www.google.com/');
                          Navigator.pop(context);
                        },
                        child: Text('SHARE APP')),
                    TextButton(
                        onPressed: () {
                          share();
                          Navigator.pop(context);
                        },
                        child: Text('MORE APPS')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isConnection ? LifeHacksImages() : SizedBox(),
            Flexible(child: LifeHacksCategory()),
          ],
        ),
      ),
    );
  }
}
