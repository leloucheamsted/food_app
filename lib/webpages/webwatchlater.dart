import 'package:slike/provider/watchlaterprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/musicmanager.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/webshorts.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebWatchLater extends StatefulWidget {
  const WebWatchLater({super.key});

  @override
  State<WebWatchLater> createState() => WebWatchLaterState();
}

class WebWatchLaterState extends State<WebWatchLater> {
  late ScrollController _scrollController;
  late WatchLaterProvider watchLaterProvider;
  final MusicManager musicManager = MusicManager();

  @override
  void initState() {
    watchLaterProvider = Provider.of<WatchLaterProvider>(
      context,
      listen: false,
    );
    _fetchData("3", 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (watchLaterProvider.currentPage ?? 0) <
            (watchLaterProvider.totalPage ?? 0)) {
      await watchLaterProvider.setLoadMore(true);
      _fetchData("3", watchLaterProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(contentType, int? nextPage) async {
    printLog("isMorePage  ======> ${watchLaterProvider.isMorePage}");
    printLog("currentPage ======> ${watchLaterProvider.currentPage}");
    printLog("totalPage   ======> ${watchLaterProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await watchLaterProvider.getContentByWatchLater(
      contentType,
      (nextPage ?? 0) + 1,
    );
  }

  @override
  void dispose() {
    super.dispose();
    watchLaterProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: "watchlater",
        categoryTap: () {},
      ),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.pageTitle(multilanguage: true, title: 'watchlater'),
              buildPage(),
            ],
          ),
        ),
      ),
    );
  }

  /* Tab Item According Perticular Type */
  Widget buildPage() {
    return Consumer<WatchLaterProvider>(
      builder: (context, watchlaterprovider, child) {
        printLog(
          "content lenght==>${watchlaterprovider.contantList?.length ?? 0}",
        );
        if (watchlaterprovider.loading && !watchlaterprovider.loadMore) {
          return buildReelsShimmer();
        } else {
          return Column(
            children: [
              buildReels(),
              if (watchlaterprovider.loadMore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  alignment: Alignment.center,
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }

  Widget buildReels() {
    if (watchLaterProvider.watchlaterModel.status == 200 &&
        watchLaterProvider.contantList != null) {
      if ((watchLaterProvider.contantList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 8,
              height1200: 6,
              height800: 4,
              height600: 2,
            ),
            maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 8,
              height1200: 6,
              height800: 4,
              height600: 2,
            ),
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
              watchLaterProvider.contantList?.length ?? 0,
              (index) {
                return buildReelsItem(index: index);
              },
            ),
          ),
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

  Widget buildReelsItem({required int index}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation1, animation2) => WebShorts(
                  initialIndex: index,
                  shortType: "watchlater",
                  userId: Constant.userID,
                  channelId: Constant.channelID,
                ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 350,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MyNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    imagePath:
                        watchLaterProvider.contantList?[index].portraitImg
                            .toString() ??
                        "",
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: MyImage(width: 30, height: 30, imagePath: "pause.png"),
                ),
                if (watchLaterProvider.position == index &&
                    watchLaterProvider.deleteWatchlaterloading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: colorAccent,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        hoverColor: transparent,
                        highlightColor: transparent,
                        onTap: () async {
                          /* Remove Watch Later Api */
                          await watchLaterProvider.addremoveWatchLater(
                            index,
                            watchLaterProvider.contantList?[index].contentType
                                    .toString() ??
                                "",
                            watchLaterProvider.contantList?[index].id
                                    .toString() ??
                                "",
                            "0",
                            "0",
                          );
                        },
                        child: MyImage(
                          width: 20,
                          height: 20,
                          imagePath: "ic_delete.png",
                          color: colorAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          MyText(
            color: white,
            text: watchLaterProvider.contantList?[index].title.toString() ?? "",
            textalign: TextAlign.left,
            fontsizeNormal: Dimens.textMedium,
            fontsizeWeb: Dimens.textMedium,
            inter: false,
            multilanguage: false,
            maxline: 2,
            fontwaight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ],
      ),
    );
  }

  Widget buildReelsShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 8,
            height1200: 6,
            height800: 4,
            height600: 2,
          ),
          maxItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 8,
            height1200: 6,
            height800: 4,
            height600: 2,
          ),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(40, (index) {
            return Column(
              children: [
                CustomWidget.roundrectborder(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                ),
                const SizedBox(height: 10),
                const CustomWidget.roundrectborder(height: 6, width: 100),
              ],
            );
          }),
        ),
      ),
    );
  }
}
