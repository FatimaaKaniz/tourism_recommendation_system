import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';
import 'package:tourism_recommendation_system/services/api_keys.dart';
import 'package:tourism_recommendation_system/view_model/attraction_view_model.dart';

class AttractionListCard extends StatefulWidget {
  AttractionListCard(
      {Key? key,
      required this.attractionViewModel,
      required this.onTap,
      this.isCalled = true})
      : super(key: key);

  bool isCalled;
  final AttractionViewModel attractionViewModel;
  final VoidCallback onTap;

  @override
  State<StatefulWidget> createState() => _AttractionListCardState();
}

class _AttractionListCardState extends State<AttractionListCard> {
  AttractionViewModel get attractionViewModel => widget.attractionViewModel;

  Attraction get attraction => attractionViewModel.attraction;

  final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
  Uint8List? image;

  void getDetails(List<String?>? photoRefs) async {
    if (attraction.photoRef != null) {
      var img = await attractionViewModel.getPhoto(
          attraction.photoRef!.elementAt(0)!, googlePlace);
      if (mounted)
        setState(() {
          image = img;
        });
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
    getDetails(attraction.photoRef!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCalled) {
      getDetails(attraction.photoRef!);
      widget.isCalled = false;
    }

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
                    ? AssetImage(
                        cupertinoActivityIndicatorSmall,
                      ) as ImageProvider
                    : MemoryImage(image!),
                fit: image == null ? BoxFit.contain : BoxFit.cover,
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
                      attraction.name!,
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
