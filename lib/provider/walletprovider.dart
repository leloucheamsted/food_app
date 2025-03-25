import 'package:slike/model/adspackagetransectionmodel.dart' as adspackagelist;
import 'package:slike/model/adspackagetransectionmodel.dart';
// import 'package:slike/model/usagehistorymodel.dart' as usagehistory;
// import 'package:slike/model/usagehistorymodel.dart';
import 'package:slike/model/withdrawalrequestmodel.dart' as withdrawal;
import 'package:slike/model/withdrawalrequestmodel.dart';
import 'package:flutter/material.dart';
import 'package:slike/model/profilemodel.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:slike/utils/utils.dart';

class WalletProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  bool loading = false;
  bool profileloading = false;
  int position = 0;

  /* Ads Package Transection Api Field */
  AdspackageTransectionModel adspackageTransectionModel =
      AdspackageTransectionModel();
  List<adspackagelist.Result>? packageTransectionList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  /* Withdrawal Request Transection Api Field */
  WithdrawalrequestModel withdrawalrequestModel = WithdrawalrequestModel();
  List<withdrawal.Result>? withdrawalTransectionList = [];
  bool withdrawalloadMore = false;
  int? withdrawaltotalRows, withdrawaltotalPage, withdrawalcurrentPage;
  bool? withdrawalisMorePage;

  /* UsageHistory Transection Api Field */
  // UsageHistoryModel usageHistoryModel = UsageHistoryModel();
  // List<usagehistory.Result>? usageHistoryList = [];
  // bool usageHistoryloadMore = false;
  // int? usageHistorytotalRows, usageHistorytotalPage, usageHistorycurrentPage;
  // bool? usageHistoryisMorePage;

  /* Profile Api With Related Method  */
  getprofile(BuildContext context, touserid) async {
    profileloading = true;
    profileModel = await ApiService().profile(touserid);
    profileloading = false;
    notifyListeners();
  }

  changeTab(index) {
    position = index;
    notifyListeners();
  }

  /* UsageHistory Transection Api Start */

  // Future<void> getUsageHistory(pageNo) async {
  //   loading = true;
  //   usageHistoryModel = await ApiService().usageHistory(pageNo);
  //   if (usageHistoryModel.status == 200) {
  //     setUsageHistoryPaginationData(
  //         usageHistoryModel.totalRows,
  //         usageHistoryModel.totalPage,
  //         usageHistoryModel.currentPage,
  //         usageHistoryModel.morePage);
  //     if (usageHistoryModel.result != null &&
  //         (usageHistoryModel.result?.length ?? 0) > 0) {
  //       printLog(
  //           "usageHistoryList length :==> ${(usageHistoryModel.result?.length ?? 0)}");
  //       if (usageHistoryModel.result != null &&
  //           (usageHistoryModel.result?.length ?? 0) > 0) {
  //         printLog(
  //             "usageHistoryList length :==> ${(usageHistoryModel.result?.length ?? 0)}");
  //         for (var i = 0; i < (usageHistoryModel.result?.length ?? 0); i++) {
  //           usageHistoryList
  //               ?.add(usageHistoryModel.result?[i] ?? usagehistory.Result());
  //         }
  //         final Map<int, usagehistory.Result> postMap = {};
  //         usageHistoryList?.forEach((item) {
  //           postMap[item.adsId ?? 0] = item;
  //         });
  //         usageHistoryList = postMap.values.toList();
  //         printLog(
  //             "usageHistoryList length :==> ${(usageHistoryList?.length ?? 0)}");
  //         setUsageHistoryLoadMore(false);
  //       }
  //     }
  //   }
  //   loading = false;
  //   notifyListeners();
  // }

  // setUsageHistoryPaginationData(
  //     int? usageHistorytotalRows,
  //     int? usageHistorytotalPage,
  //     int? usageHistorycurrentPage,
  //     bool? usageHistorymorePage) {
  //   this.usageHistorycurrentPage = usageHistorycurrentPage;
  //   this.usageHistorytotalRows = usageHistorytotalRows;
  //   this.usageHistorytotalPage = usageHistorytotalPage;
  //   usageHistorymorePage = usageHistorymorePage;
  //   notifyListeners();
  // }

  // setUsageHistoryLoadMore(usageHistoryloadMore) {
  //   this.usageHistoryloadMore = usageHistoryloadMore;
  //   notifyListeners();
  // }

  /* UsageHistory Transection Api End*/

  /* Ads Package Transection Api Start */

  Future<void> getAdsPackageTransection(pageNo) async {
    loading = true;
    adspackageTransectionModel = await ApiService().adsPackageTransection(
      pageNo,
    );
    if (adspackageTransectionModel.status == 200) {
      setPaginationData(
        adspackageTransectionModel.totalRows,
        adspackageTransectionModel.totalPage,
        adspackageTransectionModel.currentPage,
        adspackageTransectionModel.morePage,
      );
      if (adspackageTransectionModel.result != null &&
          (adspackageTransectionModel.result?.length ?? 0) > 0) {
        printLog(
          "adsPackageTransectionList length :==> ${(adspackageTransectionModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (adspackageTransectionModel.result != null &&
            (adspackageTransectionModel.result?.length ?? 0) > 0) {
          printLog(
            "adsPackageTransectionList length :==> ${(adspackageTransectionModel.result?.length ?? 0)}",
          );
          for (
            var i = 0;
            i < (adspackageTransectionModel.result?.length ?? 0);
            i++
          ) {
            packageTransectionList?.add(
              adspackageTransectionModel.result?[i] ?? adspackagelist.Result(),
            );
          }
          final Map<int, adspackagelist.Result> postMap = {};
          packageTransectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          packageTransectionList = postMap.values.toList();
          printLog(
            "adsPackageTransectionList length :==> ${(packageTransectionList?.length ?? 0)}",
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

  /* Ads Package Transection Api End*/

  /* Ads Package Transection Api Start */

  Future<void> getWithdrawalTransection(pageNo) async {
    loading = true;
    withdrawalrequestModel = await ApiService().withdrawalRequestList(pageNo);
    if (withdrawalrequestModel.status == 200) {
      setWithdrawalPaginationData(
        withdrawalrequestModel.totalRows,
        withdrawalrequestModel.totalPage,
        withdrawalrequestModel.currentPage,
        withdrawalrequestModel.morePage,
      );
      if (withdrawalrequestModel.result != null &&
          (withdrawalrequestModel.result?.length ?? 0) > 0) {
        printLog(
          "withdrawalTransectionList length :==> ${(withdrawalrequestModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (withdrawalrequestModel.result != null &&
            (withdrawalrequestModel.result?.length ?? 0) > 0) {
          printLog(
            "withdrawalTransectionList length :==> ${(withdrawalrequestModel.result?.length ?? 0)}",
          );
          for (
            var i = 0;
            i < (withdrawalrequestModel.result?.length ?? 0);
            i++
          ) {
            withdrawalTransectionList?.add(
              withdrawalrequestModel.result?[i] ?? withdrawal.Result(),
            );
          }
          final Map<int, withdrawal.Result> postMap = {};
          withdrawalTransectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          withdrawalTransectionList = postMap.values.toList();
          printLog(
            "withdrawalTransectionList length :==> ${(withdrawalTransectionList?.length ?? 0)}",
          );
          setWithdrawalLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setWithdrawalPaginationData(
    int? withdrawaltotalRows,
    int? withdrawaltotalPage,
    int? withdrawalcurrentPage,
    bool? withdrawalmorePage,
  ) {
    this.withdrawalcurrentPage = withdrawalcurrentPage;
    this.withdrawaltotalRows = withdrawaltotalRows;
    this.withdrawaltotalPage = withdrawaltotalPage;
    isMorePage = withdrawalmorePage;
    notifyListeners();
  }

  setWithdrawalLoadMore(withdrawalloadMore) {
    this.withdrawalloadMore = withdrawalloadMore;
    notifyListeners();
  }

  /* Ads Package Transection Api End*/

  /* UsageHistory Transection Api Field */
  // clearUsageHistory() {
  //   usageHistoryList = [];
  //   usageHistoryList?.clear();
  //   usageHistoryloadMore = false;
  //   usageHistorytotalRows;
  //   usageHistorytotalPage;
  //   usageHistorycurrentPage;
  //   usageHistoryisMorePage;
  // }

  /* Clear Ads Package Request Field */
  clearPackageTransection() {
    packageTransectionList = [];
    packageTransectionList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    isMorePage;
  }

  /* Clear Withdrawal Request Field */
  clearWithdrawalTransection() {
    withdrawalTransectionList = [];
    withdrawalTransectionList?.clear();
    withdrawalloadMore = false;
    withdrawaltotalRows;
    withdrawaltotalPage;
    withdrawalcurrentPage;
    withdrawalisMorePage;
    withdrawalisMorePage;
  }

  /* Clear All Field */
  clearProvider() {
    profileModel = ProfileModel();
    adspackageTransectionModel = AdspackageTransectionModel();
    withdrawalrequestModel = WithdrawalrequestModel();
    loading = false;
    position = 0;
    /* UsageHistory Transection Api Field */
    // usageHistoryList = [];
    // usageHistoryList?.clear();
    // loading = false;
    // usageHistoryloadMore = false;
    // usageHistorytotalRows;
    // usageHistorytotalPage;
    // usageHistorycurrentPage;
    // usageHistoryisMorePage;
    /* Ads Package Transection Api Field */
    packageTransectionList = [];
    packageTransectionList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    /* Withdrawal Request Field*/
    withdrawalTransectionList = [];
    withdrawalTransectionList?.clear();
    withdrawalloadMore = false;
    withdrawaltotalRows;
    withdrawaltotalPage;
    withdrawalcurrentPage;
    withdrawalisMorePage;
  }
}
