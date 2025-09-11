class User {
  String id;
  String username;
  String email;
  String? profilePictureUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
  });


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
