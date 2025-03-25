import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/provider/latestfeedprovider.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/webfeeddetail.dart';
import 'package:slike/webservice/pushnotificationservice.dart';
import 'package:slike/webwidget/interactivecontainer.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';

class WebLatestFeed extends StatefulWidget {
  const WebLatestFeed({super.key});

  @override
  State<WebLatestFeed> createState() => WebLatestFeedState();
}

class WebLatestFeedState extends State<WebLatestFeed> {
  late LatestFeedProvider latestFeedProvider;
  late GeneralProvider generalProvider;
  late ProfileProvider profileProvider;
  SharedPre sharedPre = SharedPre();
  late ScrollController _scrollSubscribePostController;
  late ScrollController _scrollMostViewPostController;
  late ScrollController _scrollGetPostByCategoryController;
  late ScrollController _categoryScrollController;
  final TextEditingController commentController = TextEditingController();
  String tempImg = "";

  @override
  void initState() {
    latestFeedProvider = Provider.of<LatestFeedProvider>(
      context,
      listen: false,
    );
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _scrollSubscribePostController = ScrollController();
    _scrollMostViewPostController = ScrollController();
    _scrollGetPostByCategoryController = ScrollController();
    _categoryScrollController = ScrollController();
    _scrollSubscribePostController.addListener(_scrollListener);
    _scrollMostViewPostController.addListener(_scrollMostViewPostListener);
    _scrollGetPostByCategoryController.addListener(
      _scrollGetPostByCategoryListener,
    );
    _categoryScrollController.addListener(_scrollCategoryListner);
    /* Fetch General Setting Data */
    getGeneralSetting();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
  }

  getApi() async {
    await latestFeedProvider.setLoading(true);
    await getSubscribeChannelPost(0);
    await getMostViewPost(0);
    await getPostByCategory(0, 0);
    await latestFeedProvider.setLoading(false);
  }

  _scrollListener() async {
    if (!_scrollSubscribePostController.hasClients) return;
    if (_scrollSubscribePostController.offset >=
            _scrollSubscribePostController.position.maxScrollExtent &&
        !_scrollSubscribePostController.position.outOfRange &&
        (latestFeedProvider.subscribeChannelPostcurrentPage ?? 0) <
            (latestFeedProvider.subscribeChannelPosttotalPage ?? 0)) {
      await latestFeedProvider.setSubscribePostLoadMore(true);
      getSubscribeChannelPost(
        latestFeedProvider.subscribeChannelPostcurrentPage ?? 0,
      );
    }
  }

  _scrollMostViewPostListener() async {
    if (!_scrollMostViewPostController.hasClients) return;
    if (_scrollMostViewPostController.offset >=
            _scrollMostViewPostController.position.maxScrollExtent &&
        !_scrollMostViewPostController.position.outOfRange &&
        (latestFeedProvider.mostviewpostcurrentPage ?? 0) <
            (latestFeedProvider.mostviewposttotalPage ?? 0)) {
      await latestFeedProvider.setMostViewPostLoadMore(true);
      getMostViewPost(latestFeedProvider.mostviewpostcurrentPage ?? 0);
    }
  }

  _scrollGetPostByCategoryListener() async {
    if (!_scrollGetPostByCategoryController.hasClients) return;
    if (_scrollGetPostByCategoryController.offset >=
            _scrollGetPostByCategoryController.position.maxScrollExtent &&
        !_scrollGetPostByCategoryController.position.outOfRange &&
        (latestFeedProvider.postbycategorycurrentPage ?? 0) <
            (latestFeedProvider.postbycategorytotalPage ?? 0)) {
      await latestFeedProvider.setPostByCategoryLoadMore(true);
      getPostByCategory(
        latestFeedProvider.selectedCategoryIds.join(","),
        latestFeedProvider.postbycategorycurrentPage ?? 0,
      );
    }
  }

  _scrollCategoryListner() async {
    if (!_categoryScrollController.hasClients) return;
    if (_categoryScrollController.offset >=
            _categoryScrollController.position.maxScrollExtent &&
        !_categoryScrollController.position.outOfRange &&
        (latestFeedProvider.categorycurrentPage ?? 0) <
            (latestFeedProvider.categorytotalPage ?? 0)) {
      await latestFeedProvider.setCategoryLoadMore(true);
      _fetchCategory(latestFeedProvider.categorycurrentPage ?? 0);
    }
  }

  Future<void> getSubscribeChannelPost(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await latestFeedProvider.getSubscribeChannelPost((nextPage ?? 0) + 1);
    await latestFeedProvider.setSubscribePostLoadMore(false);
  }

  Future<void> getMostViewPost(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await latestFeedProvider.getMostViewPost((nextPage ?? 0) + 1);
    await latestFeedProvider.setMostViewPostLoadMore(false);
  }

  Future<void> getPostByCategory(categoryId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await latestFeedProvider.getPostByCategory(categoryId, (nextPage ?? 0) + 1);
    await latestFeedProvider.setPostByCategoryLoadMore(false);
  }

  Future<void> _fetchCategory(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await latestFeedProvider.getCategory((nextPage ?? 0) + 1);
    await latestFeedProvider.setCategoryLoadMore(false);
  }

  getGeneralSetting() async {
    await generalProvider.getWebGeneralsetting(context);
    PushNotificationService().requestNotificationPermission();
    if (!mounted) return;
    if (Constant.userID != null) {
      await profileProvider.getprofile(context, Constant.userID);
      await sharedPre.save(
        "userpanelstatus",
        profileProvider.profileModel.result?[0].userPenalStatus.toString() ??
            "",
      );
      Constant.userPanelStatus = await sharedPre.read("userpanelstatus");
      await Utils.getCustomAdsStatus();
    }
  }

  @override
  void dispose() {
    latestFeedProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: "feeds",
        categoryTap: () {
          categoryDialog(context: context);
        },
      ),
      body: Consumer<LatestFeedProvider>(
        builder: (context, latestfeedprovider, child) {
          return Utils.sidePanelWithBody(
            myWidget: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSubscribePost(title: "myteam"),
                  buildMostViewPost(title: "news"),
                  buildGetPostByCategory(title: "#"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /* ======================  SubscribePost ====================== */

  Widget buildSubscribePost({String? title}) {
    return Consumer<LatestFeedProvider>(
      builder: (context, latestfeedprovider, child) {
        if (latestFeedProvider.subscribeChannelPostLoading &&
            !latestFeedProvider.subscribeChannelPostLoadMore) {
          return shimmer();
        } else {
          if (latestFeedProvider.subscribeChannelPostList != null &&
              (latestFeedProvider.subscribeChannelPostList?.length ?? 0) > 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  titleWidget(title: title, multilanguage: true),
                  const SizedBox(height: 5),
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.width > 600
                            ? Dimens.feeditemHeightWeb
                            : Dimens.feeditemHeightMobile,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollSubscribePostController,
                      child: Row(
                        children: [
                          buildSubscribePostItem(),
                          const SizedBox(width: 10),
                          if (latestFeedProvider.subscribeChannelPostLoadMore)
                            shimmerLoadMore()
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget buildSubscribePostItem() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemCount: latestFeedProvider.subscribeChannelPostList?.length ?? 0,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) => WebFeedDetail(
                      userImage:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .profileImg
                              .toString() ??
                          "",
                      userName:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .fullName
                              .toString() ??
                          "",
                      postId:
                          latestFeedProvider.subscribeChannelPostList?[index].id
                              .toString() ??
                          "",
                      channelName:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .channelName
                              .toString() ??
                          "",
                    ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: InteractiveContainer(
            child: (isHovered) {
              return AnimatedScale(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 500),
                scale: isHovered ? 1.02 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MyNetworkImage(
                    width:
                        MediaQuery.of(context).size.width > 600
                            ? Dimens.feeditemWidthWeb
                            : Dimens.feeditemWidthMobile,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath:
                        latestFeedProvider
                                    .subscribeChannelPostList?[index]
                                    .postContent?[0]
                                    .contentType ==
                                1
                            ? (latestFeedProvider
                                    .subscribeChannelPostList?[index]
                                    .postContent?[0]
                                    .contentUrl
                                    .toString() ??
                                "")
                            : (latestFeedProvider
                                    .subscribeChannelPostList?[index]
                                    .postContent?[0]
                                    .thumbnailImage
                                    .toString() ??
                                ""),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /* ======================  SubscribePost ====================== */

  /* ======================  MostViewPost ====================== */

  Widget buildMostViewPost({String? title}) {
    return Consumer<LatestFeedProvider>(
      builder: (context, latestfeedprovider, child) {
        if (latestFeedProvider.mostviewpostLoading &&
            !latestFeedProvider.mostviewpostLoadMore) {
          return shimmer();
        } else {
          if (latestFeedProvider.mostViewPostList != null &&
              (latestFeedProvider.mostViewPostList?.length ?? 0) > 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  titleWidget(title: title, multilanguage: true),
                  const SizedBox(height: 5),
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.width > 600
                            ? Dimens.feeditemHeightWeb
                            : Dimens.feeditemHeightMobile,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollMostViewPostController,
                      child: Row(
                        children: [
                          buildMostViewPostItem(),
                          const SizedBox(width: 10),
                          if (latestFeedProvider.mostviewpostLoadMore)
                            shimmerLoadMore()
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget buildMostViewPostItem() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemCount: latestFeedProvider.mostViewPostList?.length ?? 0,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) => WebFeedDetail(
                      userImage:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .profileImg
                              .toString() ??
                          "",
                      userName:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .fullName
                              .toString() ??
                          "",
                      postId:
                          latestFeedProvider.subscribeChannelPostList?[index].id
                              .toString() ??
                          "",
                      channelName:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .channelName
                              .toString() ??
                          "",
                    ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: InteractiveContainer(
            child: (isHovered) {
              return AnimatedScale(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 500),
                scale: isHovered ? 1.02 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MyNetworkImage(
                    width:
                        MediaQuery.of(context).size.width > 600
                            ? Dimens.feeditemWidthWeb
                            : Dimens.feeditemWidthMobile,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath:
                        latestFeedProvider
                                    .mostViewPostList?[index]
                                    .postContent?[0]
                                    .contentType ==
                                1
                            ? (latestFeedProvider
                                    .mostViewPostList?[index]
                                    .postContent?[0]
                                    .contentUrl
                                    .toString() ??
                                "")
                            : (latestFeedProvider
                                    .mostViewPostList?[index]
                                    .postContent?[0]
                                    .thumbnailImage
                                    .toString() ??
                                ""),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /* ======================  MostViewPost ====================== */

  /* ======================  GetPostByCategory ====================== */

  Widget buildGetPostByCategory({String? title}) {
    return Consumer<LatestFeedProvider>(
      builder: (context, latestfeedprovider, child) {
        if (latestFeedProvider.postbycategoryLoading &&
            !latestFeedProvider.postbycategoryLoadMore) {
          return shimmer();
        } else {
          if (latestFeedProvider.postByCategoryList != null &&
              (latestFeedProvider.postByCategoryList?.length ?? 0) > 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  titleWidget(title: title, multilanguage: false),
                  const SizedBox(height: 5),
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.width > 600
                            ? Dimens.feeditemHeightWeb
                            : Dimens.feeditemHeightMobile,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollGetPostByCategoryController,
                      child: Row(
                        children: [
                          buildGetPostByCategoryItem(),
                          const SizedBox(width: 10),
                          if (latestFeedProvider.postbycategoryLoadMore)
                            shimmerLoadMore()
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget buildGetPostByCategoryItem() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemCount: latestFeedProvider.postByCategoryList?.length ?? 0,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) => WebFeedDetail(
                      userImage:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .profileImg
                              .toString() ??
                          "",
                      userName:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .fullName
                              .toString() ??
                          "",
                      postId:
                          latestFeedProvider.subscribeChannelPostList?[index].id
                              .toString() ??
                          "",
                      channelName:
                          latestFeedProvider
                              .subscribeChannelPostList?[index]
                              .channelName
                              .toString() ??
                          "",
                    ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: InteractiveContainer(
            child: (isHovered) {
              return AnimatedScale(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 500),
                scale: isHovered ? 1.02 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MyNetworkImage(
                    width:
                        MediaQuery.of(context).size.width > 600
                            ? Dimens.feeditemWidthWeb
                            : Dimens.feeditemWidthMobile,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath:
                        latestFeedProvider
                                    .postByCategoryList?[index]
                                    .postContent?[0]
                                    .contentType ==
                                1
                            ? (latestFeedProvider
                                    .postByCategoryList?[index]
                                    .postContent?[0]
                                    .contentUrl
                                    .toString() ??
                                "")
                            : (latestFeedProvider
                                    .postByCategoryList?[index]
                                    .postContent?[0]
                                    .thumbnailImage
                                    .toString() ??
                                ""),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /* ======================  GetPostByCategory ====================== */

  Widget shimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: CustomWidget.roundrectborder(height: 15, width: 200),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: 8,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return CustomWidget.roundrectborder(
                  width:
                      MediaQuery.of(context).size.width > 600
                          ? Dimens.feeditemWidthWeb
                          : Dimens.feeditemWidthMobile,
                  height: MediaQuery.of(context).size.height,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget shimmerLoadMore() {
    return Container(
      width:
          MediaQuery.of(context).size.width > 600
              ? Dimens.feeditemWidthWeb
              : Dimens.feeditemWidthMobile,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: colorPrimaryDark,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget titleWidget({String? title, bool? multilanguage}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: MyText(
        color: colorAccent,
        text: (title ?? ""),
        textalign: TextAlign.center,
        fontsizeNormal: Dimens.textlargeBig,
        fontsizeWeb: Dimens.textlargeBig,
        maxline: 1,
        multilanguage: multilanguage,
        fontwaight: FontWeight.w900,
        overflow: TextOverflow.ellipsis,
        fontstyle: FontStyle.italic,
      ),
    );
  }

  /* ====================== Category ====================== */

  categoryDialog({required BuildContext context}) async {
    _fetchCategory(0);
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
            constraints: BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: MediaQuery.of(context).size.width > 400 ? 450 : 500,
              maxHeight: MediaQuery.of(context).size.width > 400 ? 500 : 550,
            ),
            child: Column(
              children: [
                Expanded(child: categoryChipList()),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width > 400 ? 60 : 120,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child:
                      MediaQuery.of(context).size.width > 400
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
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
                                  Navigator.pop(context);
                                  latestFeedProvider.clearPostByCategory();
                                  getPostByCategory(
                                    latestFeedProvider.selectedCategoryIds.join(
                                      ",",
                                    ),
                                    0,
                                  );
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
                                    text: "submit",
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
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
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
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  latestFeedProvider.clearPostByCategory();
                                  getPostByCategory(
                                    latestFeedProvider.selectedCategoryIds.join(
                                      ",",
                                    ),
                                    0,
                                  );
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
                                    text: "submit",
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget categoryChipList() {
    return Consumer<LatestFeedProvider>(
      builder: (context, categoryProvider, child) {
        if (latestFeedProvider.categoryloading &&
            !latestFeedProvider.categoryloadMore) {
          return categoryShimmer();
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _categoryScrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: MyText(
                    color:
                        categoryProvider.selectedCategoryIds.contains(0)
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
                  selected: categoryProvider.selectedCategoryIds.contains(0),
                  showCheckmark: false,
                  side: BorderSide(
                    color:
                        categoryProvider.selectedCategoryIds.contains(0)
                            ? white
                            : colorAccent,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  surfaceTintColor: colorPrimary,
                  disabledColor: colorPrimary,
                  color: const WidgetStatePropertyAll(colorPrimary),
                  selectedColor: white,
                  backgroundColor: yellow,
                  onSelected: (_) {
                    categoryProvider.toggleCategory(0);
                  },
                ),
                const SizedBox(height: 50),
                (latestFeedProvider.categorydataList != null &&
                        (latestFeedProvider.categorydataList?.length ?? 0) > 0)
                    ? Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children:
                          latestFeedProvider.categorydataList!.map((category) {
                            final isSelected = categoryProvider
                                .selectedCategoryIds
                                .contains(category.id);

                            return ChoiceChip(
                              showCheckmark: false,
                              surfaceTintColor: colorPrimary,
                              disabledColor: colorPrimary,
                              label: MyText(
                                color: isSelected ? white : colorAccent,
                                text: category.name.toString().toUpperCase(),
                                fontwaight: FontWeight.w700,
                                fontsizeNormal: Dimens.textTitle,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.italic,
                              ),
                              side: BorderSide(
                                color: isSelected ? white : colorAccent,
                                width: 1,
                              ),
                              selected: isSelected,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              selectedColor: white,
                              backgroundColor: colorAccent,
                              color: const WidgetStatePropertyAll(colorPrimary),
                              elevation: 0,
                              pressElevation: 0,
                              autofocus: false,
                              onSelected: (bool selected) async {
                                categoryProvider.toggleCategory(
                                  category.id ?? 0,
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
        children: List.generate(
          latestFeedProvider.categorydataList?.length ?? 0,
          (index) {
            return const CustomWidget.roundrectborder(height: 40, width: 90);
          },
        ),
      ),
    );
  }

  /* ====================== Category ====================== */
}
