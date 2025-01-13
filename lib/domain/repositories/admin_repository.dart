import 'dart:convert';

import 'package:bigbox/configs/api_config.dart';
import 'package:bigbox/configs/global.dart';
import 'package:bigbox/domain/models/response_model.dart';
import 'package:http/http.dart' as http;

class AdminRepository {
  // ***
  Future<ResponseModel> userList({
    int? page,
    int? limit,
  }) async {
    var postBody = jsonEncode({
      "page": page ?? 1,
      "limit": limit ?? 5,
    });
    Uri url = Uri.parse("$baseUrl/admin/users-list");
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

  Future<ResponseModel> changeUserStatus({required int id}) async {
    var postBody = jsonEncode({"id": id});
    Uri url = Uri.parse("$baseUrl/admin/change-user-status");
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

  Future<ResponseModel> changeUserPermission({
    required int id,
    required int permission,
  }) async {
    var postBody = jsonEncode({
      "id": id,
      "permission": permission,
    });
    Uri url = Uri.parse("$baseUrl/admin/change-user-permission");
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

  // Pages
  Future<ResponseModel> addPage({
    required String type,
    required String data,
    required bool isActive,
  }) async {
    var postBody = jsonEncode({
      "type": type,
      "data": data,
      "isActive": isActive,
    });
    Uri url = Uri.parse("$baseUrl/admin/add-page");
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

  Future<ResponseModel> updatePage({
    required int id,
    required String type,
    required String data,
    required int isActive,
  }) async {
    var postBody = jsonEncode({
      "id": id,
      "type": type,
      "data": data,
      "isActive": isActive,
    });
    Uri url = Uri.parse("$baseUrl/admin/update-page");
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

  Future<ResponseModel> deletePage({required int id}) async {
    var postBody = jsonEncode({"id": id});
    Uri url = Uri.parse("$baseUrl/admin/delete-page");
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

  // Address
  Future<ResponseModel> addAddress({
    required String type,
    required String address,
  }) async {
    var postBody = jsonEncode({
      "type": type,
      "address": address,
    });
    Uri url = Uri.parse("$baseUrl/admin/add-address");
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
    Uri url = Uri.parse("$baseUrl/admin/edit-address");
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

  Future<ResponseModel> deleteAddress({required int id}) async {
    var postBody = jsonEncode({"id": id});
    Uri url = Uri.parse("$baseUrl/admin/delete-address");
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

  // Order
  Future<ResponseModel> addNewOrder({
    required String barcode,
    required String phone,
    String? title,
    int? price,
  }) async {
    var postBody = jsonEncode({
      "barcode": barcode,
      "phone": phone,
      "title": title ?? '',
      "price": price ?? 0,
    });
    Uri url = Uri.parse("$baseUrl/admin/create-order");
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

  Future<ResponseModel> updateOrder({
    required int id,
    required String barcode,
    required String phone,
    required int type,
    required String containerNo,
    required String title,
    required int price,
    required String deliveryAddress,
  }) async {
    var postBody = jsonEncode({
      "id": id,
      "barcode": barcode,
      "phone": phone,
      "type": type,
      "containerNo": containerNo,
      "title": title,
      "price": price,
      "deliveryAddress": deliveryAddress,
    });
    Uri url = Uri.parse("$baseUrl/admin/create-order");
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

  Future<ResponseModel> updateOrderDynamic({
    required dynamic values,
  }) async {
    var postBody = jsonEncode(values);
    Uri url = Uri.parse("$baseUrl/admin/create-order");
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

  Future<ResponseModel> ordersList({
    int? page,
    int? limit,
    String? status,
  }) async {
    var postBody = jsonEncode({
      "page": page ?? 1,
      "limit": limit ?? 5,
      "status": status ?? "pending",
    });
    Uri url = Uri.parse("$baseUrl/admin/orders");
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

  Future<ResponseModel> orderHistory({
    int? page,
    int? limit,
  }) async {
    var postBody = jsonEncode({
      "page": page ?? 1,
      "limit": limit ?? 5,
    });
    Uri url = Uri.parse("$baseUrl/admin/orders-log");
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

  Future<ResponseModel> deleteOrdersHistory({List<String>? logs}) async {
    var postBody = jsonEncode({"logs": logs ?? []});
    Uri url = Uri.parse("$baseUrl/admin/log-remove");
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

  // Search
  Future<ResponseModel> searchByBarcode({
    required String token,
  }) async {
    var postBody = jsonEncode({"token": token});
    Uri url = Uri.parse("$baseUrl/admin/search-by-barcode");
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

  Future<ResponseModel> searchByPhone({
    required String qry,
  }) async {
    var postBody = jsonEncode({"qry": qry});
    Uri url = Uri.parse("$baseUrl/admin/users-list");
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
