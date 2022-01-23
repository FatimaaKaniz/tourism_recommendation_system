import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/home/admin/list_items_builder.dart';
import 'package:tourism_recommendation_system/home/attraction_details_page.dart';
import 'package:tourism_recommendation_system/home/attraction_list_card.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';
import 'package:tourism_recommendation_system/services/database.dart';

import '../services/api_keys.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Center(
            child: Text(
              'Attractions',
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
            stream: database.attractionStream(),
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
    AttractionDetailsPage.show(context, googlePlace, attraction);
  }
}
