import 'dart:convert';

import 'package:bigbox/configs/api_config.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<ResponseModel> signIn({
    required String phone,
    required String password,
  }) async {
    var postBody = jsonEncode({
      "phone": phone,
      "password": password,
    });
    Uri url = Uri.parse("$baseUrl/auth/sign-in");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json"
      },
      body: postBody,
    );
    ResponseModel res = ResponseModel.fromJson(jsonDecode(response.body));
    // if (res.status == 200 && (res.success ?? false)) {
    //   tkn = res.data['token'] ?? '';
    //   usr = UserModel.fromJson(res.data['user'] ?? {});
    // }
    return res;
  }

  Future<ResponseModel> sendOtp({required String phone}) async {
    var postBody = jsonEncode({
      "phone": phone,
    });
    Uri url = Uri.parse("$baseUrl/auth/otp");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> signUp({
    required String phone,
    required String otp,
    required String password,
  }) async {
    var postBody = jsonEncode({
      "phone": phone,
      "otp": otp,
      "password": password,
    });
    Uri url = Uri.parse("$baseUrl/auth/create");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> recoveryPassword({
    required String phone,
    required String otp,
    required String password,
  }) async {
    var postBody = jsonEncode({
      "phone": phone,
      "otp": otp,
      "password": password,
    });
    Uri url = Uri.parse("$baseUrl/auth/change-password");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> deviceTokenUpdate({required String token}) async {
    var postBody = jsonEncode({"token": token});
    Uri url = Uri.parse("$baseUrl/auth/update-token");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json",
        "Authorization": "Bearer $tkn"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> tokenUpdate({required String token}) async {
    var postBody = jsonEncode({"token": token});
    Uri url = Uri.parse("$baseUrl/auth/update-current-token");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json",
        "Authorization": "Bearer $tkn"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> updateInfo({
    String? lastName,
    String? firstName,
    String? email,
  }) async {
    var postBody = jsonEncode({
      "lastName": lastName ?? '',
      "firstName": firstName ?? '',
      "email": email ?? '',
    });
    Uri url = Uri.parse("$baseUrl/auth/update-info");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json",
        "Authorization": "Bearer $tkn"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> changeCover({required String image}) async {
    var postBody = jsonEncode({"image": image});
    Uri url = Uri.parse("$baseUrl/auth/change-profile");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json",
        "Authorization": "Bearer $tkn"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> accountOff() async {
    Uri url = Uri.parse("$baseUrl/auth/account-off");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json",
        "Authorization": "Bearer $tkn"
      },
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<ResponseModel> changePassword({
    required String password,
  }) async {
    var postBody = jsonEncode({"password": password});
    Uri url = Uri.parse("$baseUrl/change-password");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": "mn",
        "Accept": "application/json",
        "Authorization": "Bearer $tkn"
      },
      body: postBody,
    );
    return ResponseModel.fromJson(jsonDecode(response.body));
  }
}
