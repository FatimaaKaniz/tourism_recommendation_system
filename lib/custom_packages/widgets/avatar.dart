import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_gifs/loading_gifs.dart';

class Avatar extends StatelessWidget {
  const Avatar({this.photoUrl, required this.radius, required this.isLoading})
      : super();
  final String? photoUrl;
  final double radius;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black54,
          width: 3.0,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.black12,
        backgroundImage:
            !isLoading && photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: isLoading
            ? Image(
                image: AssetImage(cupertinoActivityIndicator),
                width: 50,
              )
            : photoUrl == null && !isLoading
                ? Icon(Icons.camera_alt, size: radius)
                : null,
      ),
    );
  }
}
