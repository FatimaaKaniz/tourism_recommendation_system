import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';
import 'package:tourism_recommendation_system/view/home/common/list_items_builder.dart';
import 'package:tourism_recommendation_system/view/home/standard_user/attraction_details_page.dart';
import 'package:tourism_recommendation_system/view/home/standard_user/attraction_list_card.dart';
import 'package:tourism_recommendation_system/model/user.dart';
import 'package:tourism_recommendation_system/view_model/attraction_view_model.dart';
import 'package:tourism_recommendation_system/view_model/user_view_model.dart';
import 'package:tourism_recommendation_system/services/api_keys.dart';
import 'package:tourism_recommendation_system/services/database.dart';

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
  Widget build(BuildContext context) {
    if (AttractionViewModel.isSavedChanged) {
      Stream<List<Attraction>> attractions;
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        attractions = await getAttractions();
        setState(() {
          this.attractions = attractions;
        });
      });
      AttractionViewModel.isSavedChanged = false;
    }
    return Scaffold(
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
                  attractionViewModel:
                      AttractionViewModel(attraction: attraction as Attraction),
                  onTap: () => _showDetailsPage(
                    googlePlace,
                    context,
                    AttractionViewModel(attraction: attraction),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetailsPage(GooglePlace googlePlace, BuildContext context,
      AttractionViewModel attractionViewModel) async {
    await AttractionDetailsPage.show(context, googlePlace, attractionViewModel,
        isSaved: true);
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
