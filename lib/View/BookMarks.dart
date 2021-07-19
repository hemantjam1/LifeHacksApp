import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lifehacks/Services/SqlServices.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class BookMarks extends StatefulWidget {
  @override
  _BookMarksState createState() => _BookMarksState();
}

class _BookMarksState extends State<BookMarks> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookMarks'),
      ),
      body: Consumer<SqlServices>(
        // stream: null,
        builder: (context, sqlServices, child) {
          return FutureBuilder(
            future: sqlServices.queryFavorite(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                List res = snapshot.data as List;
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: res.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 10),
                      child: ListTile(
                        title: Text(
                          res[index]['lifeHack'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.purple,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                          child: Center(
                            child: Text((index + 1).toString()),
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookMarksDetails(
                              pageNumber: index,
                              isFav: 'true',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: SqlServices().showBannerAd(),
    );
  }
}

class BookMarksDetails extends StatefulWidget {
  final int pageNumber;
  final String isFav;

  const BookMarksDetails(
      {Key? key, required this.pageNumber, required this.isFav})
      : super(key: key);

  @override
  _BookMarksDetailsState createState() => _BookMarksDetailsState();
}

class _BookMarksDetailsState extends State<BookMarksDetails> {
  late PageController pageController;

  @override
  void initState() {
    pageController =
        PageController(initialPage: widget.pageNumber, keepPage: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isF = widget.isFav == 'true';
    int _index = widget.pageNumber;
    return Scaffold(
      appBar: AppBar(
        title: Text('BookMarks details'),
      ),
      body: Consumer<SqlServices>(
        builder: (context, sqlServices, child) {
          return FutureBuilder(
            future: sqlServices.queryFavorite(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Your bookmarks will be listed here'),
                    ),
                  ),
                );
              } else {
                List res = snapshot.data as List;
                int number = res.length;
                return Column(
                  children: [
                    Flexible(
                      child: PageView.builder(
                        itemCount: res.length,
                        controller: pageController,
                        itemBuilder: (context, index) {
                          _index = index;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Card(
                                margin: EdgeInsets.all(10),
                                elevation: 05,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('#${index + 1}'.toString(),
                                                textScaleFactor: 1.5),
                                            IconButton(
                                              icon: Icon(
                                                  res[index]['isFav'] == 'false'
                                                      ? Icons.bookmark_outline
                                                      : Icons.bookmark),
                                              color: Colors.red,
                                              iconSize: 30,
                                              onPressed: () {
                                                isF = !isF;
                                                sqlServices
                                                    .addToFavorite(
                                                        catId: res[index]
                                                            ['categoryId'],
                                                        isFav: isF.toString(),
                                                        lifeHacksId: res[index]
                                                            ['lifeHacksId'])
                                                    .then((value) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Removed from favorite');
                                                  Navigator.pop(context);
                                                });
                                              },
                                            )
                                          ]),
                                      SizedBox(height: 20),
                                      Text(res[index]['lifeHack']),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(Icons.loop),
                            onPressed: () {
                              print(Random().nextInt(number));
                              pageController.animateToPage(
                                  Random().nextInt(number),
                                  duration: Duration(milliseconds: 1),
                                  curve: Curves.ease);
                            }),
                        Consumer<SqlServices>(
                          builder: (context, sqlServices, child) => IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              sqlServices
                                  .bookMarkCopy(
                                      hackId: res[_index]['lifeHacksId'],
                                      catId: res[_index]['categoryId'])
                                  .then(
                                (value) {
                                  Clipboard.setData(ClipboardData(text: value));
                                  Fluttertoast.showToast(
                                      msg: 'copied to clipboard');
                                },
                              );
                            },
                          ),
                        ),
                        Consumer<SqlServices>(
                          builder: (context, sqlServices, child) => IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () async {
                              sqlServices
                                  .bookMarkCopy(
                                      hackId: res[_index]['lifeHacksId'],
                                      catId: res[_index]['categoryId'])
                                  .then(
                                (value) {
                                  Share.share(value);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: SqlServices().showBannerAd(),
    );
  }
}
