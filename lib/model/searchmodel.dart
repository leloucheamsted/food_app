// To parse this JSON data, do
//
//     final searchModel = searchModelFromJson(jsonString);

import 'dart:convert';

SearchModel searchModelFromJson(String str) =>
    SearchModel.fromJson(json.decode(str));

String searchModelToJson(SearchModel data) => json.encode(data.toJson());

class SearchModel {
  int? status;
  String? message;
  List<Result>? result;
  List<dynamic>? video;
  List<Channel>? channel;
  List<dynamic>? music;
  List<dynamic>? podcast;
  List<dynamic>? radio;
  List<Reel>? reels;

  SearchModel({
    this.status,
    this.message,
    this.result,
    this.video,
    this.channel,
    this.music,
    this.podcast,
    this.radio,
    this.reels,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
        video: json["video"] == null
            ? []
            : List<dynamic>.from(json["video"]?.map((x) => x) ?? []),
        channel: json["channel"] == null
            ? []
            : List<Channel>.from(
                json["channel"]?.map((x) => Channel.fromJson(x)) ?? []),
        music: json["music"] == null
            ? []
            : List<dynamic>.from(json["music"]?.map((x) => x) ?? []),
        podcast: json["podcast"] == null
            ? []
            : List<dynamic>.from(json["podcast"]?.map((x) => x) ?? []),
        radio: json["radio"] == null
            ? []
            : List<dynamic>.from(json["radio"]?.map((x) => x) ?? []),
        reels: json["reels"] == null
            ? []
            : List<Reel>.from(
                json["reels"]?.map((x) => Reel.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "video":
            video == null ? [] : List<dynamic>.from(video?.map((x) => x) ?? []),
        "channel": channel == null
            ? []
            : List<dynamic>.from(channel?.map((x) => x.toJson()) ?? []),
        "music":
            music == null ? [] : List<dynamic>.from(music?.map((x) => x) ?? []),
        "podcast": podcast == null
            ? []
            : List<dynamic>.from(podcast?.map((x) => x) ?? []),
        "radio":
            radio == null ? [] : List<dynamic>.from(radio?.map((x) => x) ?? []),
        "reels": reels == null
            ? []
            : List<dynamic>.from(reels?.map((x) => x.toJson()) ?? []),
      };
}

class Channel {
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
  dynamic field1;
  dynamic field2;
  dynamic field3;
  dynamic field4;
  dynamic field5;
  int? userPenalStatus;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  int? isChannel;

  Channel({
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
    this.isChannel,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
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
        field1: json["field_1"],
        field2: json["field_2"],
        field3: json["field_3"],
        field4: json["field_4"],
        field5: json["field_5"],
        userPenalStatus: json["user_penal_status"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
        isChannel: json["is_channel"],
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
        "field_1": field1,
        "field_2": field2,
        "field_3": field3,
        "field_4": field4,
        "field_5": field5,
        "user_penal_status": userPenalStatus,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "is_channel": isChannel,
      };
}

class Reel {
  int? id;
  int? contentType;
  String? channelId;
  int? categoryId;
  int? languageId;
  int? artistId;
  String? hashtagId;
  String? title;
  String? description;
  String? portraitImg;
  String? landscapeImg;
  String? watermarkImg;
  String? contentUploadType;
  String? content;
  String? contentSize;
  int? contentDuration;
  int? isRent;
  int? rentPrice;
  int? isComment;
  int? isDownload;
  int? ifood_app;
  int? totalView;
  int? totalLike;
  int? totalDifood_app;
  int? playlistType;
  int? isAdminAdded;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? userId;
  String? channelName;
  String? channelImage;
  int? isBuy;
  int? totalComment;
  int? isUserLikeDifood_app;
  int? isSubscribe;
  int? isChannel;

  Reel({
    this.id,
    this.contentType,
    this.channelId,
    this.categoryId,
    this.languageId,
    this.artistId,
    this.hashtagId,
    this.title,
    this.description,
    this.portraitImg,
    this.landscapeImg,
    this.watermarkImg,
    this.contentUploadType,
    this.content,
    this.contentSize,
    this.contentDuration,
    this.isRent,
    this.rentPrice,
    this.isComment,
    this.isDownload,
    this.ifood_app,
    this.totalView,
    this.totalLike,
    this.totalDifood_app,
    this.playlistType,
    this.isAdminAdded,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.channelName,
    this.channelImage,
    this.isBuy,
    this.totalComment,
    this.isUserLikeDifood_app,
    this.isSubscribe,
    this.isChannel,
  });

  factory Reel.fromJson(Map<String, dynamic> json) => Reel(
        id: json["id"],
        contentType: json["content_type"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        artistId: json["artist_id"],
        hashtagId: json["hashtag_id"],
        title: json["title"],
        description: json["description"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        watermarkImg: json["watermark_img"],
        contentUploadType: json["content_upload_type"],
        content: json["content"],
        contentSize: json["content_size"],
        contentDuration: json["content_duration"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isComment: json["is_comment"],
        isDownload: json["is_download"],
        ifood_app: json["is_like"],
        totalView: json["total_view"],
        totalLike: json["total_like"],
        totalDifood_app: json["total_difood_app"],
        playlistType: json["playlist_type"],
        isAdminAdded: json["is_admin_added"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userId: json["user_id"],
        channelName: json["channel_name"],
        channelImage: json["channel_image"],
        isBuy: json["is_buy"],
        totalComment: json["total_comment"],
        isUserLikeDifood_app: json["is_user_like_difood_app"],
        isSubscribe: json["is_subscribe"],
        isChannel: json["is_channel"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_type": contentType,
        "channel_id": channelId,
        "category_id": categoryId,
        "language_id": languageId,
        "artist_id": artistId,
        "hashtag_id": hashtagId,
        "title": title,
        "description": description,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "watermark_img": watermarkImg,
        "content_upload_type": contentUploadType,
        "content": content,
        "content_size": contentSize,
        "content_duration": contentDuration,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_comment": isComment,
        "is_download": isDownload,
        "is_like": ifood_app,
        "total_view": totalView,
        "total_like": totalLike,
        "total_difood_app": totalDifood_app,
        "playlist_type": playlistType,
        "is_admin_added": isAdminAdded,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_id": userId,
        "channel_name": channelName,
        "channel_image": channelImage,
        "is_buy": isBuy,
        "total_comment": totalComment,
        "is_user_like_difood_app": isUserLikeDifood_app,
        "is_subscribe": isSubscribe,
        "is_channel": isChannel,
      };
}

class Result {
  int? id;
  int? contentType;
  String? channelId;
  int? categoryId;
  int? languageId;
  int? artistId;
  String? hashtagId;
  String? title;
  String? description;
  String? portraitImg;
  String? landscapeImg;
  String? watermarkImg;
  String? contentUploadType;
  String? content;
  String? contentSize;
  int? contentDuration;
  int? isRent;
  int? rentPrice;
  int? isComment;
  int? isDownload;
  int? ifood_app;
  int? totalView;
  int? totalLike;
  int? totalDifood_app;
  int? playlistType;
  int? isAdminAdded;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? userId;
  String? channelName;
  String? channelImage;
  int? isBuy;
  int? totalComment;
  int? isUserLikeDifood_app;
  int? isSubscribe;
  int? isChannel;
  String? firebaseId;
  String? fullName;
  String? email;
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  int? type;
  String? image;
  String? coverImg;
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
  dynamic field1;
  dynamic field2;
  dynamic field3;
  dynamic field4;
  dynamic field5;
  int? userPenalStatus;

  Result({
    this.id,
    this.contentType,
    this.channelId,
    this.categoryId,
    this.languageId,
    this.artistId,
    this.hashtagId,
    this.title,
    this.description,
    this.portraitImg,
    this.landscapeImg,
    this.watermarkImg,
    this.contentUploadType,
    this.content,
    this.contentSize,
    this.contentDuration,
    this.isRent,
    this.rentPrice,
    this.isComment,
    this.isDownload,
    this.ifood_app,
    this.totalView,
    this.totalLike,
    this.totalDifood_app,
    this.playlistType,
    this.isAdminAdded,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.channelName,
    this.channelImage,
    this.isBuy,
    this.totalComment,
    this.isUserLikeDifood_app,
    this.isSubscribe,
    this.isChannel,
    this.firebaseId,
    this.fullName,
    this.email,
    this.countryCode,
    this.mobileNumber,
    this.countryName,
    this.type,
    this.image,
    this.coverImg,
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
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        contentType: json["content_type"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        artistId: json["artist_id"],
        hashtagId: json["hashtag_id"],
        title: json["title"],
        description: json["description"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        watermarkImg: json["watermark_img"],
        contentUploadType: json["content_upload_type"],
        content: json["content"],
        contentSize: json["content_size"],
        contentDuration: json["content_duration"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isComment: json["is_comment"],
        isDownload: json["is_download"],
        ifood_app: json["is_like"],
        totalView: json["total_view"],
        totalLike: json["total_like"],
        totalDifood_app: json["total_difood_app"],
        playlistType: json["playlist_type"],
        isAdminAdded: json["is_admin_added"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userId: json["user_id"],
        channelName: json["channel_name"],
        channelImage: json["channel_image"],
        isBuy: json["is_buy"],
        totalComment: json["total_comment"],
        isUserLikeDifood_app: json["is_user_like_difood_app"],
        isSubscribe: json["is_subscribe"],
        isChannel: json["is_channel"],
        firebaseId: json["firebase_id"],
        fullName: json["full_name"],
        email: json["email"],
        countryCode: json["country_code"],
        mobileNumber: json["mobile_number"],
        countryName: json["country_name"],
        type: json["type"],
        image: json["image"],
        coverImg: json["cover_img"],
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
        field1: json["field_1"],
        field2: json["field_2"],
        field3: json["field_3"],
        field4: json["field_4"],
        field5: json["field_5"],
        userPenalStatus: json["user_penal_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_type": contentType,
        "channel_id": channelId,
        "category_id": categoryId,
        "language_id": languageId,
        "artist_id": artistId,
        "hashtag_id": hashtagId,
        "title": title,
        "description": description,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "watermark_img": watermarkImg,
        "content_upload_type": contentUploadType,
        "content": content,
        "content_size": contentSize,
        "content_duration": contentDuration,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_comment": isComment,
        "is_download": isDownload,
        "is_like": ifood_app,
        "total_view": totalView,
        "total_like": totalLike,
        "total_difood_app": totalDifood_app,
        "playlist_type": playlistType,
        "is_admin_added": isAdminAdded,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_id": userId,
        "channel_name": channelName,
        "channel_image": channelImage,
        "is_buy": isBuy,
        "total_comment": totalComment,
        "is_user_like_difood_app": isUserLikeDifood_app,
        "is_subscribe": isSubscribe,
        "is_channel": isChannel,
        "firebase_id": firebaseId,
        "full_name": fullName,
        "email": email,
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "country_name": countryName,
        "type": type,
        "image": image,
        "cover_img": coverImg,
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
        "field_1": field1,
        "field_2": field2,
        "field_3": field3,
        "field_4": field4,
        "field_5": field5,
        "user_penal_status": userPenalStatus,
      };
}
