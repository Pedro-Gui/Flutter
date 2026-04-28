class User{
  final String id;
  final String username;
  final List<String> emails;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.emails,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      username: map['username'] ?? '',
      emails: map['emails'] != null 
          ? (map['emails'] as List).map((email) => email['address'] as String).toList() : [],
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt']: DateTime.tryParse(map['createdAt'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'emails': emails,
      'username': username,
      'createdAt': createdAt,
    };
  }

}