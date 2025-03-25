import 'package:flutter/services.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/subscribedchannelprovider.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:slike/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:slike/widget/nodata.dart';

class SubscribedChannel extends StatefulWidget {
  final String userId;
  const SubscribedChannel({super.key, required this.userId});

  @override
  State<SubscribedChannel> createState() => SubscribedChannelState();
}

class SubscribedChannelState extends State<SubscribedChannel> {
  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late SubscribedChannelProvider subscribedChannelProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    subscribedChannelProvider = Provider.of<SubscribedChannelProvider>(
      context,
      listen: false,
    );
    _scrollController.addListener(_scrollListenerCategory);
    super.initState();
    _fetchFollowingData(0);
  }

  /* Following List Scroll Pagination */
  _scrollListenerCategory() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (subscribedChannelProvider.selectedTab == "following") {
        if ((subscribedChannelProvider.subscribercurrentPage ?? 0) <
            (subscribedChannelProvider.subscribertotalPage ?? 0)) {}
        await subscribedChannelProvider.setFollowingLoadMore(true);
        _fetchFollowingData(
          subscribedChannelProvider.subscribercurrentPage ?? 0,
        );
      } else {
        if ((subscribedChannelProvider.followercurrentPage ?? 0) <
            (subscribedChannelProvider.followertotalPage ?? 0)) {}
        await subscribedChannelProvider.setFollowerLoadMore(true);
        _fetchFollowerData(subscribedChannelProvider.followercurrentPage ?? 0);
      }
    }
  }

  Future<void> _fetchFollowingData(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getFollowingList(
      widget.userId,
      (nextPage ?? 0) + 1,
    );
    await subscribedChannelProvider.setFollowingLoadMore(false);
  }

  Future<void> _fetchFollowerData(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getFollowerList(
      widget.userId,
      (nextPage ?? 0) + 1,
    );
    await subscribedChannelProvider.setFollowerLoadMore(false);
  }

  @override
  void dispose() {
    subscribedChannelProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      // appBar: Utils().otherPageAppBar(context, "subscriptions", true),
      appBar: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        elevation: 0,
        centerTitle: false,
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
            child: MyImage(
              width: 30,
              height: 30,
              imagePath: "ic_roundback.png",
            ),
          ),
        ),
        title: MyText(
          color: white,
          multilanguage: true,
          text: "subscriber",
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),

      body: Consumer<SubscribedChannelProvider>(
        builder: (context, channelprovider, child) {
          return Column(
            children: [
              buildTab(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(children: [buildTabItem()]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  buildTab() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              hoverColor: transparent,
              splashColor: transparent,
              highlightColor: transparent,
              focusColor: transparent,
              onTap: () async {
                await subscribedChannelProvider.selectTab("following");
                subscribedChannelProvider.clearFollowing();
                _fetchFollowingData(0);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: MyText(
                        fontsizeWeb: Dimens.textDesc,
                        color: white,
                        text: "following",
                        textalign: TextAlign.center,
                        multilanguage: true,
                        fontstyle: FontStyle.normal,
                        fontsizeNormal: Dimens.textDesc,
                        fontwaight: FontWeight.normal,
                      ),
                    ),
                  ),
                  subscribedChannelProvider.selectedTab == "following"
                      ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                        color: colorAccent,
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              hoverColor: transparent,
              splashColor: transparent,
              highlightColor: transparent,
              focusColor: transparent,
              onTap: () async {
                await subscribedChannelProvider.selectTab("follower");
                subscribedChannelProvider.clearFollower();
                _fetchFollowerData(0);
              },
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: MyText(
                          fontsizeWeb: Dimens.textDesc,
                          color: white,
                          text: "follower",
                          textalign: TextAlign.center,
                          multilanguage: true,
                          fontstyle: FontStyle.normal,
                          fontsizeNormal: Dimens.textDesc,
                          fontwaight: FontWeight.normal,
                        ),
                      ),
                    ),
                    subscribedChannelProvider.selectedTab == "follower"
                        ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: colorAccent,
                        )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildTabItem() {
    if (subscribedChannelProvider.selectedTab == "following") {
      return buildFollowing();
    } else {
      return buildFollower();
    }
  }

  /* Following List */

  Widget buildFollowing() {
    if (subscribedChannelProvider.subscriberLoading &&
        !subscribedChannelProvider.subscriberloadMore) {
      return Utils.pageLoader(context);
    } else {
      return Column(
        children: [
          buildFollowingItem(),
          if (subscribedChannelProvider.subscriberloadMore)
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
      );
    }
  }

  Widget buildFollowingItem() {
    if (subscribedChannelProvider.subscriberlistModel.status == 200 &&
        subscribedChannelProvider.subscriberList != null) {
      if ((subscribedChannelProvider.subscriberList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 1,
          maxItemsPerRow: 1,
          horizontalGridSpacing: 0,
          verticalGridSpacing: 0,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            subscribedChannelProvider.subscriberList?.length ?? 0,
            (index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Profile(
                          isBottomBar: false,
                          toUserId:
                              subscribedChannelProvider
                                  .subscriberList?[index]
                                  .id
                                  .toString() ??
                              "",
                          toChannelId:
                              subscribedChannelProvider
                                  .subscriberList?[index]
                                  .channelId
                                  .toString() ??
                              "",
                        );
                      },
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // color: colorPrimaryDark,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imagePath:
                                      subscribedChannelProvider
                                          .subscriberList?[index]
                                          .image ??
                                      "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  subscribedChannelProvider
                                              .subscriberList?[index]
                                              .fullName ==
                                          ""
                                      ? MyText(
                                        color: white,
                                        text:
                                            subscribedChannelProvider
                                                .subscriberList?[index]
                                                .channelName ??
                                            "",
                                        fontwaight: FontWeight.w500,
                                        fontsizeNormal: Dimens.textMedium,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal,
                                      )
                                      : MyText(
                                        color: white,
                                        text:
                                            subscribedChannelProvider
                                                .subscriberList?[index]
                                                .fullName ??
                                            "",
                                        fontwaight: FontWeight.w500,
                                        fontsizeNormal: Dimens.textMedium,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal,
                                      ),
                                  const SizedBox(height: 5),
                                  MyText(
                                    color: gray,
                                    text:
                                        subscribedChannelProvider
                                            .subscriberList?[index]
                                            .channelName ??
                                        "",
                                    fontwaight: FontWeight.w400,
                                    fontsizeNormal: Dimens.textSmall,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    textalign: TextAlign.center,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      index ==
                              ((subscribedChannelProvider
                                          .subscriberList
                                          ?.length ??
                                      0) -
                                  1)
                          ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: colorPrimaryDark,
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              );

              // InkWell(
              //   autofocus: false,
              //   highlightColor: transparent,
              //   focusColor: transparent,
              //   hoverColor: transparent,
              //   onTap: () async {},
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(5),
              //         margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(50),
              //             border: Border.all(width: 1, color: colorAccent)),
              //         child: ClipRRect(
              //           borderRadius: BorderRadius.circular(50),
              //           child: MyNetworkImage(
              //               width: 45,
              //               height: 45,
              //               imagePath: subscribedChannelProvider
              //                       .subscriberList?[index].image ??
              //                   "",
              //               fit: BoxFit.cover),
              //         ),
              //       ),
              //       const SizedBox(height: 10),
              //       MyText(
              //         color: white,
              //         text: subscribedChannelProvider
              //                 .subscriberList?[index].fullName ??
              //             "",
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
              // );
            },
          ),
        );
      } else {
        return const NoData();
      }
    } else {
      return const NoData();
    }
  }

  /* Follower List */
  Widget buildFollower() {
    if (subscribedChannelProvider.followerLoading &&
        !subscribedChannelProvider.followerloadMore) {
      return Utils.pageLoader(context);
    } else {
      return Column(
        children: [
          buildFollowerItem(),
          if (subscribedChannelProvider.followerloadMore)
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
      );
    }
  }

  Widget buildFollowerItem() {
    if (subscribedChannelProvider.followerModel.status == 200 &&
        subscribedChannelProvider.followerList != null) {
      if ((subscribedChannelProvider.followerList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 1,
          maxItemsPerRow: 1,
          horizontalGridSpacing: 0,
          verticalGridSpacing: 0,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            subscribedChannelProvider.followerList?.length ?? 0,
            (index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Profile(
                          isBottomBar: false,
                          toUserId:
                              subscribedChannelProvider.followerList?[index].id
                                  .toString() ??
                              "",
                          toChannelId:
                              subscribedChannelProvider
                                  .followerList?[index]
                                  .channelId
                                  .toString() ??
                              "",
                        );
                      },
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // color: colorPrimaryDark,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imagePath:
                                      subscribedChannelProvider
                                          .followerList?[index]
                                          .image ??
                                      "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  subscribedChannelProvider
                                              .followerList?[index]
                                              .fullName ==
                                          ""
                                      ? MyText(
                                        color: white,
                                        text:
                                            subscribedChannelProvider
                                                .followerList?[index]
                                                .channelName ??
                                            "",
                                        fontwaight: FontWeight.w500,
                                        fontsizeNormal: Dimens.textMedium,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal,
                                      )
                                      : MyText(
                                        color: white,
                                        text:
                                            subscribedChannelProvider
                                                .followerList?[index]
                                                .fullName ??
                                            "",
                                        fontwaight: FontWeight.w500,
                                        fontsizeNormal: Dimens.textMedium,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal,
                                      ),
                                  const SizedBox(height: 5),
                                  MyText(
                                    color: gray,
                                    text:
                                        subscribedChannelProvider
                                            .followerList?[index]
                                            .channelName ??
                                        "",
                                    fontwaight: FontWeight.w400,
                                    fontsizeNormal: Dimens.textSmall,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    textalign: TextAlign.center,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      index ==
                              ((subscribedChannelProvider
                                          .followerList
                                          ?.length ??
                                      0) -
                                  1)
                          ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: colorPrimaryDark,
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return const NoData();
      }
    } else {
      return const NoData();
    }
  }
}
