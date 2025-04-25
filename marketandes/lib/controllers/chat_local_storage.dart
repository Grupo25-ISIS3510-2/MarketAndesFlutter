import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalStorage {
  static String _chatKey(String userId) => 'cachedChats_$userId';
  static String _updateKey(String userId) => 'lastUpdate_$userId';

  static Future<void> save(
    String userId,
    String lastUpdate,
    List<Map<String, dynamic>> chats,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatKey(userId), jsonEncode(chats));
    await prefs.setString(_updateKey(userId), lastUpdate);
  }

  static Future<String?> getLocalUpdate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_updateKey(userId));
  }

  static Future<List<Map<String, dynamic>>> getChats(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_chatKey(userId));
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }
}
