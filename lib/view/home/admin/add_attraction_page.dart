import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_place/google_place.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/custom_packages/widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/model/attraction.dart';
import 'package:tourism_recommendation_system/view/home/admin/location_selector.dart';
import 'package:tourism_recommendation_system/view_model/attraction_view_model.dart';
import 'package:tourism_recommendation_system/services/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class AddAttractionsPage extends StatefulWidget {
  const AddAttractionsPage({Key? key, required this.db}) : super(key: key);
  final Database db;

  static Future<void> show(BuildContext context,
      {AttractionViewModel? attraction}) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) =>
              attraction ??
              AttractionViewModel(
                attraction: Attraction(),
              ),
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
  Database get db => widget.db;



  @override
  Widget build(BuildContext context) {
    final attractionViewModel = Provider.of<AttractionViewModel>(context);
    isUpdate = attractionViewModel.isUpdate;
    if (isUpdate) {
      address = attractionViewModel.attraction.address!;
      _nameController = TextEditingController(text: attractionViewModel.attraction.name);
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
      final attractionViewModel = Provider.of<AttractionViewModel>(context, listen: false);
      await db.deleteAttraction(attractionViewModel.attraction);
      Fluttertoast.showToast(msg: 'Attraction Deleted!');
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _buildContents(BuildContext context) {
    final attractionViewModel = Provider.of<AttractionViewModel>(context);

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
                  if (attractionViewModel.isUpdate) ...<Widget>[
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
                  if (attractionViewModel.isUpdate) ...<Widget>[
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
                  child: attractionViewModel.isUpdate && address == null
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
                                  errorText: attractionViewModel.nameErrorText,
                                ),
                                style: TextStyle(fontSize: 18),
                                autocorrect: false,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                keyboardAppearance: Brightness.light,
                                onChanged: attractionViewModel.updateName,
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
                                    ? attractionViewModel.attraction.attractionType
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
                                    attractionViewModel.updateType(type),
                              ),
                              SizedBox(height: 20),
                              if (attractionViewModel.attraction.googlePlaceId == null) ...<Widget>[
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
                                            attractionViewModel.isUpdate) ...<Widget>[
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.75,
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
                                    !attractionViewModel.canSubmit ? null : _submit,
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


  _getLocationDetails(AttractionViewModel attractionViewModel ) async {
    await attractionViewModel.getLocationDetails(googlePlace);
    if (mounted) {
      setState(() {
        address = attractionViewModel.attraction.address ?? "";
        _nameController =
            TextEditingController(text: address?.split(',').elementAt(0));
      });
    }
  }

  void _showLocationSelector(BuildContext context) async {
    final attractionViewModel = Provider.of<AttractionViewModel>(context, listen: false);
    selectedPlaceId = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => LocationSelector(),
      ),
    );
    if (selectedPlaceId != null) {
      attractionViewModel.updateWith(googlePlaceId: selectedPlaceId);
      _getLocationDetails(attractionViewModel);
    }
  }

  Future<void> _submit() async {
    final attractionViewModel = Provider.of<AttractionViewModel>(context, listen: false);
    try {
      var result = await attractionViewModel.submit(db);
      if (result) {
        Fluttertoast.showToast(
            msg: 'Attraction ' +
                (attractionViewModel.isUpdate ? 'Updated' : 'Added') +
                ' Successfully!');

        Navigator.of(context, rootNavigator: true).pop();
      } else {
        showAlertDialog(
          title: 'Place is already used!',
          content: 'Please choose a different place',
          defaultActionText: 'OK',
          context: context,
        );
      }
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
          title: 'Operation failed', exception: e, context: context);
    }
  }
}
