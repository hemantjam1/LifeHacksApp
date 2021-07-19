import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lifehacks/Services/SqlServices.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class LifeHacksDetails extends StatefulWidget {
  final String title;
  final int categoryId;
  final int pageNumber;
  final String isFav;

  const LifeHacksDetails(
      {Key? key,
      required this.title,
      required this.categoryId,
      required this.isFav,
      required this.pageNumber})
      : super(key: key);
  @override
  _LifeHacksDetailsState createState() => _LifeHacksDetailsState();
}

class _LifeHacksDetailsState extends State<LifeHacksDetails> {
  late PageController pageController;
  late int number;
  @override
  void initState() {
    pageController =
        PageController(initialPage: widget.pageNumber, keepPage: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SqlServices>(
      builder: (context, sqlServices, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: FutureBuilder(
            future: sqlServices.queryCategory(catId: widget.categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                List res = snapshot.data as List;
                number = res.length;
                return PageView.builder(
                  controller: pageController,
                  itemCount: res.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          margin: EdgeInsets.all(10),
                          elevation: 05,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('#${index + 1}'.toString(),
                                        textScaleFactor: 1.5),
                                    IconButton(
                                      icon: Icon(res[index]['isFav'] == 'false'
                                          ? Icons.bookmark_outline
                                          : Icons.bookmark),
                                      color: Colors.red,
                                      iconSize: 30,
                                      onPressed: () {
                                        if (res[index]['isFav'] == 'true') {
                                          sqlServices.addToFavorite(
                                              catId: res[index]['categoryId'],
                                              isFav: 'false',
                                              lifeHacksId: res[index]
                                                  ['lifeHacksId']);
                                        } else {
                                          sqlServices.addToFavorite(
                                              catId: res[index]['categoryId'],
                                              isFav: 'true',
                                              lifeHacksId: res[index]
                                                  ['lifeHacksId']);
                                        }
                                      },
                                    )
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(res[index]['lifeHack'].toString())
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          bottomNavigationBar: Consumer<SqlServices>(
            builder: (context, sqlServices, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  sqlServices.showBannerAd(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.loop),
                        onPressed: () {
                          pageController.animateToPage(Random().nextInt(number),
                              duration: Duration(milliseconds: 1),
                              curve: Curves.ease);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          sqlServices
                              .singleLifeHack(
                                  lifeHackId: pageController.page!.ceil(),
                                  catId: widget.categoryId)
                              .then(
                            (value) {
                              Clipboard.setData(ClipboardData(text: value));
                              Fluttertoast.showToast(
                                  msg: 'copied to clipboard');
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () async {
                          sqlServices
                              .singleLifeHack(
                                  lifeHackId: pageController.page!.ceil(),
                                  catId: widget.categoryId)
                              .then(
                            (value) {
                              Share.share(value);
                            },
                          );
                        },
                      )
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
