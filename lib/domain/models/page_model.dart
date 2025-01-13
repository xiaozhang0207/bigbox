class PageModel {
  final int? id;
  final String? type;
  final String? data;
  final bool? isActive;

  PageModel({
    this.id,
    this.type,
    this.data,
    this.isActive,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
        id: json["id"] ?? 0,
        type: json["type"] ?? '',
        data: json["data"] ?? '',
        isActive: json["isActive"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "data": data,
        "isActive": isActive,
      };
}
