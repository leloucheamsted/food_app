import 'dart:io';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/feedplayer.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/feeddetailprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../model/post_details_model.dart';
import '../../provider/feed_detail_with_scrolling_provider.dart';

class FeedDetailWithScrolling extends StatefulWidget {
  final List<PostDetailsModel> data;

  const FeedDetailWithScrolling({super.key, required this.data});

  @override
  State<FeedDetailWithScrolling> createState() =>
      _FeedDetailWithScrollingState();
}

class _FeedDetailWithScrollingState extends State<FeedDetailWithScrolling> {
  late FeedDetailWithScrollingProvider feedDetailWithScrollingProvider;
  final PageController _mainPageController = PageController();
  late PageController _pageController;
  final PageController _imageController = PageController();
  late ScrollController _replayCommentScrollController, _reportScrollController;
  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();
  final ScrollController _postScrollController = ScrollController();
  String mainPostId = "";

  @override
  void initState() {
    super.initState();
    mainPostId = widget.data.first.postId;
    feedDetailWithScrollingProvider =
        Provider.of<FeedDetailWithScrollingProvider>(context, listen: false);
    _replayCommentScrollController =
        ScrollController()..addListener(() {
          _scrollListener(
            _replayCommentScrollController,
            feedDetailWithScrollingProvider.replayCommentcurrentPage ?? 0,
            feedDetailWithScrollingProvider.replayCommenttotalPage ?? 0,
            _fetchPostReplayComment,
          );
        });
    _reportScrollController =
        ScrollController()..addListener(() {
          _scrollListener(
            _reportScrollController,
            feedDetailWithScrollingProvider.reportcurrentPage ?? 0,
            feedDetailWithScrollingProvider.reporttotalPage ?? 0,
            _fetchAllReportReason,
          );
        });
    _pageController =
        PageController()..addListener(() {
          _nextDataScrollListener(
            _pageController,
            feedDetailWithScrollingProvider.imageCurrentPage ?? 0,
            feedDetailWithScrollingProvider.feedDetailModel.result?.length ?? 0,
          );
        });
    getApi(mainPostId);
    _mainPageController.addListener(() {
      setState(() {}); // Trigger rebuild when the page changes
    });
  }

  // Consolidating all scrolling listeners
  void _scrollListener(
    ScrollController scrollController,
    int currentPage,
    int totalPage,
    Function fetchData,
  ) {
    if (!scrollController.hasClients) return;
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        currentPage < totalPage) {
      fetchData(currentPage + 1);
    }
  }

  // Consolidating all scrolling listeners
  void _nextDataScrollListener(
    ScrollController scrollController,
    int imageCurrentPage,
    int totalPage,
  ) {
    if (!scrollController.hasClients) return;
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        imageCurrentPage < totalPage) {
      getApi(getNextIdByValue(mainPostId));
    }
  }

  Future<void> _moveToMainUserNextPage() async {
    await _mainPageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _moveToMainUserPreviousPage() async {
    await _mainPageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _moveToNextPage(index, totalPages) async {
    final int? currentPage = _pageController.page?.toInt();

    if (currentPage == totalPages - 1) {
      _moveToMainUserNextPage();
    } else {
      // Move to the next page
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _moveToPreviousPage() async {
    if (_pageController.page == 0) {
      _moveToMainUserPreviousPage();
    } else {
      // Move to the previous page
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String? getNextIdByValue(String postId) {
    int currentIndex = widget.data.indexWhere((item) => item.postId == postId);
    if (currentIndex != -1 && currentIndex < widget.data.length - 1) {
      return widget.data[currentIndex + 1].postId;
    }
    return null;
  }

  // Consolidated method to fetch API for comments, replies, and reports
  getApi(postId) async {
    if (postId != null) {
      await feedDetailWithScrollingProvider.getFeedDetail(postId);
      mainPostId = postId;
      setState(() {});
      feedDetailWithScrollingProvider.clearComment();
      _fetchPostComment(0, mainPostId);
    }
  }

  // Optimized API calls for different data fetches
  Future<void> _fetchPostComment(int nextPage, postId) async {
    await feedDetailWithScrollingProvider.getPostComment(postId, nextPage);
    feedDetailWithScrollingProvider.setCommentLoadMore(false);
  }

  Future<void> _fetchPostReplayComment(int commentId, int nextPage) async {
    await feedDetailWithScrollingProvider.getPostReplayComment(
      commentId,
      nextPage,
    );
    feedDetailWithScrollingProvider.setReplayCommentLoadMore(false);
  }

  Future<void> _fetchAllReportReason(int nextPage) async {
    await feedDetailWithScrollingProvider.getReportReason("2", nextPage);
    feedDetailWithScrollingProvider.setReportReasonLoadMore(false);
  }

  @override
  void dispose() {
    _replayCommentScrollController.dispose();
    _reportScrollController.dispose();
    _pageController.dispose();
    _imageController.dispose();
    _postScrollController.dispose();
    commentController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _mainPageController,
      itemCount: widget.data.length,
      onPageChanged: (parentIndex) {
        getApi(widget.data[parentIndex].postId);
      },
      itemBuilder: (context, parentIndex) {
        final data = widget.data[parentIndex];

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: colorPrimary,
          appBar: appBar(data),
          body: Consumer<FeedDetailWithScrollingProvider>(
            builder: (context, feeddetailprovider, child) {
              if (feeddetailprovider.loading) {
                return shimmer();
              } else {
                return PageView.builder(
                  controller: _pageController,
                  itemCount: feeddetailprovider.feedDetailModel.result?.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, pageIndex) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _postScrollController,
                            physics: const ScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Column(
                              children: [
                                feedDetail(
                                  title:
                                      feeddetailprovider
                                          .feedDetailModel
                                          .result?[pageIndex]
                                          .title,
                                  index: pageIndex,
                                  parentIndex: parentIndex,
                                ),
                                buildComment(
                                  feeddetailprovider
                                          .feedDetailModel
                                          .result?[pageIndex]
                                          .isComment ??
                                      0,
                                  pageIndex,
                                  data.postId,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom Navigation Bar with TextFormField
                        Container(
                          height: 80,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          color: transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  focusNode: commentFocusNode,
                                  controller: commentController,
                                  maxLines: 1,
                                  scrollPhysics:
                                      const AlwaysScrollableScrollPhysics(),
                                  textAlign: TextAlign.start,
                                  onChanged: (value) {
                                    feedDetailWithScrollingProvider
                                        .showHideSendIcon(value);
                                  },
                                  decoration: InputDecoration(
                                    suffixIcon:
                                        feedDetailWithScrollingProvider
                                                    .isSendShow ==
                                                false
                                            ? const SizedBox.shrink()
                                            : InkWell(
                                              onTap: () {
                                                sendCommentApi(
                                                  data.postId,
                                                  0,
                                                  true,
                                                  feedDetailWithScrollingProvider
                                                          .feedDetailModel
                                                          .result?[0]
                                                          .isComment ??
                                                      0,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.send,
                                                color: white,
                                              ),
                                            ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      borderSide: BorderSide(
                                        color: white,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      borderSide: BorderSide(
                                        color: white,
                                        width: 1,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors
                                            .transparent, // Replace with `transparent` color
                                    border: InputBorder.none,
                                    hintText: "Add Comments",
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
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
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  iconWithCount(
                                    width: 28,
                                    height: 28,
                                    showText: true,
                                    iconPath: "ic_muscle.png",
                                    iconColor:
                                        (feedDetailWithScrollingProvider
                                                        .feedDetailModel
                                                        .result?[0]
                                                        .ifood_app ??
                                                    0) ==
                                                1
                                            ? colorAccent
                                            : white,
                                    count: Utils.kmbGenerator(
                                      feedDetailWithScrollingProvider
                                              .feedDetailModel
                                              .result?[0]
                                              .totalLike ??
                                          0,
                                    ),
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
                                        await feedDetailWithScrollingProvider
                                            .like(
                                              feedDetailWithScrollingProvider
                                                      .feedDetailModel
                                                      .result?[0]
                                                      .id ??
                                                  0,
                                            );
                                      }
                                    },
                                  ),
                                  iconWithCount(
                                    width: 28,
                                    height: 28,
                                    iconColor: white,
                                    showText: false,
                                    iconPath: "ic_share.png",
                                    onTap: () async {
                                      Utils.shareApp(
                                        Platform.isIOS
                                            ? "Hey! I'm Showing ${feedDetailWithScrollingProvider.feedDetailModel.result?[0].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                            : "Hey! I'm Showing ${feedDetailWithScrollingProvider.feedDetailModel.result?[0].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                                      );
                                    },
                                  ),
                                  iconWithCount(
                                    width: 28,
                                    height: 28,
                                    showText: false,
                                    iconColor: white,
                                    iconPath: "ic_more.webp",
                                    onTap: () {
                                      showReportReason(
                                        context: context,
                                        postId:
                                            feedDetailWithScrollingProvider
                                                .feedDetailModel
                                                .result?[0]
                                                .id
                                                .toString() ??
                                            "",
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  AppBar appBar(PostDetailsModel data) {
    return AppBar(
      centerTitle: false,
      backgroundColor: transparent,
      titleSpacing: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: transparent,
      leading: InkWell(
        focusColor: transparent,
        highlightColor: transparent,
        hoverColor: transparent,
        splashColor: transparent,
        onTap: () {
          Navigator.of(context).pop(false);
        },
        child: Align(
          alignment: Alignment.center,
          child: MyImage(width: 30, height: 30, imagePath: "ic_roundback.png"),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Profile(
                          isBottomBar: false,
                          isFeedDetail: true,
                          toUserId: data.userId.toString(),
                          toChannelId: data.channelId.toString(),
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        width: 35,
                        height: 35,
                        imagePath: data.userImage,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: MyText(
                        color: white,
                        text:
                            data.userName == ""
                                ? data.channelName
                                : data.userName,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        multilanguage: false,
                        inter: true,
                        maxline: 1,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Consumer<FeedDetailProvider>(
              builder: (context, feeddetailprovider, child) {
                if (feeddetailprovider.loading) {
                  return const SizedBox.shrink();
                } else {
                  return Constant.userID ==
                          feedDetailWithScrollingProvider
                              .feedDetailModel
                              .result?[0]
                              .userId
                              .toString()
                      ? const SizedBox.shrink()
                      : InkWell(
                        hoverColor: transparent,
                        highlightColor: transparent,
                        splashColor: transparent,
                        focusColor: transparent,
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
                            await feedDetailWithScrollingProvider
                                .addRemoveSubscriber(
                                  feedDetailWithScrollingProvider
                                          .feedDetailModel
                                          .result?[0]
                                          .userId
                                          .toString() ??
                                      "",
                                  "1",
                                );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              width: 0.9,
                              color:
                                  feedDetailWithScrollingProvider
                                              .feedDetailModel
                                              .result?[0]
                                              .isSubscriber ==
                                          0
                                      ? gray
                                      : gray,
                            ),
                            color:
                                feedDetailWithScrollingProvider
                                            .feedDetailModel
                                            .result?[0]
                                            .isSubscriber ==
                                        0
                                    ? colorPrimary
                                    : colorAccent,
                          ),
                          child: Row(
                            children: [
                              MyImage(
                                width: 16,
                                height: 16,
                                color:
                                    feedDetailWithScrollingProvider
                                                .feedDetailModel
                                                .result?[0]
                                                .isSubscriber ==
                                            0
                                        ? white
                                        : black,
                                imagePath:
                                    feedDetailWithScrollingProvider
                                                .feedDetailModel
                                                .result?[0]
                                                .isSubscriber ==
                                            0
                                        ? "ic_followuser.png"
                                        : "ic_usertrue.png",
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                color:
                                    feedDetailWithScrollingProvider
                                                .feedDetailModel
                                                .result?[0]
                                                .isSubscriber ==
                                            0
                                        ? white
                                        : black,
                                multilanguage: true,
                                text:
                                    feedDetailWithScrollingProvider
                                                .feedDetailModel
                                                .result?[0]
                                                .isSubscriber ==
                                            0
                                        ? "follow"
                                        : "following",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textMedium,
                                inter: true,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  shimmer() {
    return const SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              children: [
                CustomWidget.roundrectborder(height: 15),
                CustomWidget.roundrectborder(height: 15),
              ],
            ),
          ),
          CustomWidget.rectangular(height: 250),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                SizedBox(height: 15),
                Row(
                  children: [
                    CustomWidget.roundcorner(height: 40, width: 80),
                    CustomWidget.roundcorner(height: 40, width: 80),
                    CustomWidget.roundcorner(height: 40, width: 80),
                  ],
                ),
                SizedBox(height: 15),
                CustomWidget.roundrectborder(height: 10, width: 120),
                SizedBox(height: 15),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
                    const SizedBox(width: 5),
                    MyText(
                      color: white,
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

  Widget feedDetail({
    String? title,
    required int index,
    required int parentIndex,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: MyText(
            color: white,
            text: title.toString(),
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textBig,
            maxline: 5,
            multilanguage: false,
            fontwaight: FontWeight.w700,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ),
        (feedDetailWithScrollingProvider
                        .feedDetailModel
                        .result?[index]
                        .postContent !=
                    null &&
                ((feedDetailWithScrollingProvider
                            .feedDetailModel
                            .result?[index]
                            .postContent
                            ?.length ??
                        0) >
                    0))
            ? Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              height: MediaQuery.of(context).size.height * 0.70,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! > 0) {
                      // Swipe down: Go back
                      Navigator.pop(context);
                    } else if (details.primaryVelocity! < 0) {
                      // Swipe up: Navigate to profile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Profile(
                              isBottomBar: false,
                              isFeedDetail: true,
                              toUserId:
                                  widget.data[parentIndex].userId.toString(),
                              toChannelId:
                                  widget.data[parentIndex].channelId.toString(),
                            );
                          },
                        ),
                      );
                    }
                  }
                },
                child: PageView.builder(
                  controller: _imageController,
                  itemCount:
                      (feedDetailWithScrollingProvider
                              .feedDetailModel
                              .result?[index]
                              .postContent
                              ?.length ??
                          0),
                  scrollDirection: Axis.horizontal,
                  allowImplicitScrolling: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (imageIndex) {},
                  itemBuilder: (context, contentIndex) {
                    return Stack(
                      children: [
                        feedDetailWithScrollingProvider
                                    .feedDetailModel
                                    .result?[index]
                                    .postContent?[contentIndex]
                                    .contentType ==
                                1
                            ? MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                              imagePath:
                                  feedDetailWithScrollingProvider
                                      .feedDetailModel
                                      .result?[index]
                                      .postContent?[contentIndex]
                                      .contentUrl
                                      .toString() ??
                                  "",
                            )
                            : FeedPlayer(
                              index: contentIndex,
                              pagePos: contentIndex,
                              thumbnailImg:
                                  feedDetailWithScrollingProvider
                                      .feedDetailModel
                                      .result?[index]
                                      .postContent?[contentIndex]
                                      .thumbnailImage
                                      .toString() ??
                                  "",
                              videoId:
                                  feedDetailWithScrollingProvider
                                      .feedDetailModel
                                      .result?[index]
                                      .postContent?[contentIndex]
                                      .id
                                      .toString() ??
                                  "",
                              videoUrl:
                                  feedDetailWithScrollingProvider
                                      .feedDetailModel
                                      .result?[index]
                                      .postContent?[contentIndex]
                                      .contentUrl
                                      .toString() ??
                                  "",
                            ),
                        Positioned(
                          left: 10,
                          top:
                              MediaQuery.of(context).size.height *
                              0.35, // Center vertically
                          child: GestureDetector(
                            onTap: () async {
                              if (_imageController.page?.toInt() == 0) {
                                _moveToPreviousPage();
                              } else {
                                // Otherwise, move the child image controller to the previous image
                                _imageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  0.6,
                                ), // Semi-transparent background
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(2, 2), // Shadow offset
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(
                                12,
                              ), // Padding around the icon
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back_ios_outlined,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top:
                              MediaQuery.of(context).size.height *
                              0.35, // Center vertically
                          child: GestureDetector(
                            onTap: () async {
                              if ((_imageController.page?.toInt() ?? 0) ==
                                  ((feedDetailWithScrollingProvider
                                              .feedDetailModel
                                              .result?[index]
                                              .postContent
                                              ?.length ??
                                          0) -
                                      1)) {
                                // If the current image is the last one in postContent, move to the next page in the parent
                                _moveToNextPage(
                                  index,
                                  feedDetailWithScrollingProvider
                                      .feedDetailModel
                                      .result
                                      ?.length,
                                );
                              } else {
                                // Otherwise, navigate to the next image in the child PageView
                                _imageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  0.6,
                                ), // Semi-transparent background
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(2, 2), // Shadow offset
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(
                                12,
                              ), // Padding around the icon
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
            : const SizedBox.shrink(),
        (feedDetailWithScrollingProvider
                        .feedDetailModel
                        .result?[index]
                        .postContent !=
                    null &&
                ((feedDetailWithScrollingProvider
                            .feedDetailModel
                            .result?[index]
                            .postContent
                            ?.length ??
                        0) >
                    0))
            ? Container(
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              child: SmoothPageIndicator(
                controller: _imageController,
                count:
                    feedDetailWithScrollingProvider
                        .feedDetailModel
                        .result?[index]
                        .postContent
                        ?.length ??
                    0,
                effect: const ExpandingDotsEffect(
                  activeDotColor: colorAccent,
                  dotColor: lightgray,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
              ),
            )
            : const SizedBox.shrink(),
        feedDetailWithScrollingProvider
                    .feedDetailModel
                    .result?[index]
                    .descripation ==
                ""
            ? const SizedBox.shrink()
            : Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: ExpandableText(
                expandOnTextTap: true,
                collapseOnTextTap: true,
                linkStyle: GoogleFonts.inter(
                  fontSize: Dimens.textMedium,
                  fontStyle: FontStyle.normal,
                  color: gray,
                  fontWeight: FontWeight.w500,
                ),
                style: GoogleFonts.inter(
                  fontSize: Dimens.textMedium,
                  fontStyle: FontStyle.normal,
                  color: white,
                  fontWeight: FontWeight.w400,
                ),
                feedDetailWithScrollingProvider
                        .feedDetailModel
                        .result?[0]
                        .descripation
                        .toString() ??
                    "",
                expandText: 'Read More',
                collapseText: "Read Less",
                linkColor: colorAccent,
                maxLines: 5,
              ),
            ),
        (feedDetailWithScrollingProvider
                        .feedDetailModel
                        .result?[index]
                        .hastegs !=
                    null &&
                ((feedDetailWithScrollingProvider
                            .feedDetailModel
                            .result?[index]
                            .hastegs
                            ?.length ??
                        0) >
                    0))
            ? SizedBox(
              height: 50,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemCount:
                    feedDetailWithScrollingProvider
                        .feedDetailModel
                        .result?[index]
                        .hastegs
                        ?.length ??
                    0,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, hashtagIndex) {
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 0.8, color: gray),
                    ),
                    child: MyText(
                      color: gray,
                      multilanguage: false,
                      text:
                          "# ${feedDetailWithScrollingProvider.feedDetailModel.result?[index].hastegs?[hashtagIndex].name.toString() ?? ""}",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textSmall,
                      inter: true,
                      maxline: 10,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  );
                },
              ),
            )
            : const SizedBox.shrink(),
      ],
    );
  }

  /* ====================== Comment Start ====================== */

  Widget buildComment(postIsComment, index, postId) {
    if (feedDetailWithScrollingProvider.commentloading &&
        !feedDetailWithScrollingProvider.commentloadMore) {
      return commentShimmer();
    } else {
      if (feedDetailWithScrollingProvider.commentList != null &&
          (feedDetailWithScrollingProvider.commentList?.length ?? 0) > 0 &&
          feedDetailWithScrollingProvider
                  .feedDetailModel
                  .result?[index]
                  .totalComment !=
              0) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MyText(
                    color: white,
                    text: Utils.kmbGenerator(
                      feedDetailWithScrollingProvider
                              .feedDetailModel
                              .result?[index]
                              .totalComment ??
                          0,
                    ),
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textBig,
                    inter: false,
                    maxline: 1,
                    multilanguage: false,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(width: 5),
                  MyText(
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
                ],
              ),
              const SizedBox(height: 20),
              buildCommentItem(postIsComment, index, postId),
              if (feedDetailWithScrollingProvider.commentloadMore)
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

  Widget buildCommentItem(postIsComment, index, postId) {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 10,
      itemCount: feedDetailWithScrollingProvider.commentList?.length ?? 0,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          // color: colorPrimaryDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    imagePath:
                        feedDetailWithScrollingProvider
                            .commentList?[index]
                            .image
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
                    feedDetailWithScrollingProvider
                                .commentList?[index]
                                .fullName ==
                            ""
                        ? MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              feedDetailWithScrollingProvider
                                  .commentList?[index]
                                  .channelName
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
                              feedDetailWithScrollingProvider
                                  .commentList?[index]
                                  .fullName
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
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.centerLeft,
                      child: ExpandableText(
                        expandOnTextTap: true,
                        collapseOnTextTap: true,
                        linkStyle: GoogleFonts.inter(
                          fontSize: Dimens.textSmall,
                          fontStyle: FontStyle.normal,
                          color: gray,
                          fontWeight: FontWeight.w500,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: Dimens.textSmall,
                          fontStyle: FontStyle.normal,
                          color: gray,
                          fontWeight: FontWeight.w400,
                        ),
                        feedDetailWithScrollingProvider
                                .commentList?[index]
                                .comment
                                .toString() ??
                            "",
                        expandText: 'Read More',
                        collapseText: "Read Less",
                        linkColor: colorAccent,
                        maxLines: 5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            feedDetailWithScrollingProvider.storeCommentId(
                              feedDetailWithScrollingProvider
                                      .commentList?[index]
                                      .id
                                      .toString() ??
                                  "",
                            );
                            await showReplayComment(
                              context: context,
                              postId: postId,
                              commentId:
                                  feedDetailWithScrollingProvider
                                      .commentList?[index]
                                      .id
                                      .toString() ??
                                  "",
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
                        const SizedBox(width: 15),
                        /* Delete Comment */
                        Constant.userID ==
                                (feedDetailWithScrollingProvider
                                        .commentList?[index]
                                        .userId
                                        .toString() ??
                                    "")
                            ? InkWell(
                              onTap: () async {
                                await feedDetailWithScrollingProvider
                                    .postDeleteComment(
                                      feedDetailWithScrollingProvider
                                              .commentList?[index]
                                              .id
                                              .toString() ??
                                          "",
                                    );
                                feedDetailWithScrollingProvider.clearComment();
                                _fetchPostComment(0, postId);
                              },
                              child: MyText(
                                color: colorAccent,
                                multilanguage: true,
                                text: "delete",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                maxline: 5,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

  /* ====================== Comment End ====================== */

  /* ====================== ReplayComment Start ====================== */

  showReplayComment({
    required BuildContext context,
    postId,
    commentId,
    required int postIsComment,
  }) async {
    _fetchPostReplayComment(commentId, 0);
    await showModalBottomSheet(
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
      context: context,
      backgroundColor: transparent,
      builder:
          (context) => Consumer<FeedDetailProvider>(
            builder: (context, feeddetailprovider, child) {
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
                                feedDetailWithScrollingProvider
                                    .clearReplayComment();
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
                      Expanded(child: buildReplayComment(postId, commentId)),
                      Utils.buildGradLine(),
                      addCommentTextField(
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

  Widget buildReplayComment(postId, commentId) {
    if (feedDetailWithScrollingProvider.replayCommentloading &&
        !feedDetailWithScrollingProvider.replayCommentloadMore) {
      return commentShimmer();
    } else {
      if (feedDetailWithScrollingProvider.getPostReplayCommentModel.result !=
              null &&
          feedDetailWithScrollingProvider.replayCommentList != null &&
          (feedDetailWithScrollingProvider.replayCommentList?.length ?? 0) >
              0) {
        return RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            await feedDetailWithScrollingProvider.clearReplayComment();
            _fetchPostReplayComment(commentId, 0);
          },
          child: SingleChildScrollView(
            controller: _replayCommentScrollController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                buildReplayCommentItem(postId, commentId),
                if (feedDetailWithScrollingProvider.replayCommentloadMore)
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

  Widget buildReplayCommentItem(postId, commentId) {
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
      children: List.generate(
        feedDetailWithScrollingProvider.replayCommentList?.length ?? 0,
        (index) {
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
                          feedDetailWithScrollingProvider
                              .replayCommentList?[index]
                              .image
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
                      feedDetailWithScrollingProvider
                                  .replayCommentList?[index]
                                  .fullName ==
                              ""
                          ? MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                feedDetailWithScrollingProvider
                                    .replayCommentList?[index]
                                    .channelName
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
                                feedDetailWithScrollingProvider
                                    .replayCommentList?[index]
                                    .fullName
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
                            feedDetailWithScrollingProvider
                                .replayCommentList?[index]
                                .comment
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

                /* Delete Comment */
                feedDetailWithScrollingProvider.replayCommentList?[index].userId
                            .toString() ==
                        Constant.userID
                    ? InkWell(
                      onTap: () async {
                        await feedDetailWithScrollingProvider.postDeleteComment(
                          feedDetailWithScrollingProvider
                                  .replayCommentList?[index]
                                  .id
                                  .toString() ??
                              "",
                        );
                        feedDetailWithScrollingProvider.clearReplayComment();
                        _fetchPostReplayComment(
                          feedDetailWithScrollingProvider
                                  .replayCommentList?[index]
                                  .id ??
                              0,
                          0,
                        );
                      },
                      child: const Icon(Icons.delete, color: white, size: 22),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  /* ====================== ReplayComment End ====================== */

  Widget addCommentTextField(postId, commentId, isComment, int postIsComment) {
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
              sendCommentApi(postId, commentId, isComment, postIsComment);
            },
            child:
                feedDetailWithScrollingProvider.addCommentLoading
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

  sendCommentApi(postId, commentId, isComment, int postIsComment) async {
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
      feedDetailWithScrollingProvider.clearComment();
      // feedDetailProvider.clearReplayComment();
      Utils.showSnackbar(context, "youcannotcommentthiscontent", true);
    } else {
      if (commentController.text.isEmpty) {
        Utils.showSnackbar(context, "pleaseenteryourcomment", true);
      } else {
        /* isComment == Ditect Comment And ReplayComment */

        /* Note: */
        /* AddComment commentId Always 0 Pass */
        /* Relplay Perticuler Comment Then Pass Comment Id */
        await feedDetailWithScrollingProvider.addPostComment(
          postId,
          commentController.text,
          commentId,
        );

        if (feedDetailWithScrollingProvider.addPostCommentModel.status == 200) {
          if (!context.mounted) return;
          commentController.clear();

          if (isComment) {
            feedDetailWithScrollingProvider.clearComment();
            _fetchPostComment(0, postId);
          } else {
            feedDetailWithScrollingProvider.clearReplayComment();
            _fetchPostReplayComment(commentId, 0);
          }
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          Utils.showSnackbar(
            context,
            feedDetailWithScrollingProvider.addPostCommentModel.message ?? "",
            false,
          );
        }
      }
    }
  }

  /* ====================== Report Reason ====================== */

  showReportReason({required BuildContext context, postId}) async {
    await _fetchAllReportReason(0);
    await feedDetailWithScrollingProvider.selectReportReason(
      0,
      feedDetailWithScrollingProvider.reportReasonList?[0].id.toString() ?? "",
    );
    if (!context.mounted) return;
    await showModalBottomSheet(
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: MediaQuery.of(context).size.height,
      context: context,
      backgroundColor: transparent,
      builder:
          (context) => Consumer<FeedDetailProvider>(
            builder: (context, feeddetailprovider, child) {
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

                                feedDetailWithScrollingProvider
                                    .clearReportReason();
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

                              feedDetailWithScrollingProvider
                                  .clearReportReason();
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
                                await feedDetailWithScrollingProvider
                                    .addPostReason(
                                      postId,
                                      feedDetailWithScrollingProvider.reason,
                                    );

                                if (feedDetailWithScrollingProvider
                                        .addContentReportModel
                                        .status ==
                                    200) {
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  Utils.showSnackbar(
                                    context,
                                    feedDetailWithScrollingProvider
                                            .addContentReportModel
                                            .message ??
                                        "",
                                    false,
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  Utils.showSnackbar(
                                    context,
                                    feedDetailWithScrollingProvider
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
    if (feedDetailWithScrollingProvider.getcontentreportloading &&
        !feedDetailWithScrollingProvider.getcontentreportloadmore) {
      return commentShimmer();
    } else {
      if (feedDetailWithScrollingProvider.getRepostReasonModel.result != null &&
          feedDetailWithScrollingProvider.reportReasonList != null &&
          (feedDetailWithScrollingProvider.reportReasonList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _reportScrollController,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              buildReportReasonItem(),
              if (feedDetailWithScrollingProvider.getcontentreportloadmore)
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
      children: List.generate(
        feedDetailWithScrollingProvider.reportReasonList?.length ?? 0,
        (index) {
          return InkWell(
            onTap: () async {
              feedDetailWithScrollingProvider.selectReportReason(
                index,
                feedDetailWithScrollingProvider.reportReasonList?[index].id
                        .toString() ??
                    "",
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
                            feedDetailWithScrollingProvider.reportPosition ==
                                    index
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
                            feedDetailWithScrollingProvider.reportPosition ==
                                    index
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
                          feedDetailWithScrollingProvider
                              .reportReasonList?[index]
                              .reason
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
        },
      ),
    );
  }

  /* ====================== Report Reason ====================== */
}
