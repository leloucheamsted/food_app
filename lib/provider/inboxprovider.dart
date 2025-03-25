import 'package:flutter/material.dart';
import 'package:slike/model/getnotificationmodel.dart' as notification;
import 'package:slike/model/successmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';

class InboxProvider extends ChangeNotifier {
  String selectedTab = "chat";

  notification.GetNotificationModel getNotificationModel =
      notification.GetNotificationModel();
  SuccessModel successModel = SuccessModel();
  int position = 0;
  bool isNotification = false;
  bool readnotificationloading = false;

  List<notification.Result>? notificationList = [];
  bool loadMore = false, loading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  /* ==================== Select Tab ==================== */

  selectTab(selecttab) async {
    selectedTab = selecttab;
    notifyListeners();
  }

  /* ==================== Get Notification List ==================== */

  Future<void> getNotification(pageNo) async {
    loading = true;
    getNotificationModel = await ApiService().notification(pageNo);
    if (getNotificationModel.status == 200) {
      setPaginationData(
        getNotificationModel.totalRows,
        getNotificationModel.totalPage,
        getNotificationModel.currentPage,
        getNotificationModel.morePage,
      );
      if (getNotificationModel.result != null &&
          (getNotificationModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(getNotificationModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (getNotificationModel.result != null &&
            (getNotificationModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(getNotificationModel.result?.length ?? 0)}",
          );
          notificationList?.addAll(getNotificationModel.result ?? []);
          // for (var i = 0; i < (getNotificationModel.result?.length ?? 0); i++) {
          //   notificationList?.add(getNotificationModel.result?[i] ?? Result());
          // }
          final Map<int, notification.Result> postMap = {};
          notificationList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          notificationList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(notificationList?.length ?? 0)}",
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

  getReadNotification(index, notificationId, isNotification) async {
    position = index;
    isNotification = isNotification;
    setReadNotificationLoading(true);
    successModel = await ApiService().readNotification(notificationId);
    setReadNotificationLoading(false);
    notificationList?.removeAt(index);
  }

  setReadNotificationLoading(isSending) {
    printLog("isSending ==> $isSending");
    readnotificationloading = isSending;
    notifyListeners();
  }

  /* ==================== Get Notification List ==================== */

  clearNotification() {
    getNotificationModel = notification.GetNotificationModel();
    loading = false;
    position = 0;
    notificationList = [];
    notificationList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }

  clearProvider() {
    selectedTab = "chat";
    getNotificationModel = notification.GetNotificationModel();
    loading = false;
    position = 0;
    notificationList = [];
    notificationList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
