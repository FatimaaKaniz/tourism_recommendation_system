import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tourism_recommendation_system/services/api_keys.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({Key? key}) : super(key: key);

  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
  List<AutocompletePrediction> predictions = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: IconButton(
        icon: Icon(
          Icons.close,
          color: Colors.teal,
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 20, top: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Location Selector',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  labelText: "Search",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });
                    autoCompleteSearch(value);
                  } else {
                    if (predictions.length > 0 && mounted) {
                      setState(() {
                        predictions = [];
                      });
                    }
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: predictions.length == 0 && isLoading
                    ? Center(
                        child: LoadingAnimationWidget.staggeredDotWave(
                          color: Colors.teal,
                          size: 65,
                        ),
                      )
                    : ListView.builder(
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.pin_drop,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(predictions[index].description ?? ""),
                            onTap: () {
                              debugPrint(predictions[index].placeId);
                              Navigator.of(context, rootNavigator: true)
                                  .pop(predictions[index].placeId);
                            },
                          );
                        },
                      ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Image.asset("resources/images/google.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}
