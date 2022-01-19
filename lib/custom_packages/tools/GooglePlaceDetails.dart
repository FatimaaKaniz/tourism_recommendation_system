import 'dart:typed_data';

import 'package:google_place/google_place.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_keys.dart';

class GooglePlaceDetails {
  static final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);

  static List<String> _photoRef = [];
  static List<Uint8List> photos = [];
  static Uint8List? photo;

  static Future<void> getDetails(String placeId, bool isSingle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(placeId) && false) {
      await getPhotos(isSingle);
    } else {
      var result = await googlePlace.details.get(placeId, fields: "photo");
      if (result != null && result.result != null) {
        var photos = result.result?.photos ?? null;
        if (photos != null && photos.length > 0) {
          for (Photo photo in photos) {
            _photoRef.add(photo.photoReference!);
          }
          prefs.setStringList(placeId, _photoRef);
          await getPhotos(isSingle);
        }
      }
    }
  }

  static Future<void> getPhotos(bool isSingle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isSingle) {
      if (prefs.containsKey(_photoRef.elementAt(0)) && false) {
        photo = Uint8List.fromList(
            prefs.getString(_photoRef.elementAt(0))!.codeUnits);
      } else {
        photo = await getPhoto(_photoRef.elementAt(0));
      }
    }

    for (String photoRef in _photoRef) {
      if (prefs.containsKey(photoRef) && false) {
        photos.add(Uint8List.fromList(prefs.getString(photoRef)!.codeUnits));
      } else {
        var image = await getPhoto(photoRef);
        if (image != null) {
          print('hassan');
          photos.add(image);
        }
      }
    }

    return null;
  }

  static Future<Uint8List?> getPhoto(String photoRef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var result = await googlePlace.photos.get(photoRef, 200, 200);
    if (result != null) {
      prefs.setString(photoRef, String.fromCharCodes(result));
      return result;
    }
    return null;
  }
}
