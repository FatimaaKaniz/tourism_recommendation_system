import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PhotoViewer extends StatefulWidget {
  final List images;
  final int current;

  const PhotoViewer(
      {Key? key, required this.images, required this.current})
      : super(key: key);

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  int _current = 0;
  bool _stateChange = false;

  @override
  void initState() {
    super.initState();
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    _current = (_stateChange == false) ? widget.current : _current;
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          child: Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                    height: MediaQuery.of(context).size.height / 1.3,
                    viewportFraction: 1.0,
                    onPageChanged: (index, data) {
                      setState(() {
                        _stateChange = true;
                        _current = index;
                      });
                    },
                    initialPage: widget.current),
                items: map<Widget>(widget.images, (index, image) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Image.memory(
                            image,
                            fit: BoxFit.fill,
                            height: 400.0,
                          ),
                        )
                      ]);
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: map<Widget>(widget.images, (index, image) {
                  return Container(
                    width: 10.0,
                    height: 9.0,
                    margin: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_current == index)
                          ? Colors.teal
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ),
        ));
  }
}
