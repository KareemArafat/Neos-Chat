import 'package:shared_preferences/shared_preferences.dart';

class ShardModel {
  Future<void> setUserId(String x) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('userId', x);
  }

  Future<String> getUserId() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('userId') ?? '';
  }

  Future<void> setSenderId(String x) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('id', x);
  }

  Future<String> getSenderId() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('id') ?? '';
  }

  Future<void> setToken(String x) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('token', x);
  }

  Future<String> getToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('token') ?? '';
  }

  Future<void> setApiKey(String x) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('key', x);
  }

  Future<String> getApiKey() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('key') ?? '';
  }

  Future<void> setUserName(String x) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('name', x);
  }

  Future<String> getUserName() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('name') ?? '';
  }
}
