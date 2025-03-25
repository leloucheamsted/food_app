import 'package:slike/model/subscriberlistmodel.dart' as subscriber;
import 'package:slike/model/subscriberlistmodel.dart' as follower;
import 'package:slike/model/subscriberlistmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:slike/webservice/apiservice.dart';

class SubscribedChannelProvider extends ChangeNotifier {
  /* Following Field */
  SubscriberlistModel subscriberlistModel = SubscriberlistModel();
  List<subscriber.Result>? subscriberList = [];
  bool subscriberloadMore = false, subscriberLoading = false;
  int? subscribertotalRows, subscribertotalPage, subscribercurrentPage;
  bool? subscriberisMorePage;

  /* Follower Field */
  follower.SubscriberlistModel followerModel = follower.SubscriberlistModel();
  List<subscriber.Result>? followerList = [];
  bool followerloadMore = false, followerLoading = false;
  int? followertotalRows, followertotalPage, followercurrentPage;
  bool? followerisMorePage;

  String selectedTab = "following";

  selectTab(tab) {
    selectedTab = tab;
    notifyListeners();
  }

  /* Following List  */

  Future<void> getFollowingList(userId, pageNo) async {
    subscriberLoading = true;
    subscriberlistModel = await ApiService().getFollowingList(userId, pageNo);
    if (subscriberlistModel.status == 200) {
      setFollowingPaginationData(
        subscriberlistModel.totalRows,
        subscriberlistModel.totalPage,
        subscriberlistModel.currentPage,
        subscriberlistModel.morePage,
      );
      if (subscriberlistModel.result != null &&
          (subscriberlistModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(subscriberlistModel.result?.length ?? 0)}",
        );
        if (subscriberlistModel.result != null &&
            (subscriberlistModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(subscriberlistModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (subscriberlistModel.result?.length ?? 0); i++) {
            subscriberList?.add(
              subscriberlistModel.result?[i] ?? subscriber.Result(),
            );
          }
          final Map<int, subscriber.Result> postMap = {};
          subscriberList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          subscriberList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(subscriberList?.length ?? 0)}",
          );
          setFollowingLoadMore(false);
        }
      }
    }
    subscriberLoading = false;
    notifyListeners();
  }

  setFollowingPaginationData(
    int? subscribertotalRows,
    int? subscribertotalPage,
    int? subscribercurrentPage,
    bool? subscriberisMorePage,
  ) {
    this.subscribercurrentPage = subscribercurrentPage;
    this.subscribertotalRows = subscribertotalRows;
    this.subscribertotalPage = subscribertotalPage;
    subscriberisMorePage = subscriberisMorePage;
    notifyListeners();
  }

  setFollowingLoadMore(subscriberloadMore) {
    this.subscriberloadMore = subscriberloadMore;
    notifyListeners();
  }

  clearFollowing() {
    subscriberlistModel = SubscriberlistModel();
    subscriberList = [];
    subscriberList?.clear();
    subscriberloadMore = false;
    subscriberLoading = false;
    subscribertotalRows;
    subscribertotalPage;
    subscribercurrentPage;
    subscriberisMorePage;
  }

  /* Follower List */

  Future<void> getFollowerList(userId, pageNo) async {
    followerLoading = true;
    followerModel = await ApiService().getFollowerList(userId, pageNo);
    if (followerModel.status == 200) {
      setFollowerPaginationData(
        followerModel.totalRows,
        followerModel.totalPage,
        followerModel.currentPage,
        followerModel.morePage,
      );
      if (followerModel.result != null &&
          (followerModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(followerModel.result?.length ?? 0)}",
        );
        if (followerModel.result != null &&
            (followerModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(followerModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (followerModel.result?.length ?? 0); i++) {
            followerList?.add(followerModel.result?[i] ?? subscriber.Result());
          }
          final Map<int, subscriber.Result> postMap = {};
          followerList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          followerList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(followerList?.length ?? 0)}",
          );
          setFollowingLoadMore(false);
        }
      }
    }
    followerLoading = false;
    notifyListeners();
  }

  setFollowerPaginationData(
    int? followertotalRows,
    int? followertotalPage,
    int? followercurrentPage,
    bool? followerisMorePage,
  ) {
    this.followercurrentPage = followercurrentPage;
    this.followertotalRows = followertotalRows;
    this.followertotalPage = followertotalPage;
    followerisMorePage = followerisMorePage;
    notifyListeners();
  }

  setFollowerLoadMore(followerloadMore) {
    this.followerloadMore = followerloadMore;
    notifyListeners();
  }

  clearFollower() {
    /* Follower Field */
    followerModel = follower.SubscriberlistModel();
    followerList = [];
    followerloadMore = false;
    followerLoading = false;
    followertotalRows;
    followertotalPage;
    followercurrentPage;
    followerisMorePage;
  }

  clearProvider() {
    subscriberlistModel = SubscriberlistModel();
    subscriberList = [];
    subscriberloadMore = false;
    subscriberLoading = false;
    subscribertotalRows;
    subscribertotalPage;
    subscribercurrentPage;
    subscriberisMorePage;

    /* Follower Field */
    followerModel = follower.SubscriberlistModel();
    followerList = [];
    followerloadMore = false;
    followerLoading = false;
    followertotalRows;
    followertotalPage;
    followercurrentPage;
    followerisMorePage;

    selectedTab = "following";
  }
}
