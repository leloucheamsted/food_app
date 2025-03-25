import 'feeddetailmodel.dart';

class FeedDetailAndRelatedContentModel {
  final int? status;
  final String? message;
  final List<Result>? result;

  FeedDetailAndRelatedContentModel({
    this.status,
    this.message,
    this.result,
  });

  FeedDetailAndRelatedContentModel.fromJson(Map<String, dynamic> json)
      : status = json['status'] as int?,
        message = json['message'] as String?,
        result = (json['result'] as List?)
            ?.map((dynamic e) => Result.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'result': result?.map((e) => e.toJson()).toList()
      };
}

class Result {
  final int? id;
  final String? channelId;
  final int? categoryId;
  final String? hashtagId;
  final String? title;
  final String? watermarkImg;
  final String? descripation;
  final int? isComment;
  final int? view;
  late int? totalLike;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final List<PostContent>? postContent;
  final List<Hasteg>? hastegs;
  final int? userId;
  final String? firebaseId;
  final String? channelName;
  final String? fullName;
  final String? email;
  final String? countryCode;
  final String? mobileNumber;
  final String? countryName;
  final String? profileImg;
  late int totalComment;
  late int? ifood_app;
  late int? isSubscriber;
  final int? isBuy;

  Result({
    this.id,
    this.channelId,
    this.categoryId,
    this.hashtagId,
    this.title,
    this.watermarkImg,
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
    this.totalComment = 0,
    this.ifood_app,
    this.isSubscriber,
    this.isBuy,
  });

  Result.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        channelId = json['channel_id'] as String?,
        categoryId = json['category_id'] as int?,
        hashtagId = json['hashtag_id'] as String?,
        title = json['title'] as String?,
        watermarkImg = json['watermark_img'] as String?,
        descripation = json['descripation'] as String?,
        isComment = json['is_comment'] as int?,
        view = json['view'] as int?,
        totalLike = json['total_like'] as int?,
        status = json['status'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        postContent = (json['post_content'] as List?)
            ?.map(
                (dynamic e) => PostContent.fromJson(e as Map<String, dynamic>))
            .toList(),
        hastegs = json["hastegs"] == null
            ? []
            : List<Hasteg>.from(
                json["hastegs"]?.map((x) => Hasteg.fromJson(x)) ?? []),
        userId = json['user_id'] as int?,
        firebaseId = json['firebase_id'] as String?,
        channelName = json['channel_name'] as String?,
        fullName = json['full_name'] as String?,
        email = json['email'] as String?,
        countryCode = json['country_code'] as String?,
        mobileNumber = json['mobile_number'] as String?,
        countryName = json['country_name'] as String?,
        profileImg = json['profile_img'] as String?,
        totalComment = json['total_comment'] ?? 0,
        ifood_app = json['is_like'] as int?,
        isSubscriber = json['is_subscriber'] as int?,
        isBuy = json['is_buy'] as int?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel_id': channelId,
        'category_id': categoryId,
        'hashtag_id': hashtagId,
        'title': title,
        'watermark_img': watermarkImg,
        'descripation': descripation,
        'is_comment': isComment,
        'view': view,
        'total_like': totalLike,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'post_content': postContent?.map((e) => e.toJson()).toList(),
        'hastegs': hastegs == null
            ? []
            : List<dynamic>.from(hastegs?.map((x) => x.toJson()) ?? []),
        'user_id': userId,
        'firebase_id': firebaseId,
        'channel_name': channelName,
        'full_name': fullName,
        'email': email,
        'country_code': countryCode,
        'mobile_number': mobileNumber,
        'country_name': countryName,
        'profile_img': profileImg,
        'total_comment': totalComment,
        'is_like': ifood_app,
        'is_subscriber': isSubscriber,
        'is_buy': isBuy
      };
}

class PostContent {
  final int? id;
  final int? postId;
  final int? contentType;
  final String? contentUrl;
  final String? thumbnailImage;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

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

  PostContent.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        postId = json['post_id'] as int?,
        contentType = json['content_type'] as int?,
        contentUrl = json['content_url'] as String?,
        thumbnailImage = json['thumbnail_image'] as String?,
        status = json['status'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'content_type': contentType,
        'content_url': contentUrl,
        'thumbnail_image': thumbnailImage,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
