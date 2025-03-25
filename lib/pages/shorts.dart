import 'dart:developer';
import 'dart:io';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/livestream/golivepreview.dart';
import 'package:slike/livestream/liveuserlist.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/music/musicdetails.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/provider/shortprovider.dart';
import 'package:slike/subscription/adspackage.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/socketmanager.dart';
import 'package:slike/widget/mymarqueetext.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/nodata.dart';
import 'package:slike/widget/nopost.dart';
import 'package:flutter/material.dart';
import 'package:slike/pages/videoscreen.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class Shorts extends StatefulWidget {
  final String? shortType;
  final int initialIndex;
  final String? userId, channelId, searchText;

  const Shorts({
    super.key,
    this.shortType,
    required this.initialIndex,
    this.userId,
    this.channelId,
    this.searchText,
  });

  @override
  State<Shorts> createState() => ShortsState();
}

class ShortsState extends State<Shorts> with SingleTickerProviderStateMixin {
  late ShortProvider shortProvider;
  late ProfileProvider profileProvider;

  late ScrollController replaycommentController;
  late ScrollController commentListController;
  late ScrollController reportReasonController;
  late ScrollController _categoryScrollController;
  late ScrollController _giftScrollController;
  final commentController = TextEditingController();

  late Future<void> initializeVideoPlayerFuture;
  late VideoPlayerController controller;

  SocketManager socketManager = SocketManager();
  io.Socket? socket;
  late PreloadPageController preloadPageController;
  late TabController _tabController;

  @override
  void initState() {
    log("initial Index=====> ${widget.initialIndex}");
    shortProvider = Provider.of<ShortProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
    audioPlayer.pause();
    commentListController = ScrollController();
    reportReasonController = ScrollController();
    replaycommentController = ScrollController();
    _categoryScrollController = ScrollController();
    _giftScrollController = ScrollController();

    commentListController.addListener(_scrollListener);
    reportReasonController.addListener(_scrollListenerReportReason);
    replaycommentController.addListener(_scrollListenerReplayComment);
    _categoryScrollController.addListener(_categoryScrollListener);
    _giftScrollController.addListener(_giftScrollListener);
    preloadPageController = PreloadPageController(
      initialPage: widget.initialIndex,
    );
    super.initState();
    getApi();
    _fetchDataAndInitialize();

    // Add listener to the TabController
    _tabController.addListener(() async {
      await shortProvider.selectTab(_tabController.index);
      await shortProvider.setLoading(true);
      if (_tabController.index == 0) {
        await _fetchDataCategory(0);
        if (shortProvider.categorymodel.status == 200 &&
            shortProvider.categorydataList != null) {
          if ((shortProvider.categorydataList?.length ?? 0) > 0) {
            shortProvider.selectCategory(
              -1,
              shortProvider.categorydataList?[0].id ?? 0,
            );
            log("Error===================>");
            await shortProvider.getShortList(false, "", 1);
          }
        }
      } else {
        shortProvider.clearShort();
      }
    });
  }

  Future<void> _fetchDataAndInitialize() async {
    if (widget.shortType == "profile" ||
        widget.shortType == "watchlater" ||
        widget.shortType == "search") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (preloadPageController.hasClients) {
          preloadPageController.jumpToPage(widget.initialIndex);
        }
      });
    }
  }

  getApi() async {
    if (widget.shortType == "profile") {
      await shortProvider.getcontentbyChannelShort(
        false,
        widget.userId,
        widget.channelId,
        "3",
        "1",
      );
    } else if (widget.shortType == "watchlater") {
      await shortProvider.getContentByWatchLater("3", "1");
    } else if (widget.shortType == "search") {
      await shortProvider.getSearch(widget.searchText, "3");
    } else {
      // await _fetchDataCategory(0);
      // if (shortProvider.categorymodel.status == 200 &&
      //     shortProvider.categorydataList != null) {
      //   if ((shortProvider.categorydataList?.length ?? 0) > 0) {
      //     await shortProvider.selectCategory(0, "");
      //     await shortProvider.selectTab(0);
      //     log("Error===================>");
      // shortProvider.clearShortList();
      // await shortProvider.getShortList("", 1);
      // }
      // }
    }
  }

  _scrollListener() async {
    if (!commentListController.hasClients) return;
    if (commentListController.offset >=
            commentListController.position.maxScrollExtent &&
        !commentListController.position.outOfRange &&
        (shortProvider.currentPageComment ?? 0) <
            (shortProvider.totalPageComment ?? 0)) {
      _fetchCommentNewData(
        shortProvider.commentId,
        shortProvider.currentPageComment ?? 0,
      );
    }
  }

  _scrollListenerReportReason() async {
    if (!reportReasonController.hasClients) return;
    if (reportReasonController.offset >=
            reportReasonController.position.maxScrollExtent &&
        !reportReasonController.position.outOfRange &&
        (shortProvider.reportcurrentPage ?? 0) <
            (shortProvider.reporttotalPage ?? 0)) {
      await shortProvider.setReportReasonLoadMore(true);
      _fetchReportReason(shortProvider.reportcurrentPage ?? 0);
    }
  }

  _scrollListenerReplayComment() async {
    if (!replaycommentController.hasClients) return;
    if (replaycommentController.offset >=
            replaycommentController.position.maxScrollExtent &&
        !replaycommentController.position.outOfRange &&
        (shortProvider.currentPageReplayComment ?? 0) <
            (shortProvider.totalPageReplayComment ?? 0)) {
      await shortProvider.setReplayCommentLoadMore(true);
      _fetchReplayCommentData(
        shortProvider.replayCommentId,
        shortProvider.currentPageReplayComment ?? 0,
      );
    }
  }

  _categoryScrollListener() async {
    if (!_categoryScrollController.hasClients) return;
    if (_categoryScrollController.offset >=
            _categoryScrollController.position.maxScrollExtent &&
        !_categoryScrollController.position.outOfRange &&
        (shortProvider.categorycurrentPage ?? 0) <
            (shortProvider.categorytotalPage ?? 0)) {
      await shortProvider.setCategoryLoadMore(true);
      _fetchDataCategory(shortProvider.categorycurrentPage ?? 0);
    }
  }

  _giftScrollListener() async {
    if (!_giftScrollController.hasClients) return;
    if (_giftScrollController.offset >=
            _giftScrollController.position.maxScrollExtent &&
        !_giftScrollController.position.outOfRange &&
        (shortProvider.giftcurrentPage ?? 0) <
            (shortProvider.gifttotalPage ?? 0)) {
      await shortProvider.setGiftLoadMore(true);
      _fetchGift(shortProvider.giftcurrentPage ?? 0);
    }
  }

  Future<void> _fetchDataCategory(int? nextPage) async {
    printLog("isMorePage  ======> ${shortProvider.categoryisMorePage}");
    printLog("currentPage ======> ${shortProvider.categorycurrentPage}");
    printLog("totalPage   ======> ${shortProvider.categorytotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await shortProvider.getCategory((nextPage ?? 0) + 1);
    await shortProvider.setCategoryLoadMore(false);
  }

  Future _fetchReportReason(int? nextPage) async {
    printLog("reportmorePage  =======> ${shortProvider.reportmorePage}");
    printLog("reportcurrentPage =======> ${shortProvider.reportcurrentPage}");
    printLog("reporttotalPage   =======> ${shortProvider.reporttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await shortProvider.getReportReason("2", (nextPage ?? 0) + 1);
    printLog(
      "fetchReportReason length ==> ${shortProvider.reportReasonList?.length}",
    );
  }

  Future _fetchAllShort(isPagination, categoryId) async {
    printLog("isMorePage  =======> ${shortProvider.morePage}");
    printLog("currentPage =======> ${shortProvider.currentPage}");
    printLog("totalPage   =======> ${shortProvider.totalPage}");
    int nextPage = (shortProvider.currentPage ?? 0) + 1;
    log("nextPage   ========> $nextPage");
    if ((shortProvider.currentPage ?? 0) <= (shortProvider.totalPage ?? 0) &&
        nextPage <= (shortProvider.totalPage ?? 0)) {
      await shortProvider.getShortList(isPagination, categoryId, nextPage);
    }
    printLog(
      "shortVideoList length ==> ${shortProvider.shortVideoList?.length}",
    );
  }

  Future _fetchCommentNewData(contentid, int? nextPage) async {
    printLog("isMorePage  =======> ${shortProvider.morePageComment}");
    printLog("currentPage =======> ${shortProvider.currentPageComment}");
    printLog("totalPage   =======> ${shortProvider.totalPageComment}");
    int nextPage = (shortProvider.currentPageComment ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.currentPageComment ?? 0) <=
            (shortProvider.totalPageComment ?? 0) &&
        nextPage <= (shortProvider.totalPageComment ?? 0)) {
      await shortProvider.getComment("3", contentid, nextPage);
    }
    printLog("commentlist length ==> ${shortProvider.commentList?.length}");
  }

  Future _fetchUserShort(isPagination) async {
    printLog("userShortmorePage  =======> ${shortProvider.userShortmorePage}");
    printLog(
      "userShortcurrentPage =======> ${shortProvider.profileShortcurrentPage}",
    );
    printLog(
      "userShorttotalPage   =======> ${shortProvider.profileShorttotalPage}",
    );
    int nextPage = (shortProvider.profileShortcurrentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.profileShortcurrentPage ?? 0) <=
            (shortProvider.profileShorttotalPage ?? 0) &&
        nextPage <= (shortProvider.profileShorttotalPage ?? 0)) {
      await shortProvider.getcontentbyChannelShort(
        isPagination,
        widget.userId,
        widget.channelId,
        "3",
        nextPage,
      );
    }
    printLog(
      "UsershortList length ==> ${shortProvider.profileShortList?.length}",
    );
  }

  Future _fetchWatchLaterShort(isPagination) async {
    printLog("userShortmorePage  =======> ${shortProvider.userShortmorePage}");
    printLog(
      "userShortcurrentPage =======> ${shortProvider.profileShortcurrentPage}",
    );
    printLog(
      "userShorttotalPage   =======> ${shortProvider.profileShorttotalPage}",
    );
    int nextPage = (shortProvider.profileShortcurrentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.watchlaterShortcurrentPage ?? 0) <=
            (shortProvider.watchlaterShorttotalPage ?? 0) &&
        nextPage <= (shortProvider.watchlaterShorttotalPage ?? 0)) {
      await shortProvider.getcontentbyChannelShort(
        isPagination,
        widget.userId,
        widget.channelId,
        "3",
        nextPage,
      );
    }
    printLog(
      "UsershortList length ==> ${shortProvider.profileShortList?.length}",
    );
  }

  Future<void> _fetchReplayCommentData(commentid, int? nextPage) async {
    printLog("isMorePage  ======> ${shortProvider.morePageReplayComment}");
    printLog("currentPage ======> ${shortProvider.currentPageReplayComment}");
    printLog("totalPage   ======> ${shortProvider.totalPageReplayComment}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await shortProvider.getReplayComment(commentid, (nextPage ?? 0) + 1);
    await shortProvider.setReplayCommentLoadMore(false);
  }

  Future<void> _fetchGift(int? nextPage) async {
    printLog("isMorePage  ======> ${shortProvider.giftisMorePage}");
    printLog("currentPage ======> ${shortProvider.giftcurrentPage}");
    printLog("totalPage   ======> ${shortProvider.gifttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getProfile(context, Constant.userID);
    await shortProvider.fetchGift((nextPage ?? 0) + 1);
    await shortProvider.setGiftLoadMore(false);
  }

  @override
  void dispose() {
    shortProvider.clearProvider();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorPrimary,
      body: Consumer<ShortProvider>(
        builder: (context, shortprovider, child) {
          return Column(
            children: [
              if (widget.shortType == "profile" ||
                  widget.shortType == "watchlater")
                const SizedBox.shrink()
              else if (shortprovider.tabType == 0)
                const SizedBox.shrink()
              else
                AppBar(
                  toolbarHeight: 60,
                  automaticallyImplyLeading: false,
                  backgroundColor: colorPrimary,
                  surfaceTintColor: transparent,
                  flexibleSpace: SafeArea(
                    bottom: false,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: white,
                              multilanguage: true,
                              text: "live_streaming",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textBig,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const GoLiveViewPreview();
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 36,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: colorAccent,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MyImage(
                                            width: 22,
                                            height: 22,
                                            color: black,
                                            imagePath: "ic_top_streaming.webp",
                                          ),
                                          const SizedBox(width: 5),
                                          MyText(
                                            color: black,
                                            multilanguage: true,
                                            text: "go_live",
                                            textalign: TextAlign.center,
                                            fontsizeNormal: Dimens.textMedium,
                                            inter: false,
                                            maxline: 1,
                                            fontwaight: FontWeight.w600,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(child: buildLayout()),
            ],
          );
        },
      ),
    );
  }

  Widget buildLayout() {
    if (widget.shortType == "profile") {
      return _buildProfileShort();
    } else if (widget.shortType == "watchlater") {
      return _buildWatchLaterShort();
    } else if (widget.shortType == "search") {
      return _buildSearchShort();
    } else {
      return Stack(
        children: [
          /* Tab Item  */
          TabBarView(
            controller: _tabController,
            children: [_buildShort(), const LiveUserList()],
          ),
          /* Tab Name  */
          (shortProvider.tabType == 0)
              ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: tabName(),
                ),
              )
              : tabName(),
          /* HashTag Button */
          (shortProvider.tabType == 1)
              ? const SizedBox.shrink()
              : SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      categoryBottomSheet(context);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: colorAccent),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: MyImage(
                          width: 20,
                          height: 20,
                          color: colorAccent,
                          imagePath: "ic_hashtag.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

          // /* select Tab */
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       InkWell(
          //         focusColor: transparent,
          //         splashColor: transparent,
          //         highlightColor: transparent,
          //         hoverColor: transparent,
          //         borderRadius: BorderRadius.circular(50),
          //         onTap: () async {
          //           await shortProvider.selectTab("short");
          //           await _fetchDataCategory(0);
          //           if (shortProvider.categorymodel.status == 200 &&
          //               shortProvider.categorydataList != null) {
          //             if ((shortProvider.categorydataList?.length ?? 0) > 0) {
          //               await shortProvider.selectCategory(0, "");
          //               log("Error===================>");
          //               await shortProvider.getShortList("", 1);
          //             }
          //           }
          //         },
          //         child: Container(
          //           width: 80,
          //           height: 80,
          //           padding: const EdgeInsets.all(20.0),
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(50),
          //           ),
          //           child: Column(
          //             children: [
          //               MyImage(
          //                 width: 25,
          //                 height: 25,
          //                 imagePath: "ic_recordvideo.png",
          //                 color: shortProvider.tabType == "short"
          //                     ? colorAccent
          //                     : white,
          //               ),
          //               const SizedBox(height: 5),
          //               MyText(
          //                   color: shortProvider.tabType == "short"
          //                       ? colorAccent
          //                       : white,
          //                   text: "shorts",
          //                   multilanguage: true,
          //                   textalign: TextAlign.center,
          //                   fontsizeNormal: 12,
          //                   inter: false,
          //                   maxline: 1,
          //                   fontwaight: FontWeight.w600,
          //                   overflow: TextOverflow.ellipsis,
          //                   fontstyle: FontStyle.normal),
          //             ],
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 5),
          //       InkWell(
          //         focusColor: transparent,
          //         splashColor: transparent,
          //         highlightColor: transparent,
          //         hoverColor: transparent,
          //         borderRadius: BorderRadius.circular(50),
          //         onTap: () async {
          //           shortProvider.clearShort();
          //           await shortProvider.selectTab("live");
          //         },
          //         child: Container(
          //           padding: const EdgeInsets.all(20.0),
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(50),
          //           ),
          //           child: Column(
          //             children: [
          //               MyImage(
          //                 width: 25,
          //                 height: 25,
          //                 imagePath: "ic_live.png",
          //                 color: shortProvider.tabType == "live"
          //                     ? colorAccent
          //                     : white,
          //               ),
          //               const SizedBox(height: 5),
          //               MyText(
          //                   color: shortProvider.tabType == "live"
          //                       ? colorAccent
          //                       : white,
          //                   text: "live",
          //                   multilanguage: true,
          //                   textalign: TextAlign.center,
          //                   fontsizeNormal: 12,
          //                   inter: false,
          //                   maxline: 1,
          //                   fontwaight: FontWeight.w600,
          //                   overflow: TextOverflow.ellipsis,
          //                   fontstyle: FontStyle.normal),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      );
    }
  }

  /* Simple Short */
  Widget _buildShort() {
    if (shortProvider.loading) {
      return shimmer();
    } else {
      if (shortProvider.shortVideoList != null &&
          (shortProvider.shortVideoList?.length ?? 0) > 0) {
        return _buildShortPageView();
      } else {
        return const NoPost(title: "nodatavideotitle", subTitle: "");
      }
    }
  }

  Widget _buildShortPageView() {
    return PreloadPageView.builder(
      itemCount: shortProvider.shortVideoList?.length ?? 0,
      preloadPagesCount: 4,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) async {
        if (index > 0 && (index % 2) == 0) {
          _fetchAllShort(true, shortProvider.categoryId);
        }
        shortProvider.onChangePage(index);
        log(
          "totalComment==>${shortProvider.shortVideoList?[index].totalComment.toString() ?? ""}",
        );
      },
      itemBuilder: (context, index) {
        return Stack(
          children: [
            /* result Video */
            Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: MediaQuery.of(context).size.height,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: VideoScreen(
                index: index,
                pagePos: shortProvider.currentPageIndex,
                thumbnailImg:
                    shortProvider.shortVideoList?[index].portraitImg
                        .toString() ??
                    "",
                videoId:
                    shortProvider.shortVideoList?[index].id.toString() ?? "",
                videoUrl:
                    shortProvider.shortVideoList?[index].content.toString() ??
                    "",
              ),
            ),
            /* Show Gift */
            showGift(),
            /* Like, Difood_app, Comment, Share and More Buttons */
            Positioned.fill(
              bottom: 30,
              right: 15,
              left: 15,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Profile(
                                isBottomBar: false,
                                toUserId:
                                    shortProvider.shortVideoList?[index].userId
                                        .toString() ??
                                    "",
                                toChannelId:
                                    shortProvider
                                        .shortVideoList?[index]
                                        .channelId
                                        .toString() ??
                                    "",
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(width: 1, color: colorAccent),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            imagePath:
                                shortProvider
                                    .shortVideoList?[index]
                                    .channelImage
                                    .toString() ??
                                "",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    /* Gift Icon */
                    giftButton(
                      shortProvider.shortVideoList?[index].channelId
                              .toString() ??
                          "",
                    ),

                    const SizedBox(height: 5),
                    // Like Button With Like Count
                    InkWell(
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else {
                          if (shortProvider.shortVideoList?[index].ifood_app ==
                              0) {
                            Utils.showSnackbar(
                              context,
                              "youcannotlikethiscontent",
                              true,
                            );
                          } else {
                            //  Call Like APi Call
                            if ((shortProvider
                                        .shortVideoList?[index]
                                        .isUserLikeDifood_app ??
                                    0) ==
                                1) {
                              printLog("Remove Api");
                              await shortProvider.shortLike(
                                index,
                                "3",
                                shortProvider.shortVideoList?[index].id
                                        .toString() ??
                                    "",
                                "0",
                                "0",
                              );
                            } else {
                              await shortProvider.shortLike(
                                index,
                                "3",
                                shortProvider.shortVideoList?[index].id
                                        .toString() ??
                                    "",
                                "1",
                                "0",
                              );
                            }
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child:
                            (shortProvider
                                            .shortVideoList?[index]
                                            .isUserLikeDifood_app ??
                                        0) ==
                                    1
                                ? MyImage(
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.cover,
                                  color: colorAccent,
                                  imagePath: "ic_muscle.png",
                                )
                                : MyImage(
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.cover,
                                  color: white,
                                  imagePath: "ic_muscle.png",
                                ),
                      ),
                    ),
                    MyText(
                      color: white,
                      text: Utils.kmbGenerator(
                        int.parse(
                          shortProvider.shortVideoList?[index].totalLike
                                  .toString() ??
                              "",
                        ),
                      ),
                      multilanguage: false,
                      textalign: TextAlign.center,
                      fontsizeNormal: 12,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 10),

                    //   Difood_app Button With Defood_app Count
                    // InkWell(
                    //   onTap: () async {
                    //     if (Constant.userID == null) {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) {
                    //             return const Login();
                    //           },
                    //         ),
                    //       );
                    //     } else {
                    //       if (shortProvider.shortVideoList?[index].ifood_app ==
                    //           0) {
                    //         Utils.showSnackbar(
                    //             context, "youcannotlikethiscontent", true);
                    //       } else {
                    //         //  Call Difood_app APi Call
                    //         if ((shortProvider.shortVideoList?[index]
                    //                     .isUserLikeDifood_app ??
                    //                 2) ==
                    //             0) {
                    //           printLog("Remove Api");
                    //           await shortProvider.shortDifood_app(
                    //               index,
                    //               "3",
                    //               shortProvider.shortVideoList?[index].id
                    //                       .toString() ??
                    //                   "",
                    //               "0",
                    //               "0");
                    //         } else {
                    //           await shortProvider.shortDifood_app(
                    //               index,
                    //               "3",
                    //               shortProvider.shortVideoList?[index].id
                    //                       .toString() ??
                    //                   "",
                    //               "2",
                    //               "0");
                    //         }
                    //       }
                    //     }
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(10.0),
                    //     child: (shortProvider.shortVideoList?[index]
                    //                     .isUserLikeDifood_app ??
                    //                 0) ==
                    //             2
                    //         ? MyImage(
                    //             width: 30,
                    //             height: 30,
                    //             color: colorAccent,
                    //             imagePath: "ic_difood_appfill.png")
                    //         : MyImage(
                    //             width: 30,
                    //             height: 30,
                    //             imagePath: "ic_difood_app.png"),
                    //   ),
                    // ),
                    // MyText(
                    //     color: white,
                    //     text: Utils.kmbGenerator(int.parse(shortProvider
                    //             .shortVideoList?[index].totalDifood_app
                    //             .toString() ??
                    //         "")),
                    //     textalign: TextAlign.center,
                    //     fontsizeNormal: 12,
                    //     multilanguage: false,
                    //     inter: false,
                    //     maxline: 1,
                    //     fontwaight: FontWeight.w600,
                    //     overflow: TextOverflow.ellipsis,
                    //     fontstyle: FontStyle.normal),
                    // const SizedBox(height: 20),

                    // Commenet Button Bottom Sheet Open
                    InkWell(
                      onTap: () {
                        shortProvider.storeContentId(
                          shortProvider.shortVideoList?[index].id.toString() ??
                              "",
                        );
                        // Call Comment bottom Sheet
                        shortProvider.getComment(
                          "3",
                          shortProvider.shortVideoList?[index].id.toString() ??
                              "",
                          1,
                        );

                        commentBottomSheet(
                          videoid:
                              shortProvider.shortVideoList?[index].id
                                  .toString() ??
                              "",
                          index: index,
                          isShortType: "short",
                        );
                      },
                      child: MyImage(
                        width: 26,
                        height: 26,
                        color: white,
                        imagePath: "ic_comment.png",
                      ),
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      color: white,
                      text: Utils.kmbGenerator(
                        shortProvider.shortVideoList?[index].totalComment ?? 0,
                      ),
                      multilanguage: false,
                      textalign: TextAlign.center,
                      fontsizeNormal: 12,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 10),
                    // Share Button
                    InkWell(
                      onTap: () {
                        Utils.shareApp(
                          Platform.isIOS
                              ? "Hey! I'm Listening ${shortProvider.shortVideoList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                              : "Hey! I'm Listening ${shortProvider.shortVideoList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                        );
                      },
                      child: MyImage(
                        width: 26,
                        height: 26,
                        imagePath: "ic_share.png",
                        color: white,
                      ),
                    ),
                    const SizedBox(height: 0),
                    MyText(
                      color: white,
                      text: "share",
                      textalign: TextAlign.center,
                      fontsizeNormal: 12,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else {
                          moreBottomSheet(
                            shortProvider.shortVideoList?[index].userId
                                    .toString() ??
                                "",
                            shortProvider.shortVideoList?[index].id
                                    .toString() ??
                                "",
                          );
                        }
                      },
                      child: MyImage(
                        width: 20,
                        height: 20,
                        imagePath: "ic_more.png",
                        color: white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 1, color: colorAccent),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              width: 40,
                              height: 40,
                              imagePath:
                                  shortProvider
                                      .shortVideoList?[index]
                                      .portraitImg
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "music.gif",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            /*  result Title */
            shortTitle(
              title:
                  shortProvider.shortVideoList?[index].title.toString() ?? "",
            ),
          ],
        );
      },
    );
  }

  /* Profile Short */
  Widget _buildProfileShort() {
    if (shortProvider.loading) {
      return shimmer();
    } else {
      if (shortProvider.getContentbyChannelModel.status == 200) {
        if (shortProvider.profileShortList != null &&
            (shortProvider.profileShortList?.length ?? 0) > 0) {
          return _buildProfileShortPageView();
        } else {
          return const NoPost(title: "nodatavideotitle", subTitle: "");
        }
      } else {
        return const NoPost(title: "nodatavideotitle", subTitle: "");
      }
    }
  }

  Widget _buildProfileShortPageView() {
    return Stack(
      children: [
        PreloadPageView.builder(
          controller: preloadPageController,
          preloadPagesCount: 4,
          itemCount: shortProvider.profileShortList?.length ?? 0,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                /* result Video */
                Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                    maxHeight: MediaQuery.of(context).size.height,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: VideoScreen(
                    index: index,
                    pagePos: shortProvider.currentPageIndex,
                    thumbnailImg:
                        shortProvider.profileShortList?[index].portraitImg
                            .toString() ??
                        "",
                    videoId:
                        shortProvider.profileShortList?[index].id.toString() ??
                        "",
                    videoUrl:
                        shortProvider.profileShortList?[index].content
                            .toString() ??
                        "",
                  ),
                ),
                /* Show Gift */
                showGift(),

                /* Like, Difood_app, Comment, Share and More Buttons*/
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Profile(
                                    isBottomBar: false,
                                    toUserId:
                                        shortProvider
                                            .profileShortList?[index]
                                            .userId
                                            .toString() ??
                                        "",
                                    toChannelId:
                                        shortProvider
                                            .profileShortList?[index]
                                            .channelId
                                            .toString() ??
                                        "",
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 1, color: colorAccent),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                imagePath:
                                    shortProvider
                                        .profileShortList?[index]
                                        .channelImage
                                        .toString() ??
                                    "",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        /* Gift Icon */
                        giftButton(
                          shortProvider.profileShortList?[index].channelId
                                  .toString() ??
                              "",
                        ),
                        // Like Button With Like Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .profileShortList?[index]
                                      .ifood_app ==
                                  0) {
                                Utils.showSnackbar(
                                  context,
                                  "youcannotlikethiscontent",
                                  true,
                                );
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider
                                            .profileShortList?[index]
                                            .isUserLikeDifood_app ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.profileShortLike(
                                    index,
                                    "3",
                                    shortProvider.profileShortList?[index].id
                                            .toString() ??
                                        "",
                                    "0",
                                    "0",
                                  );
                                } else {
                                  await shortProvider.profileShortLike(
                                    index,
                                    "3",
                                    shortProvider.profileShortList?[index].id
                                            .toString() ??
                                        "",
                                    "1",
                                    "0",
                                  );
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child:
                                (shortProvider
                                                .profileShortList?[index]
                                                .isUserLikeDifood_app ??
                                            0) ==
                                        1
                                    ? MyImage(
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.cover,
                                      color: colorAccent,
                                      imagePath: "ic_muscle.png",
                                    )
                                    : MyImage(
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.cover,
                                      color: white,
                                      imagePath: "ic_muscle.png",
                                    ),
                          ),
                        ),
                        MyText(
                          color: white,
                          text: Utils.kmbGenerator(
                            int.parse(
                              shortProvider.profileShortList?[index].totalLike
                                      .toString() ??
                                  "",
                            ),
                          ),
                          multilanguage: false,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 20),
                        // Difood_app Button With Defood_app Count
                        // InkWell(
                        //   onTap: () async {
                        //     if (Constant.userID == null) {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) {
                        //             return const Login();
                        //           },
                        //         ),
                        //       );
                        //     } else {
                        //       if (shortProvider
                        //               .profileShortList?[index].ifood_app ==
                        //           0) {
                        //         Utils.showSnackbar(
                        //             context, "youcannotlikethiscontent", true);
                        //       } else {
                        //         //  Call Difood_app APi Call
                        //         if ((shortProvider.profileShortList?[index]
                        //                     .isUserLikeDifood_app ??
                        //                 2) ==
                        //             0) {
                        //           printLog("Remove Api");
                        //           await shortProvider.profileShortDifood_app(
                        //               index,
                        //               "3",
                        //               shortProvider.profileShortList?[index].id
                        //                       .toString() ??
                        //                   "",
                        //               "0",
                        //               "0");
                        //         } else {
                        //           await shortProvider.profileShortDifood_app(
                        //               index,
                        //               "3",
                        //               shortProvider.profileShortList?[index].id
                        //                       .toString() ??
                        //                   "",
                        //               "2",
                        //               "0");
                        //         }
                        //       }
                        //     }
                        //   },
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(10.0),
                        //     child: (shortProvider.profileShortList?[index]
                        //                     .isUserLikeDifood_app ??
                        //                 0) ==
                        //             2
                        //         ? MyImage(
                        //             width: 30,
                        //             height: 30,
                        //             color: colorAccent,
                        //             imagePath: "ic_difood_appfill.png")
                        //         : MyImage(
                        //             width: 30,
                        //             height: 30,
                        //             imagePath: "ic_difood_app.png"),
                        //   ),
                        // ),
                        // MyText(
                        //     color: white,
                        //     text: Utils.kmbGenerator(int.parse(shortProvider
                        //             .profileShortList?[index].totalDifood_app
                        //             .toString() ??
                        //         "")),
                        //     textalign: TextAlign.center,
                        //     fontsizeNormal: 12,
                        //     multilanguage: false,
                        //     inter: false,
                        //     maxline: 1,
                        //     fontwaight: FontWeight.w600,
                        //     overflow: TextOverflow.ellipsis,
                        //     fontstyle: FontStyle.normal),
                        // const SizedBox(height: 20),
                        // Commenet Button Bottom Sheet Open
                        InkWell(
                          onTap: () {
                            shortProvider.storeContentId(
                              shortProvider.profileShortList?[index].id
                                      .toString() ??
                                  "",
                            );
                            // Call Comment bottom Sheet
                            shortProvider.getComment(
                              "3",
                              shortProvider.profileShortList?[index].id
                                      .toString() ??
                                  "",
                              1,
                            );

                            commentBottomSheet(
                              videoid:
                                  shortProvider.profileShortList?[index].id
                                      .toString() ??
                                  "",
                              index: index,
                              isShortType: "profile",
                            );
                          },
                          child: MyImage(
                            width: 26,
                            height: 26,
                            color: white,
                            imagePath: "ic_comment.png",
                          ),
                        ),

                        const SizedBox(height: 10),
                        MyText(
                          color: white,
                          text: Utils.kmbGenerator(
                            shortProvider
                                    .profileShortList?[index]
                                    .totalComment ??
                                0,
                          ),
                          multilanguage: false,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 20),
                        // Share Button
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              Utils.shareApp(
                                Platform.isIOS
                                    ? "Hey! I'm Listening ${shortProvider.profileShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                    : "Hey! I'm Listening ${shortProvider.profileShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                              );
                            }
                          },
                          child: MyImage(
                            width: 26,
                            height: 26,
                            color: white,
                            imagePath: "ic_share.png",
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                          color: white,
                          text: "share",
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          multilanguage: true,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              moreBottomSheet(
                                shortProvider.profileShortList?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.profileShortList?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                            width: 20,
                            height: 20,
                            color: white,
                            imagePath: "ic_more.png",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  width: 1,
                                  color: colorAccent,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imagePath:
                                      shortProvider
                                          .profileShortList?[index]
                                          .portraitImg
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "music.gif",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                /*  result Title */
                shortTitle(
                  title:
                      shortProvider.profileShortList?[index].title.toString() ??
                      "",
                ),
              ],
            );
          },
          /* result Pagination Content */
          onPageChanged: (value) async {
            if (value > 0 && (value % 2) == 0) {
              _fetchUserShort(true);
            }
            shortProvider.onChangePage(value);
            printLog("onPageChanged value ======> $value");
          },
        ),
        /* Back Button */
        Positioned.fill(
          top: 60,
          left: 20,
          right: 20,
          child: Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: MyImage(
                width: 25,
                height: 25,
                imagePath: "ic_roundback.png",
                color: white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* WatchLater Short */
  Widget _buildWatchLaterShort() {
    return Consumer<ShortProvider>(
      builder: (context, watchlaterShortprovider, child) {
        if (watchlaterShortprovider.loading) {
          return shimmer();
        } else {
          if (watchlaterShortprovider.watchlaterModel.status == 200) {
            if (watchlaterShortprovider.watchlaterShortList != null &&
                (watchlaterShortprovider.watchlaterShortList?.length ?? 0) >
                    0) {
              return _buildWatchLaterShortPageView();
            } else {
              return const NoPost(title: "nodatavideotitle", subTitle: "");
            }
          } else {
            return const NoPost(title: "nodatavideotitle", subTitle: "");
          }
        }
      },
    );
  }

  Widget _buildWatchLaterShortPageView() {
    return Stack(
      children: [
        PreloadPageView.builder(
          controller: preloadPageController,
          preloadPagesCount: 4,
          itemCount: shortProvider.watchlaterShortList?.length ?? 0,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            printLog("Index==>$index");
            printLog("initialindex==>${widget.initialIndex}");
            return Stack(
              children: [
                /* result Video */
                Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                    maxHeight: MediaQuery.of(context).size.height,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: VideoScreen(
                    index: index,
                    pagePos: shortProvider.currentPageIndex,
                    thumbnailImg:
                        shortProvider.watchlaterShortList?[index].portraitImg
                            .toString() ??
                        "",
                    videoId:
                        shortProvider.watchlaterShortList?[index].id
                            .toString() ??
                        "",
                    videoUrl:
                        shortProvider.watchlaterShortList?[index].content
                            .toString() ??
                        "",
                  ),
                ),
                /* Show Gift */
                showGift(),
                /* Like, Difood_app, Comment, Share and More Buttons*/
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Profile(
                                    isBottomBar: false,
                                    toUserId:
                                        shortProvider
                                            .watchlaterShortList?[index]
                                            .userId
                                            .toString() ??
                                        "",
                                    toChannelId:
                                        shortProvider
                                            .watchlaterShortList?[index]
                                            .channelId
                                            .toString() ??
                                        "",
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 1, color: colorAccent),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                imagePath:
                                    shortProvider
                                        .watchlaterShortList?[index]
                                        .channelImage
                                        .toString() ??
                                    "",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        /* Gift Icon */
                        giftButton(
                          shortProvider.watchlaterShortList?[index].channelId
                                  .toString() ??
                              "",
                        ),
                        // Like Button With Like Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .watchlaterShortList?[index]
                                      .ifood_app ==
                                  0) {
                                Utils.showSnackbar(
                                  context,
                                  "youcannotlikethiscontent",
                                  true,
                                );
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider
                                            .watchlaterShortList?[index]
                                            .isUserLikeDifood_app ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.watchLaterShortLike(
                                    index,
                                    "3",
                                    shortProvider.watchlaterShortList?[index].id
                                            .toString() ??
                                        "",
                                    "0",
                                    "0",
                                  );
                                } else {
                                  await shortProvider.watchLaterShortLike(
                                    index,
                                    "3",
                                    shortProvider.watchlaterShortList?[index].id
                                            .toString() ??
                                        "",
                                    "1",
                                    "0",
                                  );
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child:
                                (shortProvider
                                                .watchlaterShortList?[index]
                                                .isUserLikeDifood_app ??
                                            0) ==
                                        1
                                    ? MyImage(
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.cover,
                                      color: colorAccent,
                                      imagePath: "ic_muscle.png",
                                    )
                                    : MyImage(
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.cover,
                                      color: white,
                                      imagePath: "ic_muscle.png",
                                    ),
                          ),
                        ),
                        MyText(
                          color: white,
                          text: Utils.kmbGenerator(
                            int.parse(
                              shortProvider
                                      .watchlaterShortList?[index]
                                      .totalLike
                                      .toString() ??
                                  "",
                            ),
                          ),
                          multilanguage: false,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 20),
                        // Difood_app Button With Defood_app Count
                        // InkWell(
                        //   onTap: () async {
                        //     if (Constant.userID == null) {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) {
                        //             return const Login();
                        //           },
                        //         ),
                        //       );
                        //     } else {
                        //       if (shortProvider
                        //               .watchlaterShortList?[index].ifood_app ==
                        //           0) {
                        //         Utils.showSnackbar(
                        //             context, "youcannotlikethiscontent", true);
                        //       } else {
                        //         //  Call Difood_app APi Call
                        //         if ((shortProvider.watchlaterShortList?[index]
                        //                     .isUserLikeDifood_app ??
                        //                 2) ==
                        //             0) {
                        //           printLog("Remove Api");
                        //           await shortProvider.watchLaterShortDifood_app(
                        //               index,
                        //               "3",
                        //               shortProvider
                        //                       .watchlaterShortList?[index].id
                        //                       .toString() ??
                        //                   "",
                        //               "0",
                        //               "0");
                        //         } else {
                        //           await shortProvider.watchLaterShortDifood_app(
                        //               index,
                        //               "3",
                        //               shortProvider
                        //                       .watchlaterShortList?[index].id
                        //                       .toString() ??
                        //                   "",
                        //               "2",
                        //               "0");
                        //         }
                        //       }
                        //     }
                        //   },
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(10.0),
                        //     child: (shortProvider.watchlaterShortList?[index]
                        //                     .isUserLikeDifood_app ??
                        //                 0) ==
                        //             2
                        //         ? MyImage(
                        //             width: 30,
                        //             height: 30,
                        //             color: colorAccent,
                        //             imagePath: "ic_difood_appfill.png")
                        //         : MyImage(
                        //             width: 30,
                        //             height: 30,
                        //             imagePath: "ic_difood_app.png"),
                        //   ),
                        // ),
                        // MyText(
                        //     color: white,
                        //     text: Utils.kmbGenerator(int.parse(shortProvider
                        //             .watchlaterShortList?[index].totalDifood_app
                        //             .toString() ??
                        //         "")),
                        //     textalign: TextAlign.center,
                        //     fontsizeNormal: 12,
                        //     multilanguage: false,
                        //     inter: false,
                        //     maxline: 1,
                        //     fontwaight: FontWeight.w600,
                        //     overflow: TextOverflow.ellipsis,
                        //     fontstyle: FontStyle.normal),
                        // const SizedBox(height: 20),
                        // Commenet Button Bottom Sheet Open
                        InkWell(
                          onTap: () {
                            shortProvider.storeContentId(
                              shortProvider.watchlaterShortList?[index].id
                                      .toString() ??
                                  "",
                            );
                            // Call Comment bottom Sheet
                            shortProvider.getComment(
                              "3",
                              shortProvider.watchlaterShortList?[index].id
                                      .toString() ??
                                  "",
                              1,
                            );

                            commentBottomSheet(
                              videoid:
                                  shortProvider.watchlaterShortList?[index].id
                                      .toString() ??
                                  "",
                              index: index,
                              isShortType: "watchlater",
                            );
                          },
                          child: MyImage(
                            width: 26,
                            height: 26,
                            color: white,
                            imagePath: "ic_comment.png",
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                          color: white,
                          text: Utils.kmbGenerator(
                            shortProvider
                                    .watchlaterShortList?[index]
                                    .totalComment ??
                                0,
                          ),
                          multilanguage: false,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 20),
                        // Share Button
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              Utils.shareApp(
                                Platform.isIOS
                                    ? "Hey! I'm Listening ${shortProvider.watchlaterShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                    : "Hey! I'm Listening ${shortProvider.watchlaterShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                              );
                            }
                          },
                          child: MyImage(
                            width: 26,
                            height: 26,
                            color: white,
                            imagePath: "ic_share.png",
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                          color: white,
                          text: "share",
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          multilanguage: true,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              moreBottomSheet(
                                shortProvider.watchlaterShortList?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.watchlaterShortList?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                            width: 20,
                            height: 20,
                            imagePath: "ic_more.png",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  width: 1,
                                  color: colorAccent,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imagePath:
                                      shortProvider
                                          .watchlaterShortList?[index]
                                          .portraitImg
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "music.gif",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                /* result Title */
                shortTitle(
                  title:
                      shortProvider.watchlaterShortList?[index].title
                          .toString() ??
                      "",
                ),
              ],
            );
          },
          /* result Pagination Content */
          onPageChanged: (value) async {
            if (value > 0 && (value % 2) == 0) {
              _fetchWatchLaterShort(true);
            }
            shortProvider.onChangePage(value);
            printLog("onPageChanged value ======> $value");
          },
        ),
        /* Back Button */
        Positioned.fill(
          top: 60,
          left: 20,
          right: 20,
          child: Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: MyImage(
                width: 25,
                height: 25,
                imagePath: "ic_roundback.png",
                color: white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* Search Short */

  Widget _buildSearchShort() {
    return Consumer<ShortProvider>(
      builder: (context, watchlaterShortprovider, child) {
        if (watchlaterShortprovider.loading) {
          return shimmer();
        } else {
          if (shortProvider.searchModel.result != null &&
              (shortProvider.searchModel.result?.length ?? 0) > 0) {
            return _buildSearchShortPageView();
          } else {
            return const NoPost(title: "nodatavideotitle", subTitle: "");
          }
        }
      },
    );
  }

  Widget _buildSearchShortPageView() {
    return Stack(
      children: [
        PreloadPageView.builder(
          controller: preloadPageController,
          itemCount: shortProvider.searchModel.result?.length ?? 0,
          preloadPagesCount: 4,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) async {},
          itemBuilder: (context, index) {
            return Stack(
              children: [
                /* result Video */
                Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                    maxHeight: MediaQuery.of(context).size.height,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: VideoScreen(
                    index: index,
                    pagePos: shortProvider.currentPageIndex,
                    thumbnailImg:
                        shortProvider.searchModel.result?[index].portraitImg
                            .toString() ??
                        "",
                    videoId:
                        shortProvider.searchModel.result?[index].id
                            .toString() ??
                        "",
                    videoUrl:
                        shortProvider.searchModel.result?[index].content
                            .toString() ??
                        "",
                  ),
                ),
                /* Show Gift */
                showGift(),
                /* Like, Difood_app, Comment, Share and More Buttons */
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Profile(
                                    isBottomBar: false,
                                    toUserId:
                                        shortProvider
                                            .searchModel
                                            .result?[index]
                                            .userId
                                            .toString() ??
                                        "",
                                    toChannelId:
                                        shortProvider
                                            .searchModel
                                            .result?[index]
                                            .channelId
                                            .toString() ??
                                        "",
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 1, color: colorAccent),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                imagePath:
                                    shortProvider
                                        .searchModel
                                        .result?[index]
                                        .channelImage
                                        .toString() ??
                                    "",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        /* Gift Icon */
                        giftButton(
                          shortProvider.searchModel.result?[index].channelId
                                  .toString() ??
                              "",
                        ),

                        const SizedBox(height: 5),
                        // Like Button With Like Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .searchModel
                                      .result?[index]
                                      .ifood_app ==
                                  0) {
                                Utils.showSnackbar(
                                  context,
                                  "youcannotlikethiscontent",
                                  true,
                                );
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider
                                            .searchModel
                                            .result?[index]
                                            .isUserLikeDifood_app ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.shortLike(
                                    index,
                                    "3",
                                    shortProvider.searchModel.result?[index].id
                                            .toString() ??
                                        "",
                                    "0",
                                    "0",
                                  );
                                } else {
                                  await shortProvider.shortLike(
                                    index,
                                    "3",
                                    shortProvider.searchModel.result?[index].id
                                            .toString() ??
                                        "",
                                    "1",
                                    "0",
                                  );
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child:
                                (shortProvider
                                                .searchModel
                                                .result?[index]
                                                .isUserLikeDifood_app ??
                                            0) ==
                                        1
                                    ? MyImage(
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.cover,
                                      color: colorAccent,
                                      imagePath: "ic_muscle.png",
                                    )
                                    : MyImage(
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.cover,
                                      color: white,
                                      imagePath: "ic_muscle.png",
                                    ),
                          ),
                        ),
                        MyText(
                          color: white,
                          text: Utils.kmbGenerator(
                            shortProvider
                                    .searchModel
                                    .result?[index]
                                    .totalLike ??
                                0,
                          ),
                          multilanguage: false,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 10),

                        //   Difood_app Button With Defood_app Count
                        // InkWell(
                        //   onTap: () async {
                        //     if (Constant.userID == null) {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) {
                        //             return const Login();
                        //           },
                        //         ),
                        //       );
                        //     } else {
                        //       if (shortProvider.shortVideoList?[index].ifood_app ==
                        //           0) {
                        //         Utils.showSnackbar(
                        //             context, "youcannotlikethiscontent", true);
                        //       } else {
                        //         //  Call Difood_app APi Call
                        //         if ((shortProvider.shortVideoList?[index]
                        //                     .isUserLikeDifood_app ??
                        //                 2) ==
                        //             0) {
                        //           printLog("Remove Api");
                        //           await shortProvider.shortDifood_app(
                        //               index,
                        //               "3",
                        //               shortProvider.shortVideoList?[index].id
                        //                       .toString() ??
                        //                   "",
                        //               "0",
                        //               "0");
                        //         } else {
                        //           await shortProvider.shortDifood_app(
                        //               index,
                        //               "3",
                        //               shortProvider.shortVideoList?[index].id
                        //                       .toString() ??
                        //                   "",
                        //               "2",
                        //               "0");
                        //         }
                        //       }
                        //     }
                        //   },
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(10.0),
                        //     child: (shortProvider.shortVideoList?[index]
                        //                     .isUserLikeDifood_app ??
                        //                 0) ==
                        //             2
                        //         ? MyImage(
                        //             width: 30,
                        //             height: 30,
                        //             color: colorAccent,
                        //             imagePath: "ic_difood_appfill.png")
                        //         : MyImage(
                        //             width: 30,
                        //             height: 30,
                        //             imagePath: "ic_difood_app.png"),
                        //   ),
                        // ),
                        // MyText(
                        //     color: white,
                        //     text: Utils.kmbGenerator(int.parse(shortProvider
                        //             .shortVideoList?[index].totalDifood_app
                        //             .toString() ??
                        //         "")),
                        //     textalign: TextAlign.center,
                        //     fontsizeNormal: 12,
                        //     multilanguage: false,
                        //     inter: false,
                        //     maxline: 1,
                        //     fontwaight: FontWeight.w600,
                        //     overflow: TextOverflow.ellipsis,
                        //     fontstyle: FontStyle.normal),
                        // const SizedBox(height: 20),

                        // Commenet Button Bottom Sheet Open
                        InkWell(
                          onTap: () {
                            shortProvider.storeContentId(
                              shortProvider.searchModel.result?[index].id
                                      .toString() ??
                                  "",
                            );
                            // Call Comment bottom Sheet
                            shortProvider.getComment(
                              "3",
                              shortProvider.searchModel.result?[index].id
                                      .toString() ??
                                  "",
                              1,
                            );

                            commentBottomSheet(
                              videoid:
                                  shortProvider.searchModel.result?[index].id
                                      .toString() ??
                                  "",
                              index: index,
                              isShortType: "short",
                            );
                          },
                          child: MyImage(
                            width: 26,
                            height: 26,
                            color: white,
                            imagePath: "ic_comment.png",
                          ),
                        ),
                        const SizedBox(height: 5),
                        MyText(
                          color: white,
                          text: Utils.kmbGenerator(
                            shortProvider
                                    .searchModel
                                    .result?[index]
                                    .totalComment ??
                                0,
                          ),
                          multilanguage: false,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 10),
                        // Share Button
                        InkWell(
                          onTap: () {
                            Utils.shareApp(
                              Platform.isIOS
                                  ? "Hey! I'm Listening ${shortProvider.searchModel.result?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                  : "Hey! I'm Listening ${shortProvider.searchModel.result?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                            );
                          },
                          child: MyImage(
                            width: 26,
                            height: 26,
                            imagePath: "ic_share.png",
                            color: white,
                          ),
                        ),
                        const SizedBox(height: 0),
                        MyText(
                          color: white,
                          text: "share",
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          multilanguage: true,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              moreBottomSheet(
                                shortProvider.searchModel.result?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.searchModel.result?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                            width: 20,
                            height: 20,
                            imagePath: "ic_more.png",
                            color: white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  width: 1,
                                  color: colorAccent,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imagePath:
                                      shortProvider
                                          .searchModel
                                          .result?[index]
                                          .portraitImg
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "music.gif",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                /*  result Title */
                shortTitle(
                  title:
                      shortProvider.searchModel.result?[index].title
                          .toString() ??
                      "",
                ),
              ],
            );
          },
        ),
        /* Back Button */
        Positioned.fill(
          top: 60,
          left: 20,
          right: 20,
          child: Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: MyImage(
                width: 25,
                height: 25,
                imagePath: "ic_roundback.png",
                color: white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget shimmer() {
    return Stack(
      children: [
        PageView.builder(
          itemCount: 1,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: colorPrimary,
                ),
                const Positioned.fill(
                  bottom: 30,
                  right: 20,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomWidget.circular(width: 25, height: 25),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(width: 30, height: 15),
                        SizedBox(height: 20),
                        CustomWidget.circular(width: 25, height: 25),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(width: 30, height: 15),
                        SizedBox(height: 20),
                        CustomWidget.circular(width: 25, height: 25),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(width: 30, height: 15),
                        SizedBox(height: 20),
                        CustomWidget.circular(width: 25, height: 25),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(width: 30, height: 15),
                        SizedBox(height: 20),
                        CustomWidget.circular(width: 25, height: 25),
                        SizedBox(height: 20),
                        CustomWidget.roundrectborder(width: 45, height: 45),
                      ],
                    ),
                  ),
                ),
                const Positioned.fill(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomWidget.roundcorner(width: 30, height: 30),
                          SizedBox(width: 10),
                          CustomWidget.roundrectborder(width: 150, height: 15),
                        ],
                      ),
                      SizedBox(height: 10),
                      CustomWidget.roundrectborder(width: 200, height: 15),
                      CustomWidget.roundrectborder(width: 200, height: 15),
                    ],
                  ),
                ),
              ],
            );
          },
          onPageChanged: (index) async {},
        ),
      ],
    );
  }

  /* Comment Bottom Sheet */
  commentBottomSheet({
    required int index,
    required videoid,
    required isShortType,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(children: [buildComment(index, videoid, isShortType)]);
      },
    ).whenComplete(() {
      log("comment Back");
      commentController.clear();
      shortProvider.clearComment();
    });
  }

  /* Build Comment List */
  Widget buildComment(index, dynamic videoid, isShortType) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                        color: white,
                        multilanguage: true,
                        text: "comments",
                        fontsizeNormal: 15,
                        fontstyle: FontStyle.normal,
                        fontwaight: FontWeight.w600,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.start,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        commentController.clear();
                        shortProvider.clearComment();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Utils.buildGradLine(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: commentListController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  children: [
                    Consumer<ShortProvider>(
                      builder: (context, commentprovider, child) {
                        if (shortProvider.commentloading &&
                            !shortProvider.commentLoadmore) {
                          return Utils.pageLoader(context);
                        } else {
                          if (shortProvider.getcommentModel.status == 200 &&
                              shortProvider.commentList != null) {
                            if ((shortProvider.commentList?.length ?? 0) > 0) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          commentprovider.commentList?.length ??
                                          0,
                                      itemBuilder: (BuildContext ctx, index) {
                                        log(
                                          "printLog===> ${commentprovider.commentList?.length}",
                                        );

                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            10,
                                            0,
                                            10,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  1,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: white,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: MyNetworkImage(
                                                    imagePath:
                                                        commentprovider
                                                            .commentList?[index]
                                                            .image
                                                            .toString() ??
                                                        "",
                                                    fit: BoxFit.fill,
                                                    width: 25,
                                                    height: 25,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  commentprovider
                                                              .commentList?[index]
                                                              .channelName
                                                              .toString() ==
                                                          ""
                                                      ? MyText(
                                                        color: white,
                                                        text: "guestuser",
                                                        fontsizeNormal:
                                                            Dimens.textTitle,
                                                        fontwaight:
                                                            FontWeight.w500,
                                                        multilanguage: true,
                                                        maxline: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        inter: false,
                                                        textalign:
                                                            TextAlign.center,
                                                        fontstyle:
                                                            FontStyle.normal,
                                                      )
                                                      : MyText(
                                                        color: white,
                                                        text:
                                                            commentprovider
                                                                .commentList?[index]
                                                                .channelName
                                                                .toString() ??
                                                            "",
                                                        fontsizeNormal:
                                                            Dimens.textTitle,
                                                        fontwaight:
                                                            FontWeight.w500,
                                                        multilanguage: false,
                                                        maxline: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        inter: false,
                                                        textalign:
                                                            TextAlign.center,
                                                        fontstyle:
                                                            FontStyle.normal,
                                                      ),
                                                  const SizedBox(height: 8),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.70,
                                                    child: MyText(
                                                      color: white,
                                                      text:
                                                          commentprovider
                                                              .commentList?[index]
                                                              .comment
                                                              .toString() ??
                                                          "",
                                                      fontsizeNormal:
                                                          Dimens.textMedium,
                                                      fontwaight:
                                                          FontWeight.w400,
                                                      multilanguage: false,
                                                      maxline: 10,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      inter: false,
                                                      textalign: TextAlign.left,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 7),
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          shortProvider
                                                              .storeReplayCommentId(
                                                                shortProvider
                                                                        .commentList?[index]
                                                                        .id
                                                                        .toString() ??
                                                                    "",
                                                              );
                                                          // Set Replay Comment Channal name
                                                          commentController
                                                              .clear();

                                                          Navigator.pop(
                                                            context,
                                                          );

                                                          replayCommentBottomSheet(
                                                            index,
                                                            videoid,
                                                            commentprovider
                                                                    .commentList?[index]
                                                                    .id
                                                                    .toString() ??
                                                                "",
                                                            commentprovider
                                                                    .commentList?[index]
                                                                    .image
                                                                    .toString() ??
                                                                "",
                                                            commentprovider
                                                                    .commentList?[index]
                                                                    .fullName
                                                                    .toString() ??
                                                                "",
                                                            commentprovider
                                                                    .commentList?[index]
                                                                    .comment
                                                                    .toString() ??
                                                                "",
                                                            isShortType,
                                                          );

                                                          await shortProvider
                                                              .getReplayComment(
                                                                commentprovider
                                                                        .commentList?[index]
                                                                        .id
                                                                        .toString() ??
                                                                    "",
                                                                1,
                                                              );
                                                        },
                                                        child:
                                                            commentprovider
                                                                        .commentList?[index]
                                                                        .totalReply !=
                                                                    0
                                                                ? Row(
                                                                  children: [
                                                                    MyText(
                                                                      color:
                                                                          gray,
                                                                      text:
                                                                          "seeall",
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textSmall,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w400,
                                                                      multilanguage:
                                                                          true,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      inter:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    MyText(
                                                                      color:
                                                                          gray,
                                                                      text: Utils.kmbGenerator(
                                                                        int.parse(
                                                                          commentprovider.commentList?[index].totalReply.toString() ??
                                                                              "",
                                                                        ),
                                                                      ),
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textSmall,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w400,
                                                                      multilanguage:
                                                                          false,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      inter:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    MyText(
                                                                      color:
                                                                          gray,
                                                                      text:
                                                                          "comments",
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textSmall,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w400,
                                                                      multilanguage:
                                                                          true,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      inter:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                  ],
                                                                )
                                                                : MyText(
                                                                  color: gray,
                                                                  text:
                                                                      "seeall",
                                                                  fontsizeNormal:
                                                                      Dimens
                                                                          .textSmall,
                                                                  fontwaight:
                                                                      FontWeight
                                                                          .w400,
                                                                  multilanguage:
                                                                      true,
                                                                  maxline: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  inter: false,
                                                                  textalign:
                                                                      TextAlign
                                                                          .center,
                                                                  fontstyle:
                                                                      FontStyle
                                                                          .normal,
                                                                ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      if (commentprovider
                                                              .commentList?[index]
                                                              .userId
                                                              .toString() ==
                                                          Constant.userID)
                                                        if (commentprovider
                                                                .deletecommentLoading &&
                                                            commentprovider
                                                                    .deleteItemIndex ==
                                                                index)
                                                          const SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  color:
                                                                      colorAccent,
                                                                  strokeWidth:
                                                                      1,
                                                                ),
                                                          )
                                                        else
                                                          InkWell(
                                                            onTap: () async {
                                                              await shortProvider
                                                                  .getDeleteComment(
                                                                    commentprovider
                                                                            .commentList?[index]
                                                                            .id
                                                                            .toString() ??
                                                                        "",
                                                                    true,
                                                                    index,
                                                                    isShortType,
                                                                  );
                                                            },
                                                            child: MyImage(
                                                              width: 15,
                                                              height: 15,
                                                              imagePath:
                                                                  "ic_delete.png",
                                                            ),
                                                          )
                                                      else
                                                        const SizedBox.shrink(),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (shortProvider.commentloading)
                                    const CircularProgressIndicator(
                                      color: colorAccent,
                                    )
                                  else
                                    const SizedBox.shrink(),
                                ],
                              );
                            } else {
                              return Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                  width: 130,
                                  height:
                                      MediaQuery.of(context).size.height * 0.40,
                                  fit: BoxFit.contain,
                                  imagePath: "nodata.png",
                                ),
                              );
                            }
                          } else {
                            return Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                width: 130,
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                fit: BoxFit.contain,
                                imagePath: "nodata.png",
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Add Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: white,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else if (commentController.text.isEmpty) {
                          Utils().showToast("Please Enter Your Comment");
                        } else {
                          if (isShortType == "short" &&
                              shortProvider.shortVideoList?[index].isComment ==
                                  0) {
                            Utils.showSnackbar(
                              context,
                              "youcannotcommentthiscontent",
                              true,
                            );
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          } else {
                            await shortProvider.getaddcomment(
                              index,
                              "3",
                              videoid,
                              "0",
                              commentController.text,
                              "0",
                              widget.shortType,
                            );

                            commentController.clear();
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<ShortProvider>(
                            builder: (context, commentprovider, child) {
                              if (commentprovider.addcommentloading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorAccent,
                                    strokeWidth: 1,
                                  ),
                                );
                              } else {
                                return MyImage(
                                  height: 15,
                                  width: 15,
                                  color: white,
                                  fit: BoxFit.contain,
                                  imagePath: "ic_send.png",
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* More Button Bottom Sheet */
  moreBottomSheet(reportUserid, contentid) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.shortType == "watchlater"
                    ? const SizedBox.shrink()
                    : moreFunctionItem(
                      "ic_watchlater.png",
                      "savetowatchlater",
                      () async {
                        await shortProvider.addremoveWatchLater(
                          "3",
                          contentid,
                          "0",
                          "1",
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        Utils.showSnackbar(context, "savetowatchlater", true);
                      },
                    ),
                moreFunctionItem("report.png", "report", () async {
                  if (!mounted) return;
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  _fetchReportReason(0);
                  reportBottomSheet(reportUserid, contentid);
                }),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget moreFunctionItem(icon, title, onTap) {
    return ListTile(
      iconColor: white,
      textColor: white,
      title: MyText(
        color: white,
        text: title,
        fontwaight: FontWeight.w500,
        fontsizeNormal: Dimens.textTitle,
        maxline: 1,
        multilanguage: true,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.left,
        fontstyle: FontStyle.normal,
      ),
      leading: MyImage(width: 20, height: 20, imagePath: icon, color: white),
      onTap: onTap,
    );
  }

  /* Report Reason Bottom Sheet */
  reportBottomSheet(reportUserid, contentid) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.50,
              decoration: BoxDecoration(
                color: colorPrimaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    alignment: Alignment.centerLeft,
                    child: MyText(
                      color: white,
                      text: "selectreportreason",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: buildReportReasonList()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          if (!mounted) return;
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          shortProvider.reportReasonList?.clear();
                          shortProvider.position = 0;
                          shortProvider.clearSelectReportReason();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: white),
                          ),
                          child: MyText(
                            color: white,
                            text: "cancel",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            multilanguage: true,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () async {
                          if (Constant.userID == null) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const Login(),
                              ),
                            );
                          } else {
                            if (shortProvider.reasonId == "" ||
                                shortProvider.reasonId.isEmpty) {
                              Utils.showSnackbar(
                                context,
                                "pleaseselectyourreportreason",
                                true,
                              );
                            } else {
                              await shortProvider.addContentReport(
                                reportUserid,
                                contentid,
                                shortProvider
                                        .reportReasonList?[shortProvider
                                                .reportposition ??
                                            0]
                                        .reason
                                        .toString() ??
                                    "",
                                "1",
                              );

                              if (!context.mounted) return;
                              if (!mounted) return;
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              Utils.showSnackbar(
                                context,
                                "${shortProvider.addContentReportModel.message}",
                                false,
                              );
                              shortProvider.clearSelectReportReason();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: MyText(
                            color: white,
                            text: "report",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            multilanguage: true,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildReportReasonList() {
    return Consumer<ShortProvider>(
      builder: (context, reportreasonprovider, child) {
        if (reportreasonprovider.getcontentreportloading &&
            !reportreasonprovider.getcontentreportloadmore) {
          return Utils.pageLoader(context);
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: reportReasonController,
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                buildReportReasonListItem(),
                if (reportreasonprovider.getcontentreportloadmore)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildReportReasonListItem() {
    if (shortProvider.getRepostReasonModel.status == 200 &&
        shortProvider.reportReasonList != null) {
      if ((shortProvider.reportReasonList?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: shortProvider.reportReasonList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                shortProvider.selectReportReason(
                  index,
                  true,
                  shortProvider.reportReasonList?[index].id.toString() ?? "",
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                color:
                    shortProvider.reportposition == index &&
                            shortProvider.isSelectReason == true
                        ? colorAccent
                        : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color: white,
                      text: "${(index + 1).toString()}.",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
                      fontsizeWeb: Dimens.textTitle,
                      multilanguage: false,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                        color: white,
                        text:
                            shortProvider.reportReasonList?[index].reason
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        multilanguage: false,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(width: 20),
                    shortProvider.reportposition == index &&
                            shortProvider.isSelectReason == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const NoData(title: "nodatavideotitle", subTitle: "");
      }
    } else {
      printLog("null Array Last");
      return const NoData(title: "nodatavideotitle", subTitle: "");
    }
  }

  /* ReplayComment Bottom Sheet */
  // Replay Comment
  replayCommentBottomSheet(
    int index,
    videoid,
    commentid,
    commentUserImage,
    commentUsername,
    comment,
    isShortPage,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            buildReplayComment(
              index,
              videoid,
              commentid,
              commentUserImage,
              commentUsername,
              comment,
              isShortPage,
            ),
          ],
        );
      },
    ).whenComplete(() {
      log("clear Replaycomment====>");
      commentController.clear();
      shortProvider.clearReplayComment();
    });
  }

  Widget buildReplayComment(
    index,
    videoid,
    commentId,
    commentUserImage,
    commentUsername,
    comment,
    isShortPage,
  ) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                        color: white,
                        text: "replay",
                        fontsizeNormal: Dimens.textTitle,
                        fontwaight: FontWeight.w500,
                        multilanguage: true,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        inter: false,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        commentController.clear();
                        shortProvider.clearComment();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: white),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        imagePath: commentUserImage,
                        fit: BoxFit.fill,
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        color: white,
                        text: commentUsername,
                        fontsizeNormal: Dimens.textMedium,
                        fontwaight: FontWeight.w500,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        inter: false,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 5),
                      MyText(
                        color: white,
                        text: comment,
                        fontsizeNormal: Dimens.textSmall,
                        fontwaight: FontWeight.w400,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        inter: false,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: buildreplayCommentList(isShortPage)),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Replay Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: white,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else if (commentController.text.isEmpty) {
                          Utils().showToast("Please Enter Your Comment");
                        } else {
                          printLog("videoid==> $videoid");
                          printLog("comment==> ${commentController.text}");
                          printLog("comment==> $commentId");
                          await shortProvider.getaddReplayComment(
                            "3",
                            videoid,
                            "0",
                            commentController.text,
                            commentId,
                          );
                          commentController.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<ShortProvider>(
                            builder: (context, detailprovider, child) {
                              if (detailprovider.addreplaycommentloading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorAccent,
                                    strokeWidth: 1,
                                  ),
                                );
                              } else {
                                return MyImage(
                                  width: 20,
                                  height: 20,
                                  color: white,
                                  imagePath: "ic_send.png",
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildreplayCommentList(isShortPage) {
    return SingleChildScrollView(
      controller: replaycommentController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child: Consumer<ShortProvider>(
        builder: (context, detailprovider, child) {
          if (detailprovider.replaycommentloding &&
              !detailprovider.replayCommentloadmore) {
            return Utils.pageLoader(context);
          } else {
            return Column(
              children: [
                replayCommentList(isShortPage),
                if (detailprovider.replayCommentloadmore)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget replayCommentList(isShortPage) {
    if (shortProvider.replayCommentModel.status == 200 &&
        shortProvider.replaycommentList != null) {
      if ((shortProvider.replaycommentList?.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: shortProvider.replaycommentList?.length ?? 0,
                itemBuilder: (BuildContext ctx, index) {
                  return Container(
                    // color: gray,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 1, color: white),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              imagePath:
                                  shortProvider.replaycommentList?[index].image
                                      .toString() ??
                                  "",
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              shortProvider
                                          .replaycommentList?[index]
                                          .fullName ==
                                      ""
                                  ? MyText(
                                    color: white,
                                    text:
                                        shortProvider
                                            .replaycommentList?[index]
                                            .fullName
                                            .toString() ??
                                        "",
                                    fontsizeNormal: Dimens.textDesc,
                                    fontwaight: FontWeight.w600,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    inter: false,
                                    textalign: TextAlign.center,
                                    fontstyle: FontStyle.normal,
                                  )
                                  : MyText(
                                    color: white,
                                    text:
                                        shortProvider
                                            .replaycommentList?[index]
                                            .channelName
                                            .toString() ??
                                        "",
                                    fontsizeNormal: Dimens.textMedium,
                                    fontwaight: FontWeight.w500,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    inter: false,
                                    textalign: TextAlign.center,
                                    fontstyle: FontStyle.normal,
                                  ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: MyText(
                                  color: gray,
                                  text:
                                      shortProvider
                                          .replaycommentList?[index]
                                          .comment
                                          .toString() ??
                                      "",
                                  fontsizeNormal: Dimens.textSmall,
                                  fontwaight: FontWeight.w400,
                                  multilanguage: false,
                                  maxline: 3,
                                  overflow: TextOverflow.ellipsis,
                                  inter: false,
                                  textalign: TextAlign.left,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (shortProvider.replaycommentList?[index].userId
                                .toString() ==
                            Constant.userID)
                          if (shortProvider.deletecommentLoading &&
                              shortProvider.deleteItemIndex == index)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: colorAccent,
                                strokeWidth: 1,
                              ),
                            )
                          else
                            InkWell(
                              onTap: () async {
                                if (Constant.userID == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const Login();
                                      },
                                    ),
                                  );
                                } else {
                                  await shortProvider.getDeleteComment(
                                    shortProvider.replaycommentList?[index].id
                                            .toString() ??
                                        "",
                                    false,
                                    index,
                                    isShortPage,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  5,
                                  10,
                                  5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: colorAccent,
                                ),
                                child: MyText(
                                  color: white,
                                  text: "delete",
                                  fontsizeNormal: Dimens.textSmall,
                                  fontwaight: FontWeight.w400,
                                  multilanguage: true,
                                  maxline: 3,
                                  overflow: TextOverflow.ellipsis,
                                  inter: false,
                                  textalign: TextAlign.left,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (shortProvider.commentloading)
              const CircularProgressIndicator(color: colorAccent)
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const Expanded(child: NoData(title: "", subTitle: ""));
      }
    } else {
      return const Expanded(child: NoData(title: "", subTitle: ""));
    }
  }

  /* ======================= Open Gift ======================= */

  shortTitle({required title}) {
    return Positioned.fill(
      bottom: 30,
      left: 15,
      right: 15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 250,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: SizedBox(
              height: 20,
              child: MyMarqueeText(
                text: title,
                fontsize: Dimens.textSmall,
                fontweight: FontWeight.w600,
                color: white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget giftButton(channelId) {
    return InkWell(
      onTap: () async {
        if (Constant.userID == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Login();
              },
            ),
          );
        } else {
          openGift(channelId);
        }
      },
      child: MyImage(
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        imagePath: "ic_gift.gif",
      ),
    );
  }

  Widget showGift() {
    return shortProvider.giftUrl == null
        ? const SizedBox.shrink()
        : Align(
          alignment: Alignment.center,
          child: MyNetworkImage(
            width: 200,
            height: 200,
            imagePath: shortProvider.giftUrl ?? "",
            fit: BoxFit.cover,
          ),
        );
  }

  void openGift(channelId) {
    _fetchGift(0);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),
      builder:
          (context) => Container(
            height: 500,
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 65,
                  decoration: const BoxDecoration(color: colorAccent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Consumer<ProfileProvider>(
                        builder: (context, profileprovider, child) {
                          return Container(
                            height: 34,
                            padding: const EdgeInsets.only(left: 5, right: 10),
                            decoration: BoxDecoration(
                              color: white.withOpacity(0.1),
                              border: Border.all(color: black.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                MyImage(
                                  width: 22,
                                  height: 22,
                                  imagePath: "ic_coin.png",
                                ),
                                const SizedBox(width: 5),
                                MyText(
                                  color: black,
                                  multilanguage: false,
                                  text:
                                      profileprovider.profileloading
                                          ? "0"
                                          : Utils.kmbGenerator(
                                            profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .walletBalance ??
                                                0,
                                          ),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textSmall,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 4,
                              width: 35,
                              decoration: BoxDecoration(
                                color: black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 15),
                            MyText(
                              color: black,
                              multilanguage: true,
                              text: "sendgift",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textTitle,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!mounted) return;
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: transparent,
                            border: Border.all(color: black),
                          ),
                          child: Center(
                            child: MyImage(
                              width: 15,
                              color: black,
                              height: 15,
                              imagePath: "ic_close.webp",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Consumer2<ShortProvider, ProfileProvider>(
                  builder: (context, shortprovider, profileprovider, child) {
                    return Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: _giftScrollController,
                        child: Column(
                          children: [
                            ResponsiveGridList(
                              minItemWidth: 120,
                              minItemsPerRow: 3,
                              maxItemsPerRow: 3,
                              horizontalGridSpacing: 10,
                              verticalGridSpacing: 10,
                              listViewBuilderOptions: ListViewBuilderOptions(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                              children: List.generate(
                                shortprovider.giftList?.length ?? 0,
                                (index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: colorPrimaryDark,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: MyNetworkImage(
                                            width: 45,
                                            height: 45,
                                            imagePath:
                                                shortprovider
                                                    .giftList?[index]
                                                    .image
                                                    .toString() ??
                                                "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: gray.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: MyText(
                                            color: white,
                                            multilanguage: false,
                                            text:
                                                "${shortprovider.giftList?[index].price.toString() ?? ""} Coins",
                                            textalign: TextAlign.center,
                                            fontsizeNormal: Dimens.textSmall,
                                            inter: false,
                                            maxline: 1,
                                            fontwaight: FontWeight.w700,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            if (((shortprovider
                                                            .giftList?[index]
                                                            .price ??
                                                        0) ==
                                                    (profileprovider
                                                            .profileModel
                                                            .result?[0]
                                                            .walletBalance ??
                                                        0)) ||
                                                ((shortprovider
                                                            .giftList?[index]
                                                            .price ??
                                                        0)) <
                                                    (profileprovider
                                                            .profileModel
                                                            .result?[0]
                                                            .walletBalance ??
                                                        0)) {
                                              await shortProvider.showGift(
                                                imageUrl:
                                                    shortprovider
                                                        .giftList?[index]
                                                        .image
                                                        .toString() ??
                                                    "",
                                              );

                                              await shortProvider.minusCoin(
                                                channelId,
                                                shortprovider
                                                        .giftList?[index]
                                                        .price
                                                        .toString() ??
                                                    "",
                                              );

                                              if (!context.mounted) return;
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                            } else {
                                              /* Move TO Recharge Page */
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return const AdsPackage();
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: 35,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              color: colorAccent,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    bottom: Radius.circular(24),
                                                  ),
                                            ),
                                            child: MyText(
                                              color: black,
                                              multilanguage: true,
                                              text: "send",
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                /* Recharge Button */
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const AdsPackage();
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 55,
                          width: 130,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: MyImage(
                                    width: 22,
                                    height: 22,
                                    imagePath: "ic_coin.png",
                                  ),
                                ),
                                const SizedBox(width: 5),
                                MyText(
                                  color: white,
                                  multilanguage: true,
                                  text: "addcoins",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textDesc,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void categoryBottomSheet(BuildContext context) {
    _fetchDataCategory(0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: colorPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: categoryChipList(),
          ),
    );
  }

  Widget categoryChipList() {
    return Consumer<ShortProvider>(
      builder: (context, shortprovider, child) {
        if (shortProvider.categoryloading && !shortProvider.categoryloadMore) {
          return categoryShimmer();
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _categoryScrollController,
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    shortProvider.selectCategory(-1, 0);
                    shortProvider.clearShortList();
                    await shortProvider.getShortList(false, "", 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.5,
                        color:
                            shortProvider.selectedIndex == -1
                                ? white
                                : colorAccent,
                      ),
                    ),
                    child: MyText(
                      color:
                          shortProvider.selectedIndex == -1
                              ? white
                              : colorAccent,
                      text: "all_uppercase",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textExtraBig,
                      inter: false,
                      maxline: 1,
                      multilanguage: true,
                      fontwaight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                (shortProvider.categorydataList != null &&
                        (shortProvider.categorydataList?.length ?? 0) > 0)
                    ? Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children:
                          shortProvider.categorydataList!.map((choice) {
                            int index =
                                shortProvider.categorydataList?.indexOf(
                                  choice,
                                ) ??
                                0;
                            return ChoiceChip(
                              showCheckmark: false,
                              surfaceTintColor: colorPrimary,
                              disabledColor: colorPrimary,
                              label: MyText(
                                color:
                                    shortProvider.selectedIndex == index
                                        ? white
                                        : colorAccent,
                                text:
                                    shortProvider.categorydataList?[index].name
                                        .toString()
                                        .toUpperCase() ??
                                    "",
                                fontwaight: FontWeight.w700,
                                fontsizeNormal: Dimens.textTitle,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.italic,
                              ),
                              side: BorderSide(
                                color:
                                    shortProvider.selectedIndex == index
                                        ? white
                                        : colorAccent,
                                width: 1,
                              ),
                              selected: shortProvider.selectedIndex == index,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              selectedColor: colorPrimary,
                              backgroundColor: colorPrimary,
                              color: const WidgetStatePropertyAll(colorPrimary),
                              elevation: 0,
                              pressElevation: 0,
                              autofocus: false,
                              onSelected: (bool selected) async {
                                shortProvider.selectCategory(
                                  selected ? index : -1,
                                  shortProvider.categorydataList?[index].id ??
                                      0,
                                );
                                Navigator.pop(context);
                                shortProvider.clearShortList();
                                await shortProvider.getShortList(
                                  false,
                                  shortProvider.categorydataList?[index].id
                                          .toString() ??
                                      "",
                                  1,
                                );
                              },
                            );
                          }).toList(),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        }
      },
    );
  }

  // Widget buildCategory() {
  //   return Consumer<ShortProvider>(builder: (context, shortprovider, child) {
  //     if (shortProvider.categoryloading && !shortProvider.categoryloadMore) {
  //       return categoryShimmer();
  //     } else {
  //       return SingleChildScrollView(
  //         scrollDirection: Axis.vertical,
  //         padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
  //         physics: const AlwaysScrollableScrollPhysics(),
  //         controller: _categoryScrollController,
  //         child: Column(
  //           children: [
  //             InkWell(
  //               onTap: () async {
  //                 Navigator.pop(context);
  //                 await shortProvider.selectCategory("all", "");
  //                 shortProvider.clearShortList();
  //                 await shortProvider.getShortList(false, "", 1);
  //               },
  //               child: Container(
  //                 padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
  //                 decoration: BoxDecoration(
  //                     border: Border.all(
  //                   width: 2.5,
  //                   color:
  //                       shortProvider.catindex == "all" ? white : colorAccent,
  //                 )),
  //                 child: MyText(
  //                     color:
  //                         shortProvider.catindex == "all" ? white : colorAccent,
  //                     text: "all_uppercase",
  //                     textalign: TextAlign.center,
  //                     fontsizeNormal: Dimens.textExtraBig,
  //                     inter: false,
  //                     maxline: 1,
  //                     multilanguage: true,
  //                     fontwaight: FontWeight.w800,
  //                     overflow: TextOverflow.ellipsis,
  //                     fontstyle: FontStyle.italic),
  //               ),
  //             ),
  //             const SizedBox(height: 50),
  //             buildCategoryItem(),
  //             if (shortProvider.categoryloadMore)
  //               const SizedBox(
  //                   height: 20,
  //                   width: 20,
  //                   child: CircularProgressIndicator(
  //                     color: colorAccent,
  //                     strokeWidth: 1,
  //                   ))
  //             else
  //               const SizedBox.shrink(),
  //           ],
  //         ),
  //       );
  //     }
  //   });
  // }

  // Widget buildCategoryItem() {
  //   if (shortProvider.categorymodel.status == 200 &&
  //       shortProvider.categorydataList != null) {
  //     if ((shortProvider.categorydataList?.length ?? 0) > 0) {
  //       return Padding(
  //           padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
  //           child: ResponsiveGridList(
  //               minItemWidth: 120,
  //               minItemsPerRow: 3,
  //               maxItemsPerRow: 3,
  //               horizontalGridSpacing: 15,
  //               verticalGridSpacing: 15,
  //               listViewBuilderOptions: ListViewBuilderOptions(
  //                 scrollDirection: Axis.vertical,
  //                 shrinkWrap: true,
  //                 physics: const BouncingScrollPhysics(),
  //               ),
  //               children: List.generate(
  //                   shortProvider.categorydataList?.length ?? 0, (index) {
  //                 return InkWell(
  //                   autofocus: false,
  //                   splashColor: transparent,
  //                   highlightColor: transparent,
  //                   focusColor: transparent,
  //                   hoverColor: transparent,
  //                   onTap: () async {
  //                     shortProvider.clearShortList();
  //                     Navigator.pop(context);
  //                     await shortProvider.selectCategory(
  //                         index,
  //                         shortProvider.categorydataList?[index].id
  //                                 .toString() ??
  //                             "");
  //                     await shortProvider.getShortList(
  //                         false,
  //                         shortProvider.categorydataList?[index].id
  //                                 .toString() ??
  //                             "",
  //                         1);
  //                     // Navigator.push(
  //                     //   context,
  //                     //   MaterialPageRoute(
  //                     //     builder: (context) {
  //                     //       return GetShortbyCategory(
  //                     //         categoryId: shortProvider
  //                     //                 .categorydataList?[index].id
  //                     //                 .toString() ??
  //                     //             "",
  //                     //         categoryName: shortProvider
  //                     //                 .categorydataList?[index].name
  //                     //                 .toString()
  //                     //                 .toUpperCase() ??
  //                     //             "",
  //                     //       );
  //                     //     },
  //                     //   ),
  //                     // );
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.all(10),
  //                     alignment: Alignment.center,
  //                     decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(0),
  //                         border: Border.all(
  //                             color: index == shortProvider.catindex
  //                                 ? white
  //                                 : colorAccent,
  //                             width: 1)),
  //                     child: MyText(
  //                       // color: index == feedProvider.catindex ? black : white,
  //                       color: index == shortProvider.catindex
  //                           ? white
  //                           : colorAccent,
  //                       text: shortProvider.categorydataList?[index].name
  //                               .toString()
  //                               .toUpperCase() ??
  //                           "",
  //                       fontwaight: FontWeight.w700,
  //                       fontsizeNormal: Dimens.textTitle,
  //                       maxline: 1,
  //                       multilanguage: false,
  //                       overflow: TextOverflow.ellipsis,
  //                       textalign: TextAlign.center,
  //                       fontstyle: FontStyle.italic,
  //                     ),
  //                   ),
  //                 );
  //               })));
  //     } else {
  //       return const SizedBox.shrink();
  //     }
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }

  Widget categoryShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 3,
        maxItemsPerRow: 3,
        horizontalGridSpacing: 15,
        verticalGridSpacing: 15,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
        ),
        children: List.generate(shortProvider.categorydataList?.length ?? 0, (
          index,
        ) {
          return const CustomWidget.roundrectborder(height: 40, width: 90);
        }),
      ),
    );
  }

  Widget tabName() {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.50,
        height: 50,
        child: TabBar(
          dividerColor: transparent,
          indicatorColor: transparent,
          controller: _tabController,
          tabs: [
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyImage(
                    width: 25,
                    height: 25,
                    imagePath: "ic_recordvideo.png",
                    color: shortProvider.tabType == 0 ? colorAccent : white,
                  ),
                  MyText(
                    color: shortProvider.tabType == 0 ? colorAccent : white,
                    text: "shorts",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: 12,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyImage(
                    width: 25,
                    height: 25,
                    imagePath: "ic_live.png",
                    color: shortProvider.tabType == 1 ? colorAccent : white,
                  ),
                  MyText(
                    color: shortProvider.tabType == 1 ? colorAccent : white,
                    text: "live",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: 12,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
