class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, String?> map) {
    return UserModel(
      id: int.parse(map['id'] ?? '0'),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

//mera name danish hay