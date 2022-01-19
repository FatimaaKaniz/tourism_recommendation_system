import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_recommendation_system/custom_packages/tools/GooglePlaceDetails.dart';

import '../models/attraction_model.dart';

class AttractionDetailsPage extends StatefulWidget {
  const AttractionDetailsPage({
    Key? key,
    required this.attraction,
    required this.googlePlace,
  }) : super(key: key);
  final Attraction attraction;
  final GooglePlace googlePlace;

  @override
  _AttractionDetailsPageState createState() => _AttractionDetailsPageState(
      attraction: attraction, googlePlace: googlePlace);

  static Future<void> show(BuildContext context, GooglePlace googlePlace,
      Attraction attraction) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => AttractionDetailsPage(
          attraction: attraction,
          googlePlace: googlePlace,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class _AttractionDetailsPageState extends State<AttractionDetailsPage> {
  _AttractionDetailsPageState({
    required this.attraction,
    required this.googlePlace,
  });

  final Attraction attraction;
  final GooglePlace googlePlace;
  List<Uint8List> photos = [];
  List<String> photoRefs = [];
  DetailsResult? detailsResult;

  void getDetails(String placeId) async {
    String placeIdKey = placeId + "multi";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(placeIdKey)) {
      photoRefs = prefs.getStringList(placeIdKey)!;
    } else {
      var result = await this
          .googlePlace
          .details
          .get(placeId, fields: "photo,url,formatted_address");
      if (result != null && result.result != null && mounted) {
        setState(() {
          detailsResult = result.result!;
          this.photos = [];
        });
        var images = result.result?.photos ?? null;
        if (images != null && images.length > 0) {
          for (Photo photo in images) {
            photoRefs.add(photo.photoReference!);
          }
          prefs.setStringList(placeIdKey, photoRefs);
        }
      }
    }
    for (String ref in photoRefs) {
      var image = await getPhoto(ref);
      if (image != null) {
        setState(() {
          photos.add(image);
        });
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
    return Scaffold(
      floatingActionButton: BackButton(
        color: Colors.teal,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Center(
            child: Text(
              attraction.name!,
              style: TextStyle(
                color: Colors.teal,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (photos.length == 0) CircularProgressIndicator(),
        if (photos.length > 0)
          Expanded(
            child: ListView.builder(
              itemCount: photos.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 250,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.memory(
                        photos[index],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 10),
      ],
    );
  }
}
