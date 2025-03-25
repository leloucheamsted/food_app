import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/subscibedchannel.dart';
import 'package:slike/provider/feeddetailprovider.dart';
import 'package:slike/provider/marketplacedetailprovider.dart';
import 'package:slike/provider/shortprovider.dart';
import 'package:slike/subscription/adspackage.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/webfeeddetail.dart';
import 'package:slike/webpages/webmarketplacedetail.dart';
import 'package:slike/webpages/webshorts.dart';
import 'package:slike/webwidget/interactivecontainer.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/nodata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebProfile extends StatefulWidget {
  final String toUserId;
  final String toChannelId;
  final bool isBottomBar;
  final bool? isFeedDetail;
  const WebProfile({
    super.key,
    required this.toUserId,
    required this.toChannelId,
    required this.isBottomBar,
    this.isFeedDetail,
  });

  @override
  State<WebProfile> createState() => _ProfileState();
}

class _ProfileState extends State<WebProfile> {
  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late ScrollController _scrollController;
  late ProfileProvider profileProvider;
  late FeedDetailProvider feedDetailProvider;
  late MarketPlaceDetailProvider marketPlaceDetailProvider;

  @override
  void initState() {
    printLog("UserId ==> ${Constant.userID}");
    printLog("toUserId==> ${widget.toUserId}");
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    feedDetailProvider = Provider.of<FeedDetailProvider>(
      context,
      listen: false,
    );
    marketPlaceDetailProvider = Provider.of<MarketPlaceDetailProvider>(
      context,
      listen: false,
    );
    getApi();
    _fetchShortData(
      0,
      "3",
      widget.isBottomBar == true ? Constant.userID : widget.toUserId,
      widget.isBottomBar == true ? Constant.channelID : widget.toChannelId,
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  getApi() async {
    await profileProvider.getProfile(
      context,
      widget.isBottomBar == true ? Constant.userID : widget.toUserId,
    );
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (profileProvider.tabposition == "bio") {}
      if (profileProvider.tabposition == "short") {
        if ((profileProvider.currentPage ?? 0) <
            (profileProvider.totalPage ?? 0)) {
          await profileProvider.setLoadMore(true);
          getTabData(profileProvider.currentPage ?? 0, "3");
        }
      } else if (profileProvider.tabposition == "feed") {
        if ((profileProvider.channelcurrentPage ?? 0) <
            (profileProvider.channeltotalPage ?? 0)) {
          await profileProvider.setChannelFeedLoadMore(true);
          _fetchChannelFeedData(profileProvider.channelcurrentPage ?? 0);
        }
      } else if (profileProvider.tabposition == "shop") {
        if ((profileProvider.mediacurrentPage ?? 0) <
            (profileProvider.mediatotalPage ?? 0)) {
          await profileProvider.setShopLoadMore(true);
          _fetchShopData(profileProvider.mediacurrentPage ?? 0);
        }
      } else if (profileProvider.tabposition == "wallet") {
        if (profileProvider.walletType == "coinhistory") {
          if ((profileProvider.coinhistorycurrentPage ?? 0) <
              (profileProvider.coinhistorytotalPage ?? 0)) {
            await profileProvider.setCoinHistoryLoadMore(true);
            _fetchCoinHistory(profileProvider.coinhistorycurrentPage ?? 0);
          }
        } else {
          if ((profileProvider.withdrawalcurrentPage ?? 0) <
              (profileProvider.withdrawaltotalPage ?? 0)) {
            await profileProvider.setWithdrawalLoadMore(true);
            _fetchWithdrawalTransection(
              profileProvider.withdrawalcurrentPage ?? 0,
            );
          }
        }
      }
    }
  }

  getTabData(pageNo, contenttype) {
    _fetchShortData(
      pageNo,
      contenttype,
      widget.isBottomBar == true ? Constant.userID : widget.toUserId,
      widget.isBottomBar == true ? Constant.channelID : widget.toChannelId,
    );
  }

  /* ============== Short Content ============== */

  Future<void> _fetchShortData(
    int? nextPage,
    contenttype,
    userid,
    channelid,
  ) async {
    printLog("isMorePage  ======> ${profileProvider.isMorePage}");
    printLog("currentPage ======> ${profileProvider.currentPage}");
    printLog("totalPage   ======> ${profileProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getcontentbyChannel(
      userid,
      channelid,
      contenttype,
      (nextPage ?? 0) + 1,
    );
    await profileProvider.setLoadMore(false);
  }

  /* ============== Feed Content ============== */

  Future<void> _fetchChannelFeedData(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getChannelFeed(
      widget.isBottomBar == true ? Constant.userID : widget.toUserId,
      widget.isBottomBar == true ? Constant.channelID : widget.toChannelId,
      (nextPage ?? 0) + 1,
    );

    await profileProvider.setChannelFeedLoadMore(false);
  }

  /* ============== Shop Content ============== */

  Future<void> _fetchShopData(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getShop(
      widget.isBottomBar == true ? Constant.userID : widget.toUserId,
      (nextPage ?? 0) + 1,
    );

    await profileProvider.setShopLoadMore(false);
  }

  /* ============== Wallet Content ============== */

  Future<void> _fetchCoinHistory(int? nextPage) async {
    await profileProvider.getCoinHistory((nextPage ?? 0) + 1);
    profileProvider.setCoinHistoryLoadMore(false);
  }

  Future<void> _fetchWithdrawalTransection(int? nextPage) async {
    await profileProvider.getWithdrawalTransection((nextPage ?? 0) + 1);
    profileProvider.setWithdrawalLoadMore(false);
  }

  @override
  void dispose() {
    profileProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: "profile",
        categoryTap: () {},
      ),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Consumer<ProfileProvider>(
            builder: (context, profileprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MediaQuery.of(context).size.width > 800
                      ? buildProfileWeb()
                      : buildProfileMobile(),
                  const SizedBox(height: 25),
                  buildTab(),
                  buildTabItem(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildProfileWeb() {
    if (profileProvider.profileloading) {
      return buildProfileShimmerWeb();
    } else {
      if (profileProvider.profileModel.result != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(color: colorPrimary),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: MyNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  imagePath:
                      (profileProvider.profileModel.result?[0].image
                              .toString() ??
                          ""),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            /* Back Button & Chat Button & More Button */
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* FullName With Background */
                  MyText(
                    color: white,
                    multilanguage: false,
                    text:
                        profileProvider.profileModel.result?[0].fullName == ""
                            ? (profileProvider
                                    .profileModel
                                    .result?[0]
                                    .channelName
                                    .toString()
                                    .toUpperCase() ??
                                "")
                            : profileProvider.profileModel.result?[0].fullName
                                    .toString() ??
                                "",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textExtralargeBig,
                    fontsizeWeb: Dimens.textExtralargeBig,
                    inter: true,
                    maxline: 1,
                    fontwaight: FontWeight.w900,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.italic,
                  ),
                  const SizedBox(height: 5),
                  /* Follow Following Button */
                  Align(
                    alignment: Alignment.bottomRight,
                    child:
                        (widget.isBottomBar == true ||
                                widget.toUserId == Constant.userID)
                            ? const SizedBox.shrink()
                            : Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: InkWell(
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
                                    if (widget.isFeedDetail == true) {
                                      await feedDetailProvider
                                          .profileAddRemoveSubscription(
                                            profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "1",
                                          );
                                    } else {
                                      await marketPlaceDetailProvider
                                          .profileAddRemoveSubscription(
                                            profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "1",
                                          );
                                    }

                                    await getApi();
                                  }
                                },
                                child: Container(
                                  width: 50,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .isSubscriber ==
                                                0
                                            ? white
                                            : colorAccent,
                                    border: Border.all(
                                      width: 1,
                                      color:
                                          profileProvider
                                                      .profileModel
                                                      .result?[0]
                                                      .isSubscriber ==
                                                  0
                                              ? white
                                              : colorAccent,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: MyImage(
                                    width: 16,
                                    height: 16,
                                    color:
                                        //  profileProvider.profileModel.result?[0]
                                        //             .isSubscriber ==
                                        //         0
                                        //     ? white
                                        //     :
                                        black,
                                    imagePath:
                                        profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .isSubscriber ==
                                                0
                                            ? "ic_followuser.png"
                                            : "ic_usertrue.png",
                                  ),
                                ),
                              ),
                            ),
                  ),
                  /* Block User Button With  */
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (widget.isBottomBar == true ||
                                widget.toUserId == Constant.userID)
                            ? const SizedBox.shrink()
                            : InkWell(
                              onTap: () async {
                                await profileProvider.addremoveBlockChannel(
                                  "1",
                                  profileProvider
                                          .profileModel
                                          .result?[0]
                                          .channelId
                                          .toString() ??
                                      "",
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  8,
                                  20,
                                  8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorPrimaryDark,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child:
                                    profileProvider
                                                .profileModel
                                                .result?[0]
                                                .isBlock ==
                                            0
                                        ? MyText(
                                          color: white,
                                          text: "blockuser",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textTitle,
                                          multilanguage: true,
                                          inter: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        )
                                        : MyText(
                                          color: white,
                                          text: "removeblockuser",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textTitle,
                                          multilanguage: true,
                                          inter: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  /* My Qr code */
                  (widget.isBottomBar == true ||
                          widget.toUserId == Constant.userID)
                      ? InkWell(
                        onTap: () {
                          myQrcodeDilog(context: context);
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: colorPrimaryDark,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code, color: white),
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget buildProfileMobile() {
    if (profileProvider.profileloading) {
      return buildProfileShimmerMobile();
    } else {
      if (profileProvider.profileModel.result != null) {
        return Stack(
          children: [
            /* Background ProfileImage  */
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(color: colorPrimary),
              child: MyNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                imagePath:
                    (profileProvider.profileModel.result?[0].image.toString() ??
                        ""),
                fit: BoxFit.cover,
              ),
            ),
            /* Back Button & Chat Button & More Button */
            Positioned.fill(
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                    child:
                        (widget.isBottomBar == true ||
                                widget.toUserId == Constant.userID)
                            ? const SizedBox.shrink()
                            : InkWell(
                              onTap: () {
                                if (widget.toUserId != Constant.userID) {
                                  showMenu(
                                    context: context,
                                    position: const RelativeRect.fromLTRB(
                                      100,
                                      100,
                                      0,
                                      0,
                                    ),
                                    items: <PopupMenuEntry>[
                                      PopupMenuItem(
                                        onTap: () async {
                                          await profileProvider
                                              .addremoveBlockChannel(
                                                "1",
                                                profileProvider
                                                        .profileModel
                                                        .result?[0]
                                                        .channelId
                                                        .toString() ??
                                                    "",
                                              );
                                        },
                                        value: 'item1',
                                        child:
                                            profileProvider
                                                        .profileModel
                                                        .result?[0]
                                                        .isBlock ==
                                                    0
                                                ? MyText(
                                                  color: colorPrimaryDark,
                                                  text: "blockuser",
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textTitle,
                                                  multilanguage: true,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal,
                                                )
                                                : MyText(
                                                  color: colorPrimaryDark,
                                                  text: "removeblockuser",
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textTitle,
                                                  multilanguage: true,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal,
                                                ),
                                      ),
                                    ],
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyImage(
                                  width: 15,
                                  height: 15,
                                  imagePath: "ic_more.png",
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ),
            /* FullName With Background */
            Positioned.fill(
              child: SafeArea(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 55,
                        width: 250,
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: black,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Stack(
                          children: <Widget>[
                            MyText(
                              color: white,
                              multilanguage: false,
                              text:
                                  profileProvider
                                              .profileModel
                                              .result?[0]
                                              .fullName ==
                                          ""
                                      ? (profileProvider
                                              .profileModel
                                              .result?[0]
                                              .channelName
                                              .toString()
                                              .toUpperCase() ??
                                          "")
                                      : profileProvider
                                              .profileModel
                                              .result?[0]
                                              .fullName
                                              .toString() ??
                                          "",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textlargeBig,
                              inter: true,
                              maxline: 1,
                              fontwaight: FontWeight.w900,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.italic,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            /* Follow Following Button */
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child:
                        (widget.isBottomBar == true ||
                                widget.toUserId == Constant.userID)
                            ? const SizedBox.shrink()
                            : Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: InkWell(
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
                                    if (widget.isFeedDetail == true) {
                                      await feedDetailProvider
                                          .profileAddRemoveSubscription(
                                            profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "1",
                                          );
                                    } else {
                                      await marketPlaceDetailProvider
                                          .profileAddRemoveSubscription(
                                            profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "1",
                                          );
                                    }

                                    await getApi();
                                  }
                                },
                                child: Container(
                                  width: 50,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .isSubscriber ==
                                                0
                                            ? white
                                            : colorAccent,
                                    border: Border.all(
                                      width: 1,
                                      color:
                                          profileProvider
                                                      .profileModel
                                                      .result?[0]
                                                      .isSubscriber ==
                                                  0
                                              ? white
                                              : colorAccent,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: MyImage(
                                    width: 16,
                                    height: 16,
                                    color:
                                        //  profileProvider.profileModel.result?[0]
                                        //             .isSubscriber ==
                                        //         0
                                        //     ? white
                                        //     :
                                        black,
                                    imagePath:
                                        profileProvider
                                                    .profileModel
                                                    .result?[0]
                                                    .isSubscriber ==
                                                0
                                            ? "ic_followuser.png"
                                            : "ic_usertrue.png",
                                  ),
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ),
            /* My Qr code */
            (widget.isBottomBar == true || widget.toUserId == Constant.userID)
                ? InkWell(
                  onTap: () {
                    myQrcodeDilog(context: context);
                  },
                  child: Container(
                    height: 35,
                    width: 35,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: colorAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code, color: black),
                  ),
                )
                : const SizedBox.shrink(),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget buildProfileShimmerMobile() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.50,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 10),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          const CustomWidget.roundrectborder(width: 150, height: 8),
          const SizedBox(height: 5),
          const CustomWidget.roundrectborder(width: 80, height: 8),
          const CustomWidget.roundrectborder(width: 100, height: 8),
          const CustomWidget.roundrectborder(width: 150, height: 8),
          CustomWidget.roundcorner(
            height: 100,
            width: MediaQuery.of(context).size.width,
          ),
        ],
      ),
    );
  }

  Widget buildProfileShimmerWeb() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.50,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 10),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 5),
          CustomWidget.circular(width: 200, height: 200),
          SizedBox(height: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidget.roundrectborder(width: 80, height: 8),
              CustomWidget.roundrectborder(width: 100, height: 8),
              CustomWidget.roundrectborder(width: 150, height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTab() {
    return Container(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      width: MediaQuery.of(context).size.width,
      height: 65,
      child: Column(
        children: [
          Container(
            color: colorAccent.withOpacity(0.50),
            height: 1,
            width:
                MediaQuery.of(context).size.width > 1200
                    ? MediaQuery.of(context).size.width * 0.50
                    : MediaQuery.of(context).size.width,
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    focusColor: transparent,
                    splashColor: transparent,
                    highlightColor: transparent,
                    hoverColor: transparent,
                    onTap: () async {
                      await profileProvider.changeTab('bio');
                    },
                    child: Container(
                      // width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: MyText(
                        text: "bio",
                        color:
                            profileProvider.tabposition == "bio"
                                ? colorAccent
                                : white,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        inter: false,
                        multilanguage: true,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    focusColor: transparent,
                    splashColor: transparent,
                    highlightColor: transparent,
                    hoverColor: transparent,
                    onTap: () async {
                      await profileProvider.changeTab("short");
                      getTabData(0, "3");
                      profileProvider.clearListData();
                    },
                    child: Container(
                      // width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: MyText(
                        text: "shortprofile",
                        color:
                            profileProvider.tabposition == "short"
                                ? colorAccent
                                : white,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        inter: false,
                        multilanguage: true,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    focusColor: transparent,
                    splashColor: transparent,
                    highlightColor: transparent,
                    hoverColor: transparent,
                    onTap: () async {
                      await profileProvider.changeTab("feed");
                      _fetchChannelFeedData(0);
                    },
                    child: Container(
                      // width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: MyText(
                        text: "feedsprofile",
                        color:
                            profileProvider.tabposition == "feed"
                                ? colorAccent
                                : white,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        inter: false,
                        multilanguage: true,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    focusColor: transparent,
                    splashColor: transparent,
                    highlightColor: transparent,
                    hoverColor: transparent,
                    onTap: () async {
                      await profileProvider.changeTab("shop");
                      profileProvider.clearShop();
                      _fetchShopData(0);
                    },
                    child: Container(
                      // width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: MyText(
                        text: "shop",
                        color:
                            profileProvider.tabposition == "shop"
                                ? colorAccent
                                : white,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        inter: false,
                        multilanguage: true,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  (widget.isBottomBar == true ||
                          widget.toUserId == Constant.userID)
                      ? InkWell(
                        focusColor: transparent,
                        splashColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        onTap: () async {
                          await profileProvider.changeTab("wallet");
                          _fetchCoinHistory(0);
                        },
                        child: Container(
                          // width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          child: MyText(
                            text: "wallet",
                            color:
                                profileProvider.tabposition == "wallet"
                                    ? colorAccent
                                    : white,
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            inter: false,
                            multilanguage: true,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabItem() {
    if (profileProvider.tabposition == "bio") {
      return buildBio();
    } else if (profileProvider.tabposition == "short") {
      return buildReels();
    } else if (profileProvider.tabposition == "feed") {
      return buildFeed();
    } else if (profileProvider.tabposition == "shop") {
      return buildShop();
    } else if (profileProvider.tabposition == "wallet") {
      return buildWallet();
    } else {
      return const SizedBox.shrink();
    }
  }

  buildBio() {
    if (profileProvider.loading) {
      return const Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.roundrectborder(height: 20),
            CustomWidget.roundrectborder(height: 20),
            CustomWidget.roundrectborder(height: 20),
            CustomWidget.roundrectborder(height: 20),
            CustomWidget.roundrectborder(height: 20),
          ],
        ),
      );
    } else {
      if (profileProvider.profileModel.result != null &&
          (profileProvider.profileModel.result?.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* Social Link */
            (profileProvider.profileModel.result?[0].socialLink != null &&
                    (profileProvider
                                .profileModel
                                .result?[0]
                                .socialLink
                                ?.length ??
                            0) >
                        0)
                ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      height: 45,
                      // color: colorAccent,
                      alignment: Alignment.center,
                      child: Align(
                        alignment: Alignment.center,
                        child: ListView.separated(
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 8),
                          itemCount:
                              profileProvider
                                  .profileModel
                                  .result?[0]
                                  .socialLink
                                  ?.length ??
                              0,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                focusColor: transparent,
                                highlightColor: transparent,
                                hoverColor: transparent,
                                splashColor: transparent,
                                onTap: () async {
                                  Utils.lanchAdsUrl(
                                    profileProvider
                                            .profileModel
                                            .result?[0]
                                            .socialLink?[index]
                                            .url
                                            .toString() ??
                                        "",
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: MyNetworkImage(
                                    width: 30,
                                    height: 30,
                                    imagePath:
                                        profileProvider
                                            .profileModel
                                            .result?[0]
                                            .socialLink?[index]
                                            .image
                                            .toString() ??
                                        "",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      color: colorAccent.withOpacity(0.50),
                      height: 1,
                      width:
                          MediaQuery.of(context).size.width > 1200
                              ? MediaQuery.of(context).size.width * 0.50
                              : MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    ),
                  ],
                )
                : const SizedBox.shrink(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: MyText(
                color: white,
                text:
                    (profileProvider.profileModel.result?[0].channelName
                            .toString()
                            .toUpperCase() ??
                        ""),
                textalign: TextAlign.start,
                fontsizeNormal: Dimens.textlargeBig,
                fontsizeWeb: Dimens.textlargeBig,
                inter: false,
                multilanguage: false,
                maxline: 2,
                fontwaight: FontWeight.w900,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 5),
            InkWell(
              focusColor: transparent,
              highlightColor: transparent,
              hoverColor: transparent,
              splashColor: transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SubscribedChannel(
                        userId:
                            profileProvider.profileModel.result?[0].id
                                .toString() ??
                            "",
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      color: white,
                      text: Utils.kmbGenerator(
                        (profileProvider
                                    .profileModel
                                    .result?[0]
                                    .totalSubscribe ??
                                0)
                            .round(),
                      ),
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textTitle,
                      fontsizeWeb: Dimens.textTitle,
                      multilanguage: false,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 5),
                    MyText(
                      color: colorAccent,
                      text: "followinguppercase",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MyText(
                      color: white,
                      text:
                          profileProvider
                              .profileModel
                              .result?[0]
                              .totalSubscriber
                              .toString() ??
                          "",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textTitle,
                      fontsizeWeb: Dimens.textTitle,
                      inter: false,
                      maxline: 1,
                      multilanguage: false,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 5),
                    MyText(
                      color: colorAccent,
                      text: "followeruppercase",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      inter: false,
                      maxline: 1,
                      multilanguage: true,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
            ),
            if (profileProvider.profileModel.result?[0].field1 != null &&
                (profileProvider.profileModel.result?[0].field1?.length ?? 0) >
                    0)
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                child: MyText(
                  color: gray,
                  text:
                      (profileProvider.profileModel.result?[0].field1?[0].text
                              .toString() ??
                          ""),
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textTitle,
                  fontsizeWeb: Dimens.textTitle,
                  inter: false,
                  multilanguage: false,
                  maxline: 10,
                  fontwaight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            const SizedBox(height: 15),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  buildWallet() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* Coin History And Withdrawal History Tab */
        Consumer<ProfileProvider>(
          builder: (context, profileprovider, child) {
            if (profileProvider.tabposition == "wallet") {
              return Container(
                color: colorPrimaryDark,
                height: 50,
                width:
                    MediaQuery.of(context).size.width > 1200
                        ? MediaQuery.of(context).size.width * 0.50
                        : MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        focusColor: transparent,
                        splashColor: transparent,
                        hoverColor: transparent,
                        highlightColor: transparent,
                        onTap: () async {
                          await profileProvider.selectWalletTab("coinhistory");
                          profileProvider.clearPackageTransection();
                          _fetchCoinHistory(0);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyImage(
                                width: 25,
                                height: 25,
                                color:
                                    profileprovider.walletType == "coinhistory"
                                        ? colorAccent
                                        : gray,
                                imagePath: "ic_coin_history.webp",
                              ),
                              const SizedBox(width: 10),
                              MyText(
                                color:
                                    profileprovider.walletType == "coinhistory"
                                        ? colorAccent
                                        : gray,
                                text: "Coin history",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                multilanguage: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        focusColor: transparent,
                        splashColor: transparent,
                        hoverColor: transparent,
                        highlightColor: transparent,
                        onTap: () async {
                          await profileProvider.selectWalletTab(
                            "withdrawalhistory",
                          );
                          profileProvider.clearWithdrawalTransection();
                          _fetchWithdrawalTransection(0);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyImage(
                                width: 25,
                                height: 25,
                                color:
                                    profileprovider.walletType ==
                                            "withdrawalhistory"
                                        ? colorAccent
                                        : gray,
                                imagePath: "ic_withdraw.webp",
                              ),
                              const SizedBox(width: 10),
                              MyText(
                                color:
                                    profileprovider.walletType ==
                                            "withdrawalhistory"
                                        ? colorAccent
                                        : gray,
                                text: "Withdrawal history",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                inter: false,
                                multilanguage: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        /* Recharge Coin With Indicator */
        Container(
          height: 250,
          width:
              MediaQuery.of(context).size.width > 1200
                  ? MediaQuery.of(context).size.width * 0.50
                  : MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyImage(
                        width: 120,
                        height: 120,
                        imagePath: "ic_withdraw_coin.webp",
                      ),
                      const SizedBox(height: 10),
                      MyText(
                        color: white,
                        text: Utils.kmbGenerator(
                          profileProvider
                                  .profileModel
                                  .result?[0]
                                  .walletBalance ??
                              0,
                        ),
                        textalign: TextAlign.start,
                        fontsizeNormal: Dimens.textExtraBig,
                        inter: false,
                        multilanguage: false,
                        maxline: 2,
                        fontwaight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation1, animation2) =>
                                      const AdsPackage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Container(
                          height: 35,
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
                                fontsizeNormal: Dimens.textSmall,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.double_arrow_outlined,
                                color: white,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyImage(
                        width: 120,
                        height: 120,
                        imagePath: "ic_speedmeter.png",
                      ),
                      const SizedBox(height: 10),
                      MyText(
                        color: white,
                        text: Utils.kmbGenerator(780),
                        textalign: TextAlign.start,
                        fontsizeNormal: Dimens.textExtraBig,
                        inter: false,
                        multilanguage: false,
                        maxline: 2,
                        fontwaight: FontWeight.w700,
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
        /* Transection List */
        buildTransection(),
      ],
    );
  }

  buildTransection() {
    if (profileProvider.walletType == "coinhistory") {
      return buildCoinHistory();
    } else {
      return buildWithdrawal();
    }
  }

  Widget buildVideo() {
    if (profileProvider.loading && !profileProvider.loadMore) {
      return videoShimmer();
    } else {
      return Column(
        children: [
          video(),
          const SizedBox(height: 20),
          if (profileProvider.loadMore)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
              child: Utils.pageLoader(context),
            )
          else
            const SizedBox.shrink(),
        ],
      );
    }
  }

  Widget video() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 3,
              maxItemsPerRow: 3,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                profileProvider.channelContentList?.length ?? 0,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: InkWell(
                      onTap: () {
                        Utils.moveToDetail(
                          context,
                          0,
                          false,
                          profileProvider.channelContentList?[index].id
                                  .toString() ??
                              "",
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            // width: 90,
                            height: 90,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: MyNetworkImage(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    fit: BoxFit.cover,
                                    imagePath:
                                        profileProvider
                                            .channelContentList?[index]
                                            .portraitImg
                                            .toString() ??
                                        "",
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png",
                                  ),
                                ),
                                if (profileProvider.deleteItemIndex == index &&
                                    profileProvider.deletecontentLoading)
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: colorAccent,
                                          strokeWidth: 1,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () async {
                                        if (widget.toUserId ==
                                            Constant.userID) {
                                          await profileProvider.getDeleteContent(
                                            index,
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "0",
                                          );
                                        }
                                      },
                                      child:
                                          widget.toUserId == Constant.userID
                                              ? const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                  5,
                                                  8,
                                                  5,
                                                  8,
                                                ),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: colorAccent,
                                                ),
                                              )
                                              : const SizedBox.shrink(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          MyText(
                            color: white,
                            text:
                                profileProvider.channelContentList?[index].title
                                    .toString() ??
                                "",
                            textalign: TextAlign.start,
                            fontsizeNormal: Dimens.textSmall,
                            inter: false,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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

  Widget videoShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(10, (index) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomWidget.roundrectborder(width: 90, height: 90),
                  SizedBox(height: 8),
                  CustomWidget.roundrectborder(width: 80, height: 6),
                  CustomWidget.roundrectborder(width: 80, height: 6),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildReels() {
    if (profileProvider.loading && !profileProvider.loadMore) {
      return reelsShimmer();
    } else {
      return Column(
        children: [
          reels(),
          const SizedBox(height: 20),
          if (profileProvider.loadMore)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
              child: Utils.pageLoader(context),
            )
          else
            const SizedBox.shrink(),
        ],
      );
    }
  }

  Widget reels() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: itemCount(
                context: context,
                height1600: 10,
                height1200: 8,
                height800: 6,
                height600: 4,
              ),
              maxItemsPerRow: itemCount(
                context: context,
                height1600: 10,
                height1200: 8,
                height800: 6,
                height600: 4,
              ),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 10,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                profileProvider.channelContentList?.length ?? 0,
                (index) {
                  return InkWell(
                    splashColor: transparent,
                    hoverColor: transparent,
                    focusColor: transparent,
                    highlightColor: transparent,
                    onTap: () async {
                      final shortProvider = Provider.of<ShortProvider>(
                        context,
                        listen: false,
                      );
                      await shortProvider.setLoading(true);
                      if (!mounted) return;

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation1, animation2) => WebShorts(
                                userId:
                                    profileProvider
                                        .channelContentList?[index]
                                        .userId
                                        .toString() ??
                                    "",
                                channelId:
                                    profileProvider
                                        .channelContentList?[index]
                                        .channelId
                                        .toString() ??
                                    "",
                                initialIndex: index,
                                shortType: "profile",
                              ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 350,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                              imagePath:
                                  profileProvider
                                      .channelContentList?[index]
                                      .portraitImg
                                      .toString() ??
                                  "",
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "pause.png",
                            ),
                          ),
                          if (profileProvider.deleteItemIndex == index &&
                              profileProvider.deletecontentLoading)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorAccent,
                                    strokeWidth: 1,
                                  ),
                                ),
                              ),
                            )
                          else
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () async {
                                  if (widget.toUserId == Constant.userID) {
                                    await profileProvider.getDeleteContent(
                                      index,
                                      profileProvider
                                              .channelContentList?[index]
                                              .contentType
                                              .toString() ??
                                          "",
                                      profileProvider
                                              .channelContentList?[index]
                                              .id
                                              .toString() ??
                                          "",
                                      "0",
                                    );
                                  }
                                },
                                child:
                                    widget.toUserId == Constant.userID
                                        ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            5,
                                            8,
                                            5,
                                            8,
                                          ),
                                          child: MyImage(
                                            width: 20,
                                            height: 20,
                                            color: colorAccent,
                                            imagePath: "ic_delete.png",
                                          ),
                                        )
                                        : const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ),
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

  Widget reelsShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          maxItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return const CustomWidget.roundcorner(height: 350);
          }),
        ),
      ),
    );
  }

  Widget buildShop() {
    if (profileProvider.loading && !profileProvider.medialoadMore) {
      return shopShimmer();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // (widget.isBottomBar == true || widget.toUserId == Constant.userID)
          //     ? InkWell(
          //         splashColor: transparent,
          //         highlightColor: transparent,
          //         focusColor: transparent,
          //         hoverColor: transparent,
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) {
          //                 return const Uploadproduct();
          //               },
          //             ),
          //           );
          //         },
          //         child: Container(
          //           width: 120,
          //           height: 40,
          //           decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(50),
          //               color: colorAccent),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               MyText(
          //                   color: black,
          //                   multilanguage: true,
          //                   text: "create",
          //                   textalign: TextAlign.left,
          //                   fontsizeNormal: Dimens.textTitle,
          //                   inter: false,
          //                   maxline: 1,
          //                   fontwaight: FontWeight.w600,
          //                   overflow: TextOverflow.ellipsis,
          //                   fontstyle: FontStyle.normal),
          //               const SizedBox(width: 10),
          //               const Icon(
          //                 Icons.add_box_rounded,
          //                 color: black,
          //               ),
          //             ],
          //           ),
          //         ),
          //       )
          //     : const SizedBox.shrink(),
          buildShopItem(),
          const SizedBox(height: 20),
          if (profileProvider.medialoadMore)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
              child: Utils.pageLoader(context),
            )
          else
            const SizedBox.shrink(),
        ],
      );
    }
  }

  Widget buildShopItem() {
    if (profileProvider.shopList != null &&
        (profileProvider.shopList?.length ?? 0) > 0) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: itemCount(
              context: context,
              height1600: 10,
              height1200: 8,
              height800: 6,
              height600: 4,
            ),
            maxItemsPerRow: itemCount(
              context: context,
              height1600: 10,
              height1200: 8,
              height800: 6,
              height600: 4,
            ),
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(profileProvider.shopList?.length ?? 0, (
              index,
            ) {
              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation1, animation2) =>
                              WebMarketPlaceDetail(
                                userImage:
                                    profileProvider.shopList?[index].userImage
                                        .toString() ??
                                    "",
                                userName:
                                    profileProvider.shopList?[index].userName
                                        .toString() ??
                                    "",
                                postId:
                                    profileProvider.shopList?[index].id
                                        .toString() ??
                                    "",
                                channelName:
                                    profileProvider
                                        .shopList?[index]
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
                                  profileProvider.shopList?[index].image
                                      .toString() ??
                                  "",
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          color: white,
                          text:
                              profileProvider.shopList?[index].name
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
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ),
      );
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget shopShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          maxItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(10, (index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(
                    width: MediaQuery.of(context).size.width,
                    height: 240,
                  ),
                  const SizedBox(height: 10),
                  const CustomWidget.roundrectborder(width: 130, height: 5),
                  const SizedBox(height: 7),
                  const CustomWidget.roundrectborder(width: 130, height: 5),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  /* ============================== Feed ============================== */

  Widget buildFeed() {
    if (profileProvider.loading && !profileProvider.channelloadMore) {
      return feedShimmer();
    } else {
      if (profileProvider.channelFeedList != null &&
          (profileProvider.channelFeedList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            children: [
              buildFeedItem(),
              const SizedBox(height: 20),
              if (profileProvider.channelloadMore)
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    }
  }

  Widget buildFeedItem() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          maxItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            profileProvider.channelContentList?.length ?? 0,
            (index) {
              return InkWell(
                focusColor: transparent,
                splashColor: transparent,
                highlightColor: transparent,
                hoverColor: transparent,
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation1, animation2) => WebFeedDetail(
                            userImage:
                                profileProvider
                                    .channelFeedList?[index]
                                    .profileImg
                                    .toString() ??
                                "",
                            userName:
                                profileProvider.channelFeedList?[index].fullName
                                    .toString() ??
                                "",
                            postId:
                                profileProvider.channelFeedList?[index].id
                                    .toString() ??
                                "",
                            channelName:
                                profileProvider
                                    .channelFeedList?[index]
                                    .channelName
                                    .toString() ??
                                "",
                          ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: MyNetworkImage(
                              width: 180,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                              imagePath:
                                  profileProvider
                                              .channelFeedList?[index]
                                              .postContent?[0]
                                              .contentType ==
                                          1
                                      ? (profileProvider
                                              .channelFeedList?[index]
                                              .postContent?[0]
                                              .contentUrl
                                              .toString() ??
                                          "")
                                      : (profileProvider
                                              .channelFeedList?[index]
                                              .postContent?[0]
                                              .thumbnailImage
                                              .toString() ??
                                          ""),
                            ),
                          ),
                          /* Play Button */
                          profileProvider
                                      .channelFeedList?[index]
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
                          /* Delete Button */
                          (profileProvider.channelFeedList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                              ? Positioned.fill(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () async {
                                      await profileProvider.deletePost(
                                        profileProvider
                                                .channelFeedList?[index]
                                                .id
                                                .toString() ??
                                            "",
                                        Constant.channelID,
                                      );

                                      if (profileProvider.successModel.status ==
                                          200) {
                                        if (!mounted) return;
                                        Utils.showSnackbar(
                                          context,
                                          profileProvider
                                                  .successModel
                                                  .message ??
                                              "",
                                          false,
                                        );
                                        profileProvider.clearChannelFeed();
                                        _fetchChannelFeedData(0);
                                      } else {
                                        if (!mounted) return;
                                        Utils.showSnackbar(
                                          context,
                                          profileProvider
                                                  .successModel
                                                  .message ??
                                              "",
                                          false,
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: MyImage(
                                        width: 20,
                                        height: 20,
                                        color: colorAccent,
                                        imagePath: "ic_delete.png",
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      Positioned.fill(
                        bottom: 15,
                        top: 15,
                        left: 15,
                        right: 15,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: MyText(
                            color: white,
                            text:
                                profileProvider.channelFeedList?[index].title
                                    .toString()
                                    .toUpperCase() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            inter: false,
                            maxline: 2,
                            multilanguage: false,
                            fontwaight: FontWeight.w900,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget feedShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          maxItemsPerRow: itemCount(
            context: context,
            height1600: 10,
            height1200: 8,
            height800: 6,
            height600: 4,
          ),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return const CustomWidget.roundcorner(height: 250);
          }),
        ),
      ),
    );
  }

  /* ============================== Feed ============================== */

  /* Coin History */

  Widget buildCoinHistory() {
    if (profileProvider.coinhistoryloading && !profileProvider.loadMore) {
      return Utils.pageLoader(context);
    } else {
      return SizedBox(
        width:
            MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width * 0.50
                : MediaQuery.of(context).size.width,
        child: Column(
          children: [
            buildCoinHistoryItem(),
            if (profileProvider.coinhistoryloadMore)
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
  }

  Widget buildCoinHistoryItem() {
    if (profileProvider.adspackageTransectionModel.status == 200 &&
        profileProvider.packageTransectionList != null) {
      if ((profileProvider.packageTransectionList?.length ?? 0) > 0) {
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
                profileProvider.packageTransectionList?.length ?? 0,
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
                                          profileProvider
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
                                              profileProvider
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
                              "${Constant.currencySymbol} ${profileProvider.packageTransectionList?[index].price.toString() ?? ""}",
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

  Widget buildWithdrawal() {
    if (profileProvider.withdrawalloading &&
        !profileProvider.withdrawalloadMore) {
      return Utils.pageLoader(context);
    } else {
      return SizedBox(
        width:
            MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width * 0.50
                : MediaQuery.of(context).size.width,
        child: Column(
          children: [
            buildWithdrawalItem(),
            if (profileProvider.withdrawalloadMore)
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
  }

  Widget buildWithdrawalItem() {
    if (profileProvider.withdrawalrequestModel.status == 200 &&
        profileProvider.withdrawalTransectionList != null) {
      if ((profileProvider.withdrawalTransectionList?.length ?? 0) > 0) {
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
                profileProvider.withdrawalTransectionList?.length ?? 0,
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
                                    profileProvider
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
                                        profileProvider
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
                              "${Constant.currencySymbol} ${profileProvider.withdrawalTransectionList?[index].amount.toString() ?? ""}",
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
        padding: const EdgeInsets.all(10.0),
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

  /* MyQRCode Dilog */

  myQrcodeDilog({required BuildContext context}) async {
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
                AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: transparent,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: colorPrimary,
                  ),
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: transparent,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 25,
                          color: white,
                        ),
                      ),
                    ),
                  ],
                  title: MyText(
                    color: white,
                    multilanguage: true,
                    text: "myqrcode",
                    textalign: TextAlign.center,
                    fontsizeNormal: 16,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                QrImageView(
                  data: "${Constant.userID},${Constant.channelID},${true}",
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: const QrEyeStyle(
                    color: colorAccent,
                    eyeShape: QrEyeShape.square,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    color: colorAccent,
                    dataModuleShape: QrDataModuleShape.square,
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(
                  indent: 30,
                  endIndent: 30,
                  thickness: 1,
                  color: colorAccent,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: white, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      imagePath: Constant.userImage ?? "",
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                MyText(
                  color: white,
                  text: Constant.channelName ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textMedium,
                  inter: false,
                  multilanguage: false,
                  maxline: 1,
                  fontwaight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
