import 'dart:developer';
import 'dart:io';
import 'package:slike/pages/login.dart';
import 'package:slike/provider/homeprovider.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/widget/musictitle.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/customappbar.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late HomeProvider homeProvider;
  int checkboxIndex = 0;
  final playlistTitleController = TextEditingController();
  final ScrollController categoryController = ScrollController();
  ScrollController videoscrollController = ScrollController();
  late ScrollController reportReasonController;
  late ScrollController playlistController;

  @override
  void initState() {
    reportReasonController = ScrollController();
    playlistController = ScrollController();
    categoryController.addListener(_scrollListenerCategory);
    videoscrollController.addListener(_scrollListenerVideo);
    reportReasonController.addListener(_scrollListenerReportReason);
    playlistController.addListener(_scrollListenerPlaylist);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
  }

  /* Category Scroll Pagination */
  _scrollListenerCategory() async {
    if (!categoryController.hasClients) return;
    if (categoryController.offset >=
            categoryController.position.maxScrollExtent &&
        !categoryController.position.outOfRange &&
        (homeProvider.categorycurrentPage ?? 0) <
            (homeProvider.categorytotalPage ?? 0)) {
      printLog("load more====>");
      await homeProvider.setCategoryLoadMore(true);
      _fetchDataCategory(homeProvider.categorycurrentPage ?? 0);
    }
  }

  /* Video Scroll Pagination  */
  _scrollListenerVideo() async {
    if (!videoscrollController.hasClients) return;
    if (videoscrollController.offset >=
            videoscrollController.position.maxScrollExtent &&
        !videoscrollController.position.outOfRange &&
        (homeProvider.videolistcurrentPage ?? 0) <
            (homeProvider.videolisttotalPage ?? 0)) {
      printLog("load more====>");
      await homeProvider.setVideoListLoadMore(true);
      if (homeProvider.catindex == 0) {
        _fetchDataVideo(
          "1",
          homeProvider.categoryid,
          homeProvider.videolistcurrentPage ?? 0,
        );
      } else {
        _fetchDataVideo(
          "",
          homeProvider.categoryid,
          homeProvider.videolistcurrentPage ?? 0,
        );
      }
    }
  }

  /* Report Reason Pagination */
  _scrollListenerReportReason() async {
    if (!reportReasonController.hasClients) return;
    if (reportReasonController.offset >=
            reportReasonController.position.maxScrollExtent &&
        !reportReasonController.position.outOfRange &&
        (homeProvider.reportcurrentPage ?? 0) <
            (homeProvider.reporttotalPage ?? 0)) {
      await homeProvider.setReportReasonLoadMore(true);
      _fetchReportReason(homeProvider.reportcurrentPage ?? 0);
    }
  }

  /* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (homeProvider.playlistcurrentPage ?? 0) <
            (homeProvider.playlisttotalPage ?? 0)) {
      await homeProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(homeProvider.playlistcurrentPage ?? 0);
    }
  }

  /* First Time Open Page Call This Method */
  getApi() async {
    await homeProvider.setLoading(true);
    await _fetchDataCategory(0);
    await _fetchDataVideo("1", "0", 0);
    await homeProvider.setLoading(false);
  }

  /* Category Api  */
  Future<void> _fetchDataCategory(int? nextPage) async {
    printLog("isMorePage  ======> ${homeProvider.categoryisMorePage}");
    printLog("currentPage ======> ${homeProvider.categorycurrentPage}");
    printLog("totalPage   ======> ${homeProvider.categorytotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await homeProvider.getVideoCategory((nextPage ?? 0) + 1);
  }

  /* Video Api  */
  Future<void> _fetchDataVideo(ishomepage, categoryid, int? nextPage) async {
    printLog("isMorePage  ======> ${homeProvider.videolistisMorePage}");
    printLog("currentPage ======> ${homeProvider.videolistcurrentPage}");
    printLog("totalPage   ======> ${homeProvider.videolisttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await homeProvider.getvideolist(
      ishomepage,
      categoryid,
      (nextPage ?? 0) + 1,
    );
  }

  /* Report Reason Api */
  Future _fetchReportReason(int? nextPage) async {
    printLog("reportmorePage  =======> ${homeProvider.reportmorePage}");
    printLog("reportcurrentPage =======> ${homeProvider.reportcurrentPage}");
    printLog("reporttotalPage   =======> ${homeProvider.reporttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await homeProvider.getReportReason("2", (nextPage ?? 0) + 1);
    printLog(
      "fetchReportReason length ==> ${homeProvider.reportReasonList?.length}",
    );
  }

  /* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    printLog("playlistmorePage  =======> ${homeProvider.playlistmorePage}");
    printLog(
      "playlistcurrentPage =======> ${homeProvider.playlistcurrentPage}",
    );
    printLog("playlisttotalPage   =======> ${homeProvider.playlisttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await homeProvider.getcontentbyChannel(
      Constant.userID,
      Constant.channelID,
      "5",
      (nextPage ?? 0) + 1,
    );
    printLog("fetchPlaylist length ==> ${homeProvider.playlistData?.length}");
  }

  @override
  void dispose() {
    homeProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: const CustomAppBar(contentType: "1", isSearch: true),
      body: Column(
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
                await homeProvider.clearProvider();
                getApi();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: videoscrollController,
                child: buildVideo(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategory() {
    return Consumer<HomeProvider>(
      builder: (context, categoryprovider, child) {
        if (categoryprovider.categoryloading &&
            !categoryprovider.categoryloadMore) {
          return categoryShimmer();
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            controller: categoryController,
            child: Row(
              children: [
                videocategoryList(),
                if (homeProvider.categoryloadMore)
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
      },
    );
  }

  Widget videocategoryList() {
    if (homeProvider.categorymodel.status == 200 &&
        homeProvider.categorydataList != null) {
      if ((homeProvider.categorydataList?.length ?? 0) > 0) {
        return SizedBox(
          height: 70,
          child: ListView.builder(
            itemCount: homeProvider.categorydataList?.length ?? 0,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                autofocus: false,
                highlightColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                onTap: () async {
                  homeProvider.selectCategory(
                    index,
                    homeProvider.categorydataList?[index].id.toString(),
                  );
                  await homeProvider.setVideoLoading(true);
                  if (index == 0) {
                    _fetchDataVideo("1", "0", 0);
                    homeProvider.clearVideoListData();
                  } else {
                    _fetchDataVideo(
                      "0",
                      homeProvider.categorydataList?[index].id.toString(),
                      0,
                    );
                    homeProvider.clearVideoListData();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        homeProvider.catindex == index
                            ? colorAccent
                            : colorPrimary,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: colorAccent, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText(
                        color: homeProvider.catindex == index ? black : white,
                        text: homeProvider.categorydataList?[index].name ?? "",
                        fontwaight: FontWeight.w500,
                        fontsizeNormal: Dimens.textSmall,
                        maxline: 1,
                        multilanguage: false,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ),
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

  Widget buildVideo() {
    return Consumer<HomeProvider>(
      builder: (context, videolistprovider, child) {
        if (videolistprovider.videoloading &&
            !videolistprovider.videoloadMore) {
          return allVideoShimmer();
        } else {
          return Column(
            children: [
              allVideo(),
              if (homeProvider.videoloadMore)
                SizedBox(height: 50, child: Utils.pageLoader(context))
              else
                const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }

  Widget allVideo() {
    if (homeProvider.videolistmodel.status == 200 &&
        homeProvider.videoList != null) {
      if ((homeProvider.videoList?.length ?? 0) > 0) {
        return ListView.builder(
          itemCount: homeProvider.videoList?.length ?? 0,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              highlightColor: transparent,
              focusColor: transparent,
              hoverColor: transparent,
              splashColor: transparent,
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
                  Utils.moveToDetail(
                    context,
                    0,
                    false,
                    homeProvider.videoList?[index].id.toString() ?? "",
                  );
                }
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        height: 220,
                        imagePath:
                            homeProvider.videoList?[index].landscapeImg
                                .toString() ??
                            "",
                      ),
                      Positioned.fill(
                        right: 15,
                        bottom: 15,
                        left: 15,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                            decoration: BoxDecoration(
                              color: transparent.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: MusicTitle(
                              color: white,
                              text: Utils.formatTime(
                                double.parse(
                                  homeProvider.videoList?[index].contentDuration
                                          .toString() ??
                                      "",
                                ),
                              ),
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textSmall,
                              multilanguage: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            width: 35,
                            height: 35,
                            imagePath:
                                homeProvider.videoList?[index].portraitImg
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text:
                                    homeProvider.videoList?[index].title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                maxline: 2,
                                multilanguage: false,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  text:
                                      homeProvider
                                                  .videoList?[index]
                                                  .isAdminAdded ==
                                              0
                                          ? ""
                                          : "${homeProvider.videoList?[index].channelName.toString() ?? ""}  ",
                                  style: Utils.googleFontStyle(
                                    4,
                                    Dimens.textSmall,
                                    FontStyle.normal,
                                    gray,
                                    FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          "${Utils.kmbGenerator(homeProvider.videoList?[index].totalView ?? 0)} ",
                                      style: Utils.googleFontStyle(
                                        4,
                                        Dimens.textSmall,
                                        FontStyle.normal,
                                        gray,
                                        FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'views ',
                                      style: Utils.googleFontStyle(
                                        4,
                                        Dimens.textSmall,
                                        FontStyle.normal,
                                        gray,
                                        FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: Utils.timeAgoCustom(
                                        DateTime.parse(
                                          homeProvider
                                                  .videoList?[index]
                                                  .createdAt ??
                                              "",
                                        ),
                                      ),
                                      style: Utils.googleFontStyle(
                                        4,
                                        Dimens.textSmall,
                                        FontStyle.normal,
                                        gray,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          highlightColor: transparent,
                          focusColor: transparent,
                          hoverColor: transparent,
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
                                homeProvider.videoList?[index].userId
                                        .toString() ??
                                    "",
                                homeProvider.videoList?[index].id.toString() ??
                                    "",
                                index,
                                homeProvider.videoList?[index].title
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: const Icon(
                            Icons.more_vert_outlined,
                            color: white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        return const NoData(
          title: "nodatavideotitle",
          subTitle: "nodatavideosubtitle",
        );
      }
    } else {
      return const NoData(
        title: "nodatavideotitle",
        subTitle: "nodatavideosubtitle",
      );
    }
  }

  Widget allVideoShimmer() {
    return ListView.builder(
      itemCount: 10,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            CustomWidget.rectangular(
              width: MediaQuery.of(context).size.width,
              height: 260,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomWidget.circular(width: 35, height: 35),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(width: 250, height: 9),
                        CustomWidget.roundrectborder(width: 250, height: 7),
                        CustomWidget.roundrectborder(width: 250, height: 7),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  CustomWidget.roundrectborder(width: 5, height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /* More Item Bottom Sheet */

  moreBottomSheet(reportUserid, contentid, position, contentName) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  moreFunctionItem(
                    "ic_watchlater.png",
                    "savetowatchlater",
                    () async {
                      await homeProvider.addremoveWatchLater(
                        "1",
                        contentid,
                        "0",
                        "1",
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      Utils.showSnackbar(context, "savetowatchlater", true);
                    },
                  ),
                  moreFunctionItem(
                    "ic_playlisttitle.png",
                    "savetoplaylist",
                    () async {
                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      selectPlaylistBottomSheet(position, contentid);
                      _fetchPlaylist(0);
                    },
                  ),
                  moreFunctionItem("ic_share.png", "share", () {
                    if (!mounted) return;
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Utils.shareApp(
                      Platform.isIOS
                          ? "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                    );
                  }),
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
          ),
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
                          homeProvider.reportReasonList?.clear();
                          homeProvider.position = 0;
                          homeProvider.clearSelectReportReason();
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
                          if (homeProvider.reasonId == "" ||
                              homeProvider.reasonId.isEmpty) {
                            Utils.showSnackbar(
                              context,
                              "pleaseselectyourreportreason",
                              true,
                            );
                          } else {
                            await homeProvider.addContentReport(
                              reportUserid,
                              contentid,
                              homeProvider
                                      .reportReasonList?[homeProvider
                                              .reportPosition ??
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
                              "reportaddsuccsessfully",
                              true,
                            );
                            homeProvider.clearSelectReportReason();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: MyText(
                            color: black,
                            text: "report",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textTitle,
                            multilanguage: true,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w600,
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
    return Consumer<HomeProvider>(
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
    log("report List Lenght==>${homeProvider.reportReasonList?.length ?? 0}");
    if (homeProvider.getRepostReasonModel.status == 200 &&
        homeProvider.reportReasonList != null) {
      if ((homeProvider.reportReasonList?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: homeProvider.reportReasonList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                homeProvider.selectReportReason(
                  index,
                  true,
                  homeProvider.reportReasonList?[index].id.toString() ?? "",
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                color:
                    homeProvider.reportPosition == index &&
                            homeProvider.isSelectReason == true
                        ? colorAccent
                        : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color:
                          homeProvider.reportPosition == index &&
                                  homeProvider.isSelectReason == true
                              ? black
                              : white,
                      text: "${(index + 1).toString()}.",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
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
                        color:
                            homeProvider.reportPosition == index &&
                                    homeProvider.isSelectReason == true
                                ? black
                                : white,
                        text:
                            homeProvider.reportReasonList?[index].reason
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        multilanguage: false,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(width: 20),
                    homeProvider.reportPosition == index &&
                            homeProvider.isSelectReason == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        printLog("null Array");
        return const NoData(
          title: "nodatavideotitle",
          subTitle: "nodatavideosubtitle",
        );
      }
    } else {
      printLog("null Array Last");
      return const NoData(
        title: "nodatavideotitle",
        subTitle: "nodatavideosubtitle",
      );
    }
  }

  /* Playlist Bottom Sheet */
  selectPlaylistBottomSheet(position, contentid) {
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          color: white,
                          text: "selectplaylist",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          multilanguage: true,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        InkWell(
                          onTap: () async {
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            createPlaylistDilog(
                              playlistId: homeProvider.playlistId,
                            );
                          },
                          child: Container(
                            width: 160,
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorAccent),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: white, size: 22),
                                const SizedBox(width: 5),
                                MyText(
                                  color: white,
                                  text: "createplaylist",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textDesc,
                                  multilanguage: true,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w500,
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
                  const SizedBox(height: 10),
                  Expanded(child: buildPlayList()),
                  Consumer<HomeProvider>(
                    builder: (context, playlistprovider, child) {
                      if (playlistprovider.playlistLoading &&
                          !playlistprovider.playlistLoadmore) {
                        return const SizedBox.shrink();
                      } else {
                        if (homeProvider.getContentbyChannelModel.status ==
                                200 &&
                            homeProvider.playlistData != null) {
                          if ((homeProvider.playlistData?.length ?? 0) > 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    playlistprovider.clearPlaylistData();
                                    if (!mounted) return;
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      15,
                                      10,
                                      15,
                                      10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        width: 1,
                                        color: white,
                                      ),
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
                                    if (!mounted) return;
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                    if (homeProvider.playlistId.isEmpty ||
                                        homeProvider.playlistId == "") {
                                      Utils.showSnackbar(
                                        context,
                                        "pleaseelectyourplaylist",
                                        true,
                                      );
                                    } else {
                                      await homeProvider
                                          .addremoveContentToPlaylist(
                                            Constant.channelID,
                                            homeProvider
                                                    .getContentbyChannelModel
                                                    .result?[homeProvider
                                                            .playlistPosition ??
                                                        0]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "1",
                                            contentid,
                                            "0",
                                            "1",
                                          );

                                      if (!homeProvider
                                          .addremovecontentplaylistloading) {
                                        if (homeProvider
                                                .addremoveContentToPlaylistModel
                                                .status ==
                                            200) {
                                          printLog("Added Succsessfully");
                                          Utils().showToast("Save to Playlist");
                                        } else {
                                          Utils().showToast(
                                            "${homeProvider.addremoveContentToPlaylistModel.message}",
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      15,
                                      10,
                                      15,
                                      10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorAccent,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: MyText(
                                      color: black,
                                      text: "addcontent",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      multilanguage: true,
                                      inter: false,
                                      maxline: 2,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        } else {
                          return const SizedBox.shrink();
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildPlayList() {
    return Consumer<HomeProvider>(
      builder: (context, playlistprovider, child) {
        if (playlistprovider.playlistLoading &&
            !playlistprovider.playlistLoadmore) {
          return Utils.pageLoader(context);
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: playlistController,
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                buildPlaylistItem(),
                if (playlistprovider.playlistLoadmore)
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

  Widget buildPlaylistItem() {
    if (homeProvider.getContentbyChannelModel.status == 200 &&
        homeProvider.playlistData != null) {
      if ((homeProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: homeProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                homeProvider.selectPlaylist(
                  index,
                  homeProvider.playlistData?[index].id.toString() ?? "",
                  true,
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color:
                    homeProvider.playlistPosition == index &&
                            homeProvider.isSelectPlaylist == true
                        ? colorAccent
                        : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color:
                          homeProvider.playlistPosition == index &&
                                  homeProvider.isSelectPlaylist == true
                              ? black
                              : white,
                      text: "${(index + 1).toString()}.",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
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
                        color:
                            homeProvider.playlistPosition == index &&
                                    homeProvider.isSelectPlaylist == true
                                ? black
                                : white,
                        text:
                            homeProvider.playlistData?[index].title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        multilanguage: false,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(width: 20),
                    homeProvider.playlistPosition == index &&
                            homeProvider.isSelectPlaylist == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const NoData(
          title: "noplaylistfound",
          subTitle: "createnewplaylist",
        );
      }
    } else {
      return const NoData(
        title: "noplaylistfound",
        subTitle: "createnewplaylist",
      );
    }
  }

  /* Create Playlist Bottom Sheet */
  createPlaylistDilog({playlistId}) {
    printLog("playlistId==> $playlistId");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorAccent.withOpacity(0.10),
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer<HomeProvider>(
              builder: (context, createplaylistprovider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color: white,
                      multilanguage: true,
                      text: "newplaylist",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textExtraBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      cursorColor: white,
                      controller: playlistTitleController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      style: Utils.googleFontStyle(
                        1,
                        Dimens.textBig,
                        FontStyle.normal,
                        white,
                        FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Give your playlist a title",
                        hintStyle: Utils.googleFontStyle(
                          1,
                          Dimens.textBig,
                          FontStyle.normal,
                          gray,
                          FontWeight.w500,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: gray),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: gray),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        MyText(
                          color: white,
                          multilanguage: true,
                          text: "privacy",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          color: white,
                          multilanguage: false,
                          text: ":",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            createplaylistprovider.selectPrivacy(type: 1);
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color:
                                  createplaylistprovider.isType == 1
                                      ? colorAccent
                                      : transparent,
                              border: Border.all(
                                width: 2,
                                color:
                                    createplaylistprovider.isType == 1
                                        ? colorAccent
                                        : white,
                              ),
                            ),
                            child:
                                createplaylistprovider.isType == 1
                                    ? const Icon(
                                      Icons.check,
                                      color: black,
                                      size: 15,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        MyText(
                          color: white,
                          multilanguage: true,
                          text: "public",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            createplaylistprovider.selectPrivacy(type: 2);
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color:
                                  createplaylistprovider.isType == 2
                                      ? colorAccent
                                      : transparent,
                              border: Border.all(
                                width: 2,
                                color:
                                    createplaylistprovider.isType == 2
                                        ? colorAccent
                                        : white,
                              ),
                            ),
                            child:
                                createplaylistprovider.isType == 2
                                    ? const Icon(
                                      Icons.check,
                                      color: black,
                                      size: 15,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        MyText(
                          color: white,
                          multilanguage: true,
                          text: "private",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          radius: 50,
                          autofocus: false,
                          onTap: () {
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            playlistTitleController.clear();
                            homeProvider.isType = 0;
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorPrimaryDark,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAccent.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5, //New
                                ),
                              ],
                            ),
                            child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        InkWell(
                          onTap: () async {
                            if (playlistTitleController.text.isEmpty) {
                              Utils.showSnackbar(
                                context,
                                "pleaseenterplaylistname",
                                true,
                              );
                            } else if (createplaylistprovider.isType == 0) {
                              Utils.showSnackbar(
                                context,
                                "pleaseselectplaylisttype",
                                true,
                              );
                            } else {
                              await createplaylistprovider.getcreatePlayList(
                                Constant.channelID,
                                playlistTitleController.text,
                                homeProvider.isType.toString(),
                              );
                              if (!createplaylistprovider.loading) {
                                if (createplaylistprovider
                                        .createPlaylistModel
                                        .status ==
                                    200) {
                                  if (!context.mounted) return;
                                  Utils.showSnackbar(
                                    context,
                                    "${createplaylistprovider.createPlaylistModel.message}",
                                    false,
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  Utils.showSnackbar(
                                    context,
                                    "${createplaylistprovider.createPlaylistModel.message}",
                                    false,
                                  );
                                }
                              }
                              if (!context.mounted) return;
                              if (!mounted) return;
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              playlistTitleController.clear();
                              homeProvider.isType = 0;
                              // _fetchPlaylist(0);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorAccent,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAccent.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5, //New
                                ),
                              ],
                            ),
                            child: MyText(
                              color: black,
                              multilanguage: true,
                              text: "create",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
