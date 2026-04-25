import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../data/database_helper.dart';
import '../models/user.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _db = DatabaseHelper.instance;

  static const _userTokenKey = 'auth_token';

  Future<User?> signUp(String email, String password) async {
    final existingUser = await _db.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('User already exists');
    }

    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    final user = User(
      id: const Uuid().v4(),
      email: email,
      passwordHash: passwordHash,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _db.createUser(user);
    await _storage.write(key: _userTokenKey, value: user.id);
    return user;
  }

  Future<User?> login(String email, String password) async {
    final user = await _db.getUserByEmail(email);
    if (user == null) {
      throw Exception('User not found');
    }

    final isValid = BCrypt.checkpw(password, user.passwordHash);
    if (!isValid) {
      throw Exception('Invalid password');
    }

    await _storage.write(key: _userTokenKey, value: user.id);
    return user;
  }

  Future<void> logout() async {
    await _storage.delete(key: _userTokenKey);
  }

  Future<String?> getAuthenticatedUserId() async {
    return await _storage.read(key: _userTokenKey);
  }

  Future<User?> getCurrentUser() async {
    final id = await getAuthenticatedUserId();
    if (id == null) return null;
    return await _db.getUserById(id);
  }
}
