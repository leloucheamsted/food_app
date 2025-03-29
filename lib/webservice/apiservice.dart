import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:slike/firebase_options.dart';
import 'package:slike/model/addcommentmodel.dart';
import 'package:slike/model/addcontentreportmodel.dart';
import 'package:slike/model/addcontenttohistorymodel.dart';
import 'package:slike/model/addremoveblockchannelmodel.dart';
import 'package:slike/model/avatarlistmodel.dart';
import 'package:slike/model/chatusermodel.dart';
import 'package:slike/model/download_item.dart';
import 'package:slike/model/feeddetailmodel.dart';
import 'package:slike/model/fetchgiftmodel.dart';
import 'package:slike/model/getchannelfeedmodel.dart';
import 'package:slike/model/getpostcommentmodel.dart';
import 'package:slike/model/getsociallinkmodel.dart';
import 'package:slike/model/getusermarketplacemodel.dart';
import 'package:slike/model/imageuploadmodel.dart';
import 'package:slike/model/introscreenmodel.dart';
import 'package:slike/model/liveuserlistmodel.dart';
import 'package:slike/model/marketplacedetailmodel.dart';
import 'package:slike/model/marketplacemodel.dart';
import 'package:slike/model/postcontentuploadmodel.dart';
import 'package:slike/model/postmodel.dart';
import 'package:slike/model/sociallinkmodel.dart';
import 'package:slike/model/subscribechannelpostmodel.dart';
import 'package:slike/model/subscriberlistmodel.dart';
import 'package:slike/provider/downloadprovider.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/model/addremovesubscribemodel.dart';
import 'package:slike/model/addremovewatchlatermodel.dart';
import 'package:slike/model/addviewmodel.dart';
import 'package:slike/model/adspackagemodel.dart';
import 'package:slike/model/adspackagetransectionmodel.dart';
import 'package:slike/model/deletecommentmodel.dart';
import 'package:slike/model/deleteplaylistmodel.dart';
import 'package:slike/model/editplaylistmodel.dart';
import 'package:slike/model/episodebyplaylistmodel.dart';
import 'package:slike/model/episodebypodcastmodel.dart';
import 'package:slike/model/episodebyradio.dart';
import 'package:slike/model/getadsmodel.dart';
import 'package:slike/model/getcontentbychannelmodel.dart';
import 'package:slike/model/getcontentbyplaylistmodel.dart';
import 'package:slike/model/gethistorymodel.dart';
import 'package:slike/model/getmusicbycategorymodel.dart';
import 'package:slike/model/getmusicbylanguagemodel.dart';
import 'package:slike/model/getnotificationmodel.dart';
import 'package:slike/model/getpagesmodel.dart';
import 'package:slike/model/getplaylistcontentmodel.dart';
import 'package:slike/model/getrelatedmusicmodel.dart';
import 'package:slike/model/getrentcontentbychannelmodel.dart';
import 'package:slike/model/getreportreasonmodel.dart';
import 'package:slike/model/getuserbyrentcontentmodel.dart';
import 'package:slike/model/likevideosmodel.dart';
import 'package:slike/model/packagemodel.dart';
import 'package:slike/model/paymentoptionmodel.dart';
import 'package:slike/model/relatedvideomodel.dart';
import 'package:slike/model/removecontenttohistorymodel.dart';
import 'package:slike/model/rentsectiondetailmodel.dart';
import 'package:slike/model/rentsectionmodel.dart';
import 'package:slike/model/replaycommentmodel.dart';
import 'package:slike/model/sectiondetailmodel.dart';
import 'package:slike/model/sectionlistmodel.dart';
import 'package:slike/model/shortmodel.dart';
import 'package:slike/model/usagehistorymodel.dart';
import 'package:slike/model/watchlatermodel.dart';
import 'package:slike/model/withdrawalrequestmodel.dart';
import 'package:slike/model/categorymodel.dart';
import 'package:slike/model/commentmodel.dart';
import 'package:slike/model/generalsettingmodel.dart';
import 'package:slike/model/loginmodel.dart';
import 'package:slike/model/profilemodel.dart';
import 'package:slike/model/searchhistorymodel.dart';
import 'package:slike/model/searchmodel.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/model/detailmodel.dart';
import 'package:slike/model/videolistmodel.dart';
import 'package:slike/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../model/addremovecontenttoplaylistmodel.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import '../model/feed_detail_and_related_content_model.dart';

class ApiService {
  String baseurl = Constant().baseurl;
  late Dio dio;

  ApiService() {
    dio = Dio();
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: false,
        ),
      );
    }
  }

  /* Send FCM PushNotification API */
  Future sendFCMPushNoti(
    ChatUserModel? currentUserData,
    currentuserfirebasid,
    touserfirebaseid,
    ChatUserModel? toUserData,
    String? msgContent,
  ) async {
    printLog("push token == ${toUserData?.pushToken}");
    var params = {
      "message": {
        "token": toUserData?.pushToken ?? "",
        // "topic": "chat",
        "notification": {
          "title": "New Message from ${currentUserData?.name}:",
          "body": msgContent ?? "",
        },
        "data": {
          "type": "chat",
          "fromFId": currentuserfirebasid,
          "toFId": touserfirebaseid,
          "username": currentUserData?.name,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          // "hello": "This is a Firebase Cloud Messaging device group message!"
        },
        "android": {"priority": "high"},
        "apns": {
          "payload": {
            "aps": {"category": Constant.appName},
          },
        },
        "webpush": {
          "fcm_options": {"link": "https://dummypage.com"},
        },
      },
    };
    var url =
        'https://fcm.googleapis.com/v1/projects/${DefaultFirebaseOptions.android.projectId}/messages:send';
    printLog("push token == $url");
    var response = await http.post(
      Uri.parse(url),
      headers: {
        /* Use Authorization key = Your Firebase Server key from Project Setting */
        "Authorization": "Bearer ${Constant.accessToken}",
        "Content-Type": "application/json;charset=UTF-8",
        "Charset": "utf-8",
      },
      body: json.encode(params),
    );

    if (response.statusCode == 200) {
      printLog("Send Notification");
      Map<String, dynamic> map = json.decode(response.body);
      printLog("fcm.google map :=====> $map");
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      printLog("fcm.google error :=====> $error");
    }
  }

  Future<GeneralsettingModel> generalsetting() async {
    GeneralsettingModel generalsettingModel;
    String apiname = "general_setting";
    Response response = await dio.post('$baseurl$apiname');
    generalsettingModel = GeneralsettingModel.fromJson(response.data);
    return generalsettingModel;
  }

  Future<IntroScreenModel> getOnboardingScreen() async {
    IntroScreenModel introScreenModel;
    String apiName = "get_onboarding_screen";
    Response response = await dio.post('$baseurl$apiName');
    introScreenModel = IntroScreenModel.fromJson(response.data);
    return introScreenModel;
  }

  Future<LoginModel> login(
    String type,
    String email,
    String mobile,
    String devicetype,
    String devicetoken,
    String countrycode,
    String countryName,
    String firebaseId,
  ) async {
    LoginModel loginModel;
    String apiname = "login";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'type': type,
        'email': email,
        'mobile_number': mobile,
        'device_type': devicetype,
        'device_token': devicetoken,
        'country_code': countrycode,
        'country_name': countryName,
        'firebase_id': firebaseId,
      }),
    );

    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  // login with username and password
  Future<LoginModel> loginWithName(
    String email,
    String password,
  
  ) async {
    LoginModel loginModel;
    String apiname = "login?type=4";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'email': email, 'password': password}),
    );

    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  Future<LoginModel> otpLogin(String type, String mobile) async {
    LoginModel loginModel;
    String apiname = "login";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'type': type, 'mobile_number': mobile}),
    );

    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  Future<CategoryModel> videoCategory(pageNo) async {
    CategoryModel categoryModel;
    String apiname = "get_video_category";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'page_no': pageNo}),
    );
    categoryModel = CategoryModel.fromJson(response.data);
    return categoryModel;
  }

  Future<SuccessModel> removesearchhistory(id) async {
    SuccessModel removesearchhistoryModel;
    String apiname = "remove_search_history";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'id': id}),
    );
    removesearchhistoryModel = SuccessModel.fromJson(response.data);
    return removesearchhistoryModel;
  }

  Future<VideoListModel> videolist(ishomePage, categoryid, pageNo) async {
    VideoListModel videolistModel;
    String getvideolist = "get_video_list";
    Response response = await dio.post(
      '$baseurl$getvideolist',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'is_home_page': ishomePage,
        'category_id': categoryid,
        'page_no': pageNo,
      }),
    );
    videolistModel = VideoListModel.fromJson(response.data);
    return videolistModel;
  }

  Future<ShortModel> shrotslist(categoryId, pageNo) async {
    ShortModel shortModel;
    String apiname = "get_reels_list";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'category_id': categoryId,
        'page_no': pageNo,
      }),
    );
    shortModel = ShortModel.fromJson(response.data);
    return shortModel;
  }

  Future<DetailsModel> videodetails(contentid, contenttype) async {
    printLog("contentid===>$contentid");
    printLog("contenttype===>$contenttype");
    printLog("contenttype===>${Constant.userID}");
    DetailsModel detailsModel;
    String apiname = "get_content_detail";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_id': contentid,
        'content_type': contenttype,
      }),
    );
    detailsModel = DetailsModel.fromJson(response.data);
    return detailsModel;
  }

  Future<RelatedVideoModel> relatedVideo(contentId, pageNo) async {
    RelatedVideoModel relatedVideoModel;
    String apiname = "get_releted_video";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_id': contentId,
        'page_no': pageNo,
      }),
    );
    relatedVideoModel = RelatedVideoModel.fromJson(response.data);
    return relatedVideoModel;
  }

  Future<SearchHistoryModel> searchvideohistory(userid) async {
    SearchHistoryModel searchvideohistoryModel;
    String apiname = "get_search_history";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      }),
    );
    searchvideohistoryModel = SearchHistoryModel.fromJson(response.data);
    return searchvideohistoryModel;
  }

  Future<SearchModel> searchvideo(userid, String title) async {
    SearchModel searchvideoModel;
    String apiname = "search_video";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'title': title,
      }),
    );
    searchvideoModel = SearchModel.fromJson(response.data);
    return searchvideoModel;
  }

  Future<AddCommentModel> addcomment(
    contenttype,
    contentid,
    episodeid,
    comment,
    commentid,
  ) async {
    AddCommentModel addCommentModel;
    String apiname = "add_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contenttype,
        'content_id': contentid,
        'episode_id': episodeid,
        'comment': comment,
        'comment_id': commentid,
      }),
    );
    addCommentModel = AddCommentModel.fromJson(response.data);
    return addCommentModel;
  }

  Future<DeleteCommentModel> deleteComment(commentid) async {
    DeleteCommentModel deleteCommentModel;
    String apiname = "delete_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'comment_id': commentid}),
    );
    deleteCommentModel = DeleteCommentModel.fromJson(response.data);
    return deleteCommentModel;
  }

  Future<CommentModel> getcomment(contenttype, videoid, pageNo) async {
    CommentModel getcommentModel;
    String apiname = "get_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contenttype,
        'content_id': videoid,
        'page_no': pageNo,
      }),
    );
    getcommentModel = CommentModel.fromJson(response.data);
    return getcommentModel;
  }

  Future<ReplayCommentModel> replayComment(commentid, pageNo) async {
    ReplayCommentModel replayCommentModel;
    String apiname = "get_reply_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'comment_id': commentid, 'page_no': pageNo}),
    );
    replayCommentModel = ReplayCommentModel.fromJson(response.data);
    return replayCommentModel;
  }

  Future<ProfileModel> profile(touserid) async {
    ProfileModel profileModel;
    String apiname = "get_profile";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'to_user_id': touserid,
      }),
    );
    profileModel = ProfileModel.fromJson(response.data);
    return profileModel;
  }

  Future<SuccessModel> coinMinus(channelId, giftCoin) async {
    SuccessModel successModel;
    String apiname = "minus_coin";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'channel_id': channelId,
        'coin': giftCoin,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<ImageUploadModel> imageUpload(File image) async {
    ImageUploadModel imageUploadModel;
    String apiname = "image_upload";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        "image":
            (image.path.isNotEmpty)
                ? MultipartFile.fromFileSync(image.path, filename: (image.path))
                : "",
      }),
    );
    imageUploadModel = ImageUploadModel.fromJson(response.data);
    return imageUploadModel;
  }

  Future<SuccessModel> updateprofile(
    String userid,
    String fullname,
    String channelName,
    String email,
    dynamic socialLink,
    dynamic field1,
    imageType,
    File image,
    avatarImage,
  ) async {
    SuccessModel updateprofileModel;
    String apiname = "update_profile";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': userid.isEmpty || userid == "" ? "0" : userid,
        'full_name': fullname,
        'channel_name': channelName,
        'email': email,
        'social_link': jsonEncode(socialLink),
        'field_1': jsonEncode(field1),
        'image_type': imageType,
        "image":
            imageType == 1
                ? (image.path.isNotEmpty)
                    ? MultipartFile.fromFileSync(
                      image.path,
                      filename: (image.path),
                    )
                    : ""
                : avatarImage,
        "cover_img":
            imageType == 1
                ? (image.path.isNotEmpty)
                    ? MultipartFile.fromFileSync(
                      image.path,
                      filename: (image.path),
                    )
                    : ""
                : avatarImage,
      }),
    );
    updateprofileModel = SuccessModel.fromJson(response.data);
    return updateprofileModel;
  }

  Future<SuccessModel> updateAvatar(
    String userid,
    imageType,
    File image,
    avatarImage,
  ) async {
    SuccessModel updateprofileModel;
    String apiname = "update_profile";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': userid.isEmpty || userid == "" ? "0" : userid,
        'image_type': imageType,
        "image":
            imageType == 1
                ? (image.path.isNotEmpty)
                    ? MultipartFile.fromFileSync(
                      image.path,
                      filename: (image.path),
                    )
                    : ""
                : avatarImage,
        "cover_img":
            imageType == 1
                ? (image.path.isNotEmpty)
                    ? MultipartFile.fromFileSync(
                      image.path,
                      filename: (image.path),
                    )
                    : ""
                : avatarImage,
      }),
    );
    updateprofileModel = SuccessModel.fromJson(response.data);
    return updateprofileModel;
  }

  Future<AvatatListModel> avatarImage(pageNo) async {
    AvatatListModel avatatListModel;
    String apiname = "get_avatar";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'page_no': pageNo}),
    );
    avatatListModel = AvatatListModel.fromJson(response.data);
    return avatatListModel;
  }

  Future<PackageModel> package() async {
    PackageModel getpackageModel;
    String apiname = "get_package";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      }),
    );
    getpackageModel = PackageModel.fromJson(response.data);
    return getpackageModel;
  }

  Future<AddViewModel> addView(contenttype, contentid) async {
    AddViewModel addViewModel;
    String apiname = "add_view";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contenttype,
        'content_id': contentid,
      }),
    );
    addViewModel = AddViewModel.fromJson(response.data);
    return addViewModel;
  }

  Future<SectionListModel> sectionList(
    ishomescreen,
    contenttype,
    pageNo,
  ) async {
    log("UserId==> ${Constant.userID}");
    SectionListModel sectionListModel;
    String apiname = "get_music_section";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'is_home_screen': ishomescreen,
        'content_type': contenttype,
        'page_no': pageNo,
      }),
    );
    sectionListModel = SectionListModel.fromJson(response.data);
    return sectionListModel;
  }

  Future<SuccessModel> createPlayList(chennelId, title, playlistType) async {
    SuccessModel successModel;
    String apiname = "create_playlist";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'channel_id': chennelId,
        'title': title,
        'playlist_type': playlistType,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<AddremoveContentToPlaylistModel> addremoveContenttoPlaylist(
    chennelId,
    playlistId,
    contenttype,
    contentid,
    episodeid,
    type,
  ) async {
    AddremoveContentToPlaylistModel addremoveContentToPlaylistModel;
    String apiname = "add_remove_content_to_playlist";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'channel_id': chennelId,
        'playlist_id': playlistId,
        'content_type': contenttype,
        'content_id': contentid,
        'episode_id': episodeid,
        'type': type,
      }),
    );
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel.fromJson(
      response.data,
    );
    return addremoveContentToPlaylistModel;
  }

  Future<GetContentbyChannelModel> contentbyChannel(
    userid,
    chennelId,
    contenttype,
    pageNo,
  ) async {
    GetContentbyChannelModel getContentbyChannelModel;
    String apiname = "get_content_by_channel";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        // 'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'user_id': userid,
        'channel_id': chennelId,
        'content_type': contenttype,
        'page_no': pageNo,
      }),
    );
    getContentbyChannelModel = GetContentbyChannelModel.fromJson(response.data);
    return getContentbyChannelModel;
  }

  Future<EditPlaylistModel> editPlaylist(
    playlistId,
    title,
    playlistType,
  ) async {
    EditPlaylistModel editPlaylistModel;
    String apiname = "edit_playlist";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'content_id': playlistId,
        'title': title,
        'playlist_type': playlistType,
      }),
    );
    editPlaylistModel = EditPlaylistModel.fromJson(response.data);
    return editPlaylistModel;
  }

  Future<DeletePlaylistModel> deletePlaylist(playlistId) async {
    DeletePlaylistModel deletePlaylistModel;
    String apiname = "delete_playlist";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'content_id': playlistId}),
    );
    deletePlaylistModel = DeletePlaylistModel.fromJson(response.data);
    return deletePlaylistModel;
  }

  Future<AddRemoveLikeDifood_appModel> addRemoveLikeDifood_app(
    contenttype,
    contentid,
    status,
    episodeId,
  ) async {
    log("UserId==> ${Constant.userID}");
    AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel;
    String apiname = "add_remove_like_difood_app";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contenttype,
        'content_id': contentid,
        'status': status,
        'episode_id': episodeId,
      }),
    );
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel.fromJson(
      response.data,
    );
    return addRemoveLikeDifood_appModel;
  }

  Future<GetRepostReasonModel> reportReason(type, pageNo) async {
    GetRepostReasonModel getRepostReasonModel;
    String apiname = "get_report_reason";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'type': type, 'page_no': pageNo}),
    );
    getRepostReasonModel = GetRepostReasonModel.fromJson(response.data);
    return getRepostReasonModel;
  }

  Future<AddContentReportModel> addContentReport(
    reportUserid,
    contentid,
    message,
    contenttype,
  ) async {
    AddContentReportModel addContentReportModel;
    String apiname = "add_content_report";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'report_user_id': reportUserid,
        'content_id': contentid,
        'message': message,
        'content_type': contenttype,
      }),
    );
    addContentReportModel = AddContentReportModel.fromJson(response.data);
    return addContentReportModel;
  }

  Future<GetWatchlaterModel> watchLaterList(contentType, pageNo) async {
    GetWatchlaterModel watchlaterModel;
    String apiname = "get_watch_later_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contentType,
        'page_no': pageNo,
      }),
    );
    watchlaterModel = GetWatchlaterModel.fromJson(response.data);
    return watchlaterModel;
  }

  Future<LikeContentModel> likeVideos(contentType, pageNo) async {
    log("pageNo========>$pageNo");
    LikeContentModel likeContentModel;
    String apiname = "get_like_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contentType,
        'page_no': pageNo,
      }),
    );
    likeContentModel = LikeContentModel.fromJson(response.data);
    return likeContentModel;
  }

  Future<AddremoveWatchlaterModel> addremoveWatchLater(
    contenttype,
    contentid,
    episodeid,
    type,
  ) async {
    AddremoveWatchlaterModel addremoveWatchlaterModel;
    String apiname = "add_remove_watch_later";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contenttype,
        'content_id': contentid,
        'episode_id': episodeid,
        'type': type,
      }),
    );
    addremoveWatchlaterModel = AddremoveWatchlaterModel.fromJson(response.data);
    return addremoveWatchlaterModel;
  }

  Future<AddremoveSubscribeModel> addremoveSubscribe(touserid, type) async {
    AddremoveSubscribeModel addremoveSubscribeModel;
    String apiname = "add_remove_subscribe";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'to_user_id': touserid,
        'type': type,
      }),
    );
    addremoveSubscribeModel = AddremoveSubscribeModel.fromJson(response.data);
    return addremoveSubscribeModel;
  }

  Future<AddcontenttoHistoryModel> addContentToHistory(
    contenttype,
    contentid,
    stoptime,
    episodeid,
  ) async {
    AddcontenttoHistoryModel addcontenttoHistoryModel;
    String apiname = "add_content_to_history";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contenttype,
        'content_id': contentid,
        'stop_time': stoptime,
        'episode_id': episodeid,
      }),
    );
    addcontenttoHistoryModel = AddcontenttoHistoryModel.fromJson(response.data);
    return addcontenttoHistoryModel;
  }

  Future<RemoveContentHistoryModel> removeContentToHistory(
    contenttype,
    contentid,
    episodeid,
  ) async {
    RemoveContentHistoryModel removeContentHistoryModel;
    String apiname = "remove_content_to_history";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contenttype,
        'content_id': contentid,
        'episode_id': episodeid,
      }),
    );
    removeContentHistoryModel = RemoveContentHistoryModel.fromJson(
      response.data,
    );
    return removeContentHistoryModel;
  }

  Future<GetHistoryModel> historyList(contentType, pageNo) async {
    log("pageNo========>$pageNo");
    GetHistoryModel getHistoryModel;
    String apiname = "get_content_to_history";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contentType,
        'page_no': pageNo,
      }),
    );
    getHistoryModel = GetHistoryModel.fromJson(response.data);
    return getHistoryModel;
  }

  Future<AddremoveblockchannelModel> addremoveBlockChannel(
    blockUserId,
    blockChannelId,
  ) async {
    AddremoveblockchannelModel addremoveblockchannelModel;
    String apiname = "add_remove_block_channel";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'block_user_id': blockUserId,
        'block_channel_id': blockChannelId,
      }),
    );
    addremoveblockchannelModel = AddremoveblockchannelModel.fromJson(
      response.data,
    );
    return addremoveblockchannelModel;
  }

  Future<EpidoseByPodcastModel> episodeByPodcast(podcastId, pageNo) async {
    EpidoseByPodcastModel epidoseByPodcastModel;
    String apiname = "get_episode_by_podcasts";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'podcasts_id': podcastId,
        'page_no': pageNo,
      }),
    );
    epidoseByPodcastModel = EpidoseByPodcastModel.fromJson(response.data);
    return epidoseByPodcastModel;
  }

  Future<EpidoseByRadioModel> episodeByRadio(radioId, pageNo) async {
    EpidoseByRadioModel epidoseByRadioModel;
    String apiname = "get_radio_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'radio_id': radioId,
        'page_no': pageNo,
      }),
    );
    epidoseByRadioModel = EpidoseByRadioModel.fromJson(response.data);
    return epidoseByRadioModel;
  }

  Future<SearchModel> search(name, type) async {
    SearchModel searchModel;
    String apiname = "search_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'name': name,
        'type': type,
      }),
    );
    searchModel = SearchModel.fromJson(response.data);
    return searchModel;
  }

  Future<SuccessModel> addTransaction(packageid, price, discription) async {
    SuccessModel successModel;
    String apiname = "add_transaction";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'package_id': packageid,
        'price': price,
        'description': discription,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String apiname = "get_payment_option";
    Response response = await dio.post('$baseurl$apiname');
    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  Future<EpisodebyplaylistModel> episodeByPlaylist(
    playlistId,
    contentType,
    pageNo,
  ) async {
    EpisodebyplaylistModel episodebyplaylistModel;
    String apiname = "get_playlist_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'playlist_id': playlistId,
        'content_type': contentType,
        'page_no': pageNo,
      }),
    );
    episodebyplaylistModel = EpisodebyplaylistModel.fromJson(response.data);
    return episodebyplaylistModel;
  }

  Future<SectionDetailModel> sectionDetail(sectionId, pageNo) async {
    SectionDetailModel sectionDetailModel;
    String apiname = "get_music_section_detail";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'section_id': sectionId,
        'page_no': pageNo,
      }),
    );
    sectionDetailModel = SectionDetailModel.fromJson(response.data);
    return sectionDetailModel;
  }

  Future<GetMusicByCategoryModel> getMusicbyCategory(categoryId, pageNo) async {
    GetMusicByCategoryModel getMusicByCategoryModel;
    String apiname = "get_music_by_category";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'category_id': categoryId,
        'page_no': pageNo,
      }),
    );
    getMusicByCategoryModel = GetMusicByCategoryModel.fromJson(response.data);
    return getMusicByCategoryModel;
  }

  Future<GetMusicByLanguageModel> getMusicbyLanguage(languageId, pageNo) async {
    GetMusicByLanguageModel getMusicByLanguageModel;
    String apiname = "get_music_by_language";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'language_id': languageId,
        'page_no': pageNo,
      }),
    );
    getMusicByLanguageModel = GetMusicByLanguageModel.fromJson(response.data);
    return getMusicByLanguageModel;
  }

  Future<GetNotificationModel> notification(pageNo) async {
    GetNotificationModel getNotificationModel;
    String apiname = "get_notification";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'page_no': pageNo,
      }),
    );
    getNotificationModel = GetNotificationModel.fromJson(response.data);
    return getNotificationModel;
  }

  Future<SuccessModel> readNotification(notificationId) async {
    SuccessModel successModel;
    String apiname = "read_notification";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'notification_id': notificationId,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> deleteContent(contentType, contentId, episodeId) async {
    SuccessModel successModel;
    String apiname = "delete_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contentType,
        'content_id': contentId,
        'episode_id': episodeId,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> activeUserPanel(password, userpanelStatus) async {
    log("Password====>$password");
    log("userpanalType====>$userpanelStatus");
    SuccessModel updateprofileModel;
    String apiname = "update_profile";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'password': password,
        'user_penal_status': userpanelStatus,
      }),
    );
    updateprofileModel = SuccessModel.fromJson(response.data);
    return updateprofileModel;
  }

  Future<RentSectionModel> rentSection(pageNo) async {
    RentSectionModel rentSectionModel;
    String apiname = "get_rent_section";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'page_no': pageNo,
      }),
    );
    rentSectionModel = RentSectionModel.fromJson(response.data);
    return rentSectionModel;
  }

  Future<GetRentContentbyChannel> getRentContentByChannel(
    userId,
    channelId,
    pageNo,
  ) async {
    GetRentContentbyChannel getRentContentbyChannel;
    String apiname = "get_rent_content_by_channel";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': userId,
        'channel_id': channelId,
        'page_no': pageNo,
      }),
    );
    getRentContentbyChannel = GetRentContentbyChannel.fromJson(response.data);
    return getRentContentbyChannel;
  }

  Future<RentSectionDetailModel> rentSectionDetail(sectionId, pageNo) async {
    RentSectionDetailModel rentSectionModel;
    String apiname = "get_rent_section_detail";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'section_id': sectionId,
        'page_no': pageNo,
      }),
    );
    rentSectionModel = RentSectionDetailModel.fromJson(response.data);
    return rentSectionModel;
  }

  Future<SuccessModel> rentTransection(
    contentId,
    price,
    discription,
    transectionId,
  ) async {
    SuccessModel successModel;
    String apiname = "add_rent_transaction";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_id': contentId,
        'price': price,
        'description': discription,
        'transaction_id': transectionId,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetUserRentContentModel> rentContenetByUser(userId, pageNo) async {
    GetUserRentContentModel getUserRentContentModel;
    String apiname = "get_user_rent_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': userId == null || userId == "" ? "0" : userId,
        'page_no': pageNo,
      }),
    );
    getUserRentContentModel = GetUserRentContentModel.fromJson(response.data);
    return getUserRentContentModel;
  }

  Future<GetContentByPlaylistModel> contentByPlaylist(
    contentType,
    pageNo,
  ) async {
    GetContentByPlaylistModel getContentByPlaylistModel;
    String apiname = "get_content_to_playlist";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_type': contentType,
        'page_no': pageNo,
      }),
    );
    getContentByPlaylistModel = GetContentByPlaylistModel.fromJson(
      response.data,
    );
    return getContentByPlaylistModel;
  }

  Future<SuccessModel> addMultipleContentToPlaylist(
    playlistId,
    contentType,
    contentIds,
  ) async {
    SuccessModel successModel;
    String apiname = "add_multipal_content_to_playlist";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'playlist_id': playlistId,
        'content_type': contentType,
        'content_id': contentIds,
        'channel_id': Constant.channelID,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetPlaylistContentModel> getPlaylistContent(
    playlistId,
    contentType,
    pageNo,
  ) async {
    GetPlaylistContentModel getPlaylistContentModel;
    String apiname = "get_playlist_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'playlist_id': playlistId,
        'content_type': contentType,
        'page_no': pageNo,
      }),
    );
    getPlaylistContentModel = GetPlaylistContentModel.fromJson(response.data);
    return getPlaylistContentModel;
  }

  Future<GetpagesModel> getPages() async {
    GetpagesModel getpagesModel;
    String apiname = "get_pages";
    Response response = await dio.post('$baseurl$apiname');
    getpagesModel = GetpagesModel.fromJson(response.data);
    return getpagesModel;
  }

  Future<SocialLinkModel> getSocialLink() async {
    SocialLinkModel socialLinkModel;
    String apiname = "get_social_links";
    Response response = await dio.post('$baseurl$apiname');
    socialLinkModel = SocialLinkModel.fromJson(response.data);
    return socialLinkModel;
  }

  Future<SuccessModel> updateDataForPayment(
    fullName,
    email,
    mobileNumber,
  ) async {
    printLog("updateDataForPayment userID :====> ${Constant.userID}");
    printLog("updateDataForPayment fullName :==> $fullName");
    printLog("updateDataForPayment email :=====> $email");
    printLog("updateProfile mobileNumber :=====> $mobileNumber");
    SuccessModel responseModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
      }),
    );

    responseModel = SuccessModel.fromJson(response.data);
    return responseModel;
  }

  Future<SuccessModel> uploadVideo(
    categoryId,
    title,
    watermarkFile,
    videoFile,
    imageFile,
  ) async {
    printLog("Title:=========> $title");
    printLog("Video :===> $videoFile");
    printLog("Image:=======> $imageFile");
    SuccessModel successModel;
    String uploadVideo = "upload_reels";
    Response response = await dio.post(
      '$baseurl$uploadVideo',
      data: FormData.fromMap({
        'channel_id': Constant.channelID,
        'category_id': categoryId,
        'title': title,
        'watermark_img':
            (watermarkFile?.path ?? "") != ""
                ? (MultipartFile.fromFileSync(
                  watermarkFile?.path ?? "",
                  filename: watermarkFile?.path.split('/').last ?? "",
                ))
                : "",
        "video":
            (videoFile?.path ?? "") != ""
                ? (MultipartFile.fromFileSync(
                  videoFile?.path ?? "",
                  filename: videoFile?.path.split('/').last ?? "",
                ))
                : "",
        "portrait_img":
            (imageFile?.path ?? "") != ""
                ? (MultipartFile.fromFileSync(
                  imageFile?.path ?? "",
                  filename: imageFile?.path.split('/').last ?? "",
                ))
                : "",
      }),
    );

    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> logout() async {
    SuccessModel successModel;
    String apiname = "logout";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': Constant.userID}),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<UsageHistoryModel> usageHistory(pageNo) async {
    UsageHistoryModel usageHistoryModel;
    String apiname = "get_ads_coin_history";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'page_no': pageNo,
      }),
    );
    usageHistoryModel = UsageHistoryModel.fromJson(response.data);
    return usageHistoryModel;
  }

  Future<AdspackageTransectionModel> adsPackageTransection(pageNo) async {
    AdspackageTransectionModel adspackageTransectionModel;
    String apiname = "get_ads_transaction_list";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'page_no': pageNo,
      }),
    );
    adspackageTransectionModel = AdspackageTransectionModel.fromJson(
      response.data,
    );
    return adspackageTransectionModel;
  }

  Future<WithdrawalrequestModel> withdrawalRequestList(pageNo) async {
    WithdrawalrequestModel withdrawalrequestModel;
    String apiname = "get_withdrawal_request_list";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'page_no': pageNo,
      }),
    );
    withdrawalrequestModel = WithdrawalrequestModel.fromJson(response.data);
    return withdrawalrequestModel;
  }

  Future<AdsPackageModel> adsPackage() async {
    AdsPackageModel adsPackageModel;
    String apiname = "get_ads_package";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
      }),
    );
    adsPackageModel = AdsPackageModel.fromJson(response.data);
    return adsPackageModel;
  }

  Future<SuccessModel> adsTransection(
    packageId,
    price,
    coin,
    transectionId,
    description,
  ) async {
    SuccessModel successModel;
    String apiname = "add_ads_transaction";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'package_id': packageId,
        'price': price,
        'coin': coin,
        'transaction_id': transectionId,
        'description': description,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<GetAdsModel> getAds(type) async {
    GetAdsModel getAdsModel;
    String apiname = "get_ads";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'type': type}),
    );
    getAdsModel = GetAdsModel.fromJson(response.data);
    return getAdsModel;
  }

  Future<SuccessModel> adsViewClickCount(
    adsType,
    adsId,
    diviceType,
    diviceToken,
    type,
    contentId,
  ) async {
    SuccessModel successModel;
    String apiname = "add_ads_view_click_count";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'ads_type': adsType,
        'ads_id': adsId,
        'device_type': diviceType,
        'device_token': diviceToken,
        'type': type,
        'content_id': contentId,
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<RelatedMusicModel> getRelatedMusic(contentId, pageNo) async {
    RelatedMusicModel relatedMusicModel;
    String apiname = "get_releted_music";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'content_id': contentId,
        'page_no': pageNo,
      }),
    );
    relatedMusicModel = RelatedMusicModel.fromJson(response.data);
    return relatedMusicModel;
  }

  Future<SubscriberlistModel> getFollowingList(userId, pageNo) async {
    SubscriberlistModel followingModel;
    String apiname = "get_subscribe_list";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': userId, 'page_no': pageNo}),
    );
    followingModel = SubscriberlistModel.fromJson(response.data);
    return followingModel;
  }

  Future<SubscriberlistModel> getFollowerList(userId, pageNo) async {
    SubscriberlistModel followerModel;
    String apiname = "get_subscriber_list";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': userId, 'page_no': pageNo}),
    );
    followerModel = SubscriberlistModel.fromJson(response.data);
    return followerModel;
  }

  /* ************************* Live Streaming & Gift APIs START ************************* */

  Future<LiveUserListModel> listOfLiveUsers(pageNo) async {
    LiveUserListModel liveStreamModel;
    String apiname = "list_of_live_users";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    liveStreamModel = LiveUserListModel.fromJson(response.data);
    return liveStreamModel;
  }

  Future<SuccessModel> addLiveUser(liveUserId, status, roomId) async {
    printLog("addLiveUser liveUserId =====> $liveUserId");
    printLog("addLiveUser status =========> $status");
    printLog("addLiveUser roomId =========> $roomId");
    SuccessModel successModel;
    String apiname = "add_live_user";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'user_id': liveUserId, 'status': status, 'room_id': roomId},
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> deleteLiveUser(liveUserId) async {
    printLog("deleteLiveUser liveUserId =========> $liveUserId");
    SuccessModel successModel;
    String apiname = "delete_live_user";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'user_id': liveUserId},
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<FetchGiftModel> getGift(pageNo) async {
    FetchGiftModel fetchGiftModel;
    String apiname = "get_gift";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    fetchGiftModel = FetchGiftModel.fromJson(response.data);
    return fetchGiftModel;
  }

  Future<SuccessModel> buyGift(coin, giftId) async {
    printLog("buyGift giftId =========> $giftId");
    SuccessModel liveStreamModel;
    String apiname = "buy_gift";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'user_id': Constant.userID, 'gift_id': giftId, 'coin': coin},
    );
    liveStreamModel = SuccessModel.fromJson(response.data);
    return liveStreamModel;
  }

  /* ************************* Live Streaming & Gift APIs END *************************** */

  /* **************************** Market Place ****************************************** */

  Future<MarketPlaceModel> getMarketPlace(
    name,
    String categoryId,
    pageNo,
  ) async {
    MarketPlaceModel marketPlaceModel;
    String apiname = "get_marketplace";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'name': name, 'category_id': categoryId, 'page_no': pageNo},
    );
    marketPlaceModel = MarketPlaceModel.fromJson(response.data);
    return marketPlaceModel;
  }

  Future<SuccessModel> uploadProduct(
    productName,
    categoryId,
    price,
    disciption,
    url,
    File image,
  ) async {
    SuccessModel uploadMarketPlace;
    String apiname = "upload_marketplace";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'category_id': categoryId,
        'name': productName,
        'price': price,
        'descripation': disciption,
        'url': url,
        "image":
            (image.path.isNotEmpty)
                ? MultipartFile.fromFileSync(image.path, filename: (image.path))
                : "",
      }),
    );
    uploadMarketPlace = SuccessModel.fromJson(response.data);
    return uploadMarketPlace;
  }

  Future<GetUserMarketPlaceModel> getUserMarketPlace(toUserId, pageNo) async {
    GetUserMarketPlaceModel getUserMarketPlaceModel;
    String apiname = "get_user_marketplace";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'user_id': toUserId, 'page_no': pageNo},
    );
    getUserMarketPlaceModel = GetUserMarketPlaceModel.fromJson(response.data);
    return getUserMarketPlaceModel;
  }

  Future<SuccessModel> getDeleteMarketPlace(marketplaceId) async {
    SuccessModel successModel;
    String apiname = "delete_marketplace";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: {'user_id': Constant.userID, 'marketplace_id': marketplaceId},
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<MarketPlaceDetailModel> productDetail(marketplaceId) async {
    MarketPlaceDetailModel marketPlaceDetailModel;
    String apiname = "get_marketplace_detail";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'marketplace_id': marketplaceId,
      }),
    );
    marketPlaceDetailModel = MarketPlaceDetailModel.fromJson(response.data);
    return marketPlaceDetailModel;
  }

  /* **************************** Market Place ************************************** */

  /* **************************** Feed Api ************************************** */

  Future<PostModel> getFeedPost(categoryId, pageNo) async {
    PostModel postModel;
    String apiname = "get_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
        'category_id': categoryId,
        'page_no': pageNo,
      }),
    );
    postModel = PostModel.fromJson(response.data);
    return postModel;
  }

  Future<SuccessModel> deleteFeedPost(postId) async {
    SuccessModel uploadMarketPlace;
    String apiname = "delete_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'channel_id': Constant.channelID,
        'post_id': postId,
      }),
    );
    uploadMarketPlace = SuccessModel.fromJson(response.data);
    return uploadMarketPlace;
  }

  Future<PostContentUploadModel> postContentUpload(contentType, content) async {
    PostContentUploadModel postContentUploadModel;
    String apiname = "post_content_upload";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'content_type': contentType,
        "content":
            (content.path.isNotEmpty)
                ? MultipartFile.fromFileSync(
                  content.path,
                  filename: (content.path),
                )
                : "",
      }),
    );
    postContentUploadModel = PostContentUploadModel.fromJson(response.data);
    return postContentUploadModel;
  }

  Future<SuccessModel> uploadFeedPost(
    categoryId,
    title,
    dynamic postContent,
    watermarkFile,
  ) async {
    SuccessModel successModel;
    String apiname = "upload_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'channel_id': Constant.channelID,
        'category_id': categoryId,
        'title': title,
        'post_content': jsonEncode(postContent),
        'watermark_img':
            (watermarkFile?.path ?? "") != ""
                ? (MultipartFile.fromFileSync(
                  watermarkFile?.path ?? "",
                  filename: watermarkFile?.path.split('/').last ?? "",
                ))
                : "",
      }),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<AddRemoveLikeDifood_appModel> likeUnlikePost(postId) async {
    AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel;
    String apiname = "like_unlike_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': Constant.userID, "post_id": postId}),
    );
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel.fromJson(
      response.data,
    );
    return addRemoveLikeDifood_appModel;
  }

  Future<AddCommentModel> addPostComment(postId, comment, commentId) async {
    AddCommentModel addCommentModel;
    String apiname = "add_post_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        "post_id": postId,
        "comment": comment,
        /* Replya Perticuler Comment Then Pass Comment ID */
        "comment_id": commentId,
      }),
    );
    addCommentModel = AddCommentModel.fromJson(response.data);
    return addCommentModel;
  }

  Future<GetPostCommentModel> getPostComment(postId, pageNo) async {
    GetPostCommentModel getPostCommentModel;
    String apiname = "get_post_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({"post_id": postId, 'page_no': pageNo}),
    );
    getPostCommentModel = GetPostCommentModel.fromJson(response.data);
    return getPostCommentModel;
  }

  Future<GetPostCommentModel> getPostReplayComment(commentId, pageNo) async {
    GetPostCommentModel getPostReplayCommentModel;
    String apiname = "get_post_reply_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({"comment_id": commentId, 'page_no': pageNo}),
    );
    getPostReplayCommentModel = GetPostCommentModel.fromJson(response.data);
    return getPostReplayCommentModel;
  }

  Future<SuccessModel> postDeleteComment(commentId) async {
    SuccessModel successModel;
    String apiname = "delete_post_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({"comment_id": commentId}),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<AddContentReportModel> addPostReport(postId, reason) async {
    AddContentReportModel addContentReportModel;
    String apiname = "add_post_report";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'report_user_id': Constant.userID,
        'post_id': postId,
        'message': reason,
      }),
    );
    addContentReportModel = AddContentReportModel.fromJson(response.data);
    return addContentReportModel;
  }

  Future<GetChannelFeedModel> getChennalFeed(userId, channelId, pageNo) async {
    GetChannelFeedModel getChannelFeedModel;
    String apiname = "get_channel_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': userId,
        'channel_id': channelId,
        'page_no': pageNo,
      }),
    );
    getChannelFeedModel = GetChannelFeedModel.fromJson(response.data);
    return getChannelFeedModel;
  }

  Future<SuccessModel> deletePost(postId, channelId) async {
    SuccessModel successModel;
    String apiname = "delete_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'post_id': postId, 'channel_id': channelId}),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<FeedDetailModel> feedDetail(postId) async {
    FeedDetailModel feedDetailModel;
    String apiname = "get_post_detail";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': Constant.userID, 'post_id': postId}),
    );
    feedDetailModel = FeedDetailModel.fromJson(response.data);
    return feedDetailModel;
  }

  Future<FeedDetailAndRelatedContentModel> getPostAndRelatedContent(
    postId,
  ) async {
    FeedDetailAndRelatedContentModel feedDetailModel;
    String apiname = "get_post_and_related_content";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': Constant.userID, 'post_id': postId}),
    );
    feedDetailModel = FeedDetailAndRelatedContentModel.fromJson(response.data);
    return feedDetailModel;
  }

  // Feed Latest New Page Three Api Start

  Future<SubscribeChannelPostModel> subcribeChannelPost(pageNo) async {
    SubscribeChannelPostModel subscribeChannelPostModel;
    String apiname = "get_subscribe_channel_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': Constant.userID, 'page_no': pageNo}),
    );
    subscribeChannelPostModel = SubscribeChannelPostModel.fromJson(
      response.data,
    );
    return subscribeChannelPostModel;
  }

  Future<SubscribeChannelPostModel> mostViewPost(pageNo) async {
    SubscribeChannelPostModel mostViewPostModel;
    String apiname = "most_view_post";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({'user_id': Constant.userID, 'page_no': pageNo}),
    );
    mostViewPostModel = SubscribeChannelPostModel.fromJson(response.data);
    return mostViewPostModel;
  }

  Future<SubscribeChannelPostModel> postByCategory(categoryId, pageNo) async {
    SubscribeChannelPostModel postByCategoryModel;
    String apiname = "get_post_by_category";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'category_id': categoryId,
        'page_no': pageNo,
      }),
    );
    postByCategoryModel = SubscribeChannelPostModel.fromJson(response.data);
    return postByCategoryModel;
  }

  // Feed Latest New Page Three Api End

  /* **************************** Feed Api ************************************** */

  /* **************************** Feed Link Start ************************************** */

  Future<GetSocialLinkModel> socialLink() async {
    GetSocialLinkModel getSocialLinkModel;
    String apiname = "get_social_media";
    Response response = await dio.post('$baseurl$apiname');
    getSocialLinkModel = GetSocialLinkModel.fromJson(response.data);
    return getSocialLinkModel;
  }

  /* **************************** Feed Link End ************************************** */

  /* ************************* Download Video Offline START ************************* */

  downloadContent({
    required BuildContext context,
    required int contentId,
    required String title,
    required String channelName,
    required String image,
    required String videoUrl,
    required String videoUploadType,
  }) async {
    Box<DownloadItem> downloadBox = Hive.box<DownloadItem>('downloads');
    final downloadprovider = Provider.of<DownloadProvider>(
      context,
      listen: false,
    );
    /* TimeStap Get */
    DateTime now = DateTime.now();
    String timestamp = now.toString();
    /* Splite Image And Video Url Extension */

    final directory = await getApplicationDocumentsDirectory();

    String imgext = p.extension(image);
    String videoext = p.extension(videoUrl);

    /* Image Path */
    final imgPath = '${directory.path}/img_$contentId$timestamp$imgext';
    final videoPath = '${directory.path}/video_$contentId$timestamp$videoext';
    log("Image Path===> $imgPath");
    log("Video Path===> $videoPath");

    try {
      if (!context.mounted) return;
      Utils.showSnackbar(context, "downloaditemadded", true);
      Utils().progressDilog(context);
      await dio.download(
        image,
        imgPath,
        onReceiveProgress: (received, total) {
          printLog('Received: $received / Total: $total');
        },
      );
      await dio.download(
        videoUrl,
        videoPath,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            await downloadprovider.updateProgress(received / total);
          }
        },
      );
      final downloadItem = DownloadItem(
        id: contentId,
        title: title,
        imagePath: imgPath,
        videoPath: videoPath,
        channelName: channelName,
        videoUploadType: videoUploadType,
      );
      downloadBox.add(downloadItem);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      Utils.showSnackbar(context, "downloadcomplited", true);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      Utils.showSnackbar(context, "downloadingfailed", true);
    }
  }

  /* ************************* Download Video Offline End ************************* */
}
