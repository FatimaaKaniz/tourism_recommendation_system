import 'package:flutter/material.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';

class AttractionListTile extends StatelessWidget {
  AttractionListTile({Key? key, required this.attraction, required this.onTap})
      : super(key: key);
  final Attraction attraction;
  final VoidCallback onTap;

  final leftEditIcon = Container(
    color: Colors.green,
    child: Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Icon(Icons.edit),
    ),
    alignment: Alignment.centerLeft,
  );
  final rightDeleteIcon = Container(
    color: Colors.red,
    child: Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: Icon(Icons.delete),
    ),
    alignment: Alignment.centerRight,
  );

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
