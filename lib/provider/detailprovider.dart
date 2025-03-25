import 'dart:developer';
import 'package:slike/model/addcommentmodel.dart';
import 'package:slike/model/addcontenttohistorymodel.dart';
import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:slike/model/addremovesubscribemodel.dart';
import 'package:slike/model/addviewmodel.dart';
import 'package:slike/model/commentmodel.dart';
import 'package:slike/model/deletecommentmodel.dart';
import 'package:slike/model/profilemodel.dart';
import 'package:slike/model/relatedvideomodel.dart' as related;
import 'package:slike/model/relatedvideomodel.dart';
import 'package:slike/model/removecontenttohistorymodel.dart';
import 'package:slike/model/replaycommentmodel.dart' as replaycomment;
import 'package:slike/model/replaycommentmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:slike/model/commentmodel.dart' as comment;
import 'package:slike/model/successmodel.dart';
import 'package:slike/model/detailmodel.dart';
import 'package:slike/webservice/apiservice.dart';

class DetailProvider extends ChangeNotifier {
  DetailsModel detailsModel = DetailsModel();
  ProfileModel profileModel = ProfileModel();
  AddCommentModel addCommentModel = AddCommentModel();
  SuccessModel likedifood_appmodel = SuccessModel();
  CommentModel getcommentModel = CommentModel();
  ReplayCommentModel replayCommentModel = ReplayCommentModel();
  AddViewModel addViewModel = AddViewModel();
  AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel =
      AddRemoveLikeDifood_appModel();
  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();
  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();
  RelatedVideoModel relatedVideoModel = RelatedVideoModel();

  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();
  DeleteCommentModel deleteCommentModel = DeleteCommentModel();
  bool loading = false;
  String commentId = "";
  int deleteItemIndex = 0;
  bool deletecommentLoading = false;

  // Comment List Field Pagination
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;
  List<comment.Result>? commentList = [];
  bool commentloadmore = false, commentloading = false;

  // Add Comment & Add Replay Comment
  bool addcommentloading = false, addreplaycommentloading = false;

  // ReplayComment With Pagination
  int? totalRowsReplayComment, totalPageReplayComment, currentPageReplayComment;
  bool? morePageReplayComment;
  List<replaycomment.Result>? replaycommentList = [];
  bool replayCommentloadmore = false, replaycommentloding = false;

  /* RelatedVideo Field */
  List<related.Result>? relatedVideoList = [];
  bool relatedVideoLoadMore = false;
  int? relatedVideototalRows, relatedVideototalPage, relatedVideocurrentPage;
  bool? relatedVideoisMorePage;

  String videoId = "";

  setLoading(loading) {
    this.loading = loading;
    notifyListeners();
  }

  /* Store Video Id Using in Flutter Web */

  storeVideoId(id) {
    videoId = id;
  }

  getvideodetails(contentid, contenttype) async {
    loading = true;
    detailsModel = await ApiService().videodetails(contentid, contenttype);
    loading = false;
    notifyListeners();
  }

  getaddcomment(contenttype, contentid, episodeid, comment, commentid) async {
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

  /*  Comment Pagination Start */
  setCommentLoading(bool isLoading) {
    commentloading = isLoading;
    notifyListeners();
  }

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

  setCommentLoadMore(commentloadmore) {
    this.commentloadmore = commentloadmore;
    notifyListeners();
  }

  Future<void> updateComments(contenttype, contentid) async {
    loading = true;
    getcommentModel = await ApiService().getcomment(
      contenttype,
      contentid,
      "0",
    );
    loading = false;
    notifyListeners();
  }
  /*  Comment Pagination End */

  /* Delete Comment And Replay Comment Both OF Delete */
  getDeleteComment(commentid, isComment, index) async {
    deleteItemIndex = index;
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

  addremoveSubscribe(touserid, type) {
    if ((detailsModel.result?[0].isSubscribe ?? 0) == 0) {
      detailsModel.result?[0].isSubscribe = 1;
      detailsModel.result?[0].totalSubscriber =
          (detailsModel.result?[0].totalSubscriber ?? 0) + 1;
    } else {
      detailsModel.result?[0].isSubscribe = 0;
      if ((detailsModel.result?[0].totalSubscriber ?? 0) > 0) {
        detailsModel.result?[0].totalSubscriber =
            (detailsModel.result?[0].totalSubscriber ?? 0) - 1;
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

  Future<void> addVideoView(contenttype, contentid) async {
    printLog("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    printLog("addPostView status :==> ${addViewModel.status}");
    printLog("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  like(contenttype, contentid, status, episodeId) {
    if ((detailsModel.result?[0].isUserLikeDifood_app ?? 0) == 0) {
      detailsModel.result?[0].isUserLikeDifood_app = 1;
      detailsModel.result?[0].totalLike =
          (detailsModel.result?[0].totalLike ?? 0) + 1;
    } else if ((detailsModel.result?[0].isUserLikeDifood_app ?? 0) == 2) {
      detailsModel.result?[0].isUserLikeDifood_app = 1;
      detailsModel.result?[0].totalLike =
          (detailsModel.result?[0].totalLike ?? 0) + 1;
      if ((detailsModel.result?[0].totalDifood_app ?? 0) > 0) {
        detailsModel.result?[0].totalDifood_app =
            (detailsModel.result?[0].totalDifood_app ?? 0) - 1;
      }
    } else {
      detailsModel.result?[0].isUserLikeDifood_app = 0;
      if ((detailsModel.result?[0].totalLike ?? 0) > 0) {
        detailsModel.result?[0].totalLike =
            (detailsModel.result?[0].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDifood_app(contenttype, contentid, status, episodeId);
  }

  difood_app(contenttype, contentid, status, episodeId) {
    if ((detailsModel.result?[0].isUserLikeDifood_app ?? 0) == 0) {
      detailsModel.result?[0].isUserLikeDifood_app = 2;
      detailsModel.result?[0].totalDifood_app =
          (detailsModel.result?[0].totalDifood_app ?? 0) + 1;
    } else if ((detailsModel.result?[0].isUserLikeDifood_app ?? 0) == 1) {
      detailsModel.result?[0].isUserLikeDifood_app = 2;
      detailsModel.result?[0].totalDifood_app =
          (detailsModel.result?[0].totalDifood_app ?? 0) + 1;
      if ((detailsModel.result?[0].totalLike ?? 0) > 0) {
        detailsModel.result?[0].totalLike =
            (detailsModel.result?[0].totalLike ?? 0) - 1;
      }
    } else {
      detailsModel.result?[0].isUserLikeDifood_app = 0;
      if ((detailsModel.result?[0].totalDifood_app ?? 0) > 0) {
        detailsModel.result?[0].totalDifood_app =
            (detailsModel.result?[0].totalDifood_app ?? 0) - 1;
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

  Future<void> addContentHistory(
    contenttype,
    contentid,
    stoptime,
    episodeid,
  ) async {
    loading = true;
    addcontenttoHistoryModel = await ApiService().addContentToHistory(
      contenttype,
      contentid,
      stoptime,
      episodeid,
    );
    loading = false;
  }

  Future<void> removeContentHistory(contenttype, contentid, episodeid) async {
    loading = true;
    removeContentHistoryModel = await ApiService().removeContentToHistory(
      contenttype,
      contentid,
      episodeid,
    );
    loading = false;
  }

  storeReplayCommentId(iscommentId) async {
    commentId = iscommentId;
    log("Comment ID ==> $commentId");
    notifyListeners();
  }

  /* Related Videos Start */

  Future<void> getRelatedVideo(contentId, pageNo) async {
    loading = true;
    relatedVideoModel = await ApiService().relatedVideo(contentId, pageNo);
    if (relatedVideoModel.status == 200) {
      setRelatedPaginationData(
        relatedVideoModel.totalRows,
        relatedVideoModel.totalPage,
        relatedVideoModel.currentPage,
        relatedVideoModel.morePage,
      );
      if (relatedVideoModel.result != null &&
          (relatedVideoModel.result?.length ?? 0) > 0) {
        printLog(
          "RelatedVideo Model length :==> ${(relatedVideoModel.result?.length ?? 0)}",
        );
        if (relatedVideoModel.result != null &&
            (relatedVideoModel.result?.length ?? 0) > 0) {
          printLog(
            "RelatedVideo Model length :==> ${(relatedVideoModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (relatedVideoModel.result?.length ?? 0); i++) {
            relatedVideoList?.add(
              relatedVideoModel.result?[i] ?? related.Result(),
            );
          }
          final Map<int, related.Result> postMap = {};
          relatedVideoList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          relatedVideoList = postMap.values.toList();
          setRelatedLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRelatedPaginationData(
    int? relatedVideototalRows,
    int? relatedVideototalPage,
    int? relatedVideocurrentPage,
    bool? relatedVideoisMorePage,
  ) {
    this.relatedVideocurrentPage = relatedVideocurrentPage;
    this.relatedVideototalRows = relatedVideototalRows;
    this.relatedVideototalPage = relatedVideototalPage;
    relatedVideoisMorePage = relatedVideoisMorePage;
    notifyListeners();
  }

  setRelatedLoadMore(relatedVideoLoadMore) {
    this.relatedVideoLoadMore = relatedVideoLoadMore;
    notifyListeners();
  }

  /* Related Videos End */

  /* Web Uses */
  /* Open Replay Comment textField */
  int? commentIndex;
  bool isCommentReplay = false;
  openReplayCommentTextField(index, isClick) {
    commentIndex = index;
    isCommentReplay = isClick;
    notifyListeners();
  }

  /* Open Replaycomment Section For Perticuler Comment */
  int? commentPosition;
  bool isShowReplaycomment = false;
  showReplaycomment(position, isShow) {
    commentPosition = position;
    isShowReplaycomment = isShow;
    notifyListeners();
  }

  /* Download Video Offline */

  clearReplayComment() {
    totalRowsReplayComment;
    totalPageReplayComment;
    currentPageReplayComment;
    morePageReplayComment;
    replaycommentList = [];
    replaycommentList?.clear();
    replayCommentloadmore = false;
    replaycommentloding = false;
  }

  clearProvider() {
    detailsModel = DetailsModel();
    addCommentModel = AddCommentModel();
    addcontenttoHistoryModel = AddcontenttoHistoryModel();
    likedifood_appmodel = SuccessModel();
    addremoveSubscribeModel = AddremoveSubscribeModel();
    getcommentModel = CommentModel();
    replayCommentModel = ReplayCommentModel();
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentList?.clear();
    addcommentloading = false;
    commentloadmore = false;
    addreplaycommentloading = false;
    loading = false;
    deleteItemIndex = 0;
    deletecommentLoading = false;
    videoId = "";
    commentIndex;
    isCommentReplay = false;
    commentPosition;
    isShowReplaycomment = false;
    /* RelatedVideo Field */
    relatedVideoList = [];
    relatedVideoList?.clear();
    relatedVideoLoadMore = false;
    relatedVideototalRows;
    relatedVideototalPage;
    relatedVideocurrentPage;
    relatedVideoisMorePage;
  }

  clearComment() {
    replayCommentModel = ReplayCommentModel();
    replaycommentList?.clear();
    replaycommentList = [];
    deleteItemIndex = 0;
    deletecommentLoading = false;
  }
}
