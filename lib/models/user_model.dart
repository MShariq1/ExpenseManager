import '../network/api_client.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  UserModel({required this.id, required this.name, required this.email});
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final id = int.tryParse('${map['id']}');
    if (id == null ||
        id <= 0 ||
        map['name'] is! String ||
        map['email'] is! String) {
      throw const ApiException('Invalid user response.');
    }
    return UserModel(id: id, name: map['name'], email: map['email']);
  }
}
