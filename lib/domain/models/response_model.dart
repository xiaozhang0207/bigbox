class ResponseModel {
  final int? status;
  final bool? success;
  final String? message;
  final String? otp;
  final dynamic data;

  ResponseModel({
    this.status,
    this.success,
    this.message,
    this.otp,
    this.data,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(
        status: json["status"] ?? 301,
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        otp: json["otp"] ?? '',
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "message": message,
        "otp": otp,
        "data": data,
      };
}
