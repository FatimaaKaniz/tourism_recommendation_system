import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/home/admin/add_attraction_page.dart';
import 'package:tourism_recommendation_system/home/admin/job_list_tile.dart';
import 'package:tourism_recommendation_system/home/admin/list_items_builder.dart';
import 'package:tourism_recommendation_system/home/profile/profile_page.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/database.dart';

import '../../services/auth_base.dart';

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

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: SizedBox(
              height: 30,
              child: BackButton(
                color: Colors.teal,
                onPressed: () {},
              )),
        ),
        Center(
          child: Text(
            'Home Page',
            style: TextStyle(
              color: Colors.teal,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        StreamBuilder<List<Attraction>>(
          stream: database.attractionStream(),
          builder: (context, snapshot) {
            return ListItemsBuilder<Attraction>(
              snapshot: snapshot,
              itemBuilder: (context, attraction) => Dismissible(
                key: Key('attraction-${attraction.id}'),
                background: Container(color: Colors.red),
                direction: DismissDirection.endToStart,
                //onDismissed: (direction) => _delete(context, job),
                child: AttractionListTile(
                  attraction: attraction,
                  onTap: () {
                    attraction.updateWith(isUpdate: true);
                    AddAttractionsPage.show(context, attraction: attraction);
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showProfilePage(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => ChangeNotifierProvider<MyUser>(
          create: (_) => MyUser(
            email: auth.currentUser!.email,
            isAdmin: auth.isCurrentUserAdmin,
            name: auth.currentUser!.displayName,
          ),
          child: ProfilePage(),
        ),
      ),
    );
  }
}
