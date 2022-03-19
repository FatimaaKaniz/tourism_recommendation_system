import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_place/google_place.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';
import 'package:tourism_recommendation_system/view_model/attraction_view_model.dart';
import 'package:tourism_recommendation_system/view_model/user_view_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/services/database.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionDetailsPage extends StatefulWidget {
  const AttractionDetailsPage({
    Key? key,
    required this.attractionViewModel,
    required this.googlePlace,
    this.isSaved = false,
    this.user,
  }) : super(key: key);
  final AttractionViewModel attractionViewModel;
  final GooglePlace googlePlace;
  final bool isSaved;
  final MyUserViewModel? user;

  @override
  _AttractionDetailsPageState createState() => _AttractionDetailsPageState(
        attractionViewModel: attractionViewModel,
        googlePlace: googlePlace,
        isSaved: isSaved,
      );

  static Future<void> show(BuildContext context, GooglePlace googlePlace,
      AttractionViewModel attractionViewModel,
      {bool isSaved = false}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => AttractionDetailsPage(
          attractionViewModel: attractionViewModel,
          googlePlace: googlePlace,
          isSaved: isSaved,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class _AttractionDetailsPageState extends State<AttractionDetailsPage> {
  _AttractionDetailsPageState({
    required this.attractionViewModel,
    required this.googlePlace,
    required this.isSaved,
  });

  final AttractionViewModel attractionViewModel;
  bool? openNow;
  bool isSaved;
  final GooglePlace googlePlace;
  List<Uint8List> photos = [];

  Attraction get attraction => attractionViewModel.attraction;

  void getDetails(String placeId) async {
    bool? openNow = await attractionViewModel.getTimings(googlePlace);
    if (mounted) {
      setState(() {
        this.openNow = openNow;
      });
    }

    if (attraction.photoRef != null && attraction.photoRef!.length > 0) {
      attraction.photoRef!.forEach((ref) async {
        var image = await attractionViewModel.getPhoto(ref!, googlePlace);
        if (image != null && mounted) {
          setState(() {
            photos.add(image);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (attraction.types != null &&
        !attraction.types!.contains(attraction.attractionType!.name))
      attraction.types?.add(attraction.attractionType!.name);
    else
      attraction.updateWith(types: [attraction.attractionType!.name]);
    getDetails(attraction.googlePlaceId!);
    if (auth.myUser!.savedPlacesIds != null)
      isSaved = auth.myUser!.savedPlacesIds!.contains(attraction.id!);
  }

  launchURL(String url, String text) async {
    if (await canLaunch(url)) {
      await launch(url,
          enableJavaScript: true, forceSafariVC: false, enableDomStorage: true);
    } else {
      Clipboard.setData(
        ClipboardData(text: attraction.address!),
      ).then(
        (value) => Fluttertoast.showToast(
            msg: 'Cannot Launch ' + text + ', copied instead!'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'save',
              onPressed: () {
                final db = Provider.of<Database>(context, listen: false);
                final auth = Provider.of<AuthBase>(context, listen: false);
                var places = auth.myUser!.savedPlacesIds;
                if (isSaved) {
                  places?.remove(attraction.id!);
                  updatePlace(
                      auth, places!, db, 'Attraction removed Successfully!');
                  setState(() {
                    isSaved = !isSaved;
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                } else {
                  if (places == null || places.length == 0) {
                    places = [attraction.id!];
                    updatePlace(
                        auth, places, db, 'Attraction added Successfully!');
                  } else {
                    places.add(attraction.id!);
                    updatePlace(
                        auth, places, db, 'Attraction added Successfully!');
                  }
                  setState(() {
                    isSaved = !isSaved;
                  });
                }
              },
              child: Icon(
                  isSaved ? Icons.heart_broken : CupertinoIcons.heart_solid,
                  size: 30),
            ),
            if (attraction.url != null) ...<Widget>[
              SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'maps',
                onPressed: () => launchURL(attraction.url!, 'maps'),
                child: Icon(Icons.directions, size: 30),
              ),
            ]
          ],
        ),
      ),
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: SizedBox(
            height: 30,
            child: BackButton(
              color: Colors.teal,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
        ),
        Center(
          child: Text(
            attraction.name!,
            style: TextStyle(
              color: Colors.teal,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        photos.length == 0
            ? Container(
                height: 200,
                child: Center(
                  child: LoadingAnimationWidget.threeHorizontalDots(
                      color: Colors.teal, size: 50),
                ),
              )
            : Center(
                child: Container(
                  height: 200,
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
              ),
        SizedBox(height: 10),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 15, top: 10),
                  child: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                attraction.types != null && attraction.types!.length > 0
                    ? Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: attraction.types!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Chip(
                                label: Text(
                                  attraction.types![index]!,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),
                SizedBox(height: 20),
                attraction.address != null
                    ? Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            attraction.address!,
                          ),
                          onTap: () => Clipboard.setData(
                            ClipboardData(text: attraction.address!),
                          ).then(
                            (value) => Fluttertoast.showToast(
                                msg: 'Address Copied to Clipboard!'),
                          ),
                        ),
                      )
                    : Container(),
                attraction.phoneNumber != null
                    ? Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            attraction.phoneNumber!,
                          ),
                          onTap: () => launchURL(
                            'tel:' +
                                attraction.phoneNumber!.replaceAll(' ', ''),
                            'phone',
                          ),
                        ),
                      )
                    : Container(),
                attraction.website != null
                    ? Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.public,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            attraction.website!,
                          ),
                          onTap: () => launchURL(attraction.website!, 'url'),
                        ),
                      )
                    : Container(),
                openNow != null
                    ? Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: openNow!
                                ? Icon(
                                    Icons.timer_outlined,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.timer_off,
                                    color: Colors.white,
                                  ),
                          ),
                          title: Text(
                            openNow! ? 'Open Now' : 'Closed Now',
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void updatePlace(
      AuthBase auth, List<String?> places, Database db, String msg) {
    auth.myUser!.updateWith(savedPlacesIds: places);
    db.setUser(auth.myUser!, auth.currentUser!.uid);
    AttractionViewModel.isSavedChanged = true;
    Fluttertoast.showToast(msg: msg);
  }
}
