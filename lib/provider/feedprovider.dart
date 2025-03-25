import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:slike/model/addcommentmodel.dart';
import 'package:slike/model/addcontentreportmodel.dart';
import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:slike/model/addremovesubscribemodel.dart';
import 'package:slike/model/getpostcommentmodel.dart' as comment;
import 'package:slike/model/getpostcommentmodel.dart' as replaycomment;
import 'package:slike/model/getreportreasonmodel.dart' as report;
import 'package:slike/model/postmodel.dart' as feedpost;
import 'package:slike/model/categorymodel.dart' as category;
import 'package:slike/model/successmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';

class FeedProvider extends ChangeNotifier {
  /* Get All Feed  */
  feedpost.PostModel postModel = feedpost.PostModel();
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  List<feedpost.Result>? feedPostList = [];
  bool loading = false, loadMore = false;

  /* Add Remove Subscriber */
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();
  /* Add Remove Like Difood_app */
  AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel =
      AddRemoveLikeDifood_appModel();

  /* AddPostComment Model */
  AddCommentModel addPostCommentModel = AddCommentModel();
  bool addCommentLoading = false;
  String? postId, commentId;

  /* Get PostComment */
  comment.GetPostCommentModel getPostCommentModel =
      comment.GetPostCommentModel();
  int? commenttotalRows, commenttotalPage, commentcurrentPage;
  bool? commentisMorePage;
  List<comment.Result>? commentList = [];
  bool commentloading = false, commentloadMore = false;

  /* Get Post ReplayComment */
  replaycomment.GetPostCommentModel getPostReplayCommentModel =
      replaycomment.GetPostCommentModel();
  int? replayCommenttotalRows, replayCommenttotalPage, replayCommentcurrentPage;
  bool? replayCommentisMorePage;
  List<replaycomment.Result>? replayCommentList = [];
  bool replayCommentloading = false, replayCommentloadMore = false;

  /* Delete Post Comment */
  SuccessModel successModel = SuccessModel();

  /* Report Reason List Field */
  report.GetRepostReasonModel getRepostReasonModel =
      report.GetRepostReasonModel();
  int? reporttotalRows, reporttotalPage, reportcurrentPage;
  bool? reportmorePage;
  List<report.Result>? reportReasonList = [];
  bool getcontentreportloading = false, getcontentreportloadmore = false;
  String? reason;
  int? reportPosition = 0;

  /* Add Report Reason */
  AddContentReportModel addContentReportModel = AddContentReportModel();

  /* Category List */
  category.CategoryModel categorymodel = category.CategoryModel();
  List<category.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;
  bool uploadLoading = false;
  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;
  int? categoryId;

  void selectCategory(int index, int catId) {
    _selectedIndex = index;
    categoryId = catId;
    notifyListeners();
  }

  /* Notification Count */
  dynamic notificationCount;

  totalNotificationCount(totalcount) {
    notificationCount = totalcount;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    categoryloading = isLoading;
    loading = isLoading;
    notifyListeners();
  }

  storeCommentId(postid, commentid) {
    postId = postid;
    commentId = commentid;
    notifyListeners();
  }

  /* ================================== Get All Feeds Start ================================== */

  Future<void> getAllFeed(categoryId, pageNo) async {
    // postModel = feedpost.PostModel();
    // if (pageNo == 1) {
    //   feedPostList = [];
    // }
    loading = true;
    postModel = await ApiService().getFeedPost(categoryId, pageNo);
    if (postModel.status == 200) {
      setPaginationData(
        postModel.totalRows,
        postModel.totalPage,
        postModel.currentPage,
        postModel.morePage,
      );

      if (postModel.result != null && (postModel.result?.length ?? 0) > 0) {
        log("post Model length :==> ${(postModel.result?.length ?? 0)}");
        feedPostList?.addAll(postModel.result ?? []);
        log("post List length :==> ${(feedPostList?.length ?? 0)}");
        setLoadMore(false);
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
    morePage = morePage;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  clearAllPost() {
    postModel = feedpost.PostModel();
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    feedPostList = [];
    feedPostList?.clear();
    loading = false;
    loadMore = false;
  }

  /* ================================== Get All Feeds End ================================== */

  /* ================================== Add Remove Subscriber's ================================== */

  addRemoveSubscriber(index, touserid, type) {
    for (var i = 0; i < (feedPostList?.length ?? 0); i++) {
      if (feedPostList?[i].userId.toString() == touserid.toString()) {
        if ((feedPostList?[i].isSubscriber ?? 0) == 0) {
          feedPostList?[i].isSubscriber = 1;
        } else {
          feedPostList?[i].isSubscriber = 0;
        }
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

  profileAddRemoveSubscription(touserid, type) async {
    for (var i = 0; i < (feedPostList?.length ?? 0); i++) {
      if (feedPostList?[i].userId.toString() == touserid.toString()) {
        if ((feedPostList?[i].isSubscriber ?? 0) == 0) {
          feedPostList?[i].isSubscriber = 1;
        } else {
          feedPostList?[i].isSubscriber = 0;
        }
      }
    }

    notifyListeners();
    await getaddremoveSubscribe(touserid, type);
  }

  /* ================================== Add Remove Subscriber's ================================== */

  /* ==================================== Like Post Start ======================================== */

  like(postIndex, postId) {
    if ((feedPostList?[postIndex].ifood_app ?? 0) == 0) {
      feedPostList?[postIndex].ifood_app = 1;
      feedPostList?[postIndex].totalLike =
          (feedPostList?[postIndex].totalLike ?? 0) + 1;
    } else {
      feedPostList?[postIndex].ifood_app = 0;
      if ((feedPostList?[postIndex].totalLike ?? 0) > 0) {
        feedPostList?[postIndex].totalLike =
            (feedPostList?[postIndex].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addlikeUnlike(postId);
  }

  Future<void> addlikeUnlike(postId) async {
    addRemoveLikeDifood_appModel = await ApiService().likeUnlikePost(postId);
    printLog(
      "addLikeDifood_app status :==> ${addRemoveLikeDifood_appModel.status}",
    );
    printLog(
      "addLikeDifood_app message :==> ${addRemoveLikeDifood_appModel.message}",
    );
  }

  /* ================================== Like Post End ================================== */

  /* ================================== Add Comment Post Start ================================== */

  addPostComment(position, postid, comment, commentid) async {
    setSendingComment(true);
    addPostCommentModel = await ApiService().addPostComment(
      postid,
      comment,
      commentid,
    );
    setSendingComment(true);
    feedPostList?[position].totalComment =
        (feedPostList?[position].totalComment ?? 0) + 1;
    notifyListeners();
  }

  setSendingComment(isSending) {
    addCommentLoading = isSending;
    notifyListeners();
  }

  /* ================================== Add Comment Post End ==================================== */

  /* ================================== Get Comment Post Start ==================================== */

  Future<void> getPostComment(postId, pageNo) async {
    commentloading = true;
    getPostCommentModel = await ApiService().getPostComment(postId, pageNo);
    if (getPostCommentModel.status == 200) {
      setCommentPaginationData(
        getPostCommentModel.totalRows,
        getPostCommentModel.totalPage,
        getPostCommentModel.currentPage,
        getPostCommentModel.morePage,
      );
      if (getPostCommentModel.result != null &&
          (getPostCommentModel.result?.length ?? 0) > 0) {
        printLog(
          "CommentModel length :==> ${(getPostCommentModel.result?.length ?? 0)}",
        );
        if (getPostCommentModel.result != null &&
            (getPostCommentModel.result?.length ?? 0) > 0) {
          printLog(
            "CommentModel length :==> ${(getPostCommentModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (getPostCommentModel.result?.length ?? 0); i++) {
            commentList?.add(
              getPostCommentModel.result?[i] ?? comment.Result(),
            );
          }
          final Map<int, comment.Result> postMap = {};
          commentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          commentList = postMap.values.toList();
          printLog("CommentList length :==> ${(commentList?.length ?? 0)}");
          setCommentLoadMore(false);
        }
      }
    }
    commentloading = false;
    notifyListeners();
  }

  setCommentPaginationData(
    int? commenttotalRows,
    int? commenttotalPage,
    int? commentcurrentPage,
    bool? commentmorePage,
  ) {
    this.commentcurrentPage = commentcurrentPage;
    this.commenttotalRows = commenttotalRows;
    this.commenttotalPage = commenttotalPage;
    commentmorePage = commentmorePage;
    notifyListeners();
  }

  setCommentLoadMore(commentloadMore) {
    this.commentloadMore = commentloadMore;
    notifyListeners();
  }

  clearComment() {
    /* Get PostComment */
    getPostCommentModel = comment.GetPostCommentModel();
    commenttotalRows;
    commenttotalPage;
    commentcurrentPage;
    commentisMorePage;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    commentloadMore = false;
    addCommentLoading = false;
  }

  /* ================================== Get Comment Post End ==================================== */

  /* ================================== Get ReplayComment Post Start ==================================== */

  Future<void> getPostReplayComment(commentId, pageNo) async {
    replayCommentloading = true;
    getPostReplayCommentModel = await ApiService().getPostReplayComment(
      commentId,
      pageNo,
    );
    if (getPostReplayCommentModel.status == 200) {
      setReplayCommentPaginationData(
        getPostReplayCommentModel.totalRows,
        getPostReplayCommentModel.totalPage,
        getPostReplayCommentModel.currentPage,
        getPostReplayCommentModel.morePage,
      );
      if (getPostReplayCommentModel.result != null &&
          (getPostReplayCommentModel.result?.length ?? 0) > 0) {
        printLog(
          "ReplayCommentModel length :==> ${(getPostReplayCommentModel.result?.length ?? 0)}",
        );
        if (getPostReplayCommentModel.result != null &&
            (getPostReplayCommentModel.result?.length ?? 0) > 0) {
          printLog(
            "ReplayCommentModel length :==> ${(getPostReplayCommentModel.result?.length ?? 0)}",
          );
          for (
            var i = 0;
            i < (getPostReplayCommentModel.result?.length ?? 0);
            i++
          ) {
            replayCommentList?.add(
              getPostReplayCommentModel.result?[i] ?? replaycomment.Result(),
            );
          }
          final Map<int, replaycomment.Result> postMap = {};
          replayCommentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          replayCommentList = postMap.values.toList();
          printLog(
            "replayCommentList length :==> ${(replayCommentList?.length ?? 0)}",
          );
          setReplayCommentLoadMore(false);
        }
      }
    }
    replayCommentloading = false;
    notifyListeners();
  }

  setReplayCommentPaginationData(
    int? replayCommenttotalRows,
    int? replayCommenttotalPage,
    int? replayCommentcurrentPage,
    bool? replayCommentisMorePage,
  ) {
    this.replayCommentcurrentPage = replayCommentcurrentPage;
    this.replayCommenttotalRows = replayCommenttotalRows;
    this.replayCommenttotalPage = replayCommenttotalPage;
    replayCommentisMorePage = replayCommentisMorePage;
    notifyListeners();
  }

  setReplayCommentLoadMore(replayCommentloadMore) {
    this.replayCommentloadMore = replayCommentloadMore;
    notifyListeners();
  }

  clearReplayComment() {
    getPostReplayCommentModel = replaycomment.GetPostCommentModel();
    replayCommenttotalRows;
    replayCommenttotalPage;
    replayCommentcurrentPage;
    replayCommentisMorePage;
    replayCommentList = [];
    replayCommentList?.clear();
    replayCommentloading = false;
    replayCommentloadMore = false;
    addCommentLoading = false;
  }

  /* ================================== Get ReplayComment Post End ==================================== */

  /* ================================== Delete Comment Start ==================================== */

  postDeleteComment(position, commentId) async {
    successModel = await ApiService().postDeleteComment(commentId);
    if ((feedPostList?[position].totalComment ?? 0) > 0) {
      feedPostList?[position].totalComment =
          (feedPostList?[position].totalComment ?? 0) - 1;
    }
    notifyListeners();
  }

  /* ================================== Delete Comment End ==================================== */

  /* ================================== Report Reason List ================================== */

  Future<void> getReportReason(type, pageNo) async {
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

  selectReportReason(int index, reasonMessage) {
    reportPosition = index;
    reason = reasonMessage;
    notifyListeners();
  }

  clearReportReason() {
    getRepostReasonModel = report.GetRepostReasonModel();
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    reportReasonList?.clear();
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reason;
    reportPosition = 0;
  }

  Future<void> addPostReason(postId, reason) async {
    addContentReportModel = await ApiService().addPostReport(postId, reason);
    loading = false;
  }

  /* ================================== Report Reason ================================== */
  /* ================================== Category ================================== */

  /* CategoryList Api Start */

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
        printLog('Now on page ==========> $categorycurrentPage');
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
            "CategoryList length :==> ${(categorydataList?.length ?? 0)}",
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

  /* CategoryList Api End */

  /* ================================== Category ================================== */

  clearProvider() {
    /* Get All Feed  */
    postModel = feedpost.PostModel();
    feedPostList = [];
    feedPostList?.clear();
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    loading = false;
    loadMore = false;
    /* Add Remove Subscriber */
    addremoveSubscribeModel = AddremoveSubscribeModel();
    /* Add Remove Like Difood_app */
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel();
    /* AddPostComment Model */
    addPostCommentModel = AddCommentModel();
    addCommentLoading = false;
    postId;
    /* Get PostComment */
    getPostCommentModel = comment.GetPostCommentModel();
    commenttotalRows;
    commenttotalPage;
    commentcurrentPage;
    commentisMorePage;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    commentloadMore = false;

    getPostReplayCommentModel = replaycomment.GetPostCommentModel();
    replayCommenttotalRows;
    replayCommenttotalPage;
    replayCommentcurrentPage;
    replayCommentisMorePage;
    replayCommentList = [];
    replayCommentList?.clear();
    replayCommentloading = false;
    replayCommentloadMore = false;

    /* Delete Post Comment */
    successModel = SuccessModel();

    /* Report Reason List Field */
    getRepostReasonModel = report.GetRepostReasonModel();
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    reportReasonList?.clear();
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reason;
    reportPosition = 0;

    /* Add Report Reason */
    addContentReportModel = AddContentReportModel();

    /* Category List */
    categorymodel = category.CategoryModel();
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;
    uploadLoading = false;
    _selectedIndex = -1;
    categoryId;
  }
}
