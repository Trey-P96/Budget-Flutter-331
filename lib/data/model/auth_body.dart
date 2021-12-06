class AuthBody {
  String username;
  String password;

  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'password': this.password,
    };
  }

  factory AuthBody.fromMap(Map<String, dynamic> map) {
    return AuthBody(
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }

  AuthBody({
    required this.username,
    required this.password,
  });
}
