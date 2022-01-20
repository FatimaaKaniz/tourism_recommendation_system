import 'package:flutter/cupertino.dart';
import 'package:tourism_recommendation_system/custom_packages/tools/validators.dart';

class MyUser with ChangeNotifier {
  MyUser(
      {required this.email,
      required this.isAdmin,
      this.name,
      this.savedPlacesIds,
      this.localAuthEnabled});

  String? email;
  bool? isAdmin;
  String? name;
  List<String?>? savedPlacesIds;
  bool? localAuthEnabled;

  bool isNameEditAble = false;

  bool get canNameSubmit {
    return name != null &&
        EmailAndPasswordValidators().nameValidator.isValid(name!);
  }

  factory MyUser.fromMap(Map<String, dynamic> data, String documentId) {
    final bool isAdmin = data['isAdmin'];
    final bool? localAuthEnabled = data['localAuthEnabled'];
    final String email = data['email'];
    final List<String?>? savedPlacesIds = data['savedPlacesIds'] != null
        ? (data['savedPlacesIds'] as List).map((e) => e as String).toList()
        : null;
    return MyUser(
        email: email, isAdmin: isAdmin, savedPlacesIds: savedPlacesIds, localAuthEnabled: localAuthEnabled);
  }

  Map<String, dynamic> toMap() {
    return {
      'isAdmin': isAdmin,
      'email': email,
      'savedPlacesIds': savedPlacesIds,
      'localAuthEnabled' : localAuthEnabled,
    };
  }

  void updateName(String name) => updateWith(name: name);

  void updateWith({
    String? email,
    bool? isAdmin,
    String? name,
    bool? isNameEditAble,
    List<String?>? savedPlacesIds,
    bool? localAuthEnabled,
  }) {
    this.email = email ?? this.email;
    this.isAdmin = isAdmin ?? this.isAdmin;
    this.isNameEditAble = isNameEditAble ?? this.isNameEditAble;
    this.savedPlacesIds = savedPlacesIds ?? this.savedPlacesIds;
    this.localAuthEnabled = localAuthEnabled ?? this.localAuthEnabled;
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
    return 'MyUser{email: $email, isAdmin: $isAdmin}';
  }
}
