import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

Future<void> initSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}

Object? getValue(String key) => sharedPreferences.get(key);

Future<void> setValue(String key, Object value) async {
  if (value is String) {
    await sharedPreferences.setString(key, value);
  } else if (value is List<String>) {
    await sharedPreferences.setStringList(key, value);
  } else if (value is int) {
    await sharedPreferences.setInt(key, value);
  }
}
