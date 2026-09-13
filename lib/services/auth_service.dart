import '../models/user_model.dart';
import '../db/database_service.dart';

class AuthService {
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final conn = await DatabaseService.getConnection();

    final result = await conn.execute(
      '''
      SELECT id, name, email FROM users
      WHERE email = :email AND password = :password
      LIMIT 1
      ''',
      {
        'email': email,
        'password': password,
      },
    );

    await conn.close();

    if (result.rows.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.rows.first.assoc());
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final conn = await DatabaseService.getConnection();

    await conn.execute(
      '''
      INSERT INTO users (name, email, password)
      VALUES (:name, :email, :password)
      ''',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    await conn.close();
    return true;
  }
}