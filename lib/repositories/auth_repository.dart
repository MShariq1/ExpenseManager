import '../network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);
  Future<UserModel> login(String email, String password) async =>
      UserModel.fromMap(
        objectData(
          await api.request(
            'POST',
            'login',
            body: {'email': email, 'password': password},
          ),
        ),
      );
  Future<bool> register(String name, String email, String password) async {
    UserModel.fromMap(
      objectData(
        await api.request(
          'POST',
          'register',
          body: {'name': name, 'email': email, 'password': password},
        ),
      ),
    );
    return true;
  }
}
