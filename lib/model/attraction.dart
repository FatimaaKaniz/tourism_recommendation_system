import 'package:collection/collection.dart';

enum AttractionType { historical, mountains, beaches, urban }
enum SortAttractionBy { name, attractionType, country }

class Attraction implements Comparable<Attraction> {
  String? name;
  String? country;
  String? city;
  String? id;
  AttractionType? attractionType;
  String? googlePlaceId;
  String? address;
  String? phoneNumber;
  List<String?>? photoRef;
  String? website;
  String? url;
  List<String?>? types;

  Attraction({
    this.name,
    this.attractionType = AttractionType.historical,
    this.googlePlaceId,
    this.id,
    this.url,
    this.website,
    this.address,
    this.photoRef,
    this.phoneNumber,
    this.types,
    this.country,
    this.city,
  });

  static AttractionType? getAttractionType(String type) {
    return AttractionType.values
        .firstWhereOrNull((element) => element.name == type);
  }

  factory Attraction.fromMap(Map<String, dynamic> data, String documentId) {
    final String name = data['name'];
    final String? country = data['country'];
    final String? city = data['city'];
    final String type = data['attractionType'];
    AttractionType attractionType =
        AttractionType.values.firstWhere((element) => element.name == type);
    final String? googlePlaceId = data['googlePlaceId'];
    final String? address = data['address'];
    final String? phone = data['phone'];
    final List<String?>? photos = data['photos'] != null
        ? (data['photos'] as List).map((e) => e as String).toList()
        : null;
    final String? website = data['website'];
    final String? url = data['url'];
    final List<String?>? types = data['types'] != null
        ? (data['types'] as List).map((e) => e as String).toList()
        : null;

    return Attraction(
        id: documentId,
        name: name,
        attractionType: attractionType,
        googlePlaceId: googlePlaceId,
        address: address,
        phoneNumber: phone,
        photoRef: photos,
        website: website,
        url: url,
        types: types,
        city: city,
        country: country);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'city': city,
      'attractionType': this.attractionType!.name,
      'googlePlaceId': googlePlaceId,
      'address': address,
      'phone': phoneNumber,
      'photos': photoRef,
      'website': website,
      'url': url,
      'types': types
    };
  }

  @override
  String toString() {
    return 'Attraction{name: $name, attractionType: $attractionType}';
  }

  @override
  int compareTo(Attraction other) {
    return this.name!.compareTo(other.name!);
  }

  void updateWith({
    String? name,
    AttractionType? attractionType,
    String? googlePlaceId,
    String? address,
    String? phone,
    String? url,
    String? website,
    List<String?>? photoRef,
    List<String?>? types,
    String? id,
    String? country,
    String? city,
  }) {
    this.name = name ?? this.name;
    this.country = country ?? this.country;
    this.city = city ?? this.city;
    this.address = address ?? this.address;
    this.phoneNumber = phone ?? this.phoneNumber;
    this.url = url ?? this.url;
    this.website = website ?? this.website;
    this.photoRef = photoRef ?? this.photoRef;
    this.types = types ?? this.types;
    this.attractionType = attractionType ?? this.attractionType;
    this.googlePlaceId = googlePlaceId ?? this.googlePlaceId;
    this.id = id ?? this.id;
  }
}
