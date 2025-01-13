class UserModel {
  final int? id;
  String? lastName;
  String? firstName;
  int? permissionId;
  String? email;
  final String? phone;
  String? avatar;
  bool? status;
  final String? primaryColor;
  final String? accessToken;
  String? deviceToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.lastName,
    this.firstName,
    this.permissionId,
    this.email,
    this.phone,
    this.avatar,
    this.primaryColor,
    this.accessToken,
    this.status,
    this.deviceToken,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"] ?? 0,
        lastName: json["lastName"] ?? "",
        firstName: json["firstName"] ?? "",
        permissionId: json["permissionId"] ?? 0,
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        avatar: json["avatar"] ?? "",
        status: json["status"] ?? false,
        primaryColor: json["primaryColor"] ?? "",
        accessToken: json["accessToken"] ?? "",
        deviceToken: json["deviceToken"] ?? "",
        createdAt: (json["createdAt"] ?? "") == ""
            ? DateTime.now()
            : DateTime.parse(json["createdAt"]),
        updatedAt: (json["updatedAt"] ?? "") == ""
            ? DateTime.now()
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lastName": lastName,
        "firstName": firstName,
        "permissionId": permissionId,
        "email": email,
        "phone": phone,
        "avatar": avatar,
        "status": status,
        "primaryColor": primaryColor,
        "accessToken": accessToken,
        "deviceToken": deviceToken,
        "createdAt": createdAt.toString(),
        "updatedAt": updatedAt.toString(),
      };
}
