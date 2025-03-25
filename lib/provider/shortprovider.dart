import 'dart:developer';

import 'package:slike/model/addcommentmodel.dart';
import 'package:slike/model/addcontentreportmodel.dart';
import 'package:slike/model/addremovecontenttoplaylistmodel.dart';
import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:slike/model/addremovesubscribemodel.dart';
import 'package:slike/model/addremovewatchlatermodel.dart';
import 'package:slike/model/commentmodel.dart' as comment;
import 'package:slike/model/commentmodel.dart';
import 'package:slike/model/deletecommentmodel.dart';
import 'package:slike/model/getcontentbychannelmodel.dart' as usercontent;
import 'package:slike/model/getcontentbychannelmodel.dart';
import 'package:slike/model/getreportreasonmodel.dart' as report;
import 'package:slike/model/getreportreasonmodel.dart';
import 'package:slike/model/replaycommentmodel.dart' as replaycomment;
import 'package:slike/model/replaycommentmodel.dart';
import 'package:slike/model/searchmodel.dart';
import 'package:slike/model/shortmodel.dart' as shortlist;
import 'package:slike/model/successmodel.dart';
import 'package:slike/model/watchlatermodel.dart' as watchlatershort;
import 'package:slike/model/watchlatermodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import '../model/shortmodel.dart';
import 'package:slike/model/categorymodel.dart' as category;
import 'package:slike/model/fetchgiftmodel.dart' as fetchgift;

class ShortProvider extends ChangeNotifier {
  CommentModel getcommentModel = CommentModel();
  AddCommentModel addCommentModel = AddCommentModel();
  AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel =
      AddRemoveLikeDifood_appModel();
  DeleteCommentModel deleteCommentModel = DeleteCommentModel();
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();
  GetWatchlaterModel watchlaterModel = GetWatchlaterModel();

  bool loading = false;
  int position = 0;

  /* All Short Field */
  ShortModel shortModel = ShortModel();
  List<shortlist.Result>? shortVideoList = [];
  int? totalRows, totalPage, currentPage;
  bool? morePage;

  /* Perticular User Short Field */
  List<usercontent.Result>? profileShortList = [];
  int? profileShorttotalRows, profileShorttotalPage, profileShortcurrentPage;
  bool? userShortmorePage;

  /* WatchLater Short Field */
  List<watchlatershort.Result>? watchlaterShortList = [];
  int? watchlaterShorttotalRows,
      watchlaterShorttotalPage,
      watchlaterShortcurrentPage;
  bool? watchlaterShortmorePage;

  /* Get Comment Field */
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;
  List<comment.Result>? commentList = [];
  bool commentloading = false, commentLoadmore = false;
  bool addreplaycommentloading = false;
  bool addcommentloading = false;
  int deleteItemIndex = 0;
  bool deletecommentLoading = false;

  /* Report Reason Field */
  int? reporttotalRows, reporttotalPage, reportcurrentPage;
  bool? reportmorePage;
  List<report.Result>? reportReasonList = [];
  bool getcontentreportloading = false, getcontentreportloadmore = false;
  int? reportposition = 0;
  bool isSelectReason = false;
  String reasonId = "";

  GetRepostReasonModel getRepostReasonModel = GetRepostReasonModel();
  AddContentReportModel addContentReportModel = AddContentReportModel();
  bool addcontentreortloading = false;

  ReplayCommentModel replayCommentModel = ReplayCommentModel();

  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();
  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  bool addremovecontentplaylistloading = false,
      getcontentbyChannelloading = false;
  int selectPlaylistindex = 0;
  bool isselectplaylist = false;

  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();
  bool addwatchlaterloading = false;

  // ReplayComment With Pagination
  int? totalRowsReplayComment, totalPageReplayComment, currentPageReplayComment;
  bool? morePageReplayComment;
  List<replaycomment.Result>? replaycommentList = [];
  bool replayCommentloadmore = false, replaycommentloding = false;
  String replayCommentId = "";
  String commentId = "";

  /* Category Field */
  category.CategoryModel categorymodel = category.CategoryModel();
  List<category.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;
  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;
  int? categoryId;

  /* Succsess Model Gift Coin Minus */
  SuccessModel successModel = SuccessModel();

  void selectCategory(int index, int catId) {
    _selectedIndex = index;
    categoryId = catId;
    notifyListeners();
  }

  /* Gift Field */
  fetchgift.FetchGiftModel fetchGiftModel = fetchgift.FetchGiftModel();
  List<fetchgift.Result>? giftList = [];
  bool giftloadMore = false, giftloading = false;
  int? gifttotalRows, gifttotalPage, giftcurrentPage;
  bool? giftisMorePage;
  bool isShowGift = false;
  String? giftUrl;

  /* Select Tab Type */
  int tabType = 0;

  /* Current PageIndex */
  int currentPageIndex = 0;

  /* Search Api */
  SearchModel searchModel = SearchModel();
  bool searchLoading = false;

  void onChangePage(int index) async {
    currentPageIndex = index;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    // categoryloading = isLoading;
    loading = isLoading;
    notifyListeners();
  }

  selectTab(type) {
    tabType = type;
    notifyListeners();
  }

  /* Bottom Navigation All Short Api Start */

  Future<void> getShortList(isPagination, categoryId, pageNo) async {
    if (isPagination == true) {
      loading = false;
    } else {
      loading = true;
    }
    shortModel = await ApiService().shrotslist(categoryId, pageNo);
    printLog("getPostList status :===> ${shortModel.status}");
    printLog("getPostList message :==> ${shortModel.message}");
    if (shortModel.status == 200) {
      setPaginationData(
        shortModel.totalRows,
        shortModel.totalPage,
        shortModel.currentPage,
        shortModel.morePage,
      );
      if (shortModel.result != null && (shortModel.result?.length ?? 0) > 0) {
        log("Short Model length :==> ${(shortModel.result?.length ?? 0)}");
        shortVideoList?.addAll(shortModel.result ?? []);
        log("Short List length :==> ${(shortVideoList?.length ?? 0)}");
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
    this.morePage = morePage;
    notifyListeners();
  }

  clearShortList() {
    shortModel = ShortModel();
    shortVideoList = [];
    shortVideoList?.clear();
    totalRows;
    totalPage;
    currentPage;
    morePage;
    log("ClearShortList");
  }
  /* Bottom Navigation All Short Api End*/

  /* Profile Page Perticular User Short Api Start */
  Future<void> getcontentbyChannelShort(
    isPagination,
    userid,
    chennelId,
    contenttype,
    pageNo,
  ) async {
    if (isPagination == true) {
      loading = false;
    } else {
      loading = true;
    }
    getContentbyChannelModel = await ApiService().contentbyChannel(
      userid,
      chennelId,
      contenttype,
      pageNo,
    );
    if (getContentbyChannelModel.status == 200) {
      setUserShortPaginationData(
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
            profileShortList?.add(
              getContentbyChannelModel.result?[i] ?? usercontent.Result(),
            );
          }
          final Map<int, usercontent.Result> postMap = {};
          profileShortList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          profileShortList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(profileShortList?.length ?? 0)}",
          );
          // setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setUserShortPaginationData(
    int? profileShorttotalRows,
    int? profileShorttotalPage,
    int? profileShortcurrentPage,
    bool? profileShortmorePage,
  ) {
    this.profileShortcurrentPage = profileShortcurrentPage;
    this.profileShorttotalRows = profileShorttotalRows;
    this.profileShorttotalPage = profileShorttotalPage;
    profileShortmorePage = profileShortmorePage;
    notifyListeners();
  }
  /* Profile Page Perticular User Short Api End */

  /* Get Content By WatchLater Section Start*/
  Future<void> getContentByWatchLater(contentType, pageNo) async {
    loading = true;
    watchlaterModel = await ApiService().watchLaterList(contentType, pageNo);
    if (watchlaterModel.status == 200) {
      setWatchLaterShortPaginationData(
        watchlaterModel.totalRows,
        watchlaterModel.totalPage,
        watchlaterModel.currentPage,
        watchlaterModel.morePage,
      );
      if (watchlaterModel.result != null &&
          (watchlaterModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(watchlaterModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (watchlaterModel.result != null &&
            (watchlaterModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(watchlaterModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (watchlaterModel.result?.length ?? 0); i++) {
            watchlaterShortList?.add(
              watchlaterModel.result?[i] ?? watchlatershort.Result(),
            );
          }
          final Map<int, watchlatershort.Result> postMap = {};
          watchlaterShortList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          watchlaterShortList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(watchlaterShortList?.length ?? 0)}",
          );
          // setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setWatchLaterShortPaginationData(
    int? watchlaterShorttotalRows,
    int? watchlaterShorttotalPage,
    int? watchlaterShortcurrentPage,
    bool? watchlaterShortmorePage,
  ) {
    this.watchlaterShortcurrentPage = watchlaterShortcurrentPage;
    this.watchlaterShorttotalRows = watchlaterShorttotalRows;
    this.watchlaterShorttotalPage = watchlaterShorttotalPage;
    watchlaterShortmorePage = watchlaterShortmorePage;
    notifyListeners();
  }

  /* Get Content By WatchLater Section End */
  Future<void> getComment(contenttype, videoid, pageNo) async {
    printLog("getPostList pageNo :==> $pageNo");
    commentloading = true;
    getcommentModel = await ApiService().getcomment(
      contenttype,
      videoid,
      pageNo,
    );
    printLog("getPostList status :===> ${getcommentModel.status}");
    printLog("getPostList message :==> ${getcommentModel.message}");
    if (getcommentModel.status == 200) {
      setCommentPaginationData(
        getcommentModel.totalRows,
        getcommentModel.totalPage,
        getcommentModel.currentPage,
        getcommentModel.morePage,
      );
      if (getcommentModel.result != null &&
          (getcommentModel.result?.length ?? 0) > 0) {
        printLog(
          "postModel length :==> ${(getcommentModel.result?.length ?? 0)}",
        );

        for (var i = 0; i < (getcommentModel.result?.length ?? 0); i++) {
          commentList?.add(getcommentModel.result?[i] ?? comment.Result());
        }
        final Map<int, comment.Result> postMap = {};
        commentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        commentList = postMap.values.toList();
        printLog("shortVideoList length :==> ${(commentList?.length ?? 0)}");
        setCommentLoadMore(false);
      }
    }
    commentloading = false;
    notifyListeners();
  }

  setCommentPaginationData(
    int? totalRowsComment,
    int? totalPageComment,
    int? currentPageComment,
    bool? morePageComment,
  ) {
    this.currentPageComment = currentPageComment;
    this.totalRowsComment = totalRowsComment;
    this.totalPageComment = totalPageComment;
    morePageComment = morePageComment;
    notifyListeners();
  }

  setCommentLoadMore(commentLoadmore) {
    this.commentLoadmore = commentLoadmore;
    notifyListeners();
  }

  /* Add Comment And Add Replay Comment Short */
  getaddcomment(
    position,
    contenttype,
    contentid,
    episodeid,
    comment,
    commentid,
    isShortPage,
  ) {
    if (isShortPage == "profile") {
      profileShortList?[position].totalComment =
          (profileShortList?[position].totalComment ?? 0) + 1;
    } else if (isShortPage == "watchlater") {
      watchlaterShortList?[position].totalComment =
          (watchlaterShortList?[position].totalComment ?? 0) + 1;
    } else {
      shortVideoList?[position].totalComment =
          (shortVideoList?[position].totalComment ?? 0) + 1;
    }
    notifyListeners();
    addcomment(contenttype, contentid, episodeid, comment, commentid);
  }

  getaddReplayComment(
    contenttype,
    contentid,
    episodeid,
    comment,
    commentid,
  ) async {
    setSendingReplayComment(true);
    addCommentModel = await ApiService().addcomment(
      contenttype,
      contentid,
      episodeid,
      comment,
      commentid,
    );
    await getReplayComment(commentid, "0");
    setSendingReplayComment(false);
  }

  setSendingReplayComment(isSending) {
    printLog("isSending ==> $isSending");
    addreplaycommentloading = isSending;
    notifyListeners();
  }

  addcomment(contenttype, contentid, episodeid, comment, commentid) async {
    setSendingComment(true);
    addCommentModel = await ApiService().addcomment(
      contenttype,
      contentid,
      episodeid,
      comment,
      commentid,
    );
    await getComment(contenttype, contentid, "0");
    setSendingComment(false);
  }

  setSendingComment(isSending) {
    printLog("isSending ==> $isSending");
    addcommentloading = isSending;
    notifyListeners();
  }

  /* Delete Comment And Delete Replay Comment */

  getDeleteComment(commentid, isComment, index, isShortPage) async {
    deleteItemIndex = index;
    if (isComment == true) {
      if (isShortPage == "profile") {
        profileShortList?[index].totalComment =
            (profileShortList?[index].totalComment ?? 0) - 1;
      } else if (isShortPage == "watchlater") {
        watchlaterShortList?[index].totalComment =
            (watchlaterShortList?[index].totalComment ?? 0) - 1;
      } else {
        shortVideoList?[index].totalComment =
            (shortVideoList?[index].totalComment ?? 0) - 1;
      }
    }
    setDeletePlaylistLoading(true);
    deleteCommentModel = await ApiService().deleteComment(commentid);
    setDeletePlaylistLoading(false);
    if (isComment == true) {
      commentList?.removeAt(index);
      printLog("remove Comment Item");
    } else {
      replaycommentList?.removeAt(index);
      printLog("remove ReplayComment Item");
    }
  }

  setDeletePlaylistLoading(isSending) {
    printLog("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

  /* Simple Short Like And Difood_app */
  shortLike(position, contenttype, contentid, status, episodeId) {
    if ((shortVideoList?[position].isUserLikeDifood_app ?? 0) == 0) {
      shortVideoList?[position].isUserLikeDifood_app = 1;
      shortVideoList?[position].totalLike =
          (shortVideoList?[position].totalLike ?? 0) + 1;
    } else if ((shortVideoList?[position].isUserLikeDifood_app ?? 0) == 2) {
      shortVideoList?[position].isUserLikeDifood_app = 1;
      shortVideoList?[position].totalLike =
          (shortVideoList?[position].totalLike ?? 0) + 1;
      if ((shortVideoList?[position].totalDifood_app ?? 0) > 0) {
        shortVideoList?[position].totalDifood_app =
            (shortVideoList?[position].totalDifood_app ?? 0) - 1;
      }
    } else {
      shortVideoList?[position].isUserLikeDifood_app = 0;
      if ((shortVideoList?[position].totalLike ?? 0) > 0) {
        shortVideoList?[position].totalLike =
            (shortVideoList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDifood_app(contenttype, contentid, status, episodeId);
  }

  shortDifood_app(position, contenttype, contentid, status, episodeId) {
    if ((shortVideoList?[position].isUserLikeDifood_app ?? 0) == 0) {
      shortVideoList?[position].isUserLikeDifood_app = 2;
      shortVideoList?[position].totalDifood_app =
          (shortVideoList?[position].totalDifood_app ?? 0) + 1;
    } else if ((shortVideoList?[position].isUserLikeDifood_app ?? 0) == 1) {
      shortVideoList?[position].isUserLikeDifood_app = 2;
      shortVideoList?[position].totalDifood_app =
          (shortVideoList?[position].totalDifood_app ?? 0) + 1;
      if ((shortVideoList?[position].totalLike ?? 0) > 0) {
        shortVideoList?[position].totalLike =
            (shortVideoList?[position].totalLike ?? 0) - 1;
      }
    } else {
      shortVideoList?[position].isUserLikeDifood_app = 0;
      if ((shortVideoList?[position].totalDifood_app ?? 0) > 0) {
        shortVideoList?[position].totalDifood_app =
            (shortVideoList?[position].totalDifood_app ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDifood_app(contenttype, contentid, status, episodeId);
  }

  /* Profile Short Like And Difood_app */
  profileShortLike(position, contenttype, contentid, status, episodeId) {
    if ((profileShortList?[position].isUserLikeDifood_app ?? 0) == 0) {
      profileShortList?[position].isUserLikeDifood_app = 1;
      profileShortList?[position].totalLike =
          (profileShortList?[position].totalLike ?? 0) + 1;
    } else if ((profileShortList?[position].isUserLikeDifood_app ?? 0) == 2) {
      profileShortList?[position].isUserLikeDifood_app = 1;
      profileShortList?[position].totalLike =
          (profileShortList?[position].totalLike ?? 0) + 1;
      if ((profileShortList?[position].totalDifood_app ?? 0) > 0) {
        profileShortList?[position].totalDifood_app =
            (profileShortList?[position].totalDifood_app ?? 0) - 1;
      }
    } else {
      profileShortList?[position].isUserLikeDifood_app = 0;
      if ((profileShortList?[position].totalLike ?? 0) > 0) {
        profileShortList?[position].totalLike =
            (profileShortList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDifood_app(contenttype, contentid, status, episodeId);
  }

  profileShortDifood_app(position, contenttype, contentid, status, episodeId) {
    if ((profileShortList?[position].isUserLikeDifood_app ?? 0) == 0) {
      profileShortList?[position].isUserLikeDifood_app = 2;
      profileShortList?[position].totalDifood_app =
          (profileShortList?[position].totalDifood_app ?? 0) + 1;
    } else if ((profileShortList?[position].isUserLikeDifood_app ?? 0) == 1) {
      profileShortList?[position].isUserLikeDifood_app = 2;
      profileShortList?[position].totalDifood_app =
          (profileShortList?[position].totalDifood_app ?? 0) + 1;
      if ((profileShortList?[position].totalLike ?? 0) > 0) {
        profileShortList?[position].totalLike =
            (profileShortList?[position].totalLike ?? 0) - 1;
      }
    } else {
      profileShortList?[position].isUserLikeDifood_app = 0;
      if ((profileShortList?[position].totalDifood_app ?? 0) > 0) {
        profileShortList?[position].totalDifood_app =
            (profileShortList?[position].totalDifood_app ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDifood_app(contenttype, contentid, status, episodeId);
  }

  /* WatchLater Short Like And Difood_app */
  watchLaterShortLike(position, contenttype, contentid, status, episodeId) {
    if ((watchlaterShortList?[position].isUserLikeDifood_app ?? 0) == 0) {
      watchlaterShortList?[position].isUserLikeDifood_app = 1;
      watchlaterShortList?[position].totalLike =
          (watchlaterShortList?[position].totalLike ?? 0) + 1;
    } else if ((watchlaterShortList?[position].isUserLikeDifood_app ?? 0) ==
        2) {
      watchlaterShortList?[position].isUserLikeDifood_app = 1;
      watchlaterShortList?[position].totalLike =
          (watchlaterShortList?[position].totalLike ?? 0) + 1;
      if ((watchlaterShortList?[position].totalDifood_app ?? 0) > 0) {
        watchlaterShortList?[position].totalDifood_app =
            (watchlaterShortList?[position].totalDifood_app ?? 0) - 1;
      }
    } else {
      watchlaterShortList?[position].isUserLikeDifood_app = 0;
      if ((watchlaterShortList?[position].totalLike ?? 0) > 0) {
        watchlaterShortList?[position].totalLike =
            (watchlaterShortList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDifood_app(contenttype, contentid, status, episodeId);
  }

  watchLaterShortDifood_app(
    position,
    contenttype,
    contentid,
    status,
    episodeId,
  ) {
    if ((watchlaterShortList?[position].isUserLikeDifood_app ?? 0) == 0) {
      watchlaterShortList?[position].isUserLikeDifood_app = 2;
      watchlaterShortList?[position].totalDifood_app =
          (watchlaterShortList?[position].totalDifood_app ?? 0) + 1;
    } else if ((watchlaterShortList?[position].isUserLikeDifood_app ?? 0) ==
        1) {
      watchlaterShortList?[position].isUserLikeDifood_app = 2;
      watchlaterShortList?[position].totalDifood_app =
          (watchlaterShortList?[position].totalDifood_app ?? 0) + 1;
      if ((watchlaterShortList?[position].totalLike ?? 0) > 0) {
        watchlaterShortList?[position].totalLike =
            (watchlaterShortList?[position].totalLike ?? 0) - 1;
      }
    } else {
      watchlaterShortList?[position].isUserLikeDifood_app = 0;
      if ((watchlaterShortList?[position].totalDifood_app ?? 0) > 0) {
        watchlaterShortList?[position].totalDifood_app =
            (watchlaterShortList?[position].totalDifood_app ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDifood_app(contenttype, contentid, status, episodeId);
  }

  Future<void> addLikeDifood_app(
    contenttype,
    contentid,
    status,
    episodeId,
  ) async {
    printLog("addLikeDifood_app postId :==> $contentid");
    addRemoveLikeDifood_appModel = await ApiService().addRemoveLikeDifood_app(
      contenttype,
      contentid,
      status,
      episodeId,
    );
    printLog(
      "addLikeDifood_app status :==> ${addRemoveLikeDifood_appModel.status}",
    );
    printLog(
      "addLikeDifood_app message :==> ${addRemoveLikeDifood_appModel.message}",
    );
  }

  /* Get Report Reason List With Pagination */
  Future<void> getReportReason(type, pageNo) async {
    printLog("getPostList pageNo :==> $pageNo");
    getcontentreportloading = true;
    getRepostReasonModel = await ApiService().reportReason(type, pageNo);
    printLog("getPostList status :===> ${getRepostReasonModel.status}");
    printLog("getPostList message :==> ${getRepostReasonModel.message}");
    if (getRepostReasonModel.status == 200) {
      setReportReasonPaginationData(
        getRepostReasonModel.totalRows,
        getRepostReasonModel.totalPage,
        getRepostReasonModel.currentPage,
        getRepostReasonModel.morePage,
      );
      if (getRepostReasonModel.result != null &&
          (getRepostReasonModel.result?.length ?? 0) > 0) {
        printLog(
          "postModel length first:==> ${(getRepostReasonModel.result?.length ?? 0)}",
        );

        printLog(
          "postModel length :==> ${(getRepostReasonModel.result?.length ?? 0)}",
        );

        for (var i = 0; i < (getRepostReasonModel.result?.length ?? 0); i++) {
          reportReasonList?.add(
            getRepostReasonModel.result?[i] ?? report.Result(),
          );
        }
        final Map<int, report.Result> postMap = {};
        reportReasonList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        reportReasonList = postMap.values.toList();
        printLog(
          "Report Reason length :==> ${(reportReasonList?.length ?? 0)}",
        );
        setReportReasonLoadMore(false);
      }
    } else {
      printLog("else Api");
    }
    getcontentreportloading = false;
    notifyListeners();
  }

  setReportReasonPaginationData(
    int? reporttotalRows,
    int? reporttotalPage,
    int? reportcurrentPage,
    bool? reportmorePage,
  ) {
    this.reportcurrentPage = reportcurrentPage;
    this.reporttotalRows = reporttotalRows;
    this.reporttotalPage = reporttotalPage;
    reportmorePage = reportmorePage;
    notifyListeners();
  }

  setReportReasonLoadMore(getcontentreportloadmore) {
    this.getcontentreportloadmore = getcontentreportloadmore;
    notifyListeners();
  }

  /* Add Report By Perticular Content */
  addContentReport(reportUserid, contentid, message, contenttype) async {
    addcontentreortloading = true;
    addContentReportModel = await ApiService().addContentReport(
      reportUserid,
      contentid,
      message,
      contenttype,
    );
    addcontentreortloading = false;
    notifyListeners();
  }

  /* Add Remove To Playlist */
  addremoveContentToPlaylist(
    chennelId,
    playlistId,
    contenttype,
    contentid,
    episodeid,
    type,
  ) async {
    addremovecontentplaylistloading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
          chennelId,
          playlistId,
          contenttype,
          contentid,
          episodeid,
          type,
        );
    addremovecontentplaylistloading = false;
    notifyListeners();
  }

  /* Get All Playlist For Perticular User */
  getcontentbyChannel(userid, chennelId, contenttype, pageNo) async {
    getcontentbyChannelloading = true;
    getContentbyChannelModel = await ApiService().contentbyChannel(
      userid,
      chennelId,
      contenttype,
      pageNo,
    );
    getcontentbyChannelloading = false;
    notifyListeners();
  }

  /* Replay Comment Pagination Start */

  Future<void> getReplayComment(commentid, pageNo) async {
    printLog("getPostList pageNo :==> $pageNo");
    replaycommentloding = true;
    replayCommentModel = await ApiService().replayComment(commentid, pageNo);
    printLog("getPostList status :===> ${replayCommentModel.status}");
    printLog("getPostList message :==> ${replayCommentModel.message}");
    if (replayCommentModel.status == 200) {
      setReplayCommentPaginationData(
        replayCommentModel.totalRows,
        replayCommentModel.totalPage,
        replayCommentModel.currentPage,
        replayCommentModel.morePage,
      );
      if (replayCommentModel.result != null &&
          (replayCommentModel.result?.length ?? 0) > 0) {
        printLog(
          "postModel length :==> ${(replayCommentModel.result?.length ?? 0)}",
        );

        for (var i = 0; i < (replayCommentModel.result?.length ?? 0); i++) {
          replaycommentList?.add(
            replayCommentModel.result?[i] ?? replaycomment.Result(),
          );
        }
        final Map<int, replaycomment.Result> postMap = {};
        replaycommentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        replaycommentList = postMap.values.toList();
        printLog(
          "shortVideoList length :==> ${(replaycommentList?.length ?? 0)}",
        );
        setReplayCommentLoadMore(false);
      }
    }
    replaycommentloding = false;
    notifyListeners();
  }

  setReplayCommentPaginationData(
    int? totalRowsReplayComment,
    int? totalPageReplayComment,
    int? currentPageReplayComment,
    bool? morePageReplayComment,
  ) {
    this.currentPageReplayComment = currentPageReplayComment;
    this.totalRowsReplayComment = totalRowsReplayComment;
    this.totalPageReplayComment = totalPageReplayComment;
    morePageReplayComment = morePageReplayComment;
    notifyListeners();
  }

  setReplayCommentLoadMore(replayCommentloadmore) {
    this.replayCommentloadmore = replayCommentloadmore;
    notifyListeners();
  }

  /* Replay Comment Pagination End */

  /* Add Remove Subscribe For Any Channel */
  addremoveSubscribe(index, touserid, type, isShortPage) {
    if (isShortPage == "profile") {
      if ((profileShortList?[index].isSubscribe ?? 0) == 0) {
        profileShortList?[index].isSubscribe = 1;
      } else {
        profileShortList?[index].isSubscribe = 0;
      }
    } else if (isShortPage == "watchlater") {
      if ((watchlaterShortList?[index].isSubscribe ?? 0) == 0) {
        watchlaterShortList?[index].isSubscribe = 1;
      } else {
        watchlaterShortList?[index].isSubscribe = 0;
      }
    } else {
      if ((shortVideoList?[index].isSubscribe ?? 0) == 0) {
        shortVideoList?[index].isSubscribe = 1;
      } else {
        shortVideoList?[index].isSubscribe = 0;
      }
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

  /* Add Remove Watch Later For Short */
  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    addwatchlaterloading = true;
    addremoveWatchlaterModel = await ApiService().addremoveWatchLater(
      contenttype,
      contentid,
      episodeid,
      type,
    );
    addwatchlaterloading = false;
    notifyListeners();
  }

  /* Some Helper Method Start */
  selectReportReason(int index, selectReason, isReasonId) {
    reportposition = index;
    isSelectReason = selectReason;
    reasonId = isReasonId;
    printLog("reasonId===> $reasonId");
    notifyListeners();
  }

  selectPlaylist(int index, bool chack) {
    selectPlaylistindex = index;
    isselectplaylist = chack;
    notifyListeners();
  }
  /* Some Helper Method End */

  storeReplayCommentId(isReplayCommentId) async {
    replayCommentId = isReplayCommentId;
    notifyListeners();
  }

  storeContentId(isContentId) async {
    commentId = isContentId;
    notifyListeners();
  }

  changePageViewIndex(int index) {
    position = index;
    notifyListeners();
  }

  /* ============================== Caterory Start ============================== */

  Future<void> getCategory(pageNo) async {
    categoryloading = true;
    categorymodel = await ApiService().videoCategory(pageNo);
    if (categorymodel.status == 200) {
      setCategoryPaginationData(
        categorymodel.totalRows,
        categorymodel.totalPage,
        categorymodel.currentPage,
        categorymodel.morePage,
      );
      if (categorymodel.result != null &&
          (categorymodel.result?.length ?? 0) > 0) {
        printLog(
          "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}",
        );
        if (categorymodel.result != null &&
            (categorymodel.result?.length ?? 0) > 0) {
          printLog(
            "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (categorymodel.result?.length ?? 0); i++) {
            // categorydataList?.add(category.Result(id: 0, name: "Home"));
            categorydataList?.add(
              categorymodel.result?[i] ?? category.Result(),
            );
          }
          final Map<int, category.Result> postMap = {};
          categorydataList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          categorydataList = postMap.values.toList();
          printLog(
            "CategoryModel length :==> ${(categorydataList?.length ?? 0)}",
          );
          setCategoryLoadMore(false);
        }
      }
    }
    categoryloading = false;
    notifyListeners();
  }

  setCategoryPaginationData(
    int? categorytotalRows,
    int? categorytotalPage,
    int? categorycurrentPage,
    bool? videolistisMorePage,
  ) {
    this.categorycurrentPage = categorycurrentPage;
    this.categorytotalRows = categorytotalRows;
    this.categorytotalPage = categorytotalPage;
    categoryisMorePage = categoryisMorePage;
    notifyListeners();
  }

  setCategoryLoadMore(categoryloadMore) {
    this.categoryloadMore = categoryloadMore;
    notifyListeners();
  }

  clearCategory() {
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;
  }

  /* ============================== Category End ============================== */

  /*  Fetch All Gift Start */

  Future<void> fetchGift(pageNo) async {
    giftloading = true;
    fetchGiftModel = await ApiService().getGift(pageNo);
    if (fetchGiftModel.status == 200) {
      setGiftPaginationData(
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
          setGiftLoadMore(false);
        }
      }
    }
    giftloading = false;
    notifyListeners();
  }

  setGiftPaginationData(
    int? gifttotalRows,
    int? gifttotalPage,
    int? giftcurrentPage,
    bool? giftmorePage,
  ) {
    this.giftcurrentPage = giftcurrentPage;
    this.gifttotalRows = gifttotalRows;
    this.gifttotalPage = gifttotalPage;
    giftmorePage = giftmorePage;
    notifyListeners();
  }

  setGiftLoadMore(giftloadMore) {
    this.giftloadMore = giftloadMore;
    notifyListeners();
  }

  showGift({required String? imageUrl}) async {
    giftUrl = imageUrl ?? "";
    notifyListeners();
    isShowGift = true;
    Future.delayed(const Duration(milliseconds: 5000), () {
      clearImage();
    });
    isShowGift = false;
    printLog("giftUrl==>$isShowGift");
  }

  clearImage() {
    giftUrl = null;
    notifyListeners();
  }

  /*  Fetch All Gift Stop */

  /* Search Api */
  getSearch(name, type) async {
    searchLoading = true;
    searchModel = await ApiService().search(name, type);
    searchLoading = false;
    notifyListeners();
  }

  /* Coin Minus */

  minusCoin(channelId, giftcoin) async {
    successModel = await ApiService().coinMinus(channelId, giftcoin);
    notifyListeners();
  }

  /* Clear Provider */

  clearShort() {
    shortModel = ShortModel();
    getcommentModel = CommentModel();
    addCommentModel = AddCommentModel();
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel();
    deleteCommentModel = DeleteCommentModel();
    addremoveSubscribeModel = AddremoveSubscribeModel();
    watchlaterModel = GetWatchlaterModel();
    loading = false;
    _selectedIndex = -1;
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    isSelectReason = false;
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    /* All Short Field */
    log("Clear ShortList");
    shortVideoList = [];
    shortVideoList?.clear();
    totalRows;
    totalPage;
    currentPage;
    morePage;
    /* Perticular User Short Field */
    profileShortList = [];
    profileShortList?.clear();
    profileShorttotalRows;
    profileShorttotalPage;
    profileShortcurrentPage;
    userShortmorePage;
    /* WatchLater Short Field */
    watchlaterShortList = [];
    watchlaterShortList?.clear();
    watchlaterShorttotalRows;
    watchlaterShorttotalPage;
    watchlaterShortcurrentPage;
    watchlaterShortmorePage;
  }

  clearProvider() {
    shortModel = ShortModel();
    getcommentModel = CommentModel();
    addCommentModel = AddCommentModel();
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel();
    deleteCommentModel = DeleteCommentModel();
    addremoveSubscribeModel = AddremoveSubscribeModel();
    watchlaterModel = GetWatchlaterModel();
    loading = false;
    _selectedIndex = -1;
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    isSelectReason = false;
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    /* All Short Field */
    log("Clear ShortList");
    shortVideoList = [];
    shortVideoList?.clear();
    totalRows;
    totalPage;
    currentPage;
    morePage;
    /* Perticular User Short Field */
    profileShortList = [];
    profileShortList?.clear();
    profileShorttotalRows;
    profileShorttotalPage;
    profileShortcurrentPage;
    userShortmorePage;
    /* WatchLater Short Field */
    watchlaterShortList = [];
    watchlaterShortList?.clear();
    watchlaterShorttotalRows;
    watchlaterShorttotalPage;
    watchlaterShortcurrentPage;
    watchlaterShortmorePage;
    /* Get Comment Field */
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    addreplaycommentloading = false;
    getRepostReasonModel = GetRepostReasonModel();
    addContentReportModel = AddContentReportModel();
    getcontentreportloading = false;
    addcontentreortloading = false;
    reportposition = 0;
    reasonId = "";
    replayCommentModel = ReplayCommentModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremovecontentplaylistloading = false;
    getcontentbyChannelloading = false;
    selectPlaylistindex = 0;
    isselectplaylist = false;
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    addwatchlaterloading = false;
    /* Select Tab Type */
    tabType = 0;
    currentPageIndex = 0;
  }

  clearComment() {
    /* Get Comment Field */
    getcommentModel = CommentModel();
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentloading = false;
    addreplaycommentloading = false;
    addcommentloading = false;
    deleteItemIndex = 0;
    deletecommentLoading = false;
  }

  clearReplayComment() {
    totalRowsReplayComment;
    totalPageReplayComment;
    currentPageReplayComment;
    morePageReplayComment;
    replaycommentList = [];
    replayCommentloadmore = false;
    replaycommentloding = false;
    replayCommentId = "";
  }

  clearSelectReportReason() {
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reportposition = 0;
    isSelectReason = false;
    reasonId = "";
  }
}
