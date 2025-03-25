import 'package:slike/model/addremoveblockchannelmodel.dart';
import 'package:slike/model/addremovesubscribemodel.dart';
import 'package:slike/model/adspackagetransectionmodel.dart' as coinhistory;
import 'package:slike/model/getchannelfeedmodel.dart' as chennalfeed;
import 'package:slike/model/getcontentbychannelmodel.dart' as channelcontent;
import 'package:slike/model/getcontentbychannelmodel.dart';
import 'package:slike/model/getusermarketplacemodel.dart' as shop;
import 'package:slike/model/successmodel.dart';
import 'package:slike/model/withdrawalrequestmodel.dart' as withdrawl;
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:slike/model/profilemodel.dart';
import 'package:slike/webservice/apiservice.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  SuccessModel successModel = SuccessModel();
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();

  AddremoveblockchannelModel addremoveblockchannelModel =
      AddremoveblockchannelModel();

  bool loading = false, profileloading = false;
  bool loadMore = false;
  bool loadingUpdate = false;
  bool deletecontentLoading = false;
  int deleteItemIndex = 0;
  String tabposition = "bio";

  /* Short */
  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  List<channelcontent.Result>? channelContentList = [];
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  /* Feed Content */
  chennalfeed.GetChannelFeedModel getChannelFeedModel =
      chennalfeed.GetChannelFeedModel();
  List<chennalfeed.Result>? channelFeedList = [];
  bool channelloadMore = false;
  int? channeltotalRows, channeltotalPage, channelcurrentPage;
  bool? channelisMorePage;

  /* Shop Content */
  shop.GetUserMarketPlaceModel userMarketPlaceModel =
      shop.GetUserMarketPlaceModel();
  List<shop.Result>? shopList = [];
  bool medialoadMore = false;
  int? mediatotalRows, mediatotalPage, mediacurrentPage;
  bool? mediaisMorePage;

  /* Wallet */
  /* Coin History */
  String walletType = "coinhistory";
  coinhistory.AdspackageTransectionModel adspackageTransectionModel =
      coinhistory.AdspackageTransectionModel();
  List<coinhistory.Result>? packageTransectionList = [];
  bool coinhistoryloadMore = false, coinhistoryloading = false;
  int? coinhistorytotalRows, coinhistorytotalPage, coinhistorycurrentPage;
  bool? coinhistoryisMorePage;

  /* Withdraw History */
  withdrawl.WithdrawalrequestModel withdrawalrequestModel =
      withdrawl.WithdrawalrequestModel();
  List<withdrawl.Result>? withdrawalTransectionList = [];
  bool withdrawalloadMore = false, withdrawalloading = false;
  int? withdrawaltotalRows, withdrawaltotalPage, withdrawalcurrentPage;
  bool? withdrawalisMorePage;

  Future<void> getprofile(BuildContext context, touserid) async {
    printLog("getProfile userID :==> ${Constant.userID}");
    profileloading = true;
    profileModel = await ApiService().profile(touserid);
    printLog("get_profile status :==> ${profileModel.status}");
    printLog("get_profile message :==> ${profileModel.message}");

    if (profileModel.status == 200 && profileModel.result != null) {
      if ((profileModel.result?.length ?? 0) > 0) {
        if (context.mounted) {
          Utils.saveUserCreds(
            userID: profileModel.result?[0].id.toString(),
            firebaseId: profileModel.result?[0].firebaseId.toString(),
            channeId: profileModel.result?[0].channelId.toString(),
            channelName: profileModel.result?[0].channelName.toString(),
            fullName: profileModel.result?[0].fullName.toString(),
            email: profileModel.result?[0].email.toString(),
            mobileNumber: profileModel.result?[0].mobileNumber.toString(),
            image: profileModel.result?[0].image.toString(),
            coverImg: profileModel.result?[0].coverImg.toString(),
            deviceType: profileModel.result?[0].deviceType.toString(),
            deviceToken: profileModel.result?[0].deviceToken.toString(),
            userIsBuy: profileModel.result?[0].isBuy.toString(),
            isAdsFree: profileModel.result?[0].adsFree.toString(),
            isDownload: profileModel.result?[0].isDownload.toString(),
          );
          Utils.loadAds(context);
        }
      }
    }
    profileloading = false;
    notifyListeners();
  }

  Future<void> getProfile(BuildContext context, touserid) async {
    profileloading = true;
    profileModel = await ApiService().profile(touserid);
    profileloading = false;
    notifyListeners();
    print(profileModel.toJson());
  }

  getDeleteContent(index, contenttype, contentid, episodeid) async {
    deleteItemIndex = index;
    setDeletePlaylistLoading(true);
    successModel = await ApiService().deleteContent(
      contenttype,
      contentid,
      episodeid,
    );
    setDeletePlaylistLoading(false);
    channelContentList?.removeAt(index);
  }

  setDeletePlaylistLoading(isSending) {
    printLog("isSending ==> $isSending");
    deletecontentLoading = isSending;
    notifyListeners();
  }

  addremoveBlockChannel(blockUserId, blockChannelId) async {
    loading = true;
    addremoveblockchannelModel = await ApiService().addremoveBlockChannel(
      blockUserId,
      blockChannelId,
    );
    loading = false;
    notifyListeners();
  }

  /* All Content By Channel  */

  Future<void> getcontentbyChannel(
    userid,
    chennelId,
    contenttype,
    pageNo,
  ) async {
    loading = true;
    getContentbyChannelModel = await ApiService().contentbyChannel(
      userid,
      chennelId,
      contenttype,
      pageNo,
    );
    if (getContentbyChannelModel.status == 200) {
      setPaginationData(
        getContentbyChannelModel.totalRows,
        getContentbyChannelModel.totalPage,
        getContentbyChannelModel.currentPage,
        getContentbyChannelModel.morePage,
      );
      if (getContentbyChannelModel.result != null &&
          (getContentbyChannelModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (getContentbyChannelModel.result != null &&
            (getContentbyChannelModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}",
          );
          for (
            var i = 0;
            i < (getContentbyChannelModel.result?.length ?? 0);
            i++
          ) {
            channelContentList?.add(
              getContentbyChannelModel.result?[i] ?? channelcontent.Result(),
            );
          }
          final Map<int, channelcontent.Result> postMap = {};
          channelContentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          channelContentList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(channelContentList?.length ?? 0)}",
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

  /* Load More ProgressBar */

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  Future<void> getUpdateDataForPayment(fullName, email, mobileNumber) async {
    printLog("getUpdateDataForPayment fullname :==> $fullName");
    printLog("getUpdateDataForPayment email :=====> $email");
    printLog("getUpdateDataForPayment mobile :====> $mobileNumber");
    loadingUpdate = true;
    successModel = await ApiService().updateDataForPayment(
      fullName,
      email,
      mobileNumber,
    );
    printLog("getUpdateDataForPayment status :==> ${successModel.status}");
    printLog("getUpdateDataForPayment message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }

  setUpdateLoading(bool isLoading) {
    loadingUpdate = isLoading;
    notifyListeners();
  }

  changeTab(type) {
    tabposition = type;
    notifyListeners();
  }

  clearListData() {
    channelContentList = [];
    channelContentList?.clear();
    getContentbyChannelModel = GetContentbyChannelModel();
  }

  clearProvider() {
    profileModel = ProfileModel();
    successModel = SuccessModel();
    addremoveblockchannelModel = AddremoveblockchannelModel();
    loading = false;
    profileloading = false;
    loadMore = false;
    loadingUpdate = false;
    deletecontentLoading = false;
    deleteItemIndex = 0;
    tabposition = "bio";
    getContentbyChannelModel = GetContentbyChannelModel();
    channelContentList = [];
    channelContentList?.clear();
    totalRows;
    totalPage;
    currentPage;
    isMorePage;

    getChannelFeedModel = chennalfeed.GetChannelFeedModel();
    channelFeedList = [];
    channelloadMore = false;
    channeltotalRows;
    channeltotalPage;
    channelcurrentPage;
    channelisMorePage;
  }

  addremoveSubscribe(touserid, type) {
    if ((profileModel.result?[0].isSubscriber ?? 0) == 0) {
      profileModel.result?[0].isSubscriber = 1;
    } else {
      profileModel.result?[0].isSubscriber = 0;
    }
    notifyListeners();
    getaddremoveSubscribe(touserid, type);
  }

  Future<void> getaddremoveSubscribe(touserid, type) async {
    addremoveSubscribeModel = await ApiService().addremoveSubscribe(
      touserid,
      type,
    );
  }

  /* Channel Feed Content */

  Future<void> getChannelFeed(userId, channelId, pageNo) async {
    loading = true;
    getChannelFeedModel = await ApiService().getChennalFeed(
      userId,
      channelId,
      pageNo,
    );
    if (getChannelFeedModel.status == 200) {
      setChannelFeedPaginationData(
        getChannelFeedModel.totalRows,
        getChannelFeedModel.totalPage,
        getChannelFeedModel.currentPage,
        getChannelFeedModel.morePage,
      );
      if (getChannelFeedModel.result != null &&
          (getChannelFeedModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(getChannelFeedModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (getChannelFeedModel.result != null &&
            (getChannelFeedModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(getChannelFeedModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (getChannelFeedModel.result?.length ?? 0); i++) {
            channelFeedList?.add(
              getChannelFeedModel.result?[i] ?? chennalfeed.Result(),
            );
          }
          printLog("Array length :==> ${(channelFeedList?.length ?? 0)}");
          final Map<int, chennalfeed.Result> postMap = {};
          channelFeedList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          channelFeedList = postMap.values.toList();
          printLog(
            "Podcast Episode  length :==> ${(channelFeedList?.length ?? 0)}",
          );
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setChannelFeedPaginationData(
    int? channeltotalRows,
    int? channeltotalPage,
    int? channelcurrentPage,
    bool? channelisMorePage,
  ) {
    this.channelcurrentPage = channelcurrentPage;
    this.channeltotalRows = channeltotalRows;
    this.channeltotalPage = channeltotalPage;
    channelisMorePage = channelisMorePage;
    notifyListeners();
  }

  setChannelFeedLoadMore(channelloadMore) {
    this.channelloadMore = channelloadMore;
    notifyListeners();
  }

  deletePost(postId, channelid) async {
    successModel = await ApiService().deletePost(postId, channelid);
    notifyListeners();
  }

  clearChannelFeed() {
    getChannelFeedModel = chennalfeed.GetChannelFeedModel();
    channelFeedList = [];
    channelloadMore = false;
    channeltotalRows;
    channeltotalPage;
    channelcurrentPage;
    channelisMorePage;
  }

  /* Channel Media Content */

  Future<void> getShop(toUserId, pageNo) async {
    loading = true;
    userMarketPlaceModel = await ApiService().getUserMarketPlace(
      toUserId,
      pageNo,
    );
    if (userMarketPlaceModel.status == 200) {
      setShopPaginationData(
        userMarketPlaceModel.totalRows,
        userMarketPlaceModel.totalPage,
        userMarketPlaceModel.currentPage,
        userMarketPlaceModel.morePage,
      );
      if (userMarketPlaceModel.result != null &&
          (userMarketPlaceModel.result?.length ?? 0) > 0) {
        printLog(
          "UserProduct length :==> ${(userMarketPlaceModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (userMarketPlaceModel.result != null &&
            (userMarketPlaceModel.result?.length ?? 0) > 0) {
          printLog(
            "UserProduct length :==> ${(userMarketPlaceModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (userMarketPlaceModel.result?.length ?? 0); i++) {
            shopList?.add(userMarketPlaceModel.result?[i] ?? shop.Result());
          }
          final Map<int, shop.Result> postMap = {};
          shopList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          shopList = postMap.values.toList();
          printLog("UserProductList  length :==> ${(shopList?.length ?? 0)}");
          setShopLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setShopPaginationData(
    int? mediatotalRows,
    int? mediatotalPage,
    int? mediacurrentPage,
    bool? mediaisMorePage,
  ) {
    this.mediacurrentPage = mediacurrentPage;
    this.mediatotalRows = mediatotalRows;
    this.mediatotalPage = mediatotalPage;
    mediaisMorePage = mediaisMorePage;
    notifyListeners();
  }

  setShopLoadMore(medialoadMore) {
    this.medialoadMore = medialoadMore;
    notifyListeners();
  }

  clearShop() {
    userMarketPlaceModel = shop.GetUserMarketPlaceModel();
    shopList = [];
    medialoadMore = false;
    mediatotalRows;
    mediatotalPage;
    mediacurrentPage;
    mediaisMorePage;
  }

  /* ============================================ Wallet tab ============================================ */
  selectWalletTab(type) {
    walletType = type;
    notifyListeners();
  }

  /* ============================================ Coin History ============================================ */
  Future<void> getCoinHistory(pageNo) async {
    coinhistoryloading = true;
    adspackageTransectionModel = await ApiService().adsPackageTransection(
      pageNo,
    );
    if (adspackageTransectionModel.status == 200) {
      setCoinHistoryPaginationData(
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
              adspackageTransectionModel.result?[i] ?? coinhistory.Result(),
            );
          }
          final Map<int, coinhistory.Result> postMap = {};
          packageTransectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          packageTransectionList = postMap.values.toList();
          printLog(
            "adsPackageTransectionList length :==> ${(packageTransectionList?.length ?? 0)}",
          );
          setCoinHistoryLoadMore(false);
        }
      }
    }
    coinhistoryloading = false;
    notifyListeners();
  }

  setCoinHistoryPaginationData(
    int? coinhistorytotalRows,
    int? coinhistorytotalPage,
    int? coinhistorycurrentPage,
    bool? coinhistorymorePage,
  ) {
    this.coinhistorycurrentPage = coinhistorycurrentPage;
    this.coinhistorytotalRows = coinhistorytotalRows;
    this.coinhistorytotalPage = coinhistorytotalPage;
    coinhistorymorePage = coinhistorymorePage;
    notifyListeners();
  }

  setCoinHistoryLoadMore(coinhistoryloadMore) {
    this.coinhistoryloadMore = coinhistoryloadMore;
    notifyListeners();
  }

  clearPackageTransection() {
    adspackageTransectionModel = coinhistory.AdspackageTransectionModel();
    packageTransectionList = [];
    packageTransectionList?.clear();
    coinhistoryloadMore = false;
    coinhistoryloading = false;
    coinhistorytotalRows;
    coinhistorytotalPage;
    coinhistorycurrentPage;
    coinhistoryisMorePage;
  }

  Future<void> getWithdrawalTransection(pageNo) async {
    withdrawalloading = true;
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
              withdrawalrequestModel.result?[i] ?? withdrawl.Result(),
            );
          }
          final Map<int, withdrawl.Result> postMap = {};
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
    withdrawalloading = false;
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

  /* ============================================ Coin History ============================================ */
  /* ============================================ Wallet tab ============================================ */
}
