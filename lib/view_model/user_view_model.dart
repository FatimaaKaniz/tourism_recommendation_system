import 'package:flutter/cupertino.dart';
import 'package:tourism_recommendation_system/custom_packages/tools/validators.dart';
import 'package:tourism_recommendation_system/model/user.dart';

class MyUserViewModel with ChangeNotifier {
  MyUserViewModel({
    required this.myUser,
  });

  final MyUser myUser;
  bool isNameEditAble = false;

  bool get canNameSubmit {
    return myUser.name != null &&
        EmailAndPasswordValidators().nameValidator.isValid(myUser.name!);
  }


  void updateWith({
    String? email,
    bool? isAdmin,
    String? name,
    bool? isNameEditAble,
    List<String?>? savedPlacesIds,
  }) {
    this.myUser.updateWith(
          email: email,
          isAdmin: isAdmin,
          name: name,
          savedPlacesIds: savedPlacesIds,
        );

    this.isNameEditAble = isNameEditAble ?? this.isNameEditAble;
    notifyListeners();
  }


}
