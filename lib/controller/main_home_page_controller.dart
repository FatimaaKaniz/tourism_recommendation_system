import 'package:tourism_recommendation_system/model/user.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class MainHomePageController {
  Future<bool> setIsAdmin(Database db, AuthBase auth) async {
    if (auth.isCurrentUserAdmin == null) {
      final users = await db.usersStream().first;
      var myUser =
          users.where((user) => user.email == auth.currentUser!.email!).first;
      bool admin = myUser.isAdmin!;
      var places = myUser.savedPlacesIds;

      auth.setCurrentUserAdmin(admin);
      auth.setMyUser(
        MyUser(
          email: auth.currentUser!.email,
          isAdmin: admin,
          name: auth.currentUser!.displayName,
          savedPlacesIds: places,
        ),
      );
      return admin;
    } else {
      return auth.isCurrentUserAdmin!;
    }
  }
}
