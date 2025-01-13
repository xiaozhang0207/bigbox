class AddressModel {
  final int? id;
  final String? type;
  final String? address;

  AddressModel({
    this.id,
    this.type,
    this.address,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json["id"] ?? 0,
        type: json["type"] ?? '',
        address: json["address"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "address": address,
      };
}
