import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';
import 'package:tourism_recommendation_system/view/home/common/list_items_builder.dart';
import 'package:tourism_recommendation_system/view/home/standard_user/attraction_details_page.dart';
import 'package:tourism_recommendation_system/view/home/standard_user/attraction_list_card.dart';
import 'package:tourism_recommendation_system/view_model/attraction_view_model.dart';
import 'package:tourism_recommendation_system/services/api_keys.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchTextBarController = TextEditingController();

  Stream<List<Attraction>> attractionsStream = Stream.value([]);

  SortAttractionBy _sortAttractionBy = SortAttractionBy.name;
  bool ascendingSorting = true;
  int selectedTypeIndex = 0;
  var types = AttractionType.values.map((e) => e.name).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContents(context),
    );
  }

  getAttractions(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    print(_sortAttractionBy);
    print(ascendingSorting);
    print(types[selectedTypeIndex]);
    return database.attractionStream(
        type: Attraction.getAttractionType(types[selectedTypeIndex]),
        sortType: _sortAttractionBy,
        isAscending: ascendingSorting);
  }

  @override
  void initState() {
    super.initState();
    types.insert(0, 'All');
    final database = Provider.of<Database>(context, listen: false);

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (mounted)
        setState(() {
          attractionsStream = database.attractionStream();
        });
    });
  }

  Widget _buildContents(BuildContext context) {
    var types = AttractionType.values.map((e) => e.name).toList();
    types.insert(0, 'All');

    final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
    return StreamBuilder<List<Attraction>>(
      stream: attractionsStream,
      builder: (context, snapshot) {
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
            return <Widget>[createSilverAppBar1(), createSilverAppBar2()];
          },
          body: ListItemsBuilder(
            snapshot: snapshot,
            itemBuilder: (context, attraction) {
              return AttractionListCard(
                attractionViewModel:
                    AttractionViewModel(attraction: attraction as Attraction),
                isCalled: true,
                onTap: () => _showDetailsPage(
                  googlePlace,
                  context,
                  AttractionViewModel(attraction: attraction),
                ),
              );
            },
          ),
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

    final db = Provider.of<Database>(context, listen: false);

    var attractions = await db.attractionStream().first;
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
    setState(() {
      attractionsStream = Stream.value(filteredPlaces);
    });
    //_streamController.sink.add(filteredPlaces);
  }

  _sortData() async {
    Navigator.pop(context);
    setState(() {
      attractionsStream = getAttractions(context);
    });
  }

  SliverAppBar createSilverAppBar2() {
    return SliverAppBar(
      backgroundColor: Colors.teal,
      pinned: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Container(
          color: Colors.white,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: types.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 10),
                  child: InkWell(
                      child: Chip(
                        label: Text(
                          types[index],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: selectedTypeIndex == index
                            ? Colors.teal
                            : Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          selectedTypeIndex = index;
                          attractionsStream = getAttractions(context);
                        });
                      }),
                );
              },
            ),
          ),
        ),
      ),
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
                    builder: (context) => buildBottomSheet());
              },
            ),
          ),
        ),
      ),
    );
  }

  StatefulBuilder buildBottomSheet() {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        height: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 20, 23, 0),
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
              padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
            ),
          ],
        ),
      );
    });
  }

  void _showDetailsPage(GooglePlace googlePlace, BuildContext context,
      AttractionViewModel attractionViewModel) {
    AttractionDetailsPage.show(context, googlePlace, attractionViewModel);
  }
}
