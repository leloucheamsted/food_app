import 'package:flutter/material.dart';
import 'package:slike/model/addcommentmodel.dart';
import 'package:slike/model/addcontentreportmodel.dart';
import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:slike/model/addremovesubscribemodel.dart';
import 'package:slike/model/feed_detail_and_related_content_model.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:slike/model/getpostcommentmodel.dart' as comment;
import 'package:slike/model/getpostcommentmodel.dart' as replaycomment;
import 'package:slike/model/getreportreasonmodel.dart' as report;

class FeedDetailWithScrollingProvider extends ChangeNotifier {
  FeedDetailAndRelatedContentModel feedDetailModel =
      FeedDetailAndRelatedContentModel();
  bool loading = false, addCommentLoading = false;

  /* Get PostComment */
  comment.GetPostCommentModel getPostCommentModel =
      comment.GetPostCommentModel();
  int? commenttotalRows, commenttotalPage, commentcurrentPage;
  List<comment.Result>? commentList = [];
  bool commentloading = false, commentloadMore = false;

  /* Get Post ReplayComment */
  replaycomment.GetPostCommentModel getPostReplayCommentModel =
      replaycomment.GetPostCommentModel();
  int? replayCommenttotalRows, replayCommenttotalPage, replayCommentcurrentPage;
  bool? replayCommentisMorePage;
  List<replaycomment.Result>? replayCommentList = [];
  bool replayCommentloading = false, replayCommentloadMore = false;

  /* AddPostComment Model */
  AddCommentModel addPostCommentModel = AddCommentModel();

  /* Add Remove Subscriber */
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();

  /* Delete Post Comment */
  SuccessModel successModel = SuccessModel();

  /* Add Remove Like Difood_app */
  AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel =
      AddRemoveLikeDifood_appModel();

  /* Report Reason List Field */
  report.GetRepostReasonModel getRepostReasonModel =
      report.GetRepostReasonModel();
  int? reporttotalRows, reporttotalPage, reportcurrentPage, imageCurrentPage;
  bool? reportmorePage;
  List<report.Result>? reportReasonList = [];
  bool getcontentreportloading = false, getcontentreportloadmore = false;
  String? reason;
  int? reportPosition = 0;

  /* Add Report Reason */
  AddContentReportModel addContentReportModel = AddContentReportModel();

  /* Show Hide Send Icon Comment */
  bool isSendShow = false;

  /* Store CommenId Use in ReplayComment ScrollController Pagination */
  String? cmtId;

  showHideSendIcon(String text) {
    if (text != "") {
      isSendShow = true;
    } else {
      isSendShow = false;
    }
    notifyListeners();
  }

  storeCommentId(commentid) {
    cmtId = commentid;
    notifyListeners();
  }

  getFeedDetail(postId) async {
    loading = true;
    imageCurrentPage = 0;
    feedDetailModel = await ApiService().getPostAndRelatedContent(postId);
    loading = false;
    notifyListeners();
  }

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

  /* ================================== Add Comment Post Start ================================== */

  addPostComment(postid, comment, commentid) async {
    setSendingComment(true);
    addPostCommentModel = await ApiService().addPostComment(
      postid,
      comment,
      commentid,
    );
    setSendingComment(true);
    feedDetailModel.result?[0].totalComment =
        (feedDetailModel.result?[0].totalComment ?? 0) + 1;
    notifyListeners();
  }

  setSendingComment(isSending) {
    addCommentLoading = isSending;
    notifyListeners();
  }

  /* ================================== Add Comment Post Start ================================== */

  addRemoveSubscriber(touserid, type) {
    if (feedDetailModel.result?[0].userId.toString() == touserid.toString()) {
      if ((feedDetailModel.result?[0].isSubscriber ?? 0) == 0) {
        feedDetailModel.result?[0].isSubscriber = 1;
      } else {
        feedDetailModel.result?[0].isSubscriber = 0;
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
    if ((feedDetailModel.result?[0].isSubscriber ?? 0) == 0) {
      feedDetailModel.result?[0].isSubscriber = 1;
    } else {
      feedDetailModel.result?[0].isSubscriber = 0;
    }

    notifyListeners();
    await getaddremoveSubscribe(touserid, type);
  }

  /* ================================== Add Comment Post End ================================== */

  /* ================================== Delete Comment Start ==================================== */

  postDeleteComment(commentId) async {
    successModel = await ApiService().postDeleteComment(commentId);
    if ((feedDetailModel.result?[0].totalComment ?? 0) > 0) {
      feedDetailModel.result?[0].totalComment =
          (feedDetailModel.result?[0].totalComment ?? 0) - 1;
    }
    notifyListeners();
  }

  /* ================================== Delete Comment End ==================================== */

  /* ==================================== Like Post Start ======================================== */

  like(postId) {
    if ((feedDetailModel.result?[0].ifood_app ?? 0) == 0) {
      feedDetailModel.result?[0].ifood_app = 1;
      feedDetailModel.result?[0].totalLike =
          (feedDetailModel.result?[0].totalLike ?? 0) + 1;
    } else {
      feedDetailModel.result?[0].ifood_app = 0;
      if ((feedDetailModel.result?[0].totalLike ?? 0) > 0) {
        feedDetailModel.result?[0].totalLike =
            (feedDetailModel.result?[0].totalLike ?? 0) - 1;
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
    imageCurrentPage;
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

  clearProvider() {
    feedDetailModel = FeedDetailAndRelatedContentModel();
    loading = false;
    addCommentLoading = false;
    /* Get PostComment */
    getPostCommentModel = comment.GetPostCommentModel();
    commenttotalRows;
    commenttotalPage;
    commentcurrentPage;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    commentloadMore = false;
    /* Get Post ReplayComment */
    getPostReplayCommentModel = replaycomment.GetPostCommentModel();
    replayCommenttotalRows;
    replayCommenttotalPage;
    replayCommentcurrentPage;
    replayCommentisMorePage;
    replayCommentList = [];
    replayCommentList?.clear();
    replayCommentloading = false;
    replayCommentloadMore = false;
    /* AddPostComment Model */
    addPostCommentModel = AddCommentModel();
    /* Add Remove Subscriber */
    addremoveSubscribeModel = AddremoveSubscribeModel();
    /* Delete Post Comment */
    successModel = SuccessModel();
    /* Add Remove Like Difood_app */
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel();
    /* Report Reason List Field */
    getRepostReasonModel = report.GetRepostReasonModel();
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reason;
    reportPosition = 0;
    /* Add Report Reason */
    addContentReportModel = AddContentReportModel();
    /* Show Hide Send Icon COmment */
    isSendShow = false;
  }
}
