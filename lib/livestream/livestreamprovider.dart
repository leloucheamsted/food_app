import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:slike/model/fetchgiftmodel.dart' as fetchgift;
import 'package:slike/model/profilemodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class LiveStreamProvider extends ChangeNotifier {
  bool isFrontCamera = false;
  bool isFlashOn = false;
  bool isMicOn = true;
  bool isFollow = false;

  int countTime = 0;
  bool isLivePage = false;
  int? totalViewCount = 0;

  /* Comment */
  ScrollController scrollController = ScrollController();
  List<ChatModel>? commentList = [];

  /* Gift */
  bool isShowGift = false;
  String? giftUrl;

  /* Delete Room */
  int? status;
  int? deletedRoomId;

  /* Fetch All Gift Field */
  fetchgift.FetchGiftModel fetchGiftModel = fetchgift.FetchGiftModel();
  List<fetchgift.Result>? giftList = [];
  bool giftloadMore = false, giftloading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  /* Profile Api  */
  ProfileModel profileModel = ProfileModel();

  Future<void> onSwitchMic() async {
    isMicOn = !isMicOn;
    ZegoExpressEngine.instance.enableAudioCaptureDevice(isMicOn);
    notifyListeners();
  }

  Future<void> onSwitchCamera() async {
    // Get.dialog(const LoadingUi(),
    //     barrierDismissible: false); // Start Loading...
    if (isFrontCamera) {
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      isFrontCamera = !isFrontCamera;
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
    } else {
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
      isFrontCamera = !isFrontCamera;
      ZegoExpressEngine.instance.useFrontCamera(isFrontCamera);
    }
    // Get.back(); // Stop Loading...
  }

  void onChangeTime() {
    isLivePage = true;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isLivePage) {
        countTime++;
        printLog("Live Streaming Time => ${onConvertSecondToHMS(countTime)}");
        notifyListeners();
      } else {
        timer.cancel();
        countTime = 0;
        notifyListeners();
      }
    });
  }

  String onConvertSecondToHMS(int totalSeconds) {
    Duration duration = Duration(seconds: totalSeconds);

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String time =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return time;
  }

  liveCountUpdate(int viewCount) async {
    totalViewCount = viewCount;
    notifyListeners();
  }

  storeComment({required data}) async {
    log("Call Store Comment");
    // Create a new CommentModel from the parsed data
    ChatModel newComment = ChatModel.fromJson(data);
    // Add the new comment to the commentList
    commentList?.add(newComment);
    log("Length Comment==> ${commentList?.length}");
    notifyListeners();
    onScrollDown();
  }

  showGift({required data}) async {
    giftUrl = data["image"] ?? "";
    notifyListeners();
    isShowGift = true;
    Future.delayed(const Duration(milliseconds: 5000), () {
      clearImage();
    });
    isShowGift = false;

    log("giftUrl==>$isShowGift");
  }

  clearImage() {
    giftUrl = null;
    notifyListeners();
  }

  clearCount() {
    totalViewCount = 0;
  }

  clearComment() {
    commentList = [];
    commentList?.clear();
    fetchGiftModel = fetchgift.FetchGiftModel();
    totalViewCount = 0;
    giftList = [];
    giftList?.clear();
    giftloadMore = false;
    giftloading = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }

  Future<void> onScrollDown() async {
    try {
      await Future.delayed(const Duration(milliseconds: 10));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {
      printLog("Scroll Error ==> ${e.toString()}");
    }
  }

  /* Profile Api */

  Future<void> getProfile(BuildContext context, touserid) async {
    giftloading = true;
    profileModel = await ApiService().profile(touserid);
    giftloading = false;
    notifyListeners();
  }

  /* Profile Api */

  /*  Fetch All Gift Start */

  Future<void> fetchGift(pageNo) async {
    giftloading = true;
    fetchGiftModel = await ApiService().getGift(pageNo);
    if (fetchGiftModel.status == 200) {
      setPaginationData(
        fetchGiftModel.totalRows,
        fetchGiftModel.totalPage,
        fetchGiftModel.currentPage,
        fetchGiftModel.morePage,
      );
      if (fetchGiftModel.result != null &&
          (fetchGiftModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(fetchGiftModel.result?.length ?? 0)}",
        );
        if (fetchGiftModel.result != null &&
            (fetchGiftModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(fetchGiftModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (fetchGiftModel.result?.length ?? 0); i++) {
            giftList?.add(fetchGiftModel.result?[i] ?? fetchgift.Result());
          }
          final Map<int, fetchgift.Result> postMap = {};
          giftList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          giftList = postMap.values.toList();
          printLog("categoryList length :==> ${(giftList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    giftloading = false;
    notifyListeners();
  }

  setPaginationData(
    int? totalRows,
    int? totalPage,
    int? currentPage,
    bool? morePage,
  ) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setLoadMore(giftloadMore) {
    this.giftloadMore = giftloadMore;
    notifyListeners();
  }

  /*  Fetch All Gift Stop */
}

/* ============================== chat model =================================== */

// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  String? userName;
  String? fullName;
  String? image;
  String? comment;

  ChatModel({this.userName, this.fullName, this.image, this.comment});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    userName: json["user_name"],
    fullName: json["full_name"],
    image: json["image"],
    comment: json["comment"],
  );

  Map<String, dynamic> toJson() => {
    "user_name": userName,
    "full_name": fullName,
    "image": image,
    "comment": comment,
  };
}

/* ============================== chat model =================================== */
