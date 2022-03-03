import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:tourism_recommendation_system/custom_packages/tools/validators.dart';

class MyUser with ChangeNotifier {
  MyUser({
    required this.email,
    required this.isAdmin,
    this.name,
    this.savedPlacesIds,
    // this.sortByType = AttractionType.historical
  });

  String? email;
  bool? isAdmin;
  String? name;
  List<String?>? savedPlacesIds;

  // AttractionType? sortByType;

  bool isNameEditAble = false;

  bool get canNameSubmit {
    return name != null &&
        EmailAndPasswordValidators().nameValidator.isValid(name!);
  }

  factory MyUser.fromMap(Map<String, dynamic> data, String documentId) {
    final bool isAdmin = data['isAdmin'];
    final String email = data['email'];
    // final String? type = data['sortByType'];
    // AttractionType? sortByType;
    // try {
    //   sortByType= AttractionType.values.firstWhere((element) => element.name == type);
    // }catch(e){
    //   sortByType = AttractionType.historical;
    // }
    final List<String?>? savedPlacesIds = data['savedPlacesIds'] != null
        ? (data['savedPlacesIds'] as List).map((e) => e as String).toList()
        : null;
    return MyUser(
      email: email,
      isAdmin: isAdmin,
      savedPlacesIds: savedPlacesIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAdmin': isAdmin,
      'email': email,
      'savedPlacesIds': savedPlacesIds,
      // 'sortByType': this.sortByType!.name,
    };
  }

  void updateName(String name) => updateWith(name: name);

  void updateWith({
    String? email,
    bool? isAdmin,
    String? name,
    bool? isNameEditAble,
    List<String?>? savedPlacesIds,
    // AttractionType? sortByType,
  }) {
    this.email = email ?? this.email;
    // this.sortByType = sortByType ?? this.sortByType;
    this.isAdmin = isAdmin ?? this.isAdmin;
    this.isNameEditAble = isNameEditAble ?? this.isNameEditAble;
    this.savedPlacesIds = savedPlacesIds ?? this.savedPlacesIds;
    this.name = name ?? this.name;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyUser &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          isAdmin == other.isAdmin;

  @override
  int get hashCode => email.hashCode ^ isAdmin.hashCode;

  @override
  String toString() {
    return 'MyUser{email: $email, isAdmin: $isAdmin, name: $name, savedPlacesIds: $savedPlacesIds, isNameEditAble: $isNameEditAble}';
  }
}
