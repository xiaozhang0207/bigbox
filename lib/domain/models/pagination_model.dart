class PaginationModel {
  final int? total;
  final int? pageCount;
  final int? start;
  final int? end;
  final int? limit;
  final int? nextPage;
  final int? prevPage;

  PaginationModel({
    this.total,
    this.pageCount,
    this.start,
    this.end,
    this.limit,
    this.nextPage,
    this.prevPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      PaginationModel(
        total: json["total"] == null ? 0 : json["total"] ?? 0,
        pageCount: json["pageCount"] == null ? 0 : json["pageCount"] ?? 0,
        start: json["start"] == null ? 0 : json["start"] ?? 0,
        end: json["end"] == null ? 0 : json["end"] ?? 0,
        limit: json["limit"] == null ? 0 : json["limit"] ?? 0,
        nextPage: json["nextPage"] == null ? 0 : json["nextPage"] ?? 0,
        prevPage: json["prevPage"] == null ? 0 : json["prevPage"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "pageCount": pageCount,
        "start": start,
        "end": end,
        "limit": limit,
        "nextPage": nextPage,
        "prevPage": prevPage,
      };
}
