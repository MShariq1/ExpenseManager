import '../db/database_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<UserModel?> login(String email, String password) async {
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

    if (result.rows.isEmpty) return null;

    return UserModel.fromMap(result.rows.first.assoc());
  }

  Future<bool> register(String name, String email, String password) async {
    final conn = await DatabaseService.getConnection();

    await conn.execute(
      '''
      INSERT INTO users(name, email, password)
      VALUES(:name, :email, :password)
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