import 'package:flutter/material.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';

class AttractionListTile extends StatelessWidget {

  const AttractionListTile({Key? key, required this.attraction, required this.onTap}) : super(key: key);
  final Attraction attraction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(attraction.name!),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
