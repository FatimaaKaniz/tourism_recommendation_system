import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent(
      {Key? key, this.title = 'Nothing here', this.message = 'Add a new item'})
      : super(key: key);
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 32, color: Colors.black54),
          ),
          if (auth.isCurrentUserAdmin != null &&
              auth.isCurrentUserAdmin!) ...<Widget>[
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            )
          ],
        ],
      ),
    );
  }
}
