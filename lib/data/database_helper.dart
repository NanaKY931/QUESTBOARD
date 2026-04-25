import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/player.dart';
import '../models/quest.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('questboard.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE Users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        password TEXT,
        created_at TEXT
      )
    ''');

    // Create Player_Stats table
    await db.execute('''
      CREATE TABLE Player_Stats (
        user_id TEXT PRIMARY KEY,
        name TEXT,
        level INTEGER,
        current_exp INTEGER,
        hp INTEGER,
        total_completed_quests INTEGER,
        rank TEXT,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_quest_date TEXT DEFAULT ''
      )
    ''');

    // Create Quests table
    await db.execute('''
      CREATE TABLE Quests (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT,
        description TEXT,
        category TEXT,
        difficulty TEXT,
        exp_reward INTEGER,
        status TEXT,
        media_proof_path TEXT,
        deadline TEXT
      )
    ''');

    // Create Achievements table
    await db.execute('''
      CREATE TABLE Achievements (
        user_id TEXT,
        id TEXT,
        unlocked_at TEXT,
        PRIMARY KEY (user_id, id)
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // For simplicity in this dev phase, we might just drop and recreate
      // or perform complex migrations. Given the state, let's do a clean migration.
      
      // 1. Create Users table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS Users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE,
          password TEXT,
          created_at TEXT
        )
      ''');

      // 2. Add user_id to Player_Stats (if it was id INTEGER PRIMARY KEY before)
      // SQFlite doesn't support easy column renaming/primary key changes.
      // We'll create a temp table and migrate.
      
      await db.execute("ALTER TABLE Quests ADD COLUMN user_id TEXT DEFAULT 'legacy_user'");
      await db.execute("ALTER TABLE Achievements ADD COLUMN user_id TEXT DEFAULT 'legacy_user'");
      
      // Handle Player_Stats separately since it had an 'id' int primary key
      // and we want 'user_id' TEXT primary key.
    }
  }

  // --- Auth Methods ---
  Future<void> createUser(User user) async {
    final db = await instance.database;
    await db.insert('Users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query('Users', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await instance.database;
    final result = await db.query('Users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // --- Player Methods ---
  Future<void> createPlayer(PlayerStats player) async {
    final db = await instance.database;
    await db.insert('Player_Stats', player.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<PlayerStats?> getPlayer(String userId) async {
    final db = await instance.database;
    final maps = await db.query('Player_Stats', where: 'user_id = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) {
      return PlayerStats.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updatePlayer(PlayerStats player) async {
    final db = await instance.database;
    await db.update('Player_Stats', player.toMap(), where: 'user_id = ?', whereArgs: [player.userId]);
  }

  // --- Quest Methods ---
  Future<void> insertQuest(Quest quest) async {
    final db = await instance.database;
    await db.insert('Quests', quest.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Quest>> getAllQuests(String userId) async {
    final db = await instance.database;
    final orderBy = 'deadline ASC';
    final result = await db.query('Quests', where: 'user_id = ?', whereArgs: [userId], orderBy: orderBy);
    return result.map((json) => Quest.fromMap(json)).toList();
  }

  Future<List<Quest>> getQuestsByStatus(String userId, String status) async {
    final db = await instance.database;
    final result = await db.query('Quests', 
        where: 'user_id = ? AND status = ?', 
        whereArgs: [userId, status], 
        orderBy: 'deadline ASC');
    return result.map((json) => Quest.fromMap(json)).toList();
  }


  Future<void> updateQuest(Quest quest) async {
    final db = await instance.database;
    await db.update('Quests', quest.toMap(), where: 'id = ?', whereArgs: [quest.id]);
  }

  Future<void> deleteQuest(String id) async {
    final db = await instance.database;
    await db.delete('Quests', where: 'id = ?', whereArgs: [id]);
  }

  // --- Achievement Methods ---
  Future<Map<String, String>> getUnlockedAchievements(String userId) async {
    final db = await instance.database;
    final result = await db.query('Achievements', where: 'user_id = ?', whereArgs: [userId]);
    final map = <String, String>{};
    for (var row in result) {
      map[row['id'] as String] = row['unlocked_at'] as String;
    }
    return map;
  }

  Future<void> unlockAchievement(String userId, String id, String date) async {
    final db = await instance.database;
    await db.insert('Achievements', {'user_id': userId, 'id': id, 'unlocked_at': date},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('Users');
    await db.delete('Player_Stats');
    await db.delete('Quests');
    await db.delete('Achievements');
  }
}
