import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_place/google_place.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attraction_model.dart';
import '../services/database.dart';

class AttractionDetailsPage extends StatefulWidget {
  const AttractionDetailsPage({
    Key? key,
    required this.attraction,
    required this.googlePlace,
    this.isSaved = false,
    this.user,
  }) : super(key: key);
  final Attraction attraction;
  final GooglePlace googlePlace;
  final bool isSaved;
  final MyUser? user;

  @override
  _AttractionDetailsPageState createState() => _AttractionDetailsPageState(
      attraction: attraction, googlePlace: googlePlace, isSaved: isSaved);

  static Future<void> show(
      BuildContext context, GooglePlace googlePlace, Attraction attraction,
      {bool isSaved = false}) async {
     await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => AttractionDetailsPage(
          attraction: attraction,
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
    required this.attraction,
    required this.googlePlace,
    required this.isSaved,
  });

  final Attraction attraction;
  bool? openNow;
  bool isSaved;
  final GooglePlace googlePlace;
  List<Uint8List> photos = [];

  void getDetails(String placeId) async {
    var result = await googlePlace.details
        .get(attraction.googlePlaceId!, fields: "opening_hours");
    if (result != null && result.result != null && mounted) {
      setState(() {
        openNow = result.result!.openingHours?.openNow;
      });
    }
    if (attraction.photoRef != null && attraction.photoRef!.length > 0) {
      attraction.photoRef!.forEach((ref) async {
        var image = await getPhoto(ref!);
        if (image != null) {
          setState(() {
            photos.add(image);
          });
        }
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
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (attraction.types != null)
      attraction.types?.add(attraction.attractionType!.name);
    else
      attraction.updateWith(types: [attraction.attractionType!.name]);
    getDetails(attraction.googlePlaceId!);
    if (auth.myUser!.savedPlacesIds != null)
      isSaved = auth.myUser!.savedPlacesIds!.contains(attraction.id!);
  }

  launchURL(String url, String text) async {
    print(url);
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
              SizedBox(width: 10),
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
            : Container(
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
                // attraction.url != null
                //     ? Container(
                //         margin: EdgeInsets.only(left: 15, top: 10),
                //         child: ListTile(
                //           leading: CircleAvatar(
                //             child: Icon(Icons.map),
                //           ),
                //           title: Text(
                //             attraction.url!,
                //           ),
                //           onTap: () => launchURL(attraction.url!, 'maps'),
                //         ),
                //       )
                //     : Container(),
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
                // Container(
                //   width: 20,
                //   height: 20  ,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.stretch,
                //     children: [
                //       attraction.url != null
                //           ? Container(
                //               margin: EdgeInsets.only(left: 15, top: 10),
                //               child: ListTile(
                //                 leading: CircleAvatar(
                //                     backgroundColor: Colors.teal,
                //                     child: Icon(
                //                       Icons.directions,
                //                       color: Colors.white,
                //                     )),
                //                 onTap: () => launchURL(attraction.url!, 'maps'),
                //                 title: Text('Maps'),
                //               ),
                //             )
                //           : Container(),
                //       Container(
                //         margin: EdgeInsets.only(left: 15, top: 10),
                //         child: ListTile(
                //           leading: CircleAvatar(
                //               backgroundColor: Colors.teal,
                //               child: Icon(
                //                 widget.isSaved
                //                     ? Icons.heart_broken
                //                     : CupertinoIcons.heart_solid,
                //                 color: Colors.white,
                //               )),
                //           onTap: () {
                //             final db =
                //                 Provider.of<Database>(context, listen: false);
                //             final auth =
                //                 Provider.of<AuthBase>(context, listen: false);
                //             var places = auth.myUser!.savedPlacesIds;
                //             if (isSaved) {
                //               places?.remove(attraction.id!);
                //               updatePlace(auth, places!, db,
                //                   'Attraction removed Successfully!');
                //               setState(() {
                //                 isSaved = !isSaved;
                //               });
                //             } else {
                //               if (places == null || places.length == 0) {
                //                 places = [attraction.id!];
                //                 updatePlace(auth, places, db,
                //                     'Attraction added Successfully!');
                //               } else {
                //                 places.add(attraction.id!);
                //                 updatePlace(auth, places, db,
                //                     'Attraction added Successfully!');
                //               }
                //               setState(() {
                //                 isSaved = !isSaved;
                //               });
                //             }
                //           },
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // attraction.url != null
                //     ? Container(
                //         margin: EdgeInsets.only(left: 15, top: 10),
                //         child: ListTile(
                //           leading: CircleAvatar(
                //               backgroundColor: Colors.teal,
                //               child: Icon(
                //                 Icons.directions,
                //                 color: Colors.white,
                //               )),
                //           onTap: () => launchURL(attraction.url!, 'maps'),
                //           title: Text('Maps'),
                //         ),
                //       )
                //     : Container(),
                // Container(
                //   margin: EdgeInsets.only(left: 15, top: 10),
                //   child: ListTile(
                //     leading: CircleAvatar(
                //         backgroundColor: Colors.teal,
                //         child: Icon(
                //           widget.isSaved ? Icons.delete : Icons.save,
                //           color: Colors.white,
                //         )),
                //     onTap: () {
                //       final db = Provider.of<Database>(context, listen: false);
                //       final auth =
                //           Provider.of<AuthBase>(context, listen: false);
                //       var places = auth.myUser!.savedPlacesIds;
                //       if (isSaved) {
                //         places?.remove(attraction.id!);
                //         updatePlace(auth, places!, db,
                //             'Attraction removed Successfully!');
                //         setState(() {
                //           isSaved = !isSaved;
                //         });
                //       } else {
                //         if (places == null || places.length == 0) {
                //           places = [attraction.id!];
                //           updatePlace(auth, places, db,
                //               'Attraction added Successfully!');
                //         } else {
                //           if (places.contains(attraction.id!)) {
                //             Fluttertoast.showToast(
                //                 msg: 'Attraction already added to WishList');
                //           } else {
                //             places.add(attraction.id!);
                //             updatePlace(auth, places, db,
                //                 'Attraction added Successfully!');
                //           }
                //         }
                //         setState(() {
                //           isSaved = !isSaved;
                //         });
                //       }
                //     },
                //     title: Text(
                //         isSaved ? 'Remove from WishList' : 'Add to WishList'),
                //   ),
                // ),
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
    Fluttertoast.showToast(msg: msg);
  }
}
