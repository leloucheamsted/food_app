// To parse this JSON data, do
//
//     final feedDetailModel = feedDetailModelFromJson(jsonString);

import 'dart:convert';

FeedDetailModel feedDetailModelFromJson(String str) =>
    FeedDetailModel.fromJson(json.decode(str));

String feedDetailModelToJson(FeedDetailModel data) =>
    json.encode(data.toJson());

class FeedDetailModel {
  int? status;
  String? message;
  List<Result>? result;

  FeedDetailModel({
    this.status,
    this.message,
    this.result,
  });

  factory FeedDetailModel.fromJson(Map<String, dynamic> json) =>
      FeedDetailModel(
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
  String? channelId;
  int? categoryId;
  String? hashtagId;
  String? title;
  String? descripation;
  int? isComment;
  int? view;
  int? totalLike;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<PostContent>? postContent;
  List<Hasteg>? hastegs;
  int? userId;
  String? firebaseId;
  String? channelName;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  String? profileImg;
  int? totalComment;
  int? ifood_app;
  int? isSubscriber;
  int? isBuy;

  Result({
    this.id,
    this.channelId,
    this.categoryId,
    this.hashtagId,
    this.title,
    this.descripation,
    this.isComment,
    this.view,
    this.totalLike,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.postContent,
    this.hastegs,
    this.userId,
    this.firebaseId,
    this.channelName,
    this.fullName,
    this.email,
    this.countryCode,
    this.mobileNumber,
    this.countryName,
    this.profileImg,
    this.totalComment,
    this.ifood_app,
    this.isSubscriber,
    this.isBuy,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        hashtagId: json["hashtag_id"],
        title: json["title"],
        descripation: json["descripation"],
        isComment: json["is_comment"],
        view: json["view"],
        totalLike: json["total_like"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        postContent: json["post_content"] == null
            ? []
            : List<PostContent>.from(
                json["post_content"]?.map((x) => PostContent.fromJson(x)) ??
                    []),
        hastegs: json["hastegs"] == null
            ? []
            : List<Hasteg>.from(
                json["hastegs"]?.map((x) => Hasteg.fromJson(x)) ?? []),
        userId: json["user_id"],
        firebaseId: json["firebase_id"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        email: json["email"],
        countryCode: json["country_code"],
        mobileNumber: json["mobile_number"],
        countryName: json["country_name"],
        profileImg: json["profile_img"],
        totalComment: json["total_comment"],
        ifood_app: json["is_like"],
        isSubscriber: json["is_subscriber"],
        isBuy: json["is_buy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "channel_id": channelId,
        "category_id": categoryId,
        "hashtag_id": hashtagId,
        "title": title,
        "descripation": descripation,
        "is_comment": isComment,
        "view": view,
        "total_like": totalLike,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "post_content": postContent == null
            ? []
            : List<dynamic>.from(postContent?.map((x) => x.toJson()) ?? []),
        "hastegs": hastegs == null
            ? []
            : List<dynamic>.from(hastegs?.map((x) => x.toJson()) ?? []),
        "user_id": userId,
        "firebase_id": firebaseId,
        "channel_name": channelName,
        "full_name": fullName,
        "email": email,
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "country_name": countryName,
        "profile_img": profileImg,
        "total_comment": totalComment,
        "is_like": ifood_app,
        "is_subscriber": isSubscriber,
        "is_buy": isBuy,
      };
}

class Hasteg {
  int? id;
  String? name;
  int? totalUsed;
  int? status;
  String? createdAt;
  String? updatedAt;

  Hasteg({
    this.id,
    this.name,
    this.totalUsed,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Hasteg.fromJson(Map<String, dynamic> json) => Hasteg(
        id: json["id"],
        name: json["name"],
        totalUsed: json["total_used"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "total_used": totalUsed,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class PostContent {
  int? id;
  int? postId;
  int? contentType;
  String? contentUrl;
  String? thumbnailImage;
  int? status;
  String? createdAt;
  String? updatedAt;

  PostContent({
    this.id,
    this.postId,
    this.contentType,
    this.contentUrl,
    this.thumbnailImage,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PostContent.fromJson(Map<String, dynamic> json) => PostContent(
        id: json["id"],
        postId: json["post_id"],
        contentType: json["content_type"],
        contentUrl: json["content_url"],
        thumbnailImage: json["thumbnail_image"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "post_id": postId,
        "content_type": contentType,
        "content_url": contentUrl,
        "thumbnail_image": thumbnailImage,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
