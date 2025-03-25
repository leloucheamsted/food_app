import 'package:flutter/services.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/notificationprovider.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/mytext.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late NotificationProvider notificationProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    _fetchData(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (notificationProvider.currentPage ?? 0) <
            (notificationProvider.totalPage ?? 0)) {
      printLog("load more====>");
      _fetchData(notificationProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${notificationProvider.isMorePage}");
    printLog("currentPage ======> ${notificationProvider.currentPage}");
    printLog("totalPage   ======> ${notificationProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await notificationProvider.getNotification((nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    notificationProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
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
          text: "notification",
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 190),
            physics: const BouncingScrollPhysics(),
            child: buildNotification(),
          ),
          Utils.musicAndAdsPanel(context),
        ],
      ),
    );
  }

  Widget buildNotification() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationprovider, child) {
        if (notificationprovider.loading && !notificationprovider.loadMore) {
          return notificationShimmer();
        } else {
          if (notificationProvider.notificationList != null &&
              (notificationProvider.notificationList?.length ?? 0) > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                notificationList(),
                if (notificationProvider.loadMore)
                  SizedBox(height: 50, child: Utils.pageLoader(context))
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        }
      },
    );
  }

  Widget notificationList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: notificationProvider.notificationList?.length ?? 0,
      itemBuilder: (BuildContext ctx, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: colorAccent),
                  borderRadius: BorderRadius.circular(50),
                ),
                child:
                    notificationProvider.notificationList?[index].type == 1
                        ? MyImage(
                          width: 55,
                          height: 55,
                          imagePath: "ic_user.png",
                          color: colorAccent,
                        )
                        : InkWell(
                          onTap: () {
                            // if (Constant.userID == null) {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) {
                            //         return const Login();
                            //       },
                            //     ),
                            //   );
                            // } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Profile(
                                    isBottomBar: false,
                                    toUserId:
                                        notificationProvider
                                            .notificationList?[0]
                                            .userId
                                            .toString() ??
                                        "",
                                    toChannelId:
                                        notificationProvider
                                            .notificationList?[0]
                                            .userId
                                            .toString() ??
                                        "",
                                  );
                                },
                              ),
                            );
                            // }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              width: 55,
                              height: 55,
                              imagePath:
                                  notificationProvider
                                      .notificationList?[index]
                                      .userImage
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text:
                              notificationProvider
                                  .notificationList?[index]
                                  .title
                                  ?.toString() ??
                              "",
                          fontsizeNormal: Dimens.textDesc,
                          multilanguage: false,
                          maxline: 2,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.left,
                          fontstyle: FontStyle.normal,
                          fontwaight: FontWeight.w500,
                        ),
                        notificationProvider.notificationList?[index].type == 1
                            ? Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints(minHeight: 0),
                              alignment: Alignment.centerLeft,
                              child: ExpandableText(
                                notificationProvider
                                        .notificationList?[index]
                                        .message
                                        .toString() ??
                                    "sfgfgdf",
                                expandText: "Read More",
                                collapseText: "Read less",
                                maxLines: 2,
                                expandOnTextTap: true,
                                collapseOnTextTap: true,
                                linkStyle: TextStyle(
                                  fontSize: Dimens.textDesc,
                                  fontStyle: FontStyle.normal,
                                  color: colorAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                                style: TextStyle(
                                  fontSize: Dimens.textSmall,
                                  fontStyle: FontStyle.normal,
                                  color: gray,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 13),
                    deleteButton(index: index),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              notificationProvider.notificationList?[index].type == 1 ||
                      notificationProvider.notificationList?[index].type == 4
                  ? deleteButton(index: index)
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: MyNetworkImage(
                      width: 70,
                      height: 50,
                      imagePath:
                          notificationProvider
                              .notificationList?[index]
                              .contentImage
                              .toString() ??
                          "",
                      fit: BoxFit.cover,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget notificationShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (BuildContext ctx, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidget.circular(width: 55, height: 55),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(width: 250, height: 8),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(width: 250, height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget deleteButton({required index}) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationprovider, child) {
        if (notificationprovider.position == index &&
            notificationprovider.readnotificationloading) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: colorAccent,
              strokeWidth: 1,
            ),
          );
        } else {
          return InkWell(
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
                await notificationProvider.getReadNotification(
                  index,
                  notificationProvider.notificationList?[index].id
                          ?.toString() ??
                      "",
                  true,
                );
              }
            },
            child: MyImage(width: 16, height: 16, imagePath: "ic_delete.png"),
          );
        }
      },
    );
  }
}
