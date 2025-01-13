class LogModel {
  final String date;
  final String total;

  LogModel({
    required this.date,
    required this.total,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        date: json["date"] ?? '',
        total: json["total"] ?? '0',
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "total": total,
      };
}
