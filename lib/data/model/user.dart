class User {
  String? id;
  String username;
  String password;

  User({
    this.id,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': this.id,
      'userName': this.username,
      'userPassword': this.password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String?,
      username: map['userName'] as String,
      password: map['userPassword'] as String,
    );
  }
}
