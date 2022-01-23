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
  List<Attraction> attractions =[];
  var _streamController = StreamController<List<Attraction>>();

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
                element.types!.contains(value.toLowerCase())))
        .toList();


    _streamController.sink.add(filteredPlaces);
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
              size: 18,
              color: Colors.black,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
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
