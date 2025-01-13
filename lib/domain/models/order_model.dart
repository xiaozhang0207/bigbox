class OrderModel {
  final int? id;
  final int? userId;
  final String? barCode;
  final String? containerNo;
  final String? title;
  final String? phone;
  final String? qr;
  final int? type;
  bool? hasDelivery;
  String? deliveryAddress;
  final double? price;
  final String? desc;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.id,
    this.userId,
    this.barCode,
    this.containerNo,
    this.title,
    this.phone,
    this.qr,
    this.type,
    this.hasDelivery,
    this.deliveryAddress,
    this.price,
    this.desc,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json["id"] ?? 0,
        userId: json["userId"],
        barCode: json["barCode"] ?? "",
        containerNo: json["containerNo"] ?? "",
        title: json["title"] ?? "",
        phone: json["phone"] ?? "",
        qr: json["qr"] ?? "",
        type: json["type"] ?? 0,
        hasDelivery: json["hasDelivery"] ?? false,
        deliveryAddress: json["deliveryAddress"] ?? "",
        price: (json["price"] ?? 0) * 1.0,
        desc: json["desc"] ?? "",
        createdAt: (json["createdAt"] ?? "") == ""
            ? DateTime.now()
            : DateTime.parse(json["createdAt"]),
        updatedAt: (json["updatedAt"] ?? "") == ""
            ? DateTime.now()
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "barCode": barCode,
        "containerNo": containerNo,
        "title": title,
        "phone": phone,
        "qr": qr,
        "type": type,
        "hasDelivery": hasDelivery,
        "deliveryAddress": deliveryAddress,
        "price": price,
        "desc": desc,
        "createdAt": createdAt.toString(),
        "updatedAt": updatedAt.toString(),
      };
}
