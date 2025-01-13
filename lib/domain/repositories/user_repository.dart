import 'dart:convert';

import 'package:bigbox/configs/api_config.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  Future<ResponseModel> getHome() async {
    Uri url = Uri.parse("$baseUrl/guest/get-home");
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

  Future<ResponseModel> homeList({
    int? page,
    int? limit,
    String? type,
  }) async {
    var postBody = jsonEncode({
      "page": page ?? 1,
      "limit": limit ?? 5,
      "type": type ?? 'all',
    });
    Uri url = Uri.parse("$baseUrl/guest/home-list");
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

  Future<ResponseModel> orderDetail({required int id}) async {
    var postBody = jsonEncode({"id": id});
    Uri url = Uri.parse("$baseUrl/guest/order-detail");
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

  Future<ResponseModel> createOrder({
    required String barcode,
    required String phone,
    String? title,
  }) async {
    var postBody = jsonEncode({
      "barcode": barcode,
      "phone": phone,
      "title": title ?? "",
    });
    Uri url = Uri.parse("$baseUrl/guest/create-order");
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

  Future<ResponseModel> createDelivery({
    required int id,
    required bool deliveryStatus,
    required String deliveryAddress,
  }) async {
    var postBody = jsonEncode({
      "id": id,
      "deliveryStatus": deliveryStatus,
      "deliveryAddress": deliveryAddress,
    });
    Uri url = Uri.parse("$baseUrl/guest/order-delivery");
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

  Future<ResponseModel> createAddress({
    required String type,
    required String address,
  }) async {
    var postBody = jsonEncode({
      "type": type,
      "address": address,
    });
    Uri url = Uri.parse("$baseUrl/guest/add-address");
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

  Future<ResponseModel> getAddress() async {
    Uri url = Uri.parse("$baseUrl/guest/get-addresses");
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

  Future<ResponseModel> updateAddress({
    required int id,
    required String type,
    required String address,
  }) async {
    var postBody = jsonEncode({
      "id": id,
      "type": type,
      "address": address,
    });
    Uri url = Uri.parse("$baseUrl/guest/update-address");
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

  Future<ResponseModel> deleteAddress({
    required int id,
  }) async {
    var postBody = jsonEncode({"id": id});
    Uri url = Uri.parse("$baseUrl/guest/delete-address");
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

  Future<ResponseModel> searchByBarcode({
    required String token,
  }) async {
    var postBody = jsonEncode({"token": token});
    Uri url = Uri.parse("$baseUrl/guest/search-by-barcode");
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

  // Shared Repository
  Future<ResponseModel> getPages() async {
    Uri url = Uri.parse("$baseUrl/get-pages");
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

  Future<ResponseModel> getMainAddress() async {
    Uri url = Uri.parse("$baseUrl/get-address");
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

  Future<ResponseModel> getNotificationList({
    int? page,
    int? limit,
  }) async {
    var postBody = jsonEncode({
      "page": page ?? 1,
      "limit": limit ?? 5,
    });
    Uri url = Uri.parse("$baseUrl/guest/get-notifications");
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

  Future<ResponseModel> seenNotifications({
    required List<int>? ids,
  }) async {
    var postBody = jsonEncode({"ids": ids ?? []});
    Uri url = Uri.parse("$baseUrl/guest/seen-notifications");
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

  Future<ResponseModel> seenAllNotifications() async {
    Uri url = Uri.parse("$baseUrl/guest/seen-all");
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
}
