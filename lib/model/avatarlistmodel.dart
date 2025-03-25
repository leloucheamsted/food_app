// To parse this JSON data, do
//
//     final avatatListModel = avatatListModelFromJson(jsonString);

import 'dart:convert';

AvatatListModel avatatListModelFromJson(String str) =>
    AvatatListModel.fromJson(json.decode(str));

String avatatListModelToJson(AvatatListModel data) =>
    json.encode(data.toJson());

class AvatatListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  AvatatListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory AvatatListModel.fromJson(Map<String, dynamic> json) =>
      AvatatListModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  String? name;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? imageName;

  Result({
    this.id,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.imageName,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        imageName: json["image_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "image_name": imageName,
      };
}
