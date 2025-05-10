import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ChatLocalDbService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'chats.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_last_update (
        user_id TEXT PRIMARY KEY,
        last_update TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE chats (
        chat_id TEXT PRIMARY KEY,
        user_id TEXT,
        chat_data TEXT,
        user_data TEXT
      );
    ''');
  }

  Future<String?> getLastUpdate(String userId) async {
    final db = await database;
    final res = await db.query(
      'user_last_update',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return res.isNotEmpty ? res.first['last_update'] as String : null;
  }

  Future<List<Map<String, dynamic>>> getChats(String userId) async {
    final db = await database;
    final res = await db.query(
      'chats',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return res
        .map(
          (row) => {
            'chat': jsonDecode(row['chat_data'] as String),
            'userData': jsonDecode(row['user_data'] as String),
          },
        )
        .toList();
  }

  Future<void> saveChats(
    String userId,
    String lastUpdate,
    List<Map<String, dynamic>> chatList,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('chats', where: 'user_id = ?', whereArgs: [userId]);

      for (var entry in chatList) {
        final chat = entry['chat'] as Map<String, dynamic>;
        final userData = entry['userData'] as Map<String, dynamic>;

        await txn.insert('chats', {
          'chat_id': chat['id'],
          'user_id': userId,
          'chat_data': jsonEncode(chat),
          'user_data': jsonEncode(userData),
        });
      }

      await txn.insert('user_last_update', {
        'user_id': userId,
        'last_update': lastUpdate,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
