import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/provider/marketplaceprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/webmarketplacedetail.dart';
import 'package:slike/webwidget/interactivecontainer.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';

class WebMarketPlace extends StatefulWidget {
  const WebMarketPlace({super.key});

  @override
  State<WebMarketPlace> createState() => WebMarketPlaceState();
}

class WebMarketPlaceState extends State<WebMarketPlace> {
  final searchController = TextEditingController();
  late ScrollController _scrollController;
  late ScrollController _categoryScrollController;
  late MarketPlaceProvider marketPlaceProvider;

  @override
  void initState() {
    marketPlaceProvider = Provider.of<MarketPlaceProvider>(
      context,
      listen: false,
    );
    _scrollController = ScrollController();
    _categoryScrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _categoryScrollController.addListener(_categoryScrollListener);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
  }

  getApi() async {
    await _fetchDataCategory(0);
    if (marketPlaceProvider.categorymodel.status == 200 &&
        marketPlaceProvider.categorydataList != null) {
      if ((marketPlaceProvider.categorydataList?.length ?? 0) > 0) {
        await marketPlaceProvider.selectCategory(0, "");
        log("Error===================>");
        await _fetchData(0, "");
      }
    }
  }

  _categoryScrollListener() async {
    if (!_categoryScrollController.hasClients) return;
    if (_categoryScrollController.offset >=
            _categoryScrollController.position.maxScrollExtent &&
        !_categoryScrollController.position.outOfRange &&
        (marketPlaceProvider.categorycurrentPage ?? 0) <
            (marketPlaceProvider.categorytotalPage ?? 0)) {
      await marketPlaceProvider.setCategoryLoadMore(true);
      _fetchDataCategory(marketPlaceProvider.categorycurrentPage ?? 0);
    }
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (marketPlaceProvider.currentPage ?? 0) <
            (marketPlaceProvider.totalPage ?? 0)) {
      await marketPlaceProvider.setLoadMore(true);
      _fetchData(
        marketPlaceProvider.currentPage ?? 0,
        marketPlaceProvider.categoryId ?? "",
      );
    }
  }

  /* =================== Category Api =================== */
  Future<void> _fetchDataCategory(int? nextPage) async {
    printLog("isMorePage  ======> ${marketPlaceProvider.categoryisMorePage}");
    printLog("currentPage ======> ${marketPlaceProvider.categorycurrentPage}");
    printLog("totalPage   ======> ${marketPlaceProvider.categorytotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await marketPlaceProvider.getVideoCategory((nextPage ?? 0) + 1);
    await marketPlaceProvider.setCategoryLoadMore(false);
  }
  /* =================== Product Api =================== */

  /* =================== ProductData Api =================== */
  Future<void> _fetchData(int? nextPage, String categoryId) async {
    printLog(
      "MarketPlaceisMorePage  ======> ${marketPlaceProvider.isMorePage}",
    );
    printLog(
      "MarketPlacecurrentPage ======> ${marketPlaceProvider.currentPage}",
    );
    printLog("MarketPlacetotalPage   ======> ${marketPlaceProvider.totalPage}");
    printLog("MarketPlacenextpage   ======> $nextPage");
    printLog("MarketPlaceCall MyCourse");
    printLog("MarketPlacePageno:== ${(nextPage ?? 0) + 1}");
    await marketPlaceProvider.getMarketPlace(
      searchController.text,
      categoryId,
      (nextPage ?? 0) + 1,
    );
    await marketPlaceProvider.setLoadMore(false);
  }
  /* =================== ProductData Api =================== */

  @override
  void dispose() {
    super.dispose();
    marketPlaceProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: "home",
        categoryTap: () {},
      ),
      body: Utils.sidePanelWithBody(
        myWidget: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchWithTitle(),
              const SizedBox(height: 15),
              buildCategory(),
              const SizedBox(height: 15),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: colorPrimaryDark,
                  color: colorAccent,
                  displacement: 70,
                  edgeOffset: 1.0,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  strokeWidth: 3,
                  onRefresh: () async {
                    _fetchData(0, marketPlaceProvider.categoryId ?? "");
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(children: [buildProducts()]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ============================ SerchBar ============================ */

  Widget searchWithTitle() {
    if (MediaQuery.of(context).size.width > 1200) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Utils.pageTitle(title: "market_place", multilanguage: true),
          searchBar(),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.pageTitle(title: "market_place", multilanguage: true),
          const SizedBox(height: 20),
          searchBar(),
        ],
      );
    }
  }

  Widget searchBar() {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width > 1200
              ? MediaQuery.of(context).size.width * 0.25
              : MediaQuery.of(context).size.width,
      child: TextFormField(
        obscureText: false,
        onChanged: (value) async {
          marketPlaceProvider.clearData();
          _fetchData(0, marketPlaceProvider.categoryId ?? "");
        },
        keyboardType: TextInputType.text,
        controller: searchController,
        textInputAction: TextInputAction.search,
        cursorColor: lightgray,
        style: GoogleFonts.roboto(
          fontSize: Dimens.textTitle,
          fontStyle: FontStyle.normal,
          color: white,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: white),
          hintStyle: GoogleFonts.roboto(
            fontSize: Dimens.textMedium,
            fontStyle: FontStyle.normal,
            color: white,
            fontWeight: FontWeight.w400,
          ),
          hintText: Locales.string(context, "searchproduct"),
          filled: true,
          fillColor: colorPrimaryDark,
          contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
        ),
      ),
    );
  }

  Widget buildCategory() {
    return Consumer<MarketPlaceProvider>(
      builder: (context, categoryprovider, child) {
        if (categoryprovider.categoryloading &&
            !categoryprovider.categoryloadMore) {
          return categoryShimmer();
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _categoryScrollController,
            child: Row(
              children: [
                videocategoryList(),
                if (marketPlaceProvider.categoryloadMore)
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
    if (marketPlaceProvider.categorymodel.status == 200 &&
        marketPlaceProvider.categorydataList != null) {
      if ((marketPlaceProvider.categorydataList?.length ?? 0) > 0) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            itemCount: marketPlaceProvider.categorydataList?.length ?? 0,
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
                  await marketPlaceProvider.selectCategory(
                    index,
                    marketPlaceProvider.categorydataList?[index].id
                            .toString() ??
                        "",
                  );

                  marketPlaceProvider.clearData();
                  if (index == 0) {
                    _fetchData(0, "");
                  } else {
                    _fetchData(
                      0,
                      marketPlaceProvider.categorydataList?[index].id
                              .toString() ??
                          "",
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        index == marketPlaceProvider.catindex
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
                        color:
                            index == marketPlaceProvider.catindex
                                ? black
                                : white,
                        text:
                            marketPlaceProvider.categorydataList?[index].name ??
                            "",
                        fontwaight: FontWeight.w500,
                        fontsizeNormal: Dimens.textSmall,
                        fontsizeWeb: Dimens.textSmall,
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

  Widget buildProducts() {
    return Consumer<MarketPlaceProvider>(
      builder: (context, marketplaceprovider, child) {
        if (marketplaceprovider.loading && !marketplaceprovider.loadMore) {
          return shimmer();
        } else {
          if (marketplaceprovider.marketPlaceModel.status == 200 &&
              marketplaceprovider.marketplaceList != null) {
            if ((marketplaceprovider.marketplaceList?.length ?? 0) > 0) {
              return Column(
                children: [
                  buildProductsItem(),
                  if (marketplaceprovider.loadMore)
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
            } else {
              return const NoData();
            }
          } else {
            return const NoData();
          }
        }
      },
    );
  }

  Widget buildProductsItem() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: itemCount(
        context: context,
        height1600: 9,
        height1200: 7,
        height800: 5,
        height600: 3,
      ),
      maxItemsPerRow: itemCount(
        context: context,
        height1600: 9,
        height1200: 7,
        height800: 5,
        height600: 3,
      ),
      horizontalGridSpacing: 10,
      verticalGridSpacing: 10,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(marketPlaceProvider.marketplaceList?.length ?? 0, (
        index,
      ) {
        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) => WebMarketPlaceDetail(
                      userImage:
                          marketPlaceProvider.marketplaceList?[index].userImage
                              .toString() ??
                          "",
                      userName:
                          marketPlaceProvider.marketplaceList?[index].userName
                              .toString() ??
                          "",
                      postId:
                          marketPlaceProvider.marketplaceList?[index].id
                              .toString() ??
                          "",
                      channelName:
                          marketPlaceProvider
                              .marketplaceList?[index]
                              .userChannelName
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedScale(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    scale: isHovered ? 1.02 : 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 240,
                        fit: BoxFit.cover,
                        imagePath:
                            marketPlaceProvider.marketplaceList?[index].image
                                .toString() ??
                            "",
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  MyText(
                    color: white,
                    text:
                        marketPlaceProvider.marketplaceList?[index].name
                            .toString() ??
                        "",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    fontsizeWeb: Dimens.textMedium,
                    inter: true,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  // const SizedBox(height: 8),
                  // MyText(
                  //     color: white,
                  //     text:
                  //         "${Constant.currencySymbol}${marketPlaceProvider.marketplaceList?[index].price.toString() ?? ""}",
                  //     textalign: TextAlign.center,
                  //     fontsizeNormal: Dimens.textBig,
                  //     fontsizeWeb: Dimens.textBig,
                  //     inter: false,
                  //     multilanguage: false,
                  //     maxline: 2,
                  //     fontwaight: FontWeight.w700,
                  //     overflow: TextOverflow.ellipsis,
                  //     fontstyle: FontStyle.normal),
                  // const SizedBox(height: 10),
                  // InkWell(
                  //   onTap: () async {

                  //   },
                  //   child: Container(
                  //     width: MediaQuery.of(context).size.width,
                  //     height: 40,
                  //     alignment: Alignment.center,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(50),
                  //       color: white,
                  //     ),
                  //     child: MyText(
                  //         color: black,
                  //         text: "info",
                  //         textalign: TextAlign.center,
                  //         fontsizeNormal: Dimens.textExtraBig,
                  //         fontsizeWeb: Dimens.textExtraBig,
                  //         inter: false,
                  //         multilanguage: false,
                  //         maxline: 2,
                  //         fontwaight: FontWeight.bold,
                  //         overflow: TextOverflow.ellipsis,
                  //         fontstyle: FontStyle.normal),
                  //   ),
                  // ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget shimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: itemCount(
        context: context,
        height1600: 9,
        height1200: 7,
        height800: 5,
        height600: 3,
      ),
      maxItemsPerRow: itemCount(
        context: context,
        height1600: 9,
        height1200: 7,
        height800: 5,
        height600: 3,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomWidget.roundrectborder(
              height: 200,
              width: MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 8),
            const CustomWidget.roundrectborder(height: 5, width: 100),
          ],
        );
      }),
    );
  }

  static int itemCount({
    required BuildContext context,
    required int height1600,
    required int height1200,
    required int height800,
    required int height600,
  }) {
    if (MediaQuery.of(context).size.width > 1600) {
      return height1600;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return height1200;
    } else if (MediaQuery.of(context).size.width > 800) {
      return height800;
    } else if (MediaQuery.of(context).size.width > 600) {
      return height600;
    } else {
      return 2;
    }
  }
}
