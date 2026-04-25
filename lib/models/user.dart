class User {
  final String id;
  final String email;
  final String passwordHash;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': passwordHash,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      passwordHash: map['password'],
      createdAt: map['created_at'],
    );
  }
}
