import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/feedplayer.dart';
import 'package:slike/provider/feeddetailprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/weblogin.dart';
import 'package:slike/webpages/webprofile.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WebFeedDetail extends StatefulWidget {
  final String userImage, userName, channelName, postId;

  const WebFeedDetail({
    super.key,
    required this.userImage,
    required this.userName,
    required this.channelName,
    required this.postId,
  });

  @override
  State<WebFeedDetail> createState() => WebFeedDetailState();
}

class WebFeedDetailState extends State<WebFeedDetail> {
  late FeedDetailProvider feedDetailProvider;
  final PageController _pageController = PageController();
  late ScrollController _commentScrollController;
  late ScrollController _replayCommentScrollController;
  late ScrollController _reportScrollController;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    feedDetailProvider = Provider.of<FeedDetailProvider>(
      context,
      listen: false,
    );
    _commentScrollController = ScrollController();
    _replayCommentScrollController = ScrollController();
    _reportScrollController = ScrollController();
    _commentScrollController.addListener(_commentScrollListener);
    _replayCommentScrollController.addListener(_replayCommentScrollListener);
    _reportScrollController.addListener(_reportScrollListener);
    super.initState();
    getApi();
  }

  getApi() async {
    feedDetailProvider.getFeedDetail(widget.postId);
    _fetchPostComment(0);
  }

  _commentScrollListener() async {
    if (!_commentScrollController.hasClients) return;
    if (_commentScrollController.offset >=
            _commentScrollController.position.maxScrollExtent &&
        !_commentScrollController.position.outOfRange &&
        (feedDetailProvider.commentcurrentPage ?? 0) <
            (feedDetailProvider.commenttotalPage ?? 0)) {
      await feedDetailProvider.setCommentLoadMore(true);
      _fetchPostComment(feedDetailProvider.commentcurrentPage ?? 0);
    }
  }

  _replayCommentScrollListener() async {
    if (!_replayCommentScrollController.hasClients) return;
    if (_replayCommentScrollController.offset >=
            _replayCommentScrollController.position.maxScrollExtent &&
        !_replayCommentScrollController.position.outOfRange &&
        (feedDetailProvider.replayCommentcurrentPage ?? 0) <
            (feedDetailProvider.replayCommenttotalPage ?? 0)) {
      await feedDetailProvider.setReplayCommentLoadMore(true);
      _fetchPostReplayComment(
        feedDetailProvider.cmtId,
        feedDetailProvider.replayCommentcurrentPage ?? 0,
      );
    }
  }

  _reportScrollListener() async {
    if (!_reportScrollController.hasClients) return;
    if (_reportScrollController.offset >=
            _reportScrollController.position.maxScrollExtent &&
        !_reportScrollController.position.outOfRange &&
        (feedDetailProvider.reportcurrentPage ?? 0) <
            (feedDetailProvider.reporttotalPage ?? 0)) {
      await feedDetailProvider.setReportReasonLoadMore(true);
      _fetchAllReportReason(feedDetailProvider.reportcurrentPage ?? 0);
    }
  }

  Future<void> _fetchPostComment(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedDetailProvider.getPostComment(widget.postId, (nextPage ?? 0) + 1);
    await feedDetailProvider.setCommentLoadMore(false);
  }

  Future<void> _fetchPostReplayComment(commentId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedDetailProvider.getPostReplayComment(
      commentId,
      (nextPage ?? 0) + 1,
    );
    await feedDetailProvider.setReplayCommentLoadMore(false);
  }

  Future<void> _fetchAllReportReason(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await feedDetailProvider.getReportReason("2", (nextPage ?? 0) + 1);
    await feedDetailProvider.setReportReasonLoadMore(false);
  }

  @override
  void dispose() {
    feedDetailProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: "feeddetail",
        categoryTap: () {},
      ),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _commentScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Consumer<FeedDetailProvider>(
              builder: (context, feeddetailprovider, child) {
                if (feeddetailprovider.loading) {
                  return shimmer();
                } else {
                  return buildUI();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUI() {
    /* ==================== Web UI ====================*/
    if (MediaQuery.of(context).size.width > 1200) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.60,
            child: feedDetail(),
          ),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.50,
              child: buildComment(
                feedDetailProvider.feedDetailModel.result?[0].isComment ?? 0,
              ),
            ),
          ),
        ],
      );
    } else {
      /* ==================== Mobile UI ==================== */
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          feedDetail(),
          buildComment(
            feedDetailProvider.feedDetailModel.result?[0].isComment ?? 0,
          ),
        ],
      );
    }
  }

  AppBar appBar() {
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
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation1, animation2) => WebProfile(
                            isBottomBar: false,
                            isFeedDetail: true,
                            toUserId:
                                feedDetailProvider
                                    .feedDetailModel
                                    .result?[0]
                                    .userId
                                    .toString() ??
                                "",
                            toChannelId:
                                feedDetailProvider
                                    .feedDetailModel
                                    .result?[0]
                                    .channelId
                                    .toString() ??
                                "",
                          ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
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
                        imagePath: widget.userImage,
                      ),
                    ),
                    const SizedBox(width: 10),
                    MyText(
                      color: white,
                      text:
                          widget.userName == ""
                              ? widget.channelName
                              : widget.userName,
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textTitle,
                      multilanguage: false,
                      inter: true,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
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
                          feedDetailProvider.feedDetailModel.result?[0].userId
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
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const WebLogin(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          } else {
                            await feedDetailProvider.addRemoveSubscriber(
                              feedDetailProvider
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
                                  feedDetailProvider
                                              .feedDetailModel
                                              .result?[0]
                                              .isSubscriber ==
                                          0
                                      ? gray
                                      : gray,
                            ),
                            color:
                                feedDetailProvider
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
                                    feedDetailProvider
                                                .feedDetailModel
                                                .result?[0]
                                                .isSubscriber ==
                                            0
                                        ? white
                                        : black,
                                imagePath:
                                    feedDetailProvider
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
                                    feedDetailProvider
                                                .feedDetailModel
                                                .result?[0]
                                                .isSubscriber ==
                                            0
                                        ? white
                                        : black,
                                multilanguage: true,
                                text:
                                    feedDetailProvider
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

  Widget feedDetail() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (feedDetailProvider.feedDetailModel.result?[0].postContent != null &&
                  ((feedDetailProvider
                              .feedDetailModel
                              .result?[0]
                              .postContent
                              ?.length ??
                          0) >
                      0))
              ? SizedBox(
                height: 500,
                width: MediaQuery.of(context).size.width,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount:
                      feedDetailProvider
                          .feedDetailModel
                          .result?[0]
                          .postContent
                          ?.length ??
                      0,
                  scrollDirection: Axis.horizontal,
                  allowImplicitScrolling: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, contentIndex) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child:
                              feedDetailProvider
                                          .feedDetailModel
                                          .result?[0]
                                          .postContent?[contentIndex]
                                          .contentType ==
                                      1
                                  ? MyNetworkImage(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    fit: BoxFit.cover,
                                    imagePath:
                                        feedDetailProvider
                                            .feedDetailModel
                                            .result?[0]
                                            .postContent?[contentIndex]
                                            .contentUrl
                                            .toString() ??
                                        "",
                                  )
                                  : FeedPlayer(
                                    index: contentIndex,
                                    pagePos: contentIndex,
                                    thumbnailImg:
                                        feedDetailProvider
                                            .feedDetailModel
                                            .result?[0]
                                            .postContent?[contentIndex]
                                            .thumbnailImage
                                            .toString() ??
                                        "",
                                    videoId:
                                        feedDetailProvider
                                            .feedDetailModel
                                            .result?[0]
                                            .postContent?[contentIndex]
                                            .id
                                            .toString() ??
                                        "",
                                    videoUrl:
                                        feedDetailProvider
                                            .feedDetailModel
                                            .result?[0]
                                            .postContent?[contentIndex]
                                            .contentUrl
                                            .toString() ??
                                        "",
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              )
              : const SizedBox.shrink(),
          (feedDetailProvider.feedDetailModel.result?[0].postContent != null &&
                  ((feedDetailProvider
                              .feedDetailModel
                              .result?[0]
                              .postContent
                              ?.length ??
                          0) >
                      0))
              ? Container(
                margin: const EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count:
                      feedDetailProvider
                          .feedDetailModel
                          .result?[0]
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: MyText(
              color: white,
              text:
                  feedDetailProvider.feedDetailModel.result?[0].title
                      .toString() ??
                  "",
              textalign: TextAlign.center,
              fontsizeNormal: Dimens.textBig,
              fontsizeWeb: Dimens.textBig,
              maxline: 5,
              multilanguage: false,
              fontwaight: FontWeight.w700,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ),
          /* Feed upload Channel List */
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation1, animation2) => WebProfile(
                                isBottomBar: false,
                                isFeedDetail: true,
                                toUserId:
                                    feedDetailProvider
                                        .feedDetailModel
                                        .result?[0]
                                        .userId
                                        .toString() ??
                                    "",
                                toChannelId:
                                    feedDetailProvider
                                        .feedDetailModel
                                        .result?[0]
                                        .channelId
                                        .toString() ??
                                    "",
                              ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
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
                            imagePath: widget.userImage,
                          ),
                        ),
                        const SizedBox(width: 15),
                        MyText(
                          color: white,
                          text:
                              widget.userName == ""
                                  ? widget.channelName
                                  : widget.userName,
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
                          multilanguage: false,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
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
                              feedDetailProvider
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
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            const WebLogin(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              } else {
                                await feedDetailProvider.addRemoveSubscriber(
                                  feedDetailProvider
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
                                      feedDetailProvider
                                                  .feedDetailModel
                                                  .result?[0]
                                                  .isSubscriber ==
                                              0
                                          ? gray
                                          : gray,
                                ),
                                color:
                                    feedDetailProvider
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
                                        feedDetailProvider
                                                    .feedDetailModel
                                                    .result?[0]
                                                    .isSubscriber ==
                                                0
                                            ? white
                                            : black,
                                    imagePath:
                                        feedDetailProvider
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
                                        feedDetailProvider
                                                    .feedDetailModel
                                                    .result?[0]
                                                    .isSubscriber ==
                                                0
                                            ? white
                                            : black,
                                    multilanguage: true,
                                    text:
                                        feedDetailProvider
                                                    .feedDetailModel
                                                    .result?[0]
                                                    .isSubscriber ==
                                                0
                                            ? "follow"
                                            : "following",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
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
          feedDetailProvider.feedDetailModel.result?[0].descripation == ""
              ? const SizedBox.shrink()
              : Container(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
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
                  feedDetailProvider.feedDetailModel.result?[0].descripation
                          .toString() ??
                      "",
                  expandText: 'Read More',
                  collapseText: "Read Less",
                  linkColor: colorAccent,
                  maxLines: 5,
                ),
              ),
          (feedDetailProvider.feedDetailModel.result?[0].hastegs != null &&
                  ((feedDetailProvider
                              .feedDetailModel
                              .result?[0]
                              .hastegs
                              ?.length ??
                          0) >
                      0))
              ? SizedBox(
                height: 50,
                child: ListView.separated(
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 10),
                  itemCount:
                      feedDetailProvider
                          .feedDetailModel
                          .result?[0]
                          .hastegs
                          ?.length ??
                      0,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                            "# ${feedDetailProvider.feedDetailModel.result?[0].hastegs?[hashtagIndex].name.toString() ?? ""}",
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
          functionButton(),
        ],
      ),
    );
  }

  Widget functionButton() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      color: transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: commentController,
              maxLines: 1,
              scrollPhysics: const AlwaysScrollableScrollPhysics(),
              textAlign: TextAlign.start,
              onChanged: (value) {
                feedDetailProvider.showHideSendIcon(value);
              },
              decoration: InputDecoration(
                suffixIcon:
                    feedDetailProvider.isSendShow == false
                        ? const SizedBox.shrink()
                        : InkWell(
                          onTap: () {
                            sendCommentApi(
                              widget.postId,
                              0,
                              true,
                              feedDetailProvider
                                      .feedDetailModel
                                      .result?[0]
                                      .isComment ??
                                  0,
                            );
                          },
                          child: const Icon(Icons.send, color: white),
                        ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: white, width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: white, width: 1),
                ),
                filled: true,
                fillColor: transparent, // Replace with `transparent` color
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
                    (feedDetailProvider.feedDetailModel.result?[0].ifood_app ??
                                0) ==
                            1
                        ? colorAccent
                        : white,
                count: Utils.kmbGenerator(
                  feedDetailProvider.feedDetailModel.result?[0].totalLike ?? 0,
                ),
                onTap: () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation1, animation2) =>
                                const WebLogin(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    await feedDetailProvider.like(
                      feedDetailProvider.feedDetailModel.result?[0].id ?? 0,
                    );
                  }
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
                        feedDetailProvider.feedDetailModel.result?[0].id
                            .toString() ??
                        "",
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* ====================== Comment Start ====================== */

  Widget buildComment(postIsComment) {
    if (feedDetailProvider.commentloading &&
        !feedDetailProvider.commentloadMore) {
      return commentShimmer();
    } else {
      if (feedDetailProvider.commentList != null &&
          (feedDetailProvider.commentList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width > 1200 ? 25 : 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MyText(
                    color: white,
                    text: Utils.kmbGenerator(
                      feedDetailProvider
                              .feedDetailModel
                              .result?[0]
                              .totalComment ??
                          0,
                    ),
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textBig,
                    fontsizeWeb: Dimens.textBig,
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
                    fontsizeWeb: Dimens.textBig,
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
              buildCommentItem(postIsComment),
              if (feedDetailProvider.commentloadMore)
                SizedBox(height: 50, child: Utils.pageLoader(context))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget buildCommentItem(postIsComment) {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 10,
      itemCount: feedDetailProvider.commentList?.length ?? 0,
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
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    imagePath:
                        feedDetailProvider.commentList?[index].image
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
                    feedDetailProvider.commentList?[index].fullName == ""
                        ? MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              feedDetailProvider.commentList?[index].channelName
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
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
                              feedDetailProvider.commentList?[index].fullName
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
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
                        feedDetailProvider.commentList?[index].comment
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
                            feedDetailProvider.storeCommentId(
                              feedDetailProvider.commentList?[index].id
                                      .toString() ??
                                  "",
                            );

                            await showReplayComment(
                              context: context,
                              postId: widget.postId,
                              commentId:
                                  feedDetailProvider.commentList?[index].id
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
                            fontsizeWeb: Dimens.textSmall,
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
                                (feedDetailProvider.commentList?[index].userId
                                        .toString() ??
                                    "")
                            ? InkWell(
                              onTap: () async {
                                await feedDetailProvider.postDeleteComment(
                                  feedDetailProvider.commentList?[index].id
                                          .toString() ??
                                      "",
                                );
                                feedDetailProvider.clearComment();
                                _fetchPostComment(0);
                              },
                              child: MyText(
                                color: colorAccent,
                                multilanguage: true,
                                text: "delete",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
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
    await showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorPrimaryDark,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: 450,
              maxHeight: 500,
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
                          feedDetailProvider.clearReplayComment();
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
                addCommentTextField(postId, commentId, false, postIsComment),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildReplayComment(postId, commentId) {
    return Consumer<FeedDetailProvider>(
      builder: (context, feeddetailprovider, child) {
        if (feedDetailProvider.replayCommentloading &&
            !feedDetailProvider.replayCommentloadMore) {
          return commentShimmer();
        } else {
          if (feedDetailProvider.replayCommentList != null &&
              (feedDetailProvider.replayCommentList?.length ?? 0) > 0) {
            return RefreshIndicator(
              backgroundColor: colorPrimaryDark,
              color: colorAccent,
              displacement: 70,
              edgeOffset: 1.0,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              strokeWidth: 3,
              onRefresh: () async {
                await feedDetailProvider.clearReplayComment();
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
                    if (feedDetailProvider.replayCommentloadMore)
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
      },
    );
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
        feedDetailProvider.replayCommentList?.length ?? 0,
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
                          feedDetailProvider.replayCommentList?[index].image
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
                      feedDetailProvider.replayCommentList?[index].fullName ==
                              ""
                          ? MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                feedDetailProvider
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
                                feedDetailProvider
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
                            feedDetailProvider.replayCommentList?[index].comment
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
                feedDetailProvider.replayCommentList?[index].userId
                            .toString() ==
                        Constant.userID
                    ? InkWell(
                      onTap: () async {
                        await feedDetailProvider.postDeleteComment(
                          feedDetailProvider.replayCommentList?[index].id
                                  .toString() ??
                              "",
                        );
                        feedDetailProvider.clearReplayComment();
                        _fetchPostReplayComment(
                          feedDetailProvider.replayCommentList?[index].id
                                  .toString() ??
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
            borderRadius: BorderRadius.circular(50),
            onTap: () async {
              sendCommentApi(postId, commentId, isComment, postIsComment);
            },
            child:
                feedDetailProvider.addCommentLoading
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
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const WebLogin(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (postIsComment == 0) {
      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }
      commentController.clear();
      feedDetailProvider.clearComment();
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
        await feedDetailProvider.addPostComment(
          postId,
          commentController.text,
          commentId,
        );

        if (feedDetailProvider.addPostCommentModel.status == 200) {
          if (!context.mounted) return;
          commentController.clear();

          if (isComment) {
            feedDetailProvider.clearComment();
            _fetchPostComment(0);
          } else {
            feedDetailProvider.clearReplayComment();
            _fetchPostReplayComment(commentId, 0);
          }
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          Utils.showSnackbar(
            context,
            feedDetailProvider.addPostCommentModel.message ?? "",
            false,
          );
        }
      }
    }
  }

  /* ====================== Report Reason ====================== */

  showReportReason({required BuildContext context, postId}) async {
    await _fetchAllReportReason(0);
    await feedDetailProvider.selectReportReason(
      0,
      feedDetailProvider.reportReasonList?[0].id.toString() ?? "",
    );
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorPrimaryDark,
          child: Container(
            height: 500,
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.antiAlias,
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: 450,
              maxHeight: 500,
            ),
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

                          feedDetailProvider.clearReportReason();
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

                        feedDetailProvider.clearReportReason();
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
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation1, animation2) =>
                                      const WebLogin(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          await feedDetailProvider.addPostReason(
                            postId,
                            feedDetailProvider.reason,
                          );

                          if (feedDetailProvider.addContentReportModel.status ==
                              200) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            Utils.showSnackbar(
                              context,
                              feedDetailProvider
                                      .addContentReportModel
                                      .message ??
                                  "",
                              false,
                            );
                          } else {
                            if (!context.mounted) return;
                            Utils.showSnackbar(
                              context,
                              feedDetailProvider
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
    );
  }

  Widget buildReportReason() {
    if (feedDetailProvider.getcontentreportloading &&
        !feedDetailProvider.getcontentreportloadmore) {
      return commentShimmer();
    } else {
      if (feedDetailProvider.getRepostReasonModel.result != null &&
          feedDetailProvider.reportReasonList != null &&
          (feedDetailProvider.reportReasonList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _reportScrollController,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              buildReportReasonItem(),
              if (feedDetailProvider.getcontentreportloadmore)
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
        feedDetailProvider.reportReasonList?.length ?? 0,
        (index) {
          return InkWell(
            onTap: () async {
              feedDetailProvider.selectReportReason(
                index,
                feedDetailProvider.reportReasonList?[index].id.toString() ?? "",
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
                            feedDetailProvider.reportPosition == index
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
                            feedDetailProvider.reportPosition == index
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
                          feedDetailProvider.reportReasonList?[index].reason
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
