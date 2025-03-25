import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/inbox.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/search.dart';
import 'package:slike/pages/setting.dart';
import 'package:slike/provider/latestfeedprovider.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'feed_detail_with_scrolling/feed_detail_with_single_scrolling.dart';
import 'package:slike/model/subscribechannelpostmodel.dart' as mostviewpost;

class LatestFeed extends StatefulWidget {
  const LatestFeed({super.key});

  @override
  State<LatestFeed> createState() => LatestFeedState();
}

class LatestFeedState extends State<LatestFeed> {
  late LatestFeedProvider latestFeedProvider;
  late ScrollController _scrollSubscribePostController;
  late ScrollController _scrollMostViewPostController;
  late ScrollController _scrollGetPostByCategoryController;
  late ScrollController _categoryScrollController;
  final TextEditingController commentController = TextEditingController();
  String tempImg = "";
  io.Socket? socket;

  @override
  void initState() {
    latestFeedProvider = Provider.of<LatestFeedProvider>(
      context,
      listen: false,
    );
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

  @override
  void dispose() {
    latestFeedProvider.clearProvider();
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
        title: Container(
          // color: colorPrimaryDark,
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyImage(
                width: 110,
                height: 45,
                imagePath: "appicon.png",
                fit: BoxFit.cover,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
              ),
            ],
          ),
        ),
      ),
      body: Consumer<LatestFeedProvider>(
        builder: (context, latestfeedprovider, child) {
          return RefreshIndicator(
            backgroundColor: colorPrimaryDark,
            color: colorAccent,
            displacement: 70,
            edgeOffset: 1.0,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            strokeWidth: 3,
            onRefresh: () async {
              await latestFeedProvider.clearProvider();
              getApi();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
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
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  titleWidget(title: title, multilanguage: true),
                  // const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
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
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemCount: latestFeedProvider.subscribeChannelPostList?.length ?? 0,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        print(
          'latestFeedProvider.subscribeChannelPostList?.length} ================>${latestFeedProvider.subscribeChannelPostList?.length}',
        );
        final tappedPost = latestFeedProvider.subscribeChannelPostList?[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () async {
            if (tappedPost != null) {
              final tappedUserId = tappedPost.userId;

              List<mostviewpost.Result>? postDetailsList =
                  latestFeedProvider.subscribeChannelPostList
                      ?.fold<Map<int?, mostviewpost.Result>>({}, (
                        map,
                        element,
                      ) {
                        // If element's userId matches the tappedUserId, replace with the tappedPost
                        if (element.userId == tappedUserId) {
                          map[element.userId] = tappedPost;
                        } else {
                          map[element.userId] = element;
                        }
                        return map;
                      })
                      .values
                      .toList();

              if (postDetailsList != null) {
                final existingIndex = postDetailsList.indexWhere(
                  (post) => post.userId == tappedPost.userId,
                );

                if (existingIndex != -1) {
                  postDetailsList.removeAt(existingIndex);
                }

                postDetailsList.insert(0, tappedPost);
              }

              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation1, animation2) =>
                          FeedDetailWithSingleScrolling(data: postDetailsList),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MyNetworkImage(
              width: 120,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              imagePath:
                  (latestFeedProvider.subscribeChannelPostList?.isNotEmpty ??
                              false) &&
                          (latestFeedProvider
                                  .subscribeChannelPostList?[index]
                                  .postContent
                                  ?.isNotEmpty ??
                              false)
                      ? (latestFeedProvider
                                  .subscribeChannelPostList?[index]
                                  .postContent
                                  ?.first
                                  .contentType ==
                              1
                          ? (latestFeedProvider
                                  .subscribeChannelPostList?[index]
                                  .postContent
                                  ?.first
                                  .contentUrl
                                  .toString() ??
                              "")
                          : (latestFeedProvider
                                  .subscribeChannelPostList?[index]
                                  .postContent
                                  ?.first
                                  .thumbnailImage
                                  .toString() ??
                              ""))
                      : "", // You can add a default value or empty string when data is invalid
            ),
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
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  titleWidget(title: title, multilanguage: true),
                  // const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
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
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemCount: latestFeedProvider.mostViewPostList?.length ?? 0,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final tappedPost = latestFeedProvider.mostViewPostList?[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () async {
            if (tappedPost != null) {
              final tappedUserId = tappedPost.userId;

              List<mostviewpost.Result>? postDetailsList =
                  latestFeedProvider.mostViewPostList
                      ?.fold<Map<int?, mostviewpost.Result>>({}, (
                        map,
                        element,
                      ) {
                        // If element's userId matches the tappedUserId, replace with the tappedPost
                        if (element.userId == tappedUserId) {
                          map[element.userId] = tappedPost;
                        } else {
                          map[element.userId] = element;
                        }
                        return map;
                      })
                      .values
                      .toList();

              if (postDetailsList != null) {
                final existingIndex = postDetailsList.indexWhere(
                  (post) => post.userId == tappedPost.userId,
                );

                if (existingIndex != -1) {
                  postDetailsList.removeAt(existingIndex);
                }

                postDetailsList.insert(0, tappedPost);
              }

              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation1, animation2) =>
                          FeedDetailWithSingleScrolling(data: postDetailsList),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MyNetworkImage(
              width: 120,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              imagePath:
                  (latestFeedProvider.mostViewPostList?.isNotEmpty ?? false) &&
                          (latestFeedProvider
                                  .mostViewPostList?[index]
                                  .postContent
                                  ?.isNotEmpty ??
                              false)
                      ? (latestFeedProvider
                                  .mostViewPostList?[index]
                                  .postContent
                                  ?.first
                                  .contentType ==
                              1
                          ? (latestFeedProvider
                                  .mostViewPostList?[index]
                                  .postContent
                                  ?.first
                                  .contentUrl
                                  ?.toString() ??
                              "")
                          : (latestFeedProvider
                                  .mostViewPostList?[index]
                                  .postContent
                                  ?.first
                                  .thumbnailImage
                                  ?.toString() ??
                              ""))
                      : "", // Provide fallback (empty string or default image)
            ),
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
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  titleWidget(title: title, multilanguage: false),
                  // const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
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
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemCount: latestFeedProvider.postByCategoryList?.length ?? 0,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final tappedPost = latestFeedProvider.postByCategoryList?[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () async {
            if (tappedPost != null) {
              final tappedUserId = tappedPost.userId;

              List<mostviewpost.Result>? postDetailsList =
                  latestFeedProvider.postByCategoryList
                      ?.fold<Map<int?, mostviewpost.Result>>({}, (
                        map,
                        element,
                      ) {
                        // If element's userId matches the tappedUserId, replace with the tappedPost
                        if (element.userId == tappedUserId) {
                          map[element.userId] = tappedPost;
                        } else {
                          map[element.userId] = element;
                        }
                        return map;
                      })
                      .values
                      .toList();

              if (postDetailsList != null) {
                final existingIndex = postDetailsList.indexWhere(
                  (post) => post.userId == tappedPost.userId,
                );

                if (existingIndex != -1) {
                  postDetailsList.removeAt(existingIndex);
                }

                postDetailsList.insert(0, tappedPost);
              }

              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation1, animation2) =>
                          FeedDetailWithSingleScrolling(data: postDetailsList),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MyNetworkImage(
              width: 120,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              imagePath:
                  (latestFeedProvider.postByCategoryList?.isNotEmpty ??
                              false) &&
                          (latestFeedProvider
                                  .postByCategoryList?[index]
                                  .postContent
                                  ?.isNotEmpty ??
                              false)
                      ? (latestFeedProvider
                                  .postByCategoryList?[index]
                                  .postContent
                                  ?.first
                                  .contentType ==
                              1
                          ? (latestFeedProvider
                                  .postByCategoryList?[index]
                                  .postContent
                                  ?.first
                                  .contentUrl
                                  ?.toString() ??
                              "")
                          : (latestFeedProvider
                                  .postByCategoryList?[index]
                                  .postContent
                                  ?.first
                                  .thumbnailImage
                                  ?.toString() ??
                              ""))
                      : "", // Use an empty string or default image if data is invalid
            ),
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
              itemCount: 4,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return CustomWidget.roundrectborder(
                  width: 120,
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
      width: 120,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: colorPrimaryDark,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget titleWidget({String? title, bool? multilanguage}) {
    // Stack(
    //   children: [
    //     Text(
    //       (title?.toUpperCase() ?? ""),
    //       style: TextStyle(
    //         fontSize: Dimens.textExtraBig,
    //         fontStyle: FontStyle.italic,
    //         letterSpacing: 3,
    //         foreground: Paint()
    //           ..style = PaintingStyle.stroke
    //           ..strokeWidth = 6
    //           ..color = white,
    //       ),
    //     ),
    //     Text(
    //       (title?.toUpperCase() ?? ""),
    //       style: TextStyle(
    //         fontStyle: FontStyle.italic,
    //         letterSpacing: 3,
    //         fontSize: Dimens.textExtraBig,
    //         foreground: Paint()
    //           ..style = PaintingStyle.stroke
    //           ..strokeWidth = 1
    //           ..color = colorAccent,
    //       ),
    //     ),
    //   ],
    // ),
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: MyText(
        color: colorAccent,
        text: (title ?? ""),
        textalign: TextAlign.center,
        fontsizeNormal: Dimens.textlargeBig,
        maxline: 1,
        multilanguage: multilanguage,
        fontwaight: FontWeight.w900,
        overflow: TextOverflow.ellipsis,
        fontstyle: FontStyle.italic,
      ),
    );
  }

  /* ====================== Category ====================== */

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
            child: Column(
              children: [
                Expanded(child: categoryChipList()),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Row(
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
                            latestFeedProvider.selectedCategoryIds.join(","),
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
        children: List.generate(18, (index) {
          return const CustomWidget.roundrectborder(height: 40, width: 90);
        }),
      ),
    );
  }

  /* ====================== Category ====================== */
}
