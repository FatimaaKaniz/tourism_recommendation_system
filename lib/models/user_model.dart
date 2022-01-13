class MyUser {
  MyUser({required this.email, required this.isAdmin, this.id});

  final String? email;
  final bool? isAdmin;
  String? id;

  factory MyUser.fromMap(Map<String, dynamic> data, String documentId) {
    final bool isAdmin = data['isAdmin'];
    final String email = data['email'];
    return MyUser(id: documentId, email: email, isAdmin: isAdmin);
  }

  Map<String, dynamic> toMap() {
    return {
      'isAdmin': isAdmin,
      'email': email,
    };
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
    return 'MyUser{email: $email, isAdmin: $isAdmin}';
  }
}
