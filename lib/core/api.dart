import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neos_chat/core/const.dart';
import 'package:neos_chat/core/shard.dart';

class Api {
  Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
    String? header,
    String? token,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (header != null) {
      headers.addAll({'x-api-key': header});
    }
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    http.Response response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
        "Error: ${response.statusCode}, Response: ${response.body}",
      );
    }
  }

  Future<dynamic> get({required String url, String? token}) async {
    Map<String, String> headers = {};
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'there is a problem with status code ${response.statusCode}',
      );
    }
  }

  Future<dynamic> getFile({required String url, String? token}) async {
    Map<String, String> headers = {};
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'there is a problem with status code ${response.statusCode}',
      );
    }
  }
}

class Sign {
  Future<Map<String, dynamic>> loginFn({
    required String userId,
    required String appToken,
    required String apiKey,
  }) async {
    final responseData = await Api().post(
      url: "$baseUrl/auth/login",
      header: apiKey,
      body: {'userId': userId, 'appToken': appToken},
    );
    final userName = responseData['data']['user']['userName'];
    final senderId = responseData['data']['user']['_id'];
    final token = responseData['data']['token'];

    await ShardModel().setUserName(userName);
    await ShardModel().setSenderId(senderId);
    await ShardModel().setToken(token);
    await ShardModel().setUserId(userId);
    await ShardModel().setApiKey(apiKey);
    return responseData;
  }

  Future<Map<String, dynamic>> registerFn({
    required String userName,
    required String userId,
    required String appToken,
    required String apiKey,
  }) async {
    return await Api().post(
      url: "$baseUrl/auth/register",
      header: apiKey,
      body: {'userName': userName, 'userId': userId, 'appToken': appToken},
    );
  }
}
