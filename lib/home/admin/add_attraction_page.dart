import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_place/google_place.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/custom_packages/widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/home/admin/location_selector.dart';
import 'package:tourism_recommendation_system/models/attraction_model.dart';
import 'package:tourism_recommendation_system/services/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class AddAttractionsPage extends StatefulWidget {
  const AddAttractionsPage({Key? key, required this.db}) : super(key: key);
  final Database db;

  static Future<void> show(BuildContext context,
      {Attraction? attraction}) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => attraction ?? Attraction(),
          child: AddAttractionsPage(
            db: database,
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _AddAttractionsPageState createState() => _AddAttractionsPageState();
}

class _AddAttractionsPageState extends State<AddAttractionsPage> {
  TextEditingController _nameController = TextEditingController();
  final googlePlace = GooglePlace(APIKeys.googleMapsAPIKeys);
  String? address;
  String? selectedPlaceId;
  bool isUpdate = false;

  @override
  Widget build(BuildContext context) {
    final attraction = Provider.of<Attraction>(context);
    isUpdate = attraction.isUpdate;
    if (isUpdate) {
      address = attraction.address!;
      _nameController = TextEditingController(text: attraction.name);
      _nameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _nameController.text.length));
    }
    return Scaffold(
      floatingActionButton: IconButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          icon: Icon(
            Icons.close,
            color: Colors.teal,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: _buildContents(context),
    );
  }

  Future<void> _deleteAttraction(BuildContext context) async {
    try {
      final db = Provider.of<Database>(context, listen: false);
      final attraction = Provider.of<Attraction>(context, listen: false);
      await db.deleteAttraction(attraction);
      Fluttertoast.showToast(msg: 'Attraction Deleted!');
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _buildContents(BuildContext context) {
    final attraction = Provider.of<Attraction>(context);

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: !isUpdate
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (attraction.isUpdate) ...<Widget>[
                    Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.delete_sharp,
                          color: Colors.red.shade500,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    'Attraction',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (attraction.isUpdate) ...<Widget>[
                    IconButton(
                      onPressed: () {
                        _deleteAttraction(context);
                      },
                      icon: Icon(
                        Icons.delete_sharp,
                        color: Colors.red.shade500,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                child: Card(
                  elevation: 4.0,
                  child: attraction.isUpdate && address == null
                      ? Center(
                          child: LoadingAnimationWidget.staggeredDotWave(
                            color: Colors.teal,
                            size: 65,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(fontSize: 19),
                                  errorText: attraction.nameErrorText,
                                ),
                                style: TextStyle(fontSize: 18),
                                autocorrect: false,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                keyboardAppearance: Brightness.light,
                                onChanged: attraction.updateName,
                              ),
                              SizedBox(height: 10),
                              DropdownButtonFormField<AttractionType>(
                                decoration: InputDecoration(
                                  label: Text(
                                    'Attraction Type',
                                    style: TextStyle(fontSize: 19),
                                  ),
                                ),
                                value: isUpdate
                                    ? attraction.attractionType
                                    : AttractionType.historical,
                                items: AttractionType.values
                                    .map((AttractionType attractionType) {
                                  return DropdownMenuItem(
                                      value: attractionType,
                                      child: Text(
                                        attractionType.name,
                                        style: TextStyle(fontSize: 18),
                                      ));
                                }).toList(),
                                onChanged: (type) =>
                                    attraction.updateType(type),
                              ),
                              SizedBox(height: 20),
                              if (attraction.googlePlaceId == null) ...<Widget>[
                                Text(
                                  'Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _showLocationSelector(context);
                                  },
                                  child: Text(
                                    'Click here to add from Google Maps',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ] else ...<Widget>[
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Address',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        if (address != null ||
                                            attraction.isUpdate) ...<Widget>[
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            width: 293,
                                            child: Text(
                                              address!,
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        onPressed: () {
                                          _showLocationSelector(context);
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(
                                height: 10,
                              ),
                              SocialLoginButton(
                                buttonType: SocialLoginButtonType.generalLogin,
                                text: isUpdate ? 'Update' : 'Save',
                                borderRadius: 50,
                                backgroundColor: Colors.teal,
                                disabledBackgroundColor: Colors.grey,
                                onPressed:
                                    !attraction.canSubmit ? null : _submit,
                              )
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getLocationDetails(Attraction attraction) async {
    var result = await googlePlace.details.get(attraction.googlePlaceId!,
        fields:
            "photo,formatted_address,url,website,international_phone_number,type");
    if (result != null && result.result != null && mounted) {
      setState(() {
        address = result.result?.formattedAddress;
        _nameController=TextEditingController(text: address?.split(',').elementAt(0));
        attraction.updateWith(
          name: address?.split(',').elementAt(0),
          phone: result.result?.internationalPhoneNumber,
          address: result.result?.formattedAddress,
          url: result.result?.url,
          types: result.result?.types,
          photoRef:
              result.result?.photos?.map((e) => e.photoReference).toList(),
          website: result.result?.website,
        );
      });
    }
  }

  void _showLocationSelector(BuildContext context) async {
    final attraction = Provider.of<Attraction>(context, listen: false);
    selectedPlaceId = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => LocationSelector(),
      ),
    );
    if (selectedPlaceId != null) {
      attraction.updateWith(googlePlaceId: selectedPlaceId);
      _getLocationDetails(attraction);

    }
  }

  Future<void> _submit() async {
    final attraction = Provider.of<Attraction>(context, listen: false);
    attraction.updateWith(submitted: true);
    try {
      if (attraction.isUpdate) {
        widget.db.updateAttraction(attraction);
        Fluttertoast.showToast(msg: 'Attraction Updated Successfully!');
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        final attractions = await widget.db.attractionStream().first;
        final allPlaceId = attractions.map((job) => job.googlePlaceId).toList();

        if (allPlaceId.contains(attraction.googlePlaceId)) {
          showAlertDialog(
            title: 'Place already used!',
            content: 'Please choose a different place',
            defaultActionText: 'OK',
            context: context,
          );
        } else {
          final id = attraction.id ?? widget.db.documentIdFromCurrentDate();
          attraction.updateWith(id: id);
          await widget.db.setAttraction(attraction, id);
          Fluttertoast.showToast(msg: 'Attraction Added Successfully!');

          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
          title: 'Operation failed', exception: e, context: context);
    }
  }
}
