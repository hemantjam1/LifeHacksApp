// To parse this JSON data, do
//
//     final lifeHacksModel = lifeHacksModelFromJson(jsonString);

import 'dart:convert';

LifeHacksModel lifeHacksModelFromJson(String str) =>
    LifeHacksModel.fromJson(json.decode(str));

String lifeHacksModelToJson(LifeHacksModel data) => json.encode(data.toJson());

class LifeHacksModel {
  LifeHacksModel({
    required this.lifeHacksCategory,
  });

  List<LifeHacksCategory> lifeHacksCategory;

  factory LifeHacksModel.fromJson(Map<String, dynamic> json) => LifeHacksModel(
        lifeHacksCategory: List<LifeHacksCategory>.from(
            json["lifeHacksCategory"]
                .map((x) => LifeHacksCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "lifeHacksCategory":
            List<dynamic>.from(lifeHacksCategory.map((x) => x.toJson())),
      };
}

class LifeHacksCategory {
  LifeHacksCategory(
      {required this.categoryName,
      required this.imageUrl,
      required this.length,
      required this.initialLifeHack,
      required this.lifeHacks});

  String categoryName;
  String imageUrl;
  String length;
  String initialLifeHack;
  List<LifeHack> lifeHacks;

  factory LifeHacksCategory.fromJson(Map<String, dynamic> json) =>
      LifeHacksCategory(
        categoryName: json["categoryName"],
        imageUrl: json["imageUrl"],
        length: json["length"],
        initialLifeHack: json["initialLifeHack"],
        lifeHacks: List<LifeHack>.from(
            json["lifeHacks"].map((x) => LifeHack.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "imageUrl": imageUrl,
        "length": length,
        "initialLifeHack": initialLifeHack,
        "lifeHacks": List<dynamic>.from(lifeHacks.map((x) => x.toJson())),
      };
}

class LifeHack {
  LifeHack({required this.lifeHack});

  String lifeHack;

  factory LifeHack.fromJson(Map<String, dynamic> json) =>
      LifeHack(lifeHack: json["lifeHack"]);

  Map<String, dynamic> toJson() => {"lifeHack": lifeHack};
}
