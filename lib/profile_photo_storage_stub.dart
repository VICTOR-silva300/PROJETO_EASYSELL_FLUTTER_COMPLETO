import 'package:shared_preferences/shared_preferences.dart';

Future<String?> readProfilePhoto(String key) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.getString(key);
}

Future<bool> writeProfilePhoto(String key, String value) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.setString(key, value);
}

Future<void> removeProfilePhoto(String key) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(key);
}
