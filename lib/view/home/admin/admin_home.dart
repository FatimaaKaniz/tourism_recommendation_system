import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/custom_packages/widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';
import 'package:tourism_recommendation_system/view/home/admin/add_attraction_page.dart';
import 'package:tourism_recommendation_system/view/home/admin/attraction_list_tile.dart';
import 'package:tourism_recommendation_system/view/home/common/list_items_builder.dart';
import 'package:tourism_recommendation_system/view_model/attraction_view_model.dart';

import 'package:tourism_recommendation_system/services/database.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddAttractionsPage.show(context),
        child: Icon(Icons.add),
      ),
      body: _buildContents(context),
    );
  }

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

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Center(
            child: Text(
              'Attractions',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 25,
                fontWeight: FontWeight.bold,
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
                return ListItemsBuilder<Attraction>(
                  snapshot: snapshot,
                  itemBuilder: (context, attraction) {
                    var attractionViewModel = AttractionViewModel(attraction: attraction);

                    return Dismissible(
                      key: UniqueKey(),
                      background: leftEditIcon,
                      secondaryBackground: rightDeleteIcon,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart)
                          _delete(context, attraction);
                        else
                          _edit(attractionViewModel, context);
                      },
                      child: AttractionListTile(
                        attraction: attraction,
                        onTap: () {
                          _edit(attractionViewModel, context);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _edit(AttractionViewModel attractionViewModel, BuildContext context) {
    attractionViewModel.updateWith(isUpdate: true);
    AddAttractionsPage.show(context, attraction: attractionViewModel);
  }

  Future<void> _delete(BuildContext context, Attraction attraction) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteAttraction(attraction);
      Fluttertoast.showToast(msg: "Attraction Deleted!");
    } on Exception catch (e) {
      showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      );
    }
  }
}
