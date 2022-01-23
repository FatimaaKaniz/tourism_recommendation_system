import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/home/admin/list_items_builder.dart';
import 'package:tourism_recommendation_system/home/attraction_details_page.dart';
import 'package:tourism_recommendation_system/home/attraction_list_card.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';
import 'package:tourism_recommendation_system/services/database.dart';

import '../services/api_keys.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchTextBarController = TextEditingController();
  List<Attraction> attractions = [];
  var _streamController = StreamController<List<Attraction>>();

  SortAttractionBy _sortAttractionBy = SortAttractionBy.name;
  bool ascendingSorting = true;

  Stream<List<Attraction>> get _stream => _streamController.stream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContents(context),
    );
  }

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    // final auth = Provider.of<AuthBase>(context, listen: false);

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      var attractions = await database.attractionStream().first;
      // var firstList = attractions.where((element) => element.attractionType!  == auth.myUser!.sortByType!).toList();
      // var secondList = attractions.where((element) => element.attractionType!  != auth.myUser!.sortByType!).toList();
      // // print(firstList);
      // // print(secondList);
      // firstList..addAll(secondList);
      setState(() {
        this.attractions = attractions.toList();
      });
      _streamController.sink.add(this.attractions);
    });
  }

  Widget _buildContents(BuildContext context) {
    final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
    return StreamBuilder<List<Attraction>>(
      stream: _stream,
      builder: (context, snapshot) {
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
            return <Widget>[createSilverAppBar1(), createSilverAppBar2()];
          },
          body: ListItemsBuilder(
              snapshot: snapshot,
              itemBuilder: (context, attraction) {
                //print(attraction);
                return AttractionListCard(
                  attraction: attraction as Attraction,
                  onTap: () =>
                      _showDetailsPage(googlePlace, context, attraction),
                );
              }),
        );
      },
    );
  }

  SliverAppBar createSilverAppBar1() {
    return SliverAppBar(
      backgroundColor: Colors.teal,
      expandedHeight: 300,
      floating: false,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return FlexibleSpaceBar(
          collapseMode: CollapseMode.none,
          background: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('resources/images/appbar.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }),
    );
  }

  _filterStream(String value) async {
    value = value.trim();
    var filteredPlaces = attractions
        .where((element) =>
            element.name!.toLowerCase().contains(value.toLowerCase()) ||
            element.address!.toLowerCase().contains(value.toLowerCase()) ||
            (element.phoneNumber != null &&
                element.phoneNumber!.contains(value.toLowerCase())) ||
            element.attractionType!.name
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            (element.types != null &&
                element.types!.length > 0 &&
                element.types!.contains(value.toLowerCase())) ||
            (element.country != null &&
                element.country!.toLowerCase().contains(value.toLowerCase())) ||
            (element.city != null &&
                element.city!.toLowerCase().contains(value.toLowerCase())))
        .toList();

    _streamController.sink.add(filteredPlaces);
  }

  _sortData() {
    this.attractions.sort((a, b) {
      int value = 0;
      switch (_sortAttractionBy) {
        case SortAttractionBy.name:
          value = a.name == null || b.name == null
              ? 0
              : a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
          break;
        case SortAttractionBy.attractionType:
          value = a.attractionType == null || b.attractionType == null
              ? 0
              : a.attractionType!.name
                  .toLowerCase()
                  .compareTo(b.attractionType!.name.toLowerCase());
          break;
        case SortAttractionBy.country:
          value = a.country == null || b.country == null
              ? 0
              : a.country!.toLowerCase().compareTo(b.country!.toLowerCase());
          break;
      }
      return ascendingSorting ? value : -1 * value;
    });
    Navigator.pop(context);
    _streamController.sink.add(this.attractions);
  }

  SliverAppBar createSilverAppBar2() {
    return SliverAppBar(
      backgroundColor: Colors.teal,
      pinned: true,
      title: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 40,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                offset: const Offset(1.1, 1.1),
                blurRadius: 5.0),
          ],
        ),
        child: CupertinoTextField(
          controller: _searchTextBarController,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            WidgetsBinding.instance?.addPostFrameCallback((_) async {
              await _filterStream(value);
            });
          },
          placeholder: 'Attraction',
          placeholderStyle: TextStyle(
            color: Color(0xffC4C6CC),
            fontSize: 14.0,
            fontFamily: 'Brutal',
          ),
          prefix: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
            child: Icon(
              Icons.search,
              size: 22,
              color: Colors.black,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          suffix: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                size: 22,
                color: Colors.black,
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    elevation: 4.0,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return Container(
                          height: 130,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(23, 20, 23, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Sorting',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: ascendingSorting,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          ascendingSorting = value!;
                                        });
                                        _sortData();
                                      },
                                    ),
                                    Text('Ascending Order')
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 30, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          value: SortAttractionBy.name,
                                          groupValue: _sortAttractionBy,
                                          onChanged: (SortAttractionBy? value) {
                                            setState(() {
                                              _sortAttractionBy = value!;
                                            });
                                            _sortData();
                                          },
                                        ),
                                        Text('Name')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          value:
                                              SortAttractionBy.attractionType,
                                          groupValue: _sortAttractionBy,
                                          onChanged: (SortAttractionBy? value) {
                                            setState(() {
                                              _sortAttractionBy = value!;
                                            });
                                            _sortData();
                                          },
                                        ),
                                        Text('Attraction Type')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          value: SortAttractionBy.country,
                                          groupValue: _sortAttractionBy,
                                          onChanged: (SortAttractionBy? value) {
                                            setState(() {
                                              _sortAttractionBy = value!;
                                            });
                                            _sortData();
                                          },
                                        ),
                                        Text('Country')
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              //   child: Divider(
                              //     color: Colors.teal,
                              //     thickness: 2,
                              //   ),
                              // ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.fromLTRB(23, 20, 0, 0),
                              //   child: Text(
                              //     'Attraction Types',
                              //     style: TextStyle(
                              //       color: Colors.black87,
                              //       fontWeight: FontWeight.w500,
                              //       fontSize: 22,
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(height: 5),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.fromLTRB(10, 0, 30, 0),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Container(
                              //         width: 150,
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.start,
                              //           children: [
                              //             Checkbox(
                              //               value: historicalCheckBox,
                              //               onChanged: (bool? value) {},
                              //             ),
                              //             Text('Historical')
                              //           ],
                              //         ),
                              //       ),
                              //       Container(
                              //         width: 150,
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.start,
                              //           children: [
                              //             Checkbox(
                              //               value: beachesCheckBox,
                              //               onChanged: (bool? value) {
                              //                 setState((){
                              //                   beachesCheckBox = value!;
                              //
                              //                 });
                              //               },
                              //             ),
                              //             Text('Beaches')
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(height: 5),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.fromLTRB(10, 0, 30, 0),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Container(
                              //         width: 150,
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.start,
                              //           children: [
                              //             Checkbox(
                              //               value: urbanCheckBox,
                              //               onChanged: (bool? value) {},
                              //             ),
                              //             Text('Urban')
                              //           ],
                              //         ),
                              //       ),
                              //       Container(
                              //         width: 150,
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.start,
                              //           children: [
                              //             Checkbox(
                              //               value: mountainsCheckBox,
                              //               onChanged: (bool? value) {},
                              //             ),
                              //             Text('Mountains')
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      });
                    });
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsPage(
      GooglePlace googlePlace, BuildContext context, Attraction attraction) {
    AttractionDetailsPage.show(context, googlePlace, attraction);
  }
}
