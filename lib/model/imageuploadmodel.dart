// To parse this JSON data, do
//
//     final imageUploadModel = imageUploadModelFromJson(jsonString);

import 'dart:convert';

ImageUploadModel imageUploadModelFromJson(String str) =>
    ImageUploadModel.fromJson(json.decode(str));

String imageUploadModelToJson(ImageUploadModel data) =>
    json.encode(data.toJson());

class ImageUploadModel {
  int? status;
  String? message;
  Result? result;

  ImageUploadModel({
    this.status,
    this.message,
    this.result,
  });

  factory ImageUploadModel.fromJson(Map<String, dynamic> json) =>
      ImageUploadModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson(),
      };
}

class Result {
  String? imageName;
  String? imageUrl;

  Result({
    this.imageName,
    this.imageUrl,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        imageName: json["image_name"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "image_name": imageName,
        "image_url": imageUrl,
      };
}
