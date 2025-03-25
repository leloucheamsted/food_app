// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  int? status;
  String? message;
  List<Result>? result;

  ProfileModel({
    this.status,
    this.message,
    this.result,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  String? firebaseId;
  String? channelId;
  String? channelName;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  int? type;
  String? image;
  String? coverImg;
  String? description;
  int? deviceType;
  String? deviceToken;
  String? website;
  String? facebookUrl;
  String? instagramUrl;
  String? twitterUrl;
  int? walletBalance;
  int? walletEarning;
  String? bankName;
  String? bankCode;
  String? bankAddress;
  String? ifscNo;
  String? accountNo;
  String? idProof;
  String? address;
  String? city;
  String? state;
  String? country;
  int? pincode;
  List<Field>? field1;
  List<Field>? field2;
  List<Field>? field3;
  List<Field>? field4;
  List<Field>? field5;
  int? userPenalStatus;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  int? isBlock;
  int? totalContent;
  int? totalSubscriber;
  int? totalSubscribe;
  int? isSubscriber;
  String? packageName;
  int? packagePrice;
  String? packageImage;
  int? adsFree;
  int? isDownload;
  int? veriflyArtist;
  int? veriflyAccount;
  List<SocialLink>? socialLink;
  List<UserBadge>? userBadge;

  Result({
    this.id,
    this.firebaseId,
    this.channelId,
    this.channelName,
    this.fullName,
    this.email,
    this.countryCode,
    this.mobileNumber,
    this.countryName,
    this.type,
    this.image,
    this.coverImg,
    this.description,
    this.deviceType,
    this.deviceToken,
    this.website,
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.walletBalance,
    this.walletEarning,
    this.bankName,
    this.bankCode,
    this.bankAddress,
    this.ifscNo,
    this.accountNo,
    this.idProof,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.field1,
    this.field2,
    this.field3,
    this.field4,
    this.field5,
    this.userPenalStatus,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isBuy,
    this.isBlock,
    this.totalContent,
    this.totalSubscriber,
    this.totalSubscribe,
    this.isSubscriber,
    this.packageName,
    this.packagePrice,
    this.packageImage,
    this.adsFree,
    this.isDownload,
    this.veriflyArtist,
    this.veriflyAccount,
    this.socialLink,
    this.userBadge,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        firebaseId: json["firebase_id"],
        channelId: json["channel_id"],
        channelName: json["channel_name"],
        fullName: json["full_name"],
        email: json["email"],
        countryCode: json["country_code"],
        mobileNumber: json["mobile_number"],
        countryName: json["country_name"],
        type: json["type"],
        image: json["image"],
        coverImg: json["cover_img"],
        description: json["description"],
        deviceType: json["device_type"],
        deviceToken: json["device_token"],
        website: json["website"],
        facebookUrl: json["facebook_url"],
        instagramUrl: json["instagram_url"],
        twitterUrl: json["twitter_url"],
        walletBalance: json["wallet_balance"],
        walletEarning: json["wallet_earning"],
        bankName: json["bank_name"],
        bankCode: json["bank_code"],
        bankAddress: json["bank_address"],
        ifscNo: json["ifsc_no"],
        accountNo: json["account_no"],
        idProof: json["id_proof"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        pincode: json["pincode"],
        field1: json["field_1"] == null ? [] : List<Field>.from(json["field_1"]?.map((x) => Field.fromJson(x)) ?? []),
        field2: json["field_2"] == null ? [] : List<Field>.from(json["field_2"]?.map((x) => Field.fromJson(x)) ?? []),
        field3: json["field_3"] == null ? [] : List<Field>.from(json["field_3"]?.map((x) => Field.fromJson(x)) ?? []),
        field4: json["field_4"] == null ? [] : List<Field>.from(json["field_4"]?.map((x) => Field.fromJson(x)) ?? []),
        field5: json["field_5"] == null ? [] : List<Field>.from(json["field_5"]?.map((x) => Field.fromJson(x)) ?? []),
        userPenalStatus: json["user_penal_status"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
        isBlock: json["is_block"],
        totalContent: json["total_content"],
        totalSubscriber: json["total_subscriber"],
        totalSubscribe: json["total_subscribe"],
        isSubscriber: json["is_subscriber"],
        packageName: json["package_name"],
        packagePrice: json["package_price"],
        packageImage: json["package_image"],
        adsFree: json["ads_free"],
        isDownload: json["is_download"],
        veriflyArtist: json["verifly_artist"],
        veriflyAccount: json["verifly_account"],
        socialLink: json["social_link"] == null
            ? []
            : List<SocialLink>.from(json["social_link"]?.map((x) => SocialLink.fromJson(x)) ?? []),
        userBadge: json["user_badge"] == null
            ? []
            : List<UserBadge>.from(json["user_badge"]!.map((x) => UserBadge.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firebase_id": firebaseId,
        "channel_id": channelId,
        "channel_name": channelName,
        "full_name": fullName,
        "email": email,
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "country_name": countryName,
        "type": type,
        "image": image,
        "cover_img": coverImg,
        "description": description,
        "device_type": deviceType,
        "device_token": deviceToken,
        "website": website,
        "facebook_url": facebookUrl,
        "instagram_url": instagramUrl,
        "twitter_url": twitterUrl,
        "wallet_balance": walletBalance,
        "wallet_earning": walletEarning,
        "bank_name": bankName,
        "bank_code": bankCode,
        "bank_address": bankAddress,
        "ifsc_no": ifscNo,
        "account_no": accountNo,
        "id_proof": idProof,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "pincode": pincode,
        "field_1": field1 == null ? [] : List<dynamic>.from(field1?.map((x) => x.toJson()) ?? []),
        "field_2": field2 == null ? [] : List<dynamic>.from(field2?.map((x) => x.toJson()) ?? []),
        "field_3": field3 == null ? [] : List<dynamic>.from(field3?.map((x) => x.toJson()) ?? []),
        "field_4": field4 == null ? [] : List<dynamic>.from(field4?.map((x) => x.toJson()) ?? []),
        "field_5": field5 == null ? [] : List<dynamic>.from(field5?.map((x) => x.toJson()) ?? []),
        "user_penal_status": userPenalStatus,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "is_block": isBlock,
        "total_content": totalContent,
        "total_subscriber": totalSubscriber,
        "total_subscribe": totalSubscribe,
        "is_subscriber": isSubscriber,
        "package_name": packageName,
        "package_price": packagePrice,
        "package_image": packageImage,
        "ads_free": adsFree,
        "is_download": isDownload,
        "verifly_artist": veriflyArtist,
        "verifly_account": veriflyAccount,
        "social_link": socialLink == null ? [] : List<dynamic>.from(socialLink?.map((x) => x.toJson()) ?? []),
        "user_badge": userBadge == null ? [] : List<dynamic>.from(userBadge!.map((x) => x.toJson())),
      };
}

class Field {
  String? text;
  String? icon;
  String? oldImage;

  Field({
    this.text,
    this.icon,
    this.oldImage,
  });

  factory Field.fromJson(Map<String, dynamic> json) => Field(
        text: json["text"],
        icon: json["icon"],
        oldImage: json["old_image"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "icon": icon,
        "old_image": oldImage,
      };
}

class SocialLink {
  int? id;
  int? socialMediaId;
  String? name;
  String? url;
  String? image;

  SocialLink({
    this.id,
    this.socialMediaId,
    this.name,
    this.url,
    this.image,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
        id: json["id"],
        socialMediaId: json["social_media_id"],
        name: json["name"],
        url: json["url"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "social_media_id": socialMediaId,
        "name": name,
        "url": url,
        "image": image,
      };
}

class UserBadge {
  int? id;
  int? badgeId;
  int? userId;
  String? image;

  UserBadge({
    this.id,
    this.badgeId,
    this.userId,
    this.image,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) => UserBadge(
        id: json["id"],
        badgeId: json["badge_id"],
        userId: json["user_id"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "badge_id": badgeId,
        "user_id": userId,
        "image": image,
      };
}
