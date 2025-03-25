import 'dart:io';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/feedprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/customappbar.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';

class Feeds extends StatefulWidget {
  const Feeds({super.key});

  @override
  State<Feeds> createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  late FeedProvider feedProvider;
  late ScrollController _scrollController;
  late ScrollController _commentScrollController;
  late ScrollController _replayCommentScrollController;
  late ScrollController _reportScrollController;
  late ScrollController _categoryScrollController;
  final TextEditingController commentController = TextEditingController();

  String tempImg = "";

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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
  }

  getApi() async {
    await feedProvider.setLoading(true);
    await _fetchCategory(0);
    if (feedProvider.categorymodel.status == 200 &&
        feedProvider.categorydataList != null) {
      if ((feedProvider.categorydataList?.length ?? 0) > 0) {
        await _fetchAllFeed("", 0);
        await feedProvider.setLoading(false);
      }
    }
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

  @override
  void dispose() {
    feedProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: const CustomAppBar(contentType: "1", isSearch: true),
      body: Consumer<FeedProvider>(
        builder: (context, feedprovider, child) {
          return Column(
            children: [
              buildCategory(),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: colorPrimaryDark,
                  color: colorAccent,
                  displacement: 70,
                  edgeOffset: 1.0,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  strokeWidth: 3,
                  onRefresh: () async {
                    await feedProvider.clearProvider();
                    getApi();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [buildFeed()],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /* ====================== Category ====================== */

  Widget buildCategory() {
    if (feedProvider.categoryloading && !feedProvider.categoryloadMore) {
      return categoryShimmer();
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _categoryScrollController,
        child: Row(
          children: [
            buildCategoryItem(),
            if (feedProvider.categoryloadMore)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: colorAccent,
                  strokeWidth: 1,
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      );
    }
  }

  Widget buildCategoryItem() {
    if (feedProvider.categorymodel.status == 200 &&
        feedProvider.categorydataList != null) {
      if ((feedProvider.categorydataList?.length ?? 0) > 0) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            itemCount: feedProvider.categorydataList?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                autofocus: false,
                splashColor: transparent,
                highlightColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                onTap: () async {
                  // await feedProvider.selectCategory(
                  //     index,
                  //     feedProvider.categorydataList?[index].id.toString() ??
                  //         "");
                  // feedProvider.clearAllPost();
                  // if (index == 0) {
                  //   _fetchAllFeed("", 0);
                  // } else {
                  //   _fetchAllFeed(
                  //       feedProvider.categorydataList?[index].id.toString() ??
                  //           "",
                  //       0);
                  // }
                },
                // child: Container(
                //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                //   alignment: Alignment.center,
                //   decoration: BoxDecoration(
                //       color: index == feedProvider.catindex
                //           ? colorAccent
                //           : colorPrimary,
                //       borderRadius: BorderRadius.circular(5),
                //       border: Border.all(color: colorAccent, width: 1)),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       MyText(
                //         color: index == feedProvider.catindex ? black : white,
                //         text: feedProvider.categorydataList?[index].name ?? "",
                //         fontwaight: FontWeight.w500,
                //         fontsizeNormal: Dimens.textSmall,
                //         maxline: 1,
                //         multilanguage: false,
                //         overflow: TextOverflow.ellipsis,
                //         textalign: TextAlign.center,
                //         fontstyle: FontStyle.normal,
                //       ),
                //     ],
                //   ),
                // ),
              );
            },
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget categoryShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 65,
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 15),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return const CustomWidget.roundrectborder(height: 8, width: 90);
        },
      ),
    );
  }

  /* ====================== Category ====================== */

  /* ====================== Get All Feed ====================== */

  Widget buildFeed() {
    if (feedProvider.loading && !feedProvider.loadMore) {
      return shimmer();
    } else {
      if (feedProvider.postModel.status == 200 &&
          feedProvider.feedPostList != null) {
        if ((feedProvider.feedPostList?.length ?? 0) > 0) {
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
      } else {
        return const NoData();
      }
    }
  }

  Widget buildFeedItem() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 10,
      itemCount: feedProvider.feedPostList?.length ?? 0,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            feedProvider.feedPostList?[index].userId
                                .toString() ??
                            "",
                        toChannelId:
                            feedProvider.feedPostList?[index].channelId
                                .toString() ??
                            "",
                      );
                    },
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: colorAccent,
                padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(width: 1.5, color: black),
                        color: yellow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: MyNetworkImage(
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                          imagePath:
                              feedProvider.feedPostList?[index].profileImg
                                  .toString() ??
                              "",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          feedProvider.feedPostList?[index].fullName == ""
                              ? MyText(
                                color: black,
                                multilanguage: false,
                                text:
                                    feedProvider
                                        .feedPostList?[index]
                                        .channelName
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textTitle,
                                inter: true,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              )
                              : MyText(
                                color: black,
                                multilanguage: false,
                                text:
                                    feedProvider.feedPostList?[index].fullName
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textTitle,
                                inter: true,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                    ),
                    const SizedBox(width: 12),
                    Constant.userID ==
                            feedProvider.feedPostList?[index].userId.toString()
                        ? const SizedBox.shrink()
                        : InkWell(
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
                              await feedProvider.addRemoveSubscriber(
                                index,
                                feedProvider.feedPostList?[index].userId
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
                                    feedProvider
                                                .feedPostList?[index]
                                                .isSubscriber ==
                                            0
                                        ? gray
                                        : black,
                              ),
                              color:
                                  feedProvider
                                              .feedPostList?[index]
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
                                      feedProvider
                                                  .feedPostList?[index]
                                                  .isSubscriber ==
                                              0
                                          ? white
                                          : black,
                                  imagePath:
                                      feedProvider
                                                  .feedPostList?[index]
                                                  .isSubscriber ==
                                              0
                                          ? "ic_followuser.png"
                                          : "ic_usertrue.png",
                                ),
                                const SizedBox(width: 5),
                                MyText(
                                  color:
                                      feedProvider
                                                  .feedPostList?[index]
                                                  .isSubscriber ==
                                              0
                                          ? white
                                          : black,
                                  multilanguage: true,
                                  text:
                                      feedProvider
                                                  .feedPostList?[index]
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
                        ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (feedProvider.feedPostList?[index].postContent != null &&
                          ((feedProvider
                                      .feedPostList?[index]
                                      .postContent
                                      ?.length ??
                                  0) >
                              0))
                      ? SizedBox(
                        height: 260,
                        child: ListView.separated(
                          separatorBuilder:
                              (context, contentIndex) =>
                                  const SizedBox(width: 10),
                          itemCount:
                              feedProvider
                                  .feedPostList?[index]
                                  .postContent
                                  ?.length ??
                              0,
                          padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, contentIndex) {
                            return Stack(
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
                            );
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                    child: MyText(
                      color: white,
                      multilanguage: false,
                      text:
                          feedProvider.feedPostList?[index].title.toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textDesc,
                      inter: false,
                      maxline: 3,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  feedProvider.feedPostList?[index].descripation == ""
                      ? const SizedBox.shrink()
                      : Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                        width: MediaQuery.of(context).size.width,
                        constraints: BoxConstraints(
                          minHeight: 50,
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
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
                          feedProvider.feedPostList?[index].descripation
                                  .toString() ??
                              "",
                          expandText: 'Read More',
                          collapseText: "Read Less",
                          linkColor: colorAccent,
                          maxLines: 5,
                        ),
                      ),
                  (feedProvider.feedPostList?[index].hastegs != null &&
                          ((feedProvider.feedPostList?[index].hastegs?.length ??
                                  0) >
                              0))
                      ? SizedBox(
                        height: 50,
                        child: ListView.separated(
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 10),
                          itemCount:
                              feedProvider
                                  .feedPostList?[index]
                                  .hastegs
                                  ?.length ??
                              0,
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
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
                                    "# ${feedProvider.feedPostList?[index].hastegs?[hashtagIndex].name.toString() ?? ""}",
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: MyText(
                      color: gray,
                      multilanguage: false,
                      text: Utils.timeAgoCustom(
                        DateTime.parse(
                          feedProvider.feedPostList?[index].createdAt
                                  .toString() ??
                              "",
                        ),
                      ),
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textSmall,
                      inter: true,
                      maxline: 10,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              iconWithCount(
                                width: 26,
                                height: 26,
                                showText: true,
                                iconPath: "ic_muscle.png",
                                iconColor:
                                    (feedProvider
                                                    .feedPostList?[index]
                                                    .totalLike ??
                                                0) ==
                                            1
                                        ? colorAccent
                                        : gray,
                                count: Utils.kmbGenerator(
                                  int.parse(
                                    feedProvider.feedPostList?[index].totalLike
                                            .toString() ??
                                        "",
                                  ),
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
                                    await feedProvider.like(
                                      index,
                                      feedProvider.feedPostList?[index].id ?? 0,
                                    );
                                  }
                                },
                              ),
                              iconWithCount(
                                width: 26,
                                height: 26,
                                showText: true,
                                iconColor: gray,
                                iconPath: "ic_comment.png",
                                count: Utils.kmbGenerator(
                                  int.parse(
                                    feedProvider
                                            .feedPostList?[index]
                                            .totalComment
                                            .toString() ??
                                        "",
                                  ),
                                ),
                                onTap: () async {
                                  showComment(
                                    context: context,
                                    postIndex: index,
                                    postId:
                                        feedProvider.feedPostList?[index].id
                                            .toString() ??
                                        "",
                                    postIsComment:
                                        feedProvider
                                            .feedPostList?[index]
                                            .isComment ??
                                        0,
                                  );
                                },
                              ),
                              iconWithCount(
                                width: 26,
                                height: 26,
                                iconColor: gray,
                                showText: false,
                                iconPath: "ic_share.png",
                                onTap: () async {
                                  Utils.shareApp(
                                    Platform.isIOS
                                        ? "Hey! I'm Showing ${feedProvider.feedPostList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                        : "Hey! I'm Showing ${feedProvider.feedPostList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                                  );
                                },
                              ),
                              iconWithCount(
                                width: 26,
                                height: 26,
                                showText: false,
                                iconColor: gray,
                                iconPath: "ic_more.webp",
                                onTap: () {
                                  showReportReason(
                                    context: context,
                                    postId:
                                        feedProvider.feedPostList?[index].id
                                            .toString() ??
                                        "",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        feedProvider.feedPostList?[index].userId.toString() ==
                                Constant.userID
                            ? const SizedBox.shrink()
                            : InkWell(
                              onTap: () async {
                                if (Constant.userID == null) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const Login();
                                      },
                                    ),
                                  );
                                } else {
                                  // await Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) {
                                  //       return Chatscreen(
                                  //         toUserName: feedProvider
                                  //                 .feedPostList?[index]
                                  //                 .fullName
                                  //                 .toString() ??
                                  //             "",
                                  //         toChatId: feedProvider
                                  //                 .feedPostList?[index]
                                  //                 .firebaseId
                                  //                 .toString() ??
                                  //             "",
                                  //         profileImg: feedProvider
                                  //                 .feedPostList?[index]
                                  //                 .profileImg
                                  //                 .toString() ??
                                  //             "",
                                  //         bioData: "",
                                  //       );
                                  //     },
                                  //   ),
                                  // );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: const LinearGradient(
                                    colors: [colorAccent, white],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MyImage(
                                      width: 20,
                                      height: 20,
                                      color: black,
                                      imagePath: "ic_say_hey.webp",
                                    ),
                                    const SizedBox(width: 5),
                                    MyText(
                                      color: black,
                                      multilanguage: false,
                                      text: "Say 'Hii'",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: true,
                                      maxline: 10,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.italic,
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
          ],
        );
      },
    );
  }

  Widget shimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: colorPrimaryDark,
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(width: 1, color: gray),
                        color: colorPrimary,
                      ),
                      child: const CustomWidget.circular(height: 35, width: 35),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomWidget.roundrectborder(height: 10, width: 150),
                          CustomWidget.roundrectborder(height: 10, width: 150),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const CustomWidget.roundcorner(height: 20, width: 80),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        separatorBuilder:
                            (context, contentIndex) =>
                                const SizedBox(width: 10),
                        itemCount: 3,
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, contentIndex) {
                          return CustomWidget.roundcorner(
                            width: 160,
                            height: MediaQuery.of(context).size.height,
                          );
                        },
                      ),
                    ),
                    const CustomWidget.roundcorner(height: 10),
                    const CustomWidget.roundcorner(height: 10),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 10),
                        itemCount: 5,
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return const CustomWidget.roundcorner(
                            width: 90,
                            height: 25,
                          );
                        },
                      ),
                    ),
                    const CustomWidget.roundcorner(height: 10, width: 100),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomWidget.circular(height: 22, width: 22),
                              SizedBox(width: 8),
                              CustomWidget.roundcorner(height: 22, width: 22),
                              SizedBox(width: 10),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomWidget.circular(height: 22, width: 22),
                              SizedBox(width: 8),
                              CustomWidget.roundcorner(height: 22, width: 22),
                              SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
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
}
