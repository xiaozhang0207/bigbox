class NotificationModel {
  final int id;
  final String type;
  final String body;
  bool isShow;
  final int? oId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.body,
    required this.isShow,
    this.oId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"] ?? 0,
        type: json["type"] ?? '',
        body: json["body"] ?? '',
        isShow: json["isShow"] ?? false,
        oId: (json["oId"] ?? 0) ?? 0,
        createdAt: (json["createdAt"] ?? "") == ""
            ? DateTime.now()
            : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "body": body,
        "isShow": isShow,
        "oId": oId,
        "createdAt": createdAt.toString(),
      };
}
