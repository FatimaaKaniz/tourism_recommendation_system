import 'package:flutter/cupertino.dart';
import 'package:tourism_recommendation_system/custom_packages/validators.dart';

enum AttractionType { historical, mountains, beaches, urban }

class Attraction with ChangeNotifier {
  Attraction(
      {this.name,
      this.attractionType = AttractionType.historical,
      this.googlePlaceId,
      this.submitted = false,
      this.isUpdate = false,
      this.id});

  String? name;
  String? id;
  AttractionType? attractionType;
  String? googlePlaceId;
  bool submitted;
  bool isUpdate;
  String? address;

  String? get nameErrorText => !submitted ||
          (name != null &&
              EmailAndPasswordValidators().nameValidator.isValid(name!))
      ? null
      : "Name shouldn't be empty!";

  void updateName(String? name) => updateWith(name: name);

  bool get canSubmit {
    return name != null &&
        name!.isNotEmpty &&
        attractionType != null &&
        googlePlaceId != null &&
        googlePlaceId!.isNotEmpty;
  }

  void updateType(AttractionType? type) => updateWith(attractionType: type);

  void updateWith(
      {String? name,
      AttractionType? attractionType,
      String? googlePlaceId,
      bool? submitted,
      bool? isUpdate,
      String? address,
      String? id}) {
    this.name = name ?? this.name;
    this.address = address ?? this.address;
    this.submitted = submitted ?? this.submitted;
    this.isUpdate = isUpdate ?? this.isUpdate;
    this.attractionType = attractionType ?? this.attractionType;
    this.googlePlaceId = googlePlaceId ?? this.googlePlaceId;
    this.id = id ?? this.id;
    notifyListeners();
  }

  factory Attraction.fromMap(Map<String, dynamic> data, String documentId) {
    final String name = data['name'];
    final String type = data['attractionType'];
    AttractionType attractionType =
        AttractionType.values.firstWhere((element) => element.name == type);
    final String? googlePlaceId = data['googlePlaceId'];

    return Attraction(
        id: documentId,
        name: name,
        attractionType: attractionType,
        googlePlaceId: googlePlaceId);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'attractionType': this.attractionType!.name,
      'googlePlaceId': googlePlaceId,
    };
  }
}
