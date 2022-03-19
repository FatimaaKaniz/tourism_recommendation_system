class MyUser {
  String? email;
  bool? isAdmin;
  String? name;
  List<String?>? savedPlacesIds;

  MyUser({
    required this.email,
    required this.isAdmin,
    this.name,
    this.savedPlacesIds,
  });

  factory MyUser.fromMap(Map<String, dynamic> data, String documentId) {
    final bool isAdmin = data['isAdmin'];
    final String email = data['email'];
    final List<String?>? savedPlacesIds = data['savedPlacesIds'] != null
        ? (data['savedPlacesIds'] as List).map((e) => e as String).toList()
        : null;
    return MyUser(
      email: email,
      isAdmin: isAdmin,
      savedPlacesIds: savedPlacesIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAdmin': isAdmin,
      'email': email,
      'savedPlacesIds': savedPlacesIds,
    };
  }
  void updateName(String name) => updateWith(name: name);

  void updateWith({
    String? email,
    bool? isAdmin,
    String? name,
    List<String?>? savedPlacesIds,
  }) {
    this.email = email ?? this.email;
    this.isAdmin = isAdmin ?? this.isAdmin;
    this.savedPlacesIds = savedPlacesIds ?? this.savedPlacesIds;
    this.name = name ?? this.name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyUser &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          isAdmin == other.isAdmin;

  @override
  int get hashCode => email.hashCode ^ isAdmin.hashCode;

  @override
  String toString() {
    return 'MyUser{email: $email, isAdmin: $isAdmin, name: $name, savedPlacesIds: $savedPlacesIds}';
  }
}
