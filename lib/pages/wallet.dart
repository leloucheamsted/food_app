import 'package:slike/provider/walletprovider.dart';
import 'package:slike/subscription/adspackage.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late WalletProvider walletProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    getApi();
    _fetchPackageTransection(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  getApi() async {
    /* Profile Api */
    await walletProvider.getprofile(context, Constant.userID);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (walletProvider.position == 0) {
        if ((walletProvider.currentPage ?? 0) <
            (walletProvider.totalPage ?? 0)) {
          walletProvider.setLoadMore(true);
          _fetchPackageTransection(walletProvider.currentPage ?? 0);
        }
      } else {
        if ((walletProvider.withdrawalcurrentPage ?? 0) <
            (walletProvider.withdrawaltotalPage ?? 0)) {
          walletProvider.setLoadMore(true);
          _fetchWithdrawalTransection(
            walletProvider.withdrawalcurrentPage ?? 0,
          );
        }
      }
    }
  }

  // Future<void> _fetchDataUsageHistory(int? nextPage) async {
  //   /* get Ads Package Transection Api */
  //   await walletProvider.getUsageHistory((nextPage ?? 0) + 1);
  //   walletProvider.setUsageHistoryLoadMore(false);
  // }

  Future<void> _fetchPackageTransection(int? nextPage) async {
    /* get Ads Package Transection Api */
    // walletProvider.setLoadMore(false);
    await walletProvider.getAdsPackageTransection((nextPage ?? 0) + 1);
    walletProvider.setLoadMore(false);
  }

  Future<void> _fetchWithdrawalTransection(int? nextPage) async {
    /* get Ads Package Transection Api */
    await walletProvider.getWithdrawalTransection((nextPage ?? 0) + 1);
    walletProvider.setWithdrawalLoadMore(false);
  }

  @override
  void dispose() {
    walletProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "mywallet", true),
      body: Stack(
        children: [
          RefreshIndicator(
            backgroundColor: colorPrimaryDark,
            color: colorAccent,
            displacement: 70,
            edgeOffset: 1.0,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            strokeWidth: 3,
            onRefresh: () async {
              getApi();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 190),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  myWallet(),
                  const SizedBox(height: 15),
                  // buildTab(),
                  buildTabItem(),
                ],
              ),
            ),
          ),
          Utils.musicAndAdsPanel(context),
        ],
      ),
    );
  }

  Widget myWallet() {
    return Consumer<WalletProvider>(
      builder: (context, walletprovider, child) {
        if (walletprovider.profileloading) {
          return myWalletShimmer();
        } else {
          return Container(
            color: colorPrimaryDark,
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorAccent, colorAccent.withOpacity(0.5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: white, width: 8),
                      ),
                      child: MyImage(
                        width: 128,
                        height: 128,
                        imagePath: "ic_withdraw_coin.webp",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                MyText(
                  color: white,
                  text: Utils.kmbGenerator(
                    int.parse(
                      walletProvider.profileModel.result?[0].walletBalance
                              .toString() ??
                          "",
                    ),
                  ),
                  textalign: TextAlign.center,
                  fontsizeNormal: 35,
                  multilanguage: false,
                  inter: true,
                  maxline: 1,
                  fontwaight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 5),
                MyText(
                  color: white,
                  multilanguage: true,
                  text: "available_coin_balance",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textMedium,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const AdsPackage();
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 56,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [colorAccent, colorPrimaryDark],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          color: white,
                          multilanguage: false,
                          text: "Recharge Coin",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.double_arrow_outlined,
                          color: white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                buildTab(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget myWalletShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomWidget.circular(height: 160, width: 160),
        const SizedBox(height: 15),
        const CustomWidget.roundcorner(height: 30, width: 200),
        const SizedBox(height: 5),
        const CustomWidget.roundcorner(height: 30, width: 250),
        CustomWidget.roundcorner(
          height: 50,
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }

  Widget buildTab() {
    return Consumer<WalletProvider>(
      builder: (context, walletprovider, child) {
        return SizedBox(
          height: 50,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: Constant.transectionHistoryList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: InkWell(
                        autofocus: false,
                        focusColor: black,
                        highlightColor: black,
                        hoverColor: black,
                        splashColor: black,
                        onTap: () async {
                          walletprovider.changeTab(index);
                          /* Usage History */
                          // if (walletprovider.position == 0) {
                          //   _fetchDataUsageHistory(0);
                          //   walletprovider.clearUsageHistory();
                          //   /* Parchas History */
                          // } else

                          if (walletprovider.position == 0) {
                            _fetchPackageTransection(0);
                            walletprovider.clearWithdrawalTransection();
                            /* Withdrawal History */
                          } else if (walletprovider.position == 1) {
                            _fetchWithdrawalTransection(0);
                            walletprovider.clearPackageTransection();
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyImage(
                                width: 25,
                                height: 25,
                                color:
                                    walletprovider.position == index
                                        ? colorAccent
                                        : gray,
                                imagePath:
                                    Constant.transectionHistoryIconList[index],
                              ),
                              const SizedBox(width: 10),
                              MyText(
                                color:
                                    walletprovider.position == index
                                        ? colorAccent
                                        : gray,
                                text: Constant.transectionHistoryList[index],
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                inter: false,
                                multilanguage: false,
                                maxline: 1,
                                fontwaight:
                                    walletprovider.position == index
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: colorPrimaryDark,
                height: 2,
                width: MediaQuery.of(context).size.width,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTabItem() {
    // return Consumer<WalletProvider>(builder: (context, profileprovider, child) {
    //   if (profileprovider.position == 0) {
    //     return buildUseHistory();
    //   } else
    if (walletProvider.position == 0) {
      return buildParchas();
    } else if (walletProvider.position == 1) {
      return buildWithdrawal();
    } else {
      return const SizedBox.shrink();
    }
    // });
  }

  /* Use History */
  // Widget buildUseHistory() {
  //   return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
  //     if (walletprovider.loading && !walletprovider.usageHistoryloadMore) {
  //       return commanShimmer();
  //     } else {
  //       return Column(
  //         children: [
  //           buildUseHistoryItem(),
  //           if (walletprovider.usageHistoryloadMore)
  //             Container(
  //               height: 50,
  //               margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
  //               child: Utils.pageLoader(context),
  //             )
  //           else
  //             const SizedBox.shrink(),
  //         ],
  //       );
  //     }
  //   });
  // }

  // Widget buildUseHistoryItem() {
  //   if (walletProvider.usageHistoryModel.status == 200 &&
  //       walletProvider.usageHistoryList != null) {
  //     if ((walletProvider.usageHistoryList?.length ?? 0) > 0) {
  //       return Padding(
  //         padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
  //         child: MediaQuery.removePadding(
  //             context: context,
  //             removeTop: true,
  //             child: ResponsiveGridList(
  //               minItemWidth: 120,
  //               minItemsPerRow: 1,
  //               maxItemsPerRow: 1,
  //               horizontalGridSpacing: 10,
  //               verticalGridSpacing: 10,
  //               listViewBuilderOptions: ListViewBuilderOptions(
  //                 scrollDirection: Axis.vertical,
  //                 shrinkWrap: true,
  //                 physics: const BouncingScrollPhysics(),
  //               ),
  //               children: List.generate(
  //                   walletProvider.usageHistoryList?.length ?? 0, (index) {
  //                 return Container(
  //                   padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
  //                   decoration: const BoxDecoration(color: colorPrimaryDark),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             MyText(
  //                                 color: colorAccent,
  //                                 multilanguage: false,
  //                                 text: "Ads",
  //                                 textalign: TextAlign.center,
  //                                 fontsizeNormal: Dimens.textExtraSmall,
  //                                 maxline: 1,
  //                                 fontwaight: FontWeight.w700,
  //                                 overflow: TextOverflow.ellipsis,
  //                                 fontstyle: FontStyle.normal),
  //                             const SizedBox(height: 8),
  //                             MyText(
  //                                 color: white,
  //                                 multilanguage: false,
  //                                 text: walletProvider
  //                                         .usageHistoryList?[index].title
  //                                         .toString() ??
  //                                     "",
  //                                 textalign: TextAlign.center,
  //                                 fontsizeNormal: Dimens.textMedium,
  //                                 maxline: 1,
  //                                 fontwaight: FontWeight.w700,
  //                                 overflow: TextOverflow.ellipsis,
  //                                 fontstyle: FontStyle.normal),
  //                           ],
  //                         ),
  //                       ),
  //                       const SizedBox(width: 10),
  //                       Row(
  //                         children: [
  //                           MyImage(
  //                               width: 15,
  //                               height: 15,
  //                               imagePath: "ic_coin.png"),
  //                           const SizedBox(width: 8),
  //                           MyText(
  //                               color: white,
  //                               multilanguage: false,
  //                               text: walletProvider
  //                                       .usageHistoryList?[index].totalCoin
  //                                       .toString() ??
  //                                   "",
  //                               textalign: TextAlign.center,
  //                               fontsizeNormal: Dimens.textTitle,
  //                               maxline: 1,
  //                               fontwaight: FontWeight.w700,
  //                               overflow: TextOverflow.ellipsis,
  //                               fontstyle: FontStyle.normal),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               }),
  //             )),
  //       );
  //     } else {
  //       return const NoData(title: "", subTitle: "");
  //     }
  //   } else {
  //     return const NoData(title: "", subTitle: "");
  //   }
  // }

  /* Parchas */
  Widget buildParchas() {
    return Consumer<WalletProvider>(
      builder: (context, walletprovider, child) {
        if (walletprovider.loading && !walletprovider.loadMore) {
          return commanShimmer();
        } else {
          return Column(
            children: [
              buildParchasItem(),
              if (walletprovider.loadMore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
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

  Widget buildParchasItem() {
    if (walletProvider.adspackageTransectionModel.status == 200 &&
        walletProvider.packageTransectionList != null) {
      if ((walletProvider.packageTransectionList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: MediaQuery.removePadding(
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
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                walletProvider.packageTransectionList?.length ?? 0,
                (index) {
                  return Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    decoration: BoxDecoration(
                      color: colorPrimaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MyImage(
                                width: 25,
                                height: 25,
                                imagePath: "ic_coin.png",
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MyText(
                                      color: colorAccent,
                                      multilanguage: false,
                                      text: Utils.timeAgoCustom(
                                        DateTime.parse(
                                          walletProvider
                                                  .packageTransectionList?[index]
                                                  .createdAt
                                                  .toString() ??
                                              "",
                                        ),
                                      ),
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textExtraSmall,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        MyText(
                                          color: white,
                                          multilanguage: false,
                                          text:
                                              walletProvider
                                                  .packageTransectionList?[index]
                                                  .coin
                                                  .toString() ??
                                              "",
                                          textalign: TextAlign.left,
                                          fontsizeNormal: Dimens.textMedium,
                                          maxline: 1,
                                          fontwaight: FontWeight.w700,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(width: 5),
                                        MyText(
                                          color: white,
                                          multilanguage: true,
                                          text: "coins",
                                          textalign: TextAlign.left,
                                          fontsizeNormal: Dimens.textMedium,
                                          maxline: 1,
                                          fontwaight: FontWeight.w700,
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
                        const SizedBox(width: 10),
                        MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              "${Constant.currencySymbol} ${walletProvider.packageTransectionList?[index].price.toString() ?? ""}",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textTitle,
                          maxline: 1,
                          fontwaight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  /* Withdrawal */
  Widget buildWithdrawal() {
    return Consumer<WalletProvider>(
      builder: (context, walletprovider, child) {
        if (walletprovider.loading && !walletprovider.withdrawalloadMore) {
          return commanShimmer();
        } else {
          return Column(
            children: [
              buildWithdrawalItem(),
              if (walletprovider.withdrawalloadMore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
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

  Widget buildWithdrawalItem() {
    if (walletProvider.withdrawalrequestModel.status == 200 &&
        walletProvider.withdrawalTransectionList != null) {
      if ((walletProvider.withdrawalTransectionList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: MediaQuery.removePadding(
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
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                walletProvider.withdrawalTransectionList?.length ?? 0,
                (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    decoration: const BoxDecoration(color: colorPrimaryDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: colorAccent,
                                multilanguage: false,
                                text: Utils.timeAgoCustom(
                                  DateTime.parse(
                                    walletProvider
                                            .withdrawalTransectionList?[index]
                                            .createdAt
                                            .toString() ??
                                        "",
                                  ),
                                ),
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textExtraSmall,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MyImage(
                                    width: 15,
                                    height: 15,
                                    imagePath: "ic_coin.png",
                                  ),
                                  const SizedBox(width: 8),
                                  MyText(
                                    color: white,
                                    multilanguage: false,
                                    text:
                                        walletProvider
                                            .withdrawalTransectionList?[index]
                                            .amount
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    maxline: 1,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(width: 5),
                                  MyText(
                                    color: white,
                                    multilanguage: true,
                                    text: "coins",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    maxline: 1,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyText(
                          color: white,
                          multilanguage: false,
                          text:
                              "${Constant.currencySymbol} ${walletProvider.withdrawalTransectionList?[index].amount.toString() ?? ""}",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textTitle,
                          maxline: 1,
                          fontwaight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget commanShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: MediaQuery.removePadding(
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
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return Container(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
              decoration: const BoxDecoration(color: colorPrimaryDark),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(height: 5, width: 80),
                        SizedBox(height: 8),
                        CustomWidget.roundrectborder(height: 5, width: 120),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  CustomWidget.roundrectborder(height: 5, width: 50),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
