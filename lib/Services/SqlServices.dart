import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifehacks/Model/ModelClass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DatabaseHelper.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mopub_flutter/mopub.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mopub_flutter/mopub_banner.dart';
import 'package:mopub_flutter/mopub_interstitial.dart'; // ignore: import_of_legacy_library_into_null_safe
import '../Model/ModelClass.dart';

class SqlServices extends ChangeNotifier {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  static bool isDbAvailable = false;
  static final bannerId = 'b195f8dd8ded45fe847ad89ed1d016da';
  // //android banner test iD
  static final interstitialId = "24534e1901884e398f1253216226017e";
  //android interstitial test Id

  static late MoPubInterstitialAd interstitialAd;

  mopubInit() {
    try {
      MoPub.init(interstitialId).then((value) => _loadInterstitialAd());
    } on PlatformException catch (e) {
      print('something wrong in mopub$e');
    }
    try {
      MoPub.init(bannerId);
    } on PlatformException catch (e) {
      print('something wrong in mopub banner ad$e');
    }
  }

  _loadInterstitialAd() {
    interstitialAd = MoPubInterstitialAd(
      interstitialId,
      (result, args) {},
      reloadOnClosed: true,
    );
    interstitialAd.load();
  }

  Widget showBannerAd() {
    return MoPubBannerAd(
        adUnitId: bannerId,
        bannerSize: BannerSize.STANDARD,
        keepAlive: true,
        listener: (result, dynamic) {});
  }

  insertData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await rootBundle.loadString('assets/Database.json');
    final lifeHacksModel = lifeHacksModelFromJson(res);
    for (int i = 0; i < lifeHacksModel.lifeHacksCategory.length; i++) {
      Map<String, dynamic> categoryRow = {
        DatabaseHelper.categoryColumnId: i,
        DatabaseHelper.categoryColumnName:
            lifeHacksModel.lifeHacksCategory[i].categoryName,
        DatabaseHelper.categoryImageUrl:
            lifeHacksModel.lifeHacksCategory[i].imageUrl,
        DatabaseHelper.categoryLength:
            lifeHacksModel.lifeHacksCategory[i].length,
        DatabaseHelper.categoryInitialHack:
            lifeHacksModel.lifeHacksCategory[i].initialLifeHack
      };
      await databaseHelper.insertIntoCategory(categoryTableRow: categoryRow);
      for (int j = 0;
          j < lifeHacksModel.lifeHacksCategory[i].lifeHacks.length;
          j++) {
        Map<String, dynamic> lifeHacksRow = {
          DatabaseHelper.categoryId: i,
          DatabaseHelper.lifeHacksColumnId: j,
          DatabaseHelper.lifeHacksColumn:
              lifeHacksModel.lifeHacksCategory[i].lifeHacks[j].lifeHack,
          DatabaseHelper.isFav: 'false'
        };
        await databaseHelper.insertIntoLifeHacks(
            categoryDetailTableRow: lifeHacksRow);
      }
    }
    queryCategoryTable();
    pref.setBool('isDB', true);
    notifyListeners();
  }

  Future queryCategoryTable() async {
    var res = await databaseHelper.queryCategoryTable('categoryTable');
    notifyListeners();
    return res;
  }

  Future queryLifeHacksTable() async {
    var res = await databaseHelper.queryCategoryTable('lifeHacksTable');
    notifyListeners();
    return res;
  }

  Future singleLifeHack({required int lifeHackId, required int catId}) async {
    String quote;
    List quoteList = [];
    var res = await databaseHelper.singleLifeHack(
        lifeHacksId: lifeHackId, catId: catId);
    quoteList = res;
    quote = quoteList.first['lifeHack'];
    return quote;
  }

  Future<bool> checkDb() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    notifyListeners();
    return pref.getBool('isDB') ?? false;
  }

  fetchDb(bool isDbAvailable) {
    if (!isDbAvailable) {
      insertData();
    } else {
      queryCategoryTable();
    }
    notifyListeners();
  }

  queryCategory({required int catId}) async {
    var res = await databaseHelper.queryCategory(catId: catId);
    notifyListeners();
    return res;
  }

  queryFavorite() async {
    var res = await databaseHelper.favQuery();
    notifyListeners();
    return res;
  }

  addToFavorite(
      {required int lifeHacksId,
      required String isFav,
      required int catId}) async {
    await databaseHelper.update(
        lifeHacksId: lifeHacksId, isFav: isFav, catId: catId);
    notifyListeners();
  }

  Future bookMarkCopy({required int hackId, required int catId}) async {
    List favList = [];
    String favCopy;
    var res = await databaseHelper.bookMarkCopy(catId: catId, hackId: hackId);
    favList = res;
    favCopy = favList.first['lifeHack'];
    return favCopy;
  }
}
