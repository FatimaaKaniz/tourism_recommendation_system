import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:google_place/google_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_recommendation_system/custom_packages/tools/validators.dart';
import 'package:collection/collection.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class AttractionViewModel with ChangeNotifier {
  AttractionViewModel({
    this.submitted = false,
    this.isUpdate = false,
    required this.attraction,
  });

  final Attraction attraction;
  bool submitted;
  bool isUpdate;

  static bool isSavedChanged = false;

  String? get nameErrorText => !submitted ||
          (attraction.name != null &&
              EmailAndPasswordValidators()
                  .nameValidator
                  .isValid(attraction.name!))
      ? null
      : "Name shouldn't be empty!";

  void updateName(String? name) => updateWith(name: name);

  bool get canSubmit {
    return attraction.name != null &&
        attraction.name!.isNotEmpty &&
        attraction.attractionType != null &&
        attraction.googlePlaceId != null &&
        attraction.googlePlaceId!.isNotEmpty;
  }

  Future<bool> submit(Database db) async {
    updateWith(submitted: true);

    if (isUpdate) {
      db.updateAttraction(attraction);
      return true;
    } else {
      final attractions = await db.attractionStream().first;
      final allPlaceId = attractions.map((job) => job.googlePlaceId).toList();
      if (allPlaceId.contains(attraction.googlePlaceId)) {
        return false;
      } else {
        final id = attraction.id ?? db.documentIdFromCurrentDate();
        attraction.updateWith(id: id);
        await db.setAttraction(attraction, id);
        return true;
      }
    }
  }

  void updateType(AttractionType? type) => updateWith(attractionType: type);

  void updateWith({
    String? name,
    AttractionType? attractionType,
    String? googlePlaceId,
    bool? submitted,
    bool? isUpdate,
    String? address,
    String? phone,
    String? url,
    String? website,
    List<String?>? photoRef,
    List<String?>? types,
    String? id,
    String? country,
    String? city,
  }) {
    attraction.updateWith(
      name: name,
      attractionType: attractionType,
      country: country,
      city: city,
      address: address,
      phone: phone,
      url: url,
      website: website,
      photoRef: photoRef,
      types: types,
      id: id,
      googlePlaceId: googlePlaceId,
    );

    this.submitted = submitted ?? this.submitted;
    this.isUpdate = isUpdate ?? this.isUpdate;

    notifyListeners();
  }

  static AttractionType? getAttractionType(String type) {
    return AttractionType.values
        .firstWhereOrNull((element) => element.name == type);
  }

  Future<bool?> getTimings(GooglePlace googlePlace, {String? placeId}) async {
    placeId = placeId ?? this.attraction.googlePlaceId!;
    var result =
        await googlePlace.details.get(placeId, fields: "opening_hours");
    if (result != null && result.result != null) {
      return result.result!.openingHours?.openNow;
    }
    return null;
  }

  Future<Uint8List?> getPhoto(
      String photoReference, GooglePlace googlePlace) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(photoReference)) {
      return Uint8List.fromList(prefs.getString(photoReference)!.codeUnits);
    } else {
      var result = await googlePlace.photos.get(photoReference, 200, 200);
      if (result != null) {
        prefs.setString(photoReference, String.fromCharCodes(result));
        return result;
      }
    }
    return null;
  }

  getLocationDetails(GooglePlace googlePlace) async {
    var result = await googlePlace.details.get(this.attraction.googlePlaceId!,
        fields:
            "photo,formatted_address,url,website,international_phone_number,type,address_component");

    if (result != null && result.result != null) {
      String? city;
      String? country;
      String? address = result.result?.formattedAddress;
      result.result?.addressComponents
          ?.where((element) =>
              element.types != null && element.types!.contains('locality'))
          .forEach((element) {
        city = element.longName;
      });
      result.result?.addressComponents
          ?.where((element) =>
              element.types != null && element.types!.contains('country'))
          .forEach((element) {
        country = element.longName;
      });

      updateWith(
        name: address?.split(',').elementAt(0),
        phone: result.result?.internationalPhoneNumber,
        address: result.result?.formattedAddress,
        url: result.result?.url,
        types: result.result?.types,
        country: country,
        city: city,
        photoRef: result.result?.photos?.map((e) => e.photoReference).toList(),
        website: result.result?.website,
      );
    }
  }
}
