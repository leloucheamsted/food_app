import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/feeddetail.dart';
import 'package:slike/pages/inbox.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/search.dart';
import 'package:slike/pages/setting.dart';
import 'package:slike/provider/feedprovider.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/socketmanager.dart';
import 'package:slike/widget/musictitle.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../model/post_details_model.dart';

class NewFeed extends StatefulWidget {
  const NewFeed({super.key});

  @override
  State<NewFeed> createState() => NewFeedState();
}

class NewFeedState extends State<NewFeed> {
  late FeedProvider feedProvider;
  late ScrollController _scrollController;
  late ScrollController _commentScrollController;
  late ScrollController _replayCommentScrollController;
  late ScrollController _reportScrollController;
  late ScrollController _categoryScrollController;
  final TextEditingController commentController = TextEditingController();
  String tempImg = "";
  io.Socket? socket;

  @override
  void initState() {
    feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _scrollController = ScrollController();
    _commentScrollController = ScrollController();
    _replayCommentScrollController = ScrollController();
    _reportScrollController = ScrollController();
    _categoryScrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _commentScrollController.addListener(_commentScrollListener);
    _replayCommentScrollController.addListener(_replayCommentScrollListener);
    _reportScrollController.addListener(_reportScrollListener);
    _categoryScrollController.addListener(_categoryScrollListener);
    // socketIO();
    super.initState();
    if (kIsWeb) _fetchAllFeed("0", 0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (feedProvider.currentPage ?? 0) < (feedProvider.totalPage ?? 0)) {
      await feedProvider.setLoadMore(true);
      _fetchAllFeed(feedProvider.categoryId, feedProvider.currentPage ?? 0);
    }
  }

  _commentScrollListener() async {
    if (!_commentScrollController.hasClients) return;
    if (_commentScrollController.offset >=
            _commentScrollController.position.maxScrollExtent &&
        !_commentScrollController.position.outOfRange &&
        (feedProvider.commentcurrentPage ?? 0) <
            (feedProvider.commenttotalPage ?? 0)) {
      await feedProvider.setCommentLoadMore(true);
      _fetchAllComment(
        feedProvider.postId,
        feedProvider.commentcurrentPage ?? 0,
      );
    }
  }

  _replayCommentScrollListener() async {
    if (!_replayCommentScrollController.hasClients) return;
    if (_replayCommentScrollController.offset >=
            _replayCommentScrollController.position.maxScrollExtent &&
        !_replayCommentScrollController.position.outOfRange &&
        (feedProvider.replayCommentcurrentPage ?? 0) <
            (feedProvider.replayCommenttotalPage ?? 0)) {
      await feedProvider.setReplayCommentLoadMore(true);
      _fetchAllReplayComment(
        feedProvider.commentId,
        feedProvider.replayCommentcurrentPage ?? 0,
      );
    }
  }

  _reportScrollListener() async {
    if (!_reportScrollController.hasClients) return;
    if (_reportScrollController.offset >=
            _reportScrollController.position.maxScrollExtent &&
        !_reportScrollController.position.outOfRange &&
        (feedProvider.reportcurrentPage ?? 0) <
            (feedProvider.replayCommenttotalPage ?? 0)) {
      await feedProvider.setReportReasonLoadMore(true);
      _fetchAllReportReason(feedProvider.reportcurrentPage ?? 0);
    }
  }

  _categoryScrollListener() async {
    if (!_categoryScrollController.hasClients) return;
    if (_categoryScrollController.offset >=
            _categoryScrollController.position.maxScrollExtent &&
        !_categoryScrollController.position.outOfRange &&
        (feedProvider.categorycurrentPage ?? 0) <
            (feedProvider.categorytotalPage ?? 0)) {
      await feedProvider.setCategoryLoadMore(true);
      _fetchCategory(feedProvider.categorycurrentPage ?? 0);
    }
  }

  Future<void> _fetchAllFeed(categoryId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getAllFeed(categoryId, (nextPage ?? 0) + 1);
    await feedProvider.setLoadMore(false);
  }

  Future<void> _fetchAllComment(postId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getPostComment(postId, (nextPage ?? 0) + 1);
    await feedProvider.setCommentLoadMore(false);
  }

  Future<void> _fetchAllReplayComment(commentId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getPostReplayComment(commentId, (nextPage ?? 0) + 1);
    await feedProvider.setReplayCommentLoadMore(false);
  }

  Future<void> _fetchAllReportReason(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getReportReason("2", (nextPage ?? 0) + 1);
    await feedProvider.setReportReasonLoadMore(false);
  }

  Future<void> _fetchCategory(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedProvider.getCategory((nextPage ?? 0) + 1);
    await feedProvider.setCategoryLoadMore(false);
  }

  void socketIO() {
    SocketManager socketManager = SocketManager();
    socket = socketManager.socket;
    debugPrint('connect Feed');
    socketManager.removeListner();
    socket?.on('NotificationCount', (data) async {
      debugPrint('notificationCount==>: $data');
      if (data != null) {
        await feedProvider.totalNotificationCount(data);
      }
    });
  }

  @override
  void dispose() {
    feedProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MyImage(width: 45, height: 45, imagePath: "appicon.png"),
                  MusicTitle(
                    color: white,
                    text: "appname",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textBig,
                    fontsizeWeb: Dimens.textBig,
                    multilanguage: true,
                    maxline: 1,
                    fontwaight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      AdHelper.showFullscreenAd(
                        context,
                        Constant.rewardAdType,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Search();
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(
                      Icons.search,
                      color: colorAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      AdHelper.showFullscreenAd(
                        context,
                        Constant.interstialAdType,
                        () {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Inbox();
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 35,
                          height: 35,
                          child: MyImage(
                            width: 25,
                            height: 25,
                            color: colorAccent,
                            imagePath: "notification.png",
                          ),
                        ),
                        // Consumer<FeedProvider>(
                        //     builder: (context, feedprovider, child) {
                        //   if (feedProvider.notificationCount == null) {
                        //     return const SizedBox.shrink();
                        //   } else {
                        //     return Positioned.fill(
                        //       child: Align(
                        //         alignment: Alignment.topRight,
                        //         child: Container(
                        //           height: 20,
                        //           width: 20,
                        //           alignment: Alignment.center,
                        //           decoration: const BoxDecoration(
                        //             shape: BoxShape.circle,
                        //             color: colorAccent,
                        //           ),
                        //           child: MyText(
                        //               color: black,
                        //               text: Utils.kmbGenerator(
                        //                 feedProvider.notificationCount,
                        //               ),
                        //               textalign: TextAlign.left,
                        //               fontsizeNormal: 8,
                        //               inter: false,
                        //               maxline: 2,
                        //               multilanguage: false,
                        //               fontwaight: FontWeight.w800,
                        //               overflow: TextOverflow.ellipsis,
                        //               fontstyle: FontStyle.normal),
                        //         ),
                        //       ),
                        //     );
                        // }
                        // }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      AdHelper.showFullscreenAd(
                        context,
                        Constant.interstialAdType,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Setting();
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(
                      Icons.settings,
                      color: colorAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      categoryBottomSheet(context);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
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
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedprovider, child) {
          return RefreshIndicator(
            backgroundColor: colorPrimaryDark,
            color: colorAccent,
            displacement: 70,
            edgeOffset: 1.0,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            strokeWidth: 3,
            onRefresh: () async {
              await feedProvider.clearProvider();
              _fetchAllFeed("", 0);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [buildFeed()],
              ),
            ),
          );
        },
      ),
    );
  }

  /* ====================== Category Horizontal ====================== */

  // Widget buildCategory() {
  //   if (feedProvider.categoryloading && !feedProvider.categoryloadMore) {
  //     return categoryShimmer();
  //   } else {
  //     return SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       // controller: _categoryScrollController,
  //       child: Row(
  //         children: [
  //           buildCategoryItem(),
  //           if (feedProvider.categoryloadMore)
  //             const SizedBox(
  //                 height: 20,
  //                 width: 20,
  //                 child: CircularProgressIndicator(
  //                   color: colorAccent,
  //                   strokeWidth: 1,
  //                 ))
  //           else
  //             const SizedBox.shrink(),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // Widget buildCategoryItem() {
  //   if (feedProvider.categorymodel.status == 200 &&
  //       feedProvider.categorydataList != null) {
  //     if ((feedProvider.categorydataList?.length ?? 0) > 0) {
  //       return SizedBox(
  //         height: 40,
  //         child: ListView.separated(
  //           itemCount: feedProvider.categorydataList?.length ?? 0,
  //           separatorBuilder: (context, index) => const SizedBox(width: 10),
  //           scrollDirection: Axis.horizontal,
  //           physics: const NeverScrollableScrollPhysics(),
  //           shrinkWrap: true,
  //           itemBuilder: (context, index) {
  //             return InkWell(
  //               autofocus: false,
  //               splashColor: transparent,
  //               highlightColor: transparent,
  //               focusColor: transparent,
  //               hoverColor: transparent,
  //               onTap: () async {
  //                 await feedProvider.selectCategory(
  //                     index,
  //                     feedProvider.categorydataList?[index].id.toString() ??
  //                         "");
  //                 feedProvider.clearAllPost();
  //                 if (index == 0) {
  //                   _fetchAllFeed("", 0);
  //                 } else {
  //                   _fetchAllFeed(
  //                       feedProvider.categorydataList?[index].id.toString() ??
  //                           "",
  //                       0);
  //                 }
  //               },
  //               child: Container(
  //                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
  //                 alignment: Alignment.center,
  //                 decoration: BoxDecoration(
  //                     color: index == feedProvider.catindex
  //                         ? colorAccent
  //                         : colorPrimary,
  //                     borderRadius: BorderRadius.circular(5),
  //                     border: Border.all(color: colorAccent, width: 1)),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     MyText(
  //                       color: index == feedProvider.catindex ? black : white,
  //                       text: feedProvider.categorydataList?[index].name ?? "",
  //                       fontwaight: FontWeight.w500,
  //                       fontsizeNormal: Dimens.textSmall,
  //                       maxline: 1,
  //                       multilanguage: false,
  //                       overflow: TextOverflow.ellipsis,
  //                       textalign: TextAlign.center,
  //                       fontstyle: FontStyle.normal,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     } else {
  //       return const SizedBox.shrink();
  //     }
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }

  // Widget categoryShimmer() {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width,
  //     height: 65,
  //     child: ListView.builder(
  //       itemCount: 5,
  //       shrinkWrap: true,
  //       padding: const EdgeInsets.fromLTRB(5, 10, 5, 15),
  //       scrollDirection: Axis.horizontal,
  //       physics: const BouncingScrollPhysics(),
  //       itemBuilder: (context, index) {
  //         return const CustomWidget.roundrectborder(height: 8, width: 90);
  //       },
  //     ),
  //   );
  // }

  /* ====================== Category ====================== */

  /* ====================== Get All Feed ====================== */

  Widget buildFeed() {
    if (feedProvider.loading && !feedProvider.loadMore) {
      return shimmer();
    } else {
      if (feedProvider.feedPostList != null &&
          (feedProvider.feedPostList?.length ?? 0) > 0) {
        return Column(
          children: [
            buildFeedItem(),
            if (feedProvider.loadMore)
              SizedBox(height: 50, child: Utils.pageLoader(context))
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget buildFeedItem() {
    return MasonryGridView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedProvider.feedPostList?.length ?? 0,
      itemBuilder: (context, index) {
        return InkWell(
          focusColor: transparent,
          splashColor: transparent,
          highlightColor: transparent,
          hoverColor: transparent,
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) => FeedDetail(
                      userImage:
                          feedProvider.feedPostList?[index].profileImg
                              .toString() ??
                          "",
                      userName:
                          feedProvider.feedPostList?[index].fullName
                              .toString() ??
                          "",
                      postId:
                          feedProvider.feedPostList?[index].id.toString() ?? "",
                      channelName:
                          feedProvider.feedPostList?[index].channelName
                              .toString() ??
                          "",
                    ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: Container(
            height: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: Stack(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: MyNetworkImage(
                        width: 180,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            feedProvider
                                        .feedPostList?[index]
                                        .postContent?[0]
                                        .contentType ==
                                    1
                                ? (feedProvider
                                        .feedPostList?[index]
                                        .postContent?[0]
                                        .contentUrl
                                        .toString() ??
                                    "")
                                : (feedProvider
                                        .feedPostList?[index]
                                        .postContent?[0]
                                        .thumbnailImage
                                        .toString() ??
                                    ""),
                      ),
                    ),
                    feedProvider
                                .feedPostList?[index]
                                .postContent?[0]
                                .contentType ==
                            1
                        ? const SizedBox.shrink()
                        : const Positioned.fill(
                          child: Align(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: white,
                              size: 35,
                            ),
                          ),
                        ),
                  ],
                ),
                Positioned.fill(
                  bottom: 15,
                  top: 15,
                  left: 15,
                  right: 15,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: MyText(
                      color: white,
                      text:
                          feedProvider.feedPostList?[index].title
                              .toString()
                              .toUpperCase() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textBig,
                      inter: false,
                      maxline: 2,
                      multilanguage: false,
                      fontwaight: FontWeight.w900,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget shimmer() {
    return MasonryGridView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          height: 300,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: CustomWidget.roundcorner(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        );
      },
    );
  }

  Widget iconWithCount({
    required onTap,
    required double width,
    required double height,
    required String iconPath,
    required bool showText,
    required Color iconColor,
    count,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      focusColor: transparent,
      splashColor: transparent,
      highlightColor: transparent,
      hoverColor: transparent,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child:
            showText == true
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyImage(
                      width: width,
                      height: height,
                      imagePath: iconPath,
                      color: iconColor,
                    ),
                    const SizedBox(width: 8),
                    MyText(
                      color: gray,
                      multilanguage: false,
                      text: count.toString(),
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      inter: true,
                      maxline: 10,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                )
                : MyImage(
                  width: width,
                  height: height,
                  imagePath: iconPath,
                  color: iconColor,
                ),
      ),
    );
  }

  /* ====================== Get All Feed ====================== */

  /* ====================== Feed Comment ====================== */

  showComment({
    required BuildContext context,
    postId,
    postIndex,
    required int postIsComment,
  }) async {
    _fetchAllComment(postId, 0);
    await showModalBottomSheet(
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
      context: context,
      backgroundColor: transparent,
      builder:
          (context) => Consumer<FeedProvider>(
            builder: (context, feedprovider, child) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: colorPrimaryDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        centerTitle: true,
                        backgroundColor: transparent,
                        automaticallyImplyLeading: false,
                        title: MyText(
                          color: white,
                          text: "comment",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          inter: false,
                          maxline: 1,
                          multilanguage: true,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                commentController.clear();
                                feedProvider.clearComment();
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                size: 25,
                                color: white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Utils.buildGradLine(),
                      Expanded(
                        child: buildComment(postId, postIndex, postIsComment),
                      ),
                      Utils.buildGradLine(),
                      addCommentTextField(
                        postIndex,
                        postId,
                        '0',
                        true,
                        postIsComment,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget buildComment(postId, postIndex, postIsComment) {
    if (feedProvider.commentloading && !feedProvider.commentloadMore) {
      return commentShimmer();
    } else {
      if (feedProvider.commentList != null &&
          (feedProvider.commentList?.length ?? 0) > 0) {
        return RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await feedProvider.clearComment();
            _fetchAllComment(postId, 0);
          },
          child: SingleChildScrollView(
            controller: _commentScrollController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                buildCommentItem(postId, postIndex, postIsComment),
                if (feedProvider.commentloadMore)
                  SizedBox(height: 50, child: Utils.pageLoader(context))
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget buildCommentItem(postId, postIndex, postIsComment) {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      horizontalGridSpacing: 15,
      verticalGridSpacing: 15,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(feedProvider.commentList?.length ?? 0, (index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: colorPrimaryDark,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 1, color: gray),
                  color: colorPrimary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: MyNetworkImage(
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                    imagePath:
                        feedProvider.commentList?[index].image.toString() ?? "",
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    feedProvider.commentList?[index].fullName == ""
                        ? MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              feedProvider.commentList?[index].channelName
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                        : MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              feedProvider.commentList?[index].fullName
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                    MyText(
                      color: gray,
                      multilanguage: false,
                      text:
                          feedProvider.commentList?[index].comment.toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textSmall,
                      inter: false,
                      maxline: 5,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  feedProvider.storeCommentId(
                    postId,
                    feedProvider.commentList?[index].id.toString() ?? "",
                  );

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  commentController.clear();

                  showReplayComment(
                    context: context,
                    postId: postId,
                    postIndex: postIndex,
                    commentId:
                        feedProvider.commentList?[index].id.toString() ?? "",
                    postIsComment: postIsComment,
                  );
                },
                child: MyText(
                  color: colorAccent,
                  multilanguage: true,
                  text: "replay",
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textSmall,
                  inter: false,
                  maxline: 5,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),

              // /* Edit Comment */
              // feedProvider.commentList?[index].userId.toString() ==
              //         Constant.userID
              //     ? Padding(
              //         padding: const EdgeInsets.all(15.0),
              //         child: InkWell(
              //           onTap: () async {
              //             await feedProvider.isEditPerticulerComment(
              //                 true,
              //                 feedProvider.commentList?[index].id
              //                         .toString() ??
              //                     "");
              //             commentController.text = feedProvider
              //                     .commentList?[index].comment
              //                     .toString() ??
              //                 "";
              //           },
              //           child: const Icon(
              //             Icons.edit,
              //             color: white,
              //             size: 22,
              //           ),
              //         ),
              //       )
              //     : const SizedBox.shrink(),
              const SizedBox(width: 15),

              /* Delete Comment */
              feedProvider.commentList?[index].userId.toString() ==
                      Constant.userID
                  ? InkWell(
                    onTap: () async {
                      await feedProvider.postDeleteComment(
                        postIndex,
                        feedProvider.commentList?[index].id.toString() ?? "",
                      );
                      feedProvider.clearComment();
                      _fetchAllComment(postId, 0);
                    },
                    child: const Icon(Icons.delete, color: white, size: 22),
                  )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      }),
    );
  }

  /* ====================== Feed Comment End ====================== */

  /* ====================== Feed Replay Comment Start ====================== */

  showReplayComment({
    required BuildContext context,
    postId,
    commentId,
    postIndex,
    required int postIsComment,
  }) async {
    _fetchAllReplayComment(commentId, 0);
    await showModalBottomSheet(
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
      context: context,
      backgroundColor: transparent,
      builder:
          (context) => Consumer<FeedProvider>(
            builder: (context, feedprovider, child) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: colorPrimaryDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        centerTitle: true,
                        backgroundColor: transparent,
                        automaticallyImplyLeading: false,
                        title: MyText(
                          color: white,
                          text: "replaycomment",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          inter: false,
                          maxline: 1,
                          multilanguage: true,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                commentController.clear();
                                feedProvider.clearReplayComment();
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                size: 25,
                                color: white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Utils.buildGradLine(),
                      Expanded(
                        child: buildReplayComment(postId, commentId, postIndex),
                      ),
                      Utils.buildGradLine(),
                      addCommentTextField(
                        postIndex,
                        postId,
                        commentId,
                        false,
                        postIsComment,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget buildReplayComment(postId, commentId, postIndex) {
    if (feedProvider.replayCommentloading &&
        !feedProvider.replayCommentloadMore) {
      return commentShimmer();
    } else {
      if (feedProvider.getPostReplayCommentModel.result != null &&
          feedProvider.replayCommentList != null &&
          (feedProvider.replayCommentList?.length ?? 0) > 0) {
        return RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await feedProvider.clearReplayComment();
            _fetchAllReplayComment(commentId, 0);
          },
          child: SingleChildScrollView(
            controller: _replayCommentScrollController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                buildReplayCommentItem(postId, commentId, postIndex),
                if (feedProvider.replayCommentloadMore)
                  SizedBox(height: 50, child: Utils.pageLoader(context))
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget buildReplayCommentItem(postId, commentId, postIndex) {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      horizontalGridSpacing: 15,
      verticalGridSpacing: 15,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(feedProvider.replayCommentList?.length ?? 0, (
        index,
      ) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: colorPrimaryDark,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 1, color: gray),
                  color: colorPrimary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: MyNetworkImage(
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                    imagePath:
                        feedProvider.replayCommentList?[index].image
                            .toString() ??
                        "",
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    feedProvider.replayCommentList?[index].fullName == ""
                        ? MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              feedProvider.replayCommentList?[index].channelName
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                        : MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              feedProvider.replayCommentList?[index].fullName
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                    MyText(
                      color: gray,
                      multilanguage: false,
                      text:
                          feedProvider.replayCommentList?[index].comment
                              .toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textSmall,
                      inter: false,
                      maxline: 5,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
              // InkWell(
              //   onTap: () {
              //     if (Navigator.canPop(context)) {
              //       Navigator.pop(context);
              //     }

              //     commentController.clear();
              //     feedProvider.clearReplayComment();

              //     showReplayComment(
              //       context: context,
              //       postId: postId,
              //       commentId:
              //           feedProvider.commentList?[index].id.toString() ?? "",
              //     );
              //   },
              //   child: MyText(
              //       color: colorAccent,
              //       multilanguage: true,
              //       text: "replay",
              //       textalign: TextAlign.left,
              //       fontsizeNormal: Dimens.textSmall,
              //       inter: false,
              //       maxline: 5,
              //       fontwaight: FontWeight.w400,
              //       overflow: TextOverflow.ellipsis,
              //       fontstyle: FontStyle.normal),
              // ),

              /* Edit Comment */
              // feedProvider.replayCommentList?[index].userId.toString() ==
              //         Constant.userID
              //     ? Padding(
              //         padding: const EdgeInsets.all(15.0),
              //         child: InkWell(
              //           onTap: () {},
              //           child: const Icon(
              //             Icons.edit,
              //             color: white,
              //             size: 22,
              //           ),
              //         ),
              //       )
              //     : const SizedBox.shrink(),

              /* Delete Comment */
              feedProvider.replayCommentList?[index].userId.toString() ==
                      Constant.userID
                  ? InkWell(
                    onTap: () async {
                      await feedProvider.postDeleteComment(
                        postIndex,
                        feedProvider.replayCommentList?[index].id.toString() ??
                            "",
                      );
                      feedProvider.clearReplayComment();
                      _fetchAllReplayComment(
                        feedProvider.replayCommentList?[index].id.toString() ??
                            "",
                        0,
                      );
                    },
                    child: const Icon(Icons.delete, color: white, size: 22),
                  )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      }),
    );
  }

  /* ====================== Feed Replay Comment End ====================== */

  Widget commentShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      horizontalGridSpacing: 10,
      verticalGridSpacing: 10,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(5, (index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: colorPrimaryDark,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Row(
            children: [
              const CustomWidget.circular(height: 35, width: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      height: 15,
                      width: MediaQuery.of(context).size.width,
                    ),
                    CustomWidget.roundrectborder(
                      height: 15,
                      width: MediaQuery.of(context).size.width * 0.50,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /* ====================== Add Comment Widget ====================== */

  Widget addCommentTextField(
    postIndex,
    postId,
    commentId,
    isComment,
    int postIsComment,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
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
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
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
          const SizedBox(width: 5),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () async {
              sendCommentApi(
                postIndex,
                postId,
                commentId,
                isComment,
                postIsComment,
              );
            },
            child:
                feedProvider.addCommentLoading
                    ? const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: colorAccent,
                        strokeWidth: 1.5,
                      ),
                    )
                    : const Icon(Icons.send_outlined, color: white, size: 25),
          ),
        ],
      ),
    );
  }

  sendCommentApi(
    postIndex,
    postId,
    commentId,
    isComment,
    int postIsComment,
  ) async {
    if (Constant.userID == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Login();
          },
        ),
      );
    } else if (postIsComment == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      commentController.clear();
      feedProvider.clearComment();
      feedProvider.clearReplayComment();
      Utils.showSnackbar(context, "youcannotcommentthiscontent", true);
    } else {
      if (commentController.text.isEmpty) {
        Utils.showSnackbar(context, "pleaseenteryourcomment", true);
      } else {
        /* isComment == Ditect Comment And ReplayComment */

        /* Note: */
        /* AddComment commentId Always 0 Pass */
        /* Relplay Perticuler Comment Then Pass Comment Id */
        await feedProvider.addPostComment(
          postIndex,
          postId,
          commentController.text,
          commentId,
        );

        if (feedProvider.addPostCommentModel.status == 200) {
          if (!context.mounted) return;
          commentController.clear();

          if (isComment) {
            feedProvider.clearComment();
            _fetchAllComment(postId, 0);
            if ((feedProvider.commentList?.length ?? 0) > 6) {
              _commentScrollController.animateTo(
                _commentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );

              _commentScrollController.animateTo(
                _commentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            }
          } else {
            feedProvider.clearReplayComment();
            _fetchAllReplayComment(commentId, 0);
            if ((feedProvider.replayCommentList?.length ?? 0) > 6) {
              _replayCommentScrollController.animateTo(
                _replayCommentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );

              _replayCommentScrollController.animateTo(
                _replayCommentScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            }
          }
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          Utils.showSnackbar(
            context,
            feedProvider.addPostCommentModel.message ?? "",
            false,
          );
        }
      }
    }
  }

  /* ====================== Add Comment Widget ====================== */

  /* ====================== Report Reason ====================== */

  showReportReason({required BuildContext context, postId}) async {
    _fetchAllReportReason(0);
    feedProvider.selectReportReason(
      0,
      feedProvider.reportReasonList?[0].id.toString() ?? "",
    );
    await showModalBottomSheet(
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
      context: context,
      backgroundColor: transparent,
      builder:
          (context) => Consumer<FeedProvider>(
            builder: (context, feedprovider, child) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: colorPrimaryDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        centerTitle: true,
                        backgroundColor: transparent,
                        automaticallyImplyLeading: false,
                        title: MyText(
                          color: white,
                          text: "report",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          inter: false,
                          maxline: 1,
                          multilanguage: true,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                feedProvider.clearReportReason();
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                size: 25,
                                color: white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Utils.buildGradLine(),
                      Expanded(child: buildReportReason()),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                              feedProvider.clearReportReason();
                            },
                            child: Container(
                              width: 100,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(width: 1, color: white),
                              ),
                              child: MyText(
                                color: white,
                                multilanguage: true,
                                text: "cancel",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textTitle,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
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
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Login();
                                    },
                                  ),
                                );
                              } else {
                                await feedProvider.addPostReason(
                                  postId,
                                  feedProvider.reason,
                                );

                                if (feedProvider.addContentReportModel.status ==
                                    200) {
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  Utils.showSnackbar(
                                    context,
                                    feedProvider
                                            .addContentReportModel
                                            .message ??
                                        "",
                                    false,
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  Utils.showSnackbar(
                                    context,
                                    feedProvider
                                            .addContentReportModel
                                            .message ??
                                        "",
                                    false,
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: 100,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: colorAccent,
                              ),
                              child: MyText(
                                color: black,
                                multilanguage: true,
                                text: "report",
                                textalign: TextAlign.left,
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget buildReportReason() {
    if (feedProvider.getcontentreportloading &&
        !feedProvider.getcontentreportloadmore) {
      return commentShimmer();
    } else {
      if (feedProvider.getRepostReasonModel.result != null &&
          feedProvider.reportReasonList != null &&
          (feedProvider.reportReasonList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _reportScrollController,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              buildReportReasonItem(),
              if (feedProvider.getcontentreportloadmore)
                SizedBox(height: 50, child: Utils.pageLoader(context))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget buildReportReasonItem() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      horizontalGridSpacing: 25,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(feedProvider.reportReasonList?.length ?? 0, (
        index,
      ) {
        return InkWell(
          onTap: () async {
            feedProvider.selectReportReason(
              index,
              feedProvider.reportReasonList?[index].id.toString() ?? "",
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: colorPrimaryDark,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1,
                      color:
                          feedProvider.reportPosition == index
                              ? colorAccent
                              : gray,
                    ),
                  ),
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          feedProvider.reportPosition == index
                              ? colorAccent
                              : transparent,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    multilanguage: false,
                    text:
                        feedProvider.reportReasonList?[index].reason
                            .toString() ??
                        "",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textTitle,
                    inter: true,
                    maxline: 5,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /* ====================== Report Reason ====================== */

  void categoryBottomSheet(BuildContext context) {
    _fetchCategory(0);
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
    return Consumer<FeedProvider>(
      builder: (context, feedprovider, child) {
        if (feedProvider.categoryloading && !feedProvider.categoryloadMore) {
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
                    feedProvider.selectCategory(-1, 0);
                    await feedProvider.clearAllPost();
                    _fetchAllFeed("", 0);
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.5,
                        color:
                            feedProvider.selectedIndex == -1
                                ? white
                                : colorAccent,
                      ),
                    ),
                    child: MyText(
                      color:
                          feedProvider.selectedIndex == -1
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
                (feedProvider.categorydataList != null &&
                        (feedProvider.categorydataList?.length ?? 0) > 0)
                    ? Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children:
                          feedProvider.categorydataList!.map((choice) {
                            int index =
                                feedProvider.categorydataList?.indexOf(
                                  choice,
                                ) ??
                                0;
                            return ChoiceChip(
                              showCheckmark: false,
                              surfaceTintColor: colorPrimary,
                              disabledColor: colorPrimary,
                              label: MyText(
                                color:
                                    feedProvider.selectedIndex == index
                                        ? white
                                        : colorAccent,
                                text:
                                    feedProvider.categorydataList?[index].name
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
                                    feedProvider.selectedIndex == index
                                        ? white
                                        : colorAccent,
                                width: 1,
                              ),
                              selected: feedProvider.selectedIndex == index,
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
                                feedProvider.selectCategory(
                                  selected ? index : -1,
                                  feedProvider.categorydataList?[index].id ?? 0,
                                );
                                Navigator.pop(context);
                                feedProvider.clearAllPost();
                                _fetchAllFeed(
                                  feedProvider.categorydataList?[index].id
                                          .toString() ??
                                      "",
                                  0,
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
        children: List.generate(feedProvider.categorydataList?.length ?? 0, (
          index,
        ) {
          return const CustomWidget.roundrectborder(height: 40, width: 90);
        }),
      ),
    );
  }
}
