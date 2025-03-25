import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:slike/livestream/liveuserlistprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/socketmanager.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class LiveUserList extends StatefulWidget {
  const LiveUserList({super.key});

  @override
  State<LiveUserList> createState() => LiveUserListState();
}

class LiveUserListState extends State<LiveUserList> {
  late LiveUserListProvider liveUserListProvider;
  late ScrollController _scrollController;
  io.Socket? socket;

  @override
  void initState() {
    liveUserListProvider = Provider.of<LiveUserListProvider>(
      context,
      listen: false,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListenerCategory);
    super.initState();
    _fetchLiveUser(0);
  }

  socketIO(callback) {
    SocketManager socketManager = SocketManager();
    socket = socketManager.socket;

    if (socket?.connected == true) {
      callback();
    } else {
      Utils.showSnackbar(
        context,
        "Socket Connection Faild Please Check Connection!!!",
        false,
      );
    }
  }

  _scrollListenerCategory() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (liveUserListProvider.currentPage ?? 0) <
            (liveUserListProvider.totalPage ?? 0)) {
      await liveUserListProvider.setLoadMore(true);
      _fetchLiveUser(liveUserListProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchLiveUser(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await liveUserListProvider.getLiveUserList((nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    liveUserListProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,

      // appBar: AppBar(
      //   toolbarHeight: 60,
      //   automaticallyImplyLeading: false,
      //   backgroundColor: colorPrimary,
      //   surfaceTintColor: transparent,
      //   flexibleSpace: SafeArea(
      //     bottom: false,
      //     child: Center(
      //       child: Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 15),
      //         child: Row(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             MyText(
      //                 color: white,
      //                 multilanguage: true,
      //                 text: "live_streaming",
      //                 textalign: TextAlign.center,
      //                 fontsizeNormal: Dimens.textBig,
      //                 inter: false,
      //                 maxline: 1,
      //                 fontwaight: FontWeight.bold,
      //                 overflow: TextOverflow.ellipsis,
      //                 fontstyle: FontStyle.normal),
      //             const SizedBox(width: 8),
      //             Expanded(
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.end,
      //                 children: [
      //                   // InkWell(
      //                   //   onTap: () {},
      //                   //   child: Container(
      //                   //     height: 36,
      //                   //     width: 36,
      //                   //     decoration: const BoxDecoration(
      //                   //         color: colorAccent, shape: BoxShape.circle),
      //                   //     child:
      //                   //         const Center(child: Icon(Icons.search_rounded)),
      //                   //   ),
      //                   // ),
      //                   // const SizedBox(width: 5),
      //                   InkWell(
      //                     onTap: () {
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(
      //                           builder: (context) {
      //                             return const GoLiveViewPreview();
      //                           },
      //                         ),
      //                       );
      //                     },
      //                     child: Container(
      //                       height: 36,
      //                       width: 100,
      //                       decoration: BoxDecoration(
      //                           color: colorAccent,
      //                           borderRadius: BorderRadius.circular(24)),
      //                       child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         children: [
      //                           MyImage(
      //                               width: 22,
      //                               height: 22,
      //                               color: black,
      //                               imagePath: "ic_top_streaming.webp"),
      //                           const SizedBox(width: 5),
      //                           MyText(
      //                               color: black,
      //                               multilanguage: true,
      //                               text: "go_live",
      //                               textalign: TextAlign.center,
      //                               fontsizeNormal: Dimens.textMedium,
      //                               inter: false,
      //                               maxline: 1,
      //                               fontwaight: FontWeight.w600,
      //                               overflow: TextOverflow.ellipsis,
      //                               fontstyle: FontStyle.normal),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: colorPrimaryDark,
          color: colorAccent,
          displacement: 70,
          edgeOffset: 1.0,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          strokeWidth: 3,
          onRefresh: () async {
            liveUserListProvider.clearProvider();
            _fetchLiveUser(0);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: buildLiveUserList(),
          ),
        ),
      ),
    );
  }

  Widget buildLiveUserList() {
    return Consumer<LiveUserListProvider>(
      builder: (context, liveuserlistprovider, child) {
        if (liveuserlistprovider.loading && !liveuserlistprovider.loadMore) {
          return shimmer();
        } else {
          if (liveuserlistprovider.liveUserList != null &&
              (liveuserlistprovider.liveUserList?.length ?? 0) > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildLiveUserListItem(),
                if (liveuserlistprovider.loadMore)
                  SizedBox(height: 50, child: Utils.pageLoader(context))
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.80,
              alignment: Alignment.center,
              child: MyImage(
                width: 200,
                height: 200,
                imagePath: "ic_commingsoon.png",
              ),
            );
          }
        }
      },
    );
  }

  Widget buildLiveUserListItem() {
    return GridView.builder(
      itemCount: liveUserListProvider.liveUserList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Utils.jumpToLive(
              context: context,
              isHost: false,
              userId: Constant.userID,
              roomId:
                  liveUserListProvider.liveUserList?[index].roomId.toString() ??
                  "",
              userImage:
                  liveUserListProvider.liveUserList?[index].image.toString() ??
                  "",
              name:
                  liveUserListProvider.liveUserList?[index].channelName
                      .toString() ??
                  "",
              userName:
                  liveUserListProvider.liveUserList?[index].channelName
                      .toString() ??
                  "",
            );
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      Container(
                        height: 180,
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            MyNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              imagePath:
                                  liveUserListProvider
                                      .liveUserList?[index]
                                      .image
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: white,
                              size: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: MyText(
                                color: white,
                                multilanguage: false,
                                text:
                                    liveUserListProvider
                                        .liveUserList?[index]
                                        .totalView
                                        .toString() ??
                                    "",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textExtraSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              // Text(
                              //   CustomFormatNumber.convert(views),
                              //   style: AppFontStyle.styleW700(
                              //       AppColor.white, 10.0),
                              // ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 10,
                        child: Container(
                          height: 20,
                          width: 45,
                          decoration: BoxDecoration(
                            color: white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: white, width: 0.3),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: -5,
                                child: Lottie.asset(
                                  "assets/images/lottie_wave_animation.json",
                                  fit: BoxFit.cover,
                                  height: 20,
                                  width: 15,
                                ),
                              ),
                              Positioned(
                                right: 5,
                                child: MyText(
                                  color: white,
                                  multilanguage: true,
                                  text: "live",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            width: 28,
                            height: 28,
                            imagePath:
                                liveUserListProvider.liveUserList?[index].image
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MyText(
                                      color: white,
                                      multilanguage: false,
                                      text:
                                          liveUserListProvider
                                              .liveUserList?[index]
                                              .fullName
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textSmall,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                  // Visibility(
                                  //   visible: isVerified,
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(
                                  //         left: 2),
                                  //     child: Image.asset(
                                  //         AppAsset.icBlueTick,
                                  //         width: 15),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: MyText(
                                color: white,
                                multilanguage: false,
                                text:
                                    liveUserListProvider
                                        .liveUserList?[index]
                                        .channelName
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textExtraSmall,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // isFake
                        //     ? Container(
                        //         height: 20,
                        //         width: 20,
                        //         child: Image.network(countryFlag))
                        //     : Text(
                        //         countryFlag,
                        //         style: AppFontStyle.styleW700(
                        //             AppColor.black, 18),
                        //       ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget shimmer() {
    return GridView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemBuilder: (context, index) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorPrimaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: 180,
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomWidget.circular(width: 28, height: 28),
                      SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomWidget.rectangular(height: 5, width: 200),
                            CustomWidget.rectangular(width: 150, height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
