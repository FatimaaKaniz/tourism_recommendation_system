import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:tourism_recommendation_system/custom_packages/validators.dart';

class MyUser with ChangeNotifier {
  MyUser({required this.email, required this.isAdmin, this.name, this.phone});

  String? email;
  bool? isAdmin;
  String? name;
  String? phone;

  bool isNameEditAble = false;

  bool get canNameSubmit {
    return name != null &&
        EmailAndPasswordValidators().nameValidator.isValid(name!);
  }

  factory MyUser.fromMap(Map<String, dynamic> data, String documentId) {
    final bool isAdmin = data['isAdmin'];
    final String email = data['email'];
    return MyUser(email: email, isAdmin: isAdmin);
  }

  Map<String, dynamic> toMap() {
    return {
      'isAdmin': isAdmin,
      'email': email,
    };
  }

  void updateName(String name)  {
  updateWith(name: name);
  print(name);
}

void updateWith({
  String? email,
  bool? isAdmin,
  String? name,
  String? phone,
  bool? isNameEditAble,
}) {
  this.email = email ?? this.email;
  this.isAdmin = isAdmin ?? this.isAdmin;
  this.isNameEditAble = isNameEditAble ?? this.isNameEditAble;

  this.name = name ?? this.name;
  this.phone = phone ?? this.phone;
  notifyListeners();
}

@override
bool operator
==
(

Object other
)
=>
identical
(
this, other) ||
other is MyUser &&runtimeType == other.runtimeType &&email == other
    .email &&isAdmin == other.isAdmin;

@override
int get hashCode => email.hashCode ^ isAdmin.hashCode;

@override
String toString() {
  return 'MyUser{email: $email, isAdmin: $isAdmin}';
}}
