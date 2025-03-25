// To parse this JSON data, do
//
//     final marketPlaceDetailModel = marketPlaceDetailModelFromJson(jsonString);

import 'dart:convert';

MarketPlaceDetailModel marketPlaceDetailModelFromJson(String str) =>
    MarketPlaceDetailModel.fromJson(json.decode(str));

String marketPlaceDetailModelToJson(MarketPlaceDetailModel data) =>
    json.encode(data.toJson());

class MarketPlaceDetailModel {
  int? status;
  String? message;
  List<Result>? result;

  MarketPlaceDetailModel({
    this.status,
    this.message,
    this.result,
  });

  factory MarketPlaceDetailModel.fromJson(Map<String, dynamic> json) =>
      MarketPlaceDetailModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  int? userId;
  int? categoryId;
  String? name;
  String? price;
  String? image;
  String? url;
  String? descripation;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isSubscribe;
  String? userChannelId;
  String? userChannelName;
  String? userName;
  String? userEmail;
  String? userCountryCode;
  String? userMobileNumber;
  String? userCountryName;
  String? userImage;

  Result({
    this.id,
    this.userId,
    this.categoryId,
    this.name,
    this.price,
    this.image,
    this.url,
    this.descripation,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isSubscribe,
    this.userChannelId,
    this.userChannelName,
    this.userName,
    this.userEmail,
    this.userCountryCode,
    this.userMobileNumber,
    this.userCountryName,
    this.userImage,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        categoryId: json["category_id"],
        name: json["name"],
        price: json["price"],
        image: json["image"],
        url: json["url"],
        descripation: json["descripation"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isSubscribe: json["is_subscribe"],
        userChannelId: json["user_channel_id"],
        userChannelName: json["user_channel_name"],
        userName: json["user_name"],
        userEmail: json["user_email"],
        userCountryCode: json["user_country_code"],
        userMobileNumber: json["user_mobile_number"],
        userCountryName: json["user_country_name"],
        userImage: json["user_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "category_id": categoryId,
        "name": name,
        "price": price,
        "image": image,
        "url": url,
        "descripation": descripation,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_subscribe": isSubscribe,
        "user_channel_id": userChannelId,
        "user_channel_name": userChannelName,
        "user_name": userName,
        "user_email": userEmail,
        "user_country_code": userCountryCode,
        "user_mobile_number": userMobileNumber,
        "user_country_name": userCountryName,
        "user_image": userImage,
      };
}
