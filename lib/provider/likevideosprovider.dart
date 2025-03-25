import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:slike/model/likevideosmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:slike/webservice/apiservice.dart';

class LikeVideosProvider extends ChangeNotifier {
  LikeContentModel likeContentModel = LikeContentModel();
  AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel =
      AddRemoveLikeDifood_appModel();
  bool loading = false;
  bool removeLikeLoading = false;

  List<Result>? likevideoList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  int position = 0;
  bool isRemove = false;

  Future<void> getlikeVideos(contentType, pageNo) async {
    loading = true;
    likeContentModel = await ApiService().likeVideos(contentType, pageNo);
    if (likeContentModel.status == 200) {
      setPaginationData(
        likeContentModel.totalRows,
        likeContentModel.totalPage,
        likeContentModel.currentPage,
        likeContentModel.morePage,
      );
      if (likeContentModel.result != null &&
          (likeContentModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(likeContentModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (likeContentModel.result != null &&
            (likeContentModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(likeContentModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (likeContentModel.result?.length ?? 0); i++) {
            likevideoList?.add(likeContentModel.result?[i] ?? Result());
          }
          final Map<int, Result> postMap = {};
          likevideoList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          likevideoList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(likevideoList?.length ?? 0)}",
          );
          setLoadMore(false);
        }
      }
    }
    loading = false;
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

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  Future<void> addLikeDifood_app(
    index,
    contenttype,
    contentid,
    status,
    episodeId,
    isremove,
  ) async {
    position = index;
    isRemove = isremove;
    setReadNotificationLoading(true);
    addRemoveLikeDifood_appModel = await ApiService().addRemoveLikeDifood_app(
      contenttype,
      contentid,
      status,
      episodeId,
    );
    setReadNotificationLoading(false);
    /* Clear Field */
    likevideoList?.removeAt(index);
    position;
    isRemove = false;
    removeLikeLoading = false;
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel();
  }

  setReadNotificationLoading(isSending) {
    removeLikeLoading = isSending;
    notifyListeners();
  }

  clearProvider() {
    likeContentModel = LikeContentModel();
    loading = false;
    removeLikeLoading = false;
    likevideoList = [];
    likevideoList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
