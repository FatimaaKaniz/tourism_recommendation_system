import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';

import '../services/api_keys.dart';
import '../services/database.dart';
import 'admin/list_items_builder.dart';
import 'attraction_details_page.dart';
import 'attraction_list_card.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({Key? key, required this.user}) : super(key: key);
  final MyUser user;

  @override
  _WishListPageState createState() => _WishListPageState(user);
}

class _WishListPageState extends State<WishListPage> {
  _WishListPageState(this.user);

  final MyUser user;
   Stream<List<Attraction>> attractions = Stream.value([]);

  @override
  void initState() {
    Stream<List<Attraction>> attractions;

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      attractions = await getAttractions();
      setState(() {
        this.attractions = attractions;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BackButton(
        color: Colors.teal,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Center(
            child: Text(
              'Wish List',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: StreamBuilder<List<Attraction>>(
            stream: this.attractions,
            builder: (context, snapshot) {
              return ListItemsBuilder(
                snapshot: snapshot,
                itemBuilder: (context, attraction) => AttractionListCard(
                  attraction: attraction as Attraction,
                  onTap: () =>
                      _showDetailsPage(googlePlace, context, attraction),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetailsPage(
      GooglePlace googlePlace, BuildContext context, Attraction attraction) {
    AttractionDetailsPage.show(context, googlePlace, attraction,isSaved: true);
  }

  Future<Stream<List<Attraction>>> getAttractions() async {
    final db = Provider.of<Database>(context, listen: false);
    var places = user.savedPlacesIds;
    if (places == null) return Stream.value([]);
    var attractions = await db.attractionStream().first;

    List<Attraction> newAttractions =
        attractions.where((element) => places.contains(element.id!)).toList();
    return Stream.value(newAttractions);
  }
}
