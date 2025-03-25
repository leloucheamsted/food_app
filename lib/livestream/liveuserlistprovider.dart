import 'package:flutter/material.dart';
import 'package:slike/model/liveuserlistmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';

class LiveUserListProvider extends ChangeNotifier {
  /* Pagination With Api Calling */
  LiveUserListModel liveUserListModel = LiveUserListModel();
  List<Result>? liveUserList = [];
  bool loadMore = false, loading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getLiveUserList(pageNo) async {
    loading = true;
    liveUserListModel = await ApiService().listOfLiveUsers(pageNo);
    if (liveUserListModel.status == 200) {
      setPaginationData(
        liveUserListModel.totalRows,
        liveUserListModel.totalPage,
        liveUserListModel.currentPage,
        liveUserListModel.morePage,
      );
      if (liveUserListModel.result != null &&
          (liveUserListModel.result?.length ?? 0) > 0) {
        printLog(
          "LiveUserModel length :==> ${(liveUserListModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (liveUserListModel.result != null &&
            (liveUserListModel.result?.length ?? 0) > 0) {
          printLog(
            "LiveUserModel length :==> ${(liveUserListModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (liveUserListModel.result?.length ?? 0); i++) {
            liveUserList?.add(liveUserListModel.result?[i] ?? Result());
          }
          printLog("LiveUserList length :==> ${(liveUserList?.length ?? 0)}");
          final Map<int, Result> postMap = {};
          liveUserList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          liveUserList = postMap.values.toList();
          printLog("LiveUserList length :==> ${(liveUserList?.length ?? 0)}");
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

  clearProvider() {
    liveUserListModel = LiveUserListModel();
    liveUserList = [];
    liveUserList?.clear();
    loadMore = false;
    loading = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
