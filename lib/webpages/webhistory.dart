import 'package:slike/provider/historyprovider.dart';
import 'package:slike/provider/musicdetailprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customads.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/musicmanager.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/webdetail.dart';
import 'package:slike/webpages/weblogin.dart';
import 'package:slike/webwidget/interactivecontainer.dart';
import 'package:slike/widget/musictitle.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebHistory extends StatefulWidget {
  const WebHistory({super.key});

  @override
  State<WebHistory> createState() => WebHistoryState();
}

class WebHistoryState extends State<WebHistory> {
  final MusicManager musicManager = MusicManager();
  late HistoryProvider historyProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    _fetchData("1", 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (historyProvider.currentPage ?? 0) < (historyProvider.totalPage ?? 0)) {
      printLog("load more====>");
      _fetchData("1", historyProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    printLog("isMorePage  ======> ${historyProvider.isMorePage}");
    printLog("currentPage ======> ${historyProvider.currentPage}");
    printLog("totalPage   ======> ${historyProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await historyProvider.getHistory(contentType, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    historyProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: Constant.videoSearch,
      ),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(0, 15, 20, 190),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MusicTitle(
                color: white,
                text: "history",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textExtraBig,
                fontsizeWeb: Dimens.textExtraBig,
                multilanguage: true,
                maxline: 1,
                fontwaight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(height: 30),
              tabButton(),
              const SizedBox(height: 20),
              buildPage(),
            ],
          ),
        ),
      ),
    );
  }

  /* Tab  */
  tabButton() {
    return Consumer<HistoryProvider>(
      builder: (context, historyprovider, child) {
        return SizedBox(
          height: 100,
          child: ListView.builder(
            itemCount: Constant.historyTabList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: colorPrimary,
                highlightColor: colorPrimary,
                hoverColor: colorPrimary,
                splashColor: colorPrimary,
                onTap: () async {
                  await historyprovider.chageTab(index);
                  await historyprovider.clearTab();
                  if (index == 0) {
                    _fetchData("1", 0);
                  } else if (index == 1) {
                    _fetchData("2", 0);
                  } else if (index == 2) {
                    _fetchData("4", 0);
                  } else if (index == 3) {
                    _fetchData("6", 0);
                  } else {
                    if (!context.mounted) return;
                    Utils.showSnackbar(
                      context,
                      "Something Went Wronge !!!",
                      true,
                    );
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: 250,
                  padding: const EdgeInsets.fromLTRB(25, 0, 15, 0),
                  margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color:
                        historyprovider.tabindex == index
                            ? colorAccent
                            : colorPrimaryDark,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InteractiveContainer(
                    child: (isHovered) {
                      return AnimatedScale(
                        scale: isHovered ? 1.2 : 1,
                        alignment: Alignment.centerLeft,
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyImage(
                              width: 28,
                              height: 28,
                              color:
                                  historyprovider.tabindex == index
                                      ? black
                                      : white,
                              imagePath: Constant.historyTabIconList[index],
                            ),
                            const SizedBox(width: 10),
                            MusicTitle(
                              color:
                                  historyprovider.tabindex == index
                                      ? black
                                      : white,
                              multilanguage: true,
                              text: Constant.historyTabList[index],
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /* Tab Item According to Type */
  Widget buildPage() {
    return Consumer<HistoryProvider>(
      builder: (context, historyprovider, child) {
        if (historyprovider.loading && !historyprovider.loadMore) {
          return buildShimmerLayout();
        } else {
          if (historyprovider.historyModel.status == 200 &&
              historyprovider.historyList != null) {
            if ((historyprovider.historyList?.length ?? 0) > 0) {
              return Column(
                children: [
                  CustomAds(adType: Constant.bannerAdType),
                  const SizedBox(height: 15),
                  buildLayout(),
                  if (historyProvider.loadMore)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                      child: Utils.pageLoader(context),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              );
            } else {
              return const NoData(title: "", subTitle: "");
            }
          } else {
            return const NoData(title: "", subTitle: "");
          }
        }
      },
    );
  }

  buildLayout() {
    return Consumer<HistoryProvider>(
      builder: (context, historyprovider, child) {
        if (historyprovider.tabindex == 0) {
          return buildHistoryVideo();
        } else if (historyprovider.tabindex == 1) {
          return buildHistoryMusic();
        } else if (historyprovider.tabindex == 2) {
          return buildHistoryPodcast();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget buildHistoryVideo() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.crossAxisCount(context),
      maxItemsPerRow: Utils.crossAxisCount(context),
      horizontalGridSpacing: 15,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
      children: List.generate(historyProvider.historyList?.length ?? 0, (
        index,
      ) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) => WebDetail(
                      stoptime:
                          historyProvider.historyList?[index].stopTime ?? 0,
                      iscontinueWatching: true,
                      videoid:
                          historyProvider.historyList?[index].id.toString() ??
                          "",
                    ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: InteractiveContainer(
            child: (isHovered) {
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        alignment: Alignment.center,
                        foregroundDecoration:
                            isHovered
                                ? BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorPrimary.withOpacity(0.50),
                                      colorPrimary.withOpacity(0.50),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                )
                                : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: MyNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                            height: MediaQuery.of(context).size.height,
                            imagePath:
                                historyProvider.historyList?[index].landscapeImg
                                    .toString() ??
                                "",
                          ),
                        ),
                      ),
                      Positioned.fill(
                        right: 15,
                        bottom: 15,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                            decoration: BoxDecoration(
                              color: transparent.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: MyText(
                              color: white,
                              text: Utils.formatTime(
                                double.parse(
                                  historyProvider
                                          .historyList?[index]
                                          .contentDuration
                                          .toString() ??
                                      "",
                                ),
                              ),
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textSmall,
                              fontsizeWeb: Dimens.textSmall,
                              inter: false,
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
                    padding: const EdgeInsets.fromLTRB(3, 20, 3, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            width: 32,
                            height: 32,
                            imagePath:
                                historyProvider.historyList?[index].channelImage
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
                                    historyProvider.historyList?[index].title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textTitle,
                                fontsizeWeb: Dimens.textTitle,
                                inter: false,
                                maxline: 2,
                                multilanguage: false,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              historyProvider.historyList?[index].channelName
                                          .toString() ==
                                      ""
                                  ? const SizedBox.shrink()
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      MyText(
                                        color: gray,
                                        text:
                                            historyProvider
                                                .historyList?[index]
                                                .channelName
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textMedium,
                                        fontsizeWeb: Dimens.textMedium,
                                        inter: false,
                                        maxline: 2,
                                        multilanguage: false,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    color: gray,
                                    text: Utils.kmbGenerator(
                                      historyProvider
                                              .historyList?[0]
                                              .totalView ??
                                          0,
                                    ),
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    inter: false,
                                    maxline: 2,
                                    multilanguage: false,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(width: 5),
                                  MyText(
                                    color: gray,
                                    text: "views",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    inter: false,
                                    maxline: 2,
                                    multilanguage: true,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(width: 5),
                                  MyText(
                                    color: gray,
                                    text: Utils.timeAgoCustom(
                                      DateTime.parse(
                                        historyProvider
                                                .historyList?[index]
                                                .createdAt ??
                                            "",
                                      ),
                                    ),
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    inter: false,
                                    maxline: 2,
                                    multilanguage: false,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
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
            },
          ),
        );
      }),
    );
  }

  Widget buildHistoryMusic() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 3,
            height1200: 3,
            height800: 2,
            height600: 1,
          ),
          maxItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 3,
            height1200: 3,
            height800: 2,
            height600: 1,
          ),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(historyProvider.historyList?.length ?? 0, (
            index,
          ) {
            return InkWell(
              onTap: () {
                playAudio(
                  playingType:
                      historyProvider.historyList?[index].contentType
                          .toString() ??
                      "",
                  episodeid:
                      historyProvider.historyList?[index].id.toString() ?? "",
                  contentid:
                      historyProvider.historyList?[index].id.toString() ?? "",
                  position: index,
                  contentList: historyProvider.historyList,
                  contentName:
                      historyProvider.historyList?[index].title.toString() ??
                      "",
                  stoptime:
                      historyProvider.historyList?[index].stopTime.toString() ??
                      "",
                  isBuy:
                      historyProvider.historyList?[index].isBuy.toString() ??
                      "",
                );
              },
              child: InteractiveContainer(
                child: (isHovered) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: 55,
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              foregroundDecoration:
                                  isHovered
                                      ? BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorPrimary.withOpacity(0.50),
                                            colorPrimary.withOpacity(0.50),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      )
                                      : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: MyNetworkImage(
                                  fit: BoxFit.cover,
                                  imagePath:
                                      historyProvider
                                          .historyList?[index]
                                          .portraitImg
                                          .toString() ??
                                      "",
                                ),
                              ),
                            ),
                            isHovered
                                ? const Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: white,
                                      size: 25,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MusicTitle(
                                color: white,
                                text:
                                    historyProvider.historyList?[index].title
                                        .toString() ??
                                    "",
                                fontsizeNormal: Dimens.textMedium,
                                fontsizeWeb: Dimens.textMedium,
                                fontwaight: FontWeight.w400,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                        color: gray,
                                        text: Utils.kmbGenerator(
                                          historyProvider
                                                  .historyList?[index]
                                                  .totalView ??
                                              0,
                                        ),
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        fontwaight: FontWeight.w400,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.left,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(width: 5),
                                      MyText(
                                        color: gray,
                                        text: "views",
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        fontwaight: FontWeight.w400,
                                        multilanguage: true,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.left,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: MyText(
                                      color: gray,
                                      text: Utils.timeAgoCustom(
                                        DateTime.parse(
                                          historyProvider
                                                  .historyList?[index]
                                                  .createdAt ??
                                              "",
                                        ),
                                      ),
                                      fontsizeNormal: Dimens.textSmall,
                                      fontsizeWeb: Dimens.textSmall,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildHistoryPodcast() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 3,
            height1200: 3,
            height800: 2,
            height600: 1,
          ),
          maxItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 3,
            height1200: 3,
            height800: 2,
            height600: 1,
          ),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(historyProvider.historyList?.length ?? 0, (
            index,
          ) {
            return InkWell(
              onTap: () {
                playAudio(
                  playingType:
                      historyProvider.historyList?[index].contentType
                          .toString() ??
                      "",
                  episodeid:
                      historyProvider.historyList?[index].episode?[0].id
                          .toString() ??
                      "",
                  contentid:
                      historyProvider.historyList?[index].id.toString() ?? "",
                  position: index,
                  contentName:
                      historyProvider.historyList?[index].episode?[0].name
                          .toString() ??
                      "",
                  isBuy:
                      historyProvider.historyList?[index].isBuy.toString() ??
                      "",
                  contentList: historyProvider.historyList ?? [],
                  stoptime:
                      historyProvider.historyList?[index].stopTime.toString() ??
                      "",
                );
              },
              child: InteractiveContainer(
                child: (isHovered) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: 55,
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              foregroundDecoration:
                                  isHovered
                                      ? BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorPrimary.withOpacity(0.50),
                                            colorPrimary.withOpacity(0.50),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      )
                                      : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: MyNetworkImage(
                                  fit: BoxFit.cover,
                                  imagePath:
                                      historyProvider
                                          .historyList?[index]
                                          .episode?[0]
                                          .portraitImg
                                          .toString() ??
                                      "",
                                ),
                              ),
                            ),
                            isHovered
                                ? const Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: white,
                                      size: 25,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MusicTitle(
                                color: white,
                                text:
                                    historyProvider
                                        .historyList?[index]
                                        .episode?[0]
                                        .name
                                        .toString() ??
                                    "",
                                fontsizeNormal: Dimens.textMedium,
                                fontsizeWeb: Dimens.textMedium,
                                fontwaight: FontWeight.w400,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 8),
                              MyText(
                                color: gray,
                                text: Utils.timeAgoCustom(
                                  DateTime.parse(
                                    historyProvider
                                            .historyList?[index]
                                            .episode?[0]
                                            .createdAt
                                            .toString() ??
                                        "",
                                  ),
                                ),
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                fontwaight: FontWeight.w400,
                                multilanguage: false,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                inter: false,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  /* Shimmer Type Wise  */

  buildShimmerLayout() {
    if (historyProvider.tabindex == 0) {
      return buildHistoryVideoShimmer();
    } else if (historyProvider.tabindex == 1) {
      return buildMusicAndPodcastShimmer();
    } else if (historyProvider.tabindex == 2) {
      return buildMusicAndPodcastShimmer();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildHistoryVideoShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.crossAxisCount(context),
      maxItemsPerRow: Utils.crossAxisCount(context),
      horizontalGridSpacing: 15,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
      children: List.generate(20, (index) {
        return Column(
          children: [
            CustomWidget.webImageRound(
              width: MediaQuery.of(context).size.width,
              height: 180,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(3, 20, 3, 20),
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
                        CustomWidget.roundrectborder(width: 250, height: 5),
                        CustomWidget.roundrectborder(width: 250, height: 5),
                        CustomWidget.roundrectborder(width: 250, height: 5),
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
      }),
    );
  } /* More Item Bottom Sheet */

  Widget buildMusicAndPodcastShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: Utils.crossAxisCount(context),
      maxItemsPerRow: Utils.crossAxisCount(context),
      horizontalGridSpacing: 15,
      verticalGridSpacing: 25,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
      children: List.generate(20, (index) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 55,
          child: const Row(
            children: [
              CustomWidget.roundrectborder(width: 55, height: 55),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(width: 200, height: 8),
                    SizedBox(height: 8),
                    CustomWidget.roundrectborder(width: 200, height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /* Play Audio Medthod With View Count Api */

  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    required int position,
    dynamic contentList,
    required String contentName,
    dynamic stoptime,
    required String? isBuy,
  }) async {
    int finalStopTime = int.parse(stoptime);
    if (Constant.userID == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const WebLogin();
          },
        ),
      );
    } else {
      if (playingType == "2") {
        /* Only Music Direct Play*/
        musicManager.setInitialMusic(
          position,
          playingType,
          contentList,
          contentid,
          addView(playingType, contentid),
          true,
          finalStopTime,
          isBuy ?? "",
        );
      } else if (playingType == "4") {
        musicManager.setInitialHistory(
          context,
          episodeid,
          position,
          playingType,
          contentList,
          contentid,
          addView(playingType, contentid),
          true,
          finalStopTime,
          isBuy ?? "",
          "episode",
        );
      }
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider = Provider.of<MusicDetailProvider>(
      context,
      listen: false,
    );
    await musicDetailProvider.addView(contentType, contentId);
  }
}
