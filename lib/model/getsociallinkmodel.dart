// To parse this JSON data, do
//
//     final getSocialLinkModel = getSocialLinkModelFromJson(jsonString);

import 'dart:convert';

GetSocialLinkModel getSocialLinkModelFromJson(String str) => GetSocialLinkModel.fromJson(json.decode(str));

String getSocialLinkModelToJson(GetSocialLinkModel data) => json.encode(data.toJson());

class GetSocialLinkModel {
    int? status;
    String? message;
    List<Result>? result;

    GetSocialLinkModel({
        this.status,
        this.message,
        this.result,
    });

    factory GetSocialLinkModel.fromJson(Map<String, dynamic> json) => GetSocialLinkModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
    };
}

class Result {
    int? id;
    String? name;
    String? image;
    int? status;
    String? createdAt;
    String? updatedAt;

    Result({
        this.id,
        this.name,
        this.image,
        this.status,
        this.createdAt,
        this.updatedAt,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}
