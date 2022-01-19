import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_recommendation_system/custom_packages/tools/GooglePlaceDetails.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';

import '../services/api_keys.dart';

class AttractionListCard extends StatefulWidget {
  AttractionListCard({Key? key, required this.attraction, required this.onTap})
      : super(key: key);
  final Attraction attraction;
  final VoidCallback onTap;

  @override
  State<StatefulWidget> createState() => _AttractionListCardState();
}

class _AttractionListCardState extends State<AttractionListCard> {
  final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
  Uint8List? image;

  void getDetails(String placeId) async {
    String placeIdKey = placeId + "single";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(placeIdKey)) {
      var h = await getPhoto(prefs.getString(placeIdKey)!);
      setState(() {
        image = h;
      });
    } else {
      var result = await this.googlePlace.details.get(placeId, fields: "photo");
      if (result != null && result.result != null && mounted) {
        var photos = result.result?.photos ?? null;
        if (photos != null && photos.length > 0) {
          var h = await getPhoto(photos.elementAt(0).photoReference!);
          if (mounted) {
            setState(() {
              image = h;
            });
            prefs.setString(placeIdKey, photos.elementAt(0).photoReference!);
          }
        }
      }
    }
  }

  Future<Uint8List?> getPhoto(String photoReference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(photoReference)) {
      return Uint8List.fromList(prefs.getString(photoReference)!.codeUnits);
    } else {
      var result = await this.googlePlace.photos.get(photoReference, 200, 200);
      if (result != null && mounted) {
        prefs.setString(photoReference, String.fromCharCodes(result));
        return result;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getDetails(widget.attraction.googlePlaceId!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 100,
      child: InkWell(
        onTap: widget.onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: image == null
                    ? AssetImage(cupertinoActivityIndicatorSmall,) as ImageProvider
                    : MemoryImage(image!),
                fit: image== null? BoxFit.contain: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 400,
                  height: 50,
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      widget.attraction.name!,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
