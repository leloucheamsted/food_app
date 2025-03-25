import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:slike/provider/marketplacedetailprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';

class WebMarketPlaceDetail extends StatefulWidget {
  final String userImage, userName, channelName, postId;

  const WebMarketPlaceDetail({
    super.key,
    required this.userImage,
    required this.userName,
    required this.channelName,
    required this.postId,
  });

  @override
  State<WebMarketPlaceDetail> createState() => WebMarketPlaceDetailState();
}

class WebMarketPlaceDetailState extends State<WebMarketPlaceDetail> {
  late MarketPlaceDetailProvider marketPlaceDetailProvider;

  @override
  void initState() {
    marketPlaceDetailProvider = Provider.of<MarketPlaceDetailProvider>(
      context,
      listen: false,
    );
    super.initState();
    getApi();
  }

  getApi() async {
    marketPlaceDetailProvider.getShopDetail(widget.postId);
  }

  @override
  void dispose() {
    marketPlaceDetailProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: "webmarketplacedetails",
        categoryTap: () {},
      ),

      // appBar: AppBar(
      //   centerTitle: false,
      //   backgroundColor: transparent,
      //   titleSpacing: 0,
      //   scrolledUnderElevation: 0,
      //   surfaceTintColor: transparent,
      //   leading: InkWell(
      //     focusColor: transparent,
      //     highlightColor: transparent,
      //     hoverColor: transparent,
      //     splashColor: transparent,
      //     onTap: () {
      //       Navigator.of(context).pop(false);
      //     },
      //     child: Align(
      //         alignment: Alignment.center,
      //         child: MyImage(
      //             width: 30, height: 30, imagePath: "ic_roundback.png")),
      //   ),
      //   title: Padding(
      //     padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
      //     child: Row(
      //       children: [
      //         Expanded(
      //           child: InkWell(
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) {
      //                     return Profile(
      //                       isBottomBar: false,
      //                       toUserId: marketPlaceDetailProvider
      //                               .marketPlaceDetailModel.result?[0].userId
      //                               .toString() ??
      //                           "",
      //                       toChannelId: marketPlaceDetailProvider
      //                               .marketPlaceDetailModel
      //                               .result?[0]
      //                               .userChannelId
      //                               .toString() ??
      //                           "",
      //                     );
      //                   },
      //                 ),
      //               );
      //             },
      //             child: Row(
      //               children: [
      //                 ClipRRect(
      //                   borderRadius: BorderRadius.circular(50),
      //                   child: MyNetworkImage(
      //                     fit: BoxFit.cover,
      //                     width: 35,
      //                     height: 35,
      //                     imagePath: widget.userImage,
      //                   ),
      //                 ),
      //                 const SizedBox(width: 10),
      //                 MyText(
      //                     color: white,
      //                     text: widget.userName == ""
      //                         ? widget.channelName
      //                         : widget.userName,
      //                     textalign: TextAlign.center,
      //                     fontsizeNormal: Dimens.textTitle,
      //                     fontsizeWeb: Dimens.textTitle,
      //                     multilanguage: false,
      //                     inter: true,
      //                     maxline: 1,
      //                     fontwaight: FontWeight.w600,
      //                     overflow: TextOverflow.ellipsis,
      //                     fontstyle: FontStyle.normal),
      //               ],
      //             ),
      //           ),
      //         ),
      //         const SizedBox(width: 10),
      //         Consumer<MarketPlaceDetailProvider>(
      //             builder: (context, feeddetailprovider, child) {
      //           if (feeddetailprovider.loading) {
      //             return const SizedBox.shrink();
      //           } else {
      //             return Constant.userID ==
      //                     marketPlaceDetailProvider
      //                         .marketPlaceDetailModel.result?[0].userId
      //                         .toString()
      //                 ? const SizedBox.shrink()
      //                 : InkWell(
      //                     hoverColor: transparent,
      //                     highlightColor: transparent,
      //                     splashColor: transparent,
      //                     focusColor: transparent,
      //                     onTap: () async {
      //                       if (Constant.userID == null) {
      //                         Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) {
      //                               return const Login();
      //                             },
      //                           ),
      //                         );
      //                       } else {
      //                         await marketPlaceDetailProvider
      //                             .addRemoveSubscriber(
      //                                 marketPlaceDetailProvider
      //                                         .marketPlaceDetailModel
      //                                         .result?[0]
      //                                         .userId
      //                                         .toString() ??
      //                                     "",
      //                                 "1");
      //                       }
      //                     },
      //                     child: Container(
      //                       padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      //                       decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(50),
      //                           border: Border.all(
      //                               width: 0.9,
      //                               color: marketPlaceDetailProvider
      //                                           .marketPlaceDetailModel
      //                                           .result?[0]
      //                                           .isSubscribe ==
      //                                       0
      //                                   ? gray
      //                                   : gray),
      //                           color: marketPlaceDetailProvider
      //                                       .marketPlaceDetailModel
      //                                       .result?[0]
      //                                       .isSubscribe ==
      //                                   0
      //                               ? colorPrimary
      //                               : colorAccent),
      //                       child: Row(
      //                         children: [
      //                           MyImage(
      //                             width: 16,
      //                             height: 16,
      //                             color: marketPlaceDetailProvider
      //                                         .marketPlaceDetailModel
      //                                         .result?[0]
      //                                         .isSubscribe ==
      //                                     0
      //                                 ? white
      //                                 : black,
      //                             imagePath: marketPlaceDetailProvider
      //                                         .marketPlaceDetailModel
      //                                         .result?[0]
      //                                         .isSubscribe ==
      //                                     0
      //                                 ? "ic_followuser.png"
      //                                 : "ic_usertrue.png",
      //                           ),
      //                           const SizedBox(width: 5),
      //                           MyText(
      //                               color: marketPlaceDetailProvider
      //                                           .marketPlaceDetailModel
      //                                           .result?[0]
      //                                           .isSubscribe ==
      //                                       0
      //                                   ? white
      //                                   : black,
      //                               multilanguage: true,
      //                               text: marketPlaceDetailProvider
      //                                           .marketPlaceDetailModel
      //                                           .result?[0]
      //                                           .isSubscribe ==
      //                                       0
      //                                   ? "follow"
      //                                   : "following",
      //                               textalign: TextAlign.center,
      //                               fontsizeNormal: Dimens.textMedium,
      //                               fontsizeWeb: Dimens.textMedium,
      //                               inter: true,
      //                               maxline: 1,
      //                               fontwaight: FontWeight.w600,
      //                               overflow: TextOverflow.ellipsis,
      //                               fontstyle: FontStyle.normal),
      //                         ],
      //                       ),
      //                     ),
      //                   );
      //           }
      //         }),
      //       ],
      //     ),
      //   ),
      // ),
      body: Utils.sidePanelWithBody(
        myWidget: Consumer<MarketPlaceDetailProvider>(
          builder: (context, feeddetailprovider, child) {
            if (feeddetailprovider.loading) {
              return shimmer();
            } else {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [feedDetail()],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  shimmer() {
    return const SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              children: [
                CustomWidget.roundrectborder(height: 15),
                CustomWidget.roundrectborder(height: 15),
              ],
            ),
          ),
          CustomWidget.rectangular(height: 250),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                CustomWidget.rectangular(height: 10),
                SizedBox(height: 15),
                Row(
                  children: [
                    CustomWidget.roundcorner(height: 40, width: 80),
                    CustomWidget.roundcorner(height: 40, width: 80),
                    CustomWidget.roundcorner(height: 40, width: 80),
                  ],
                ),
                SizedBox(height: 15),
                CustomWidget.roundrectborder(height: 10, width: 120),
                SizedBox(height: 15),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Column(
                      children: [
                        CustomWidget.roundrectborder(height: 10, width: 250),
                        CustomWidget.roundrectborder(height: 10, width: 250),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(5.0),
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
                    const SizedBox(width: 5),
                    MyText(
                      color: white,
                      multilanguage: false,
                      text: count.toString(),
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
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

  Widget feedDetail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: MyText(
            color: white,
            text:
                marketPlaceDetailProvider.marketPlaceDetailModel.result?[0].name
                    .toString() ??
                "",
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textBig,
            fontsizeWeb: Dimens.textBig,
            maxline: 5,
            multilanguage: false,
            fontwaight: FontWeight.w700,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: MyNetworkImage(
            width: 250,
            height: 250,
            fit: BoxFit.cover,
            imagePath:
                marketPlaceDetailProvider
                    .marketPlaceDetailModel
                    .result?[0]
                    .image
                    .toString() ??
                "",
          ),
        ),
        const SizedBox(height: 20),
        marketPlaceDetailProvider
                    .marketPlaceDetailModel
                    .result?[0]
                    .descripation ==
                ""
            ? const SizedBox.shrink()
            : Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: ExpandableText(
                expandOnTextTap: true,
                collapseOnTextTap: true,
                textAlign: TextAlign.center,
                linkStyle: GoogleFonts.inter(
                  fontSize: Dimens.textMedium,
                  fontStyle: FontStyle.normal,
                  color: gray,
                  fontWeight: FontWeight.w500,
                ),
                style: GoogleFonts.inter(
                  fontSize: Dimens.textMedium,
                  fontStyle: FontStyle.normal,
                  color: white,
                  fontWeight: FontWeight.w400,
                ),
                marketPlaceDetailProvider
                        .marketPlaceDetailModel
                        .result?[0]
                        .descripation
                        .toString() ??
                    "",
                expandText: 'Read More',
                collapseText: "Read Less",
                linkColor: colorAccent,
                maxLines: 5,
              ),
            ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: MyText(
            color: white,
            text:
                "${Constant.currencySymbol}${marketPlaceDetailProvider.marketPlaceDetailModel.result?[0].price.toString() ?? ""}",
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textExtraBig,
            fontsizeWeb: Dimens.textExtraBig,
            maxline: 5,
            multilanguage: false,
            fontwaight: FontWeight.w700,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              Utils.lanchAdsUrl(
                marketPlaceDetailProvider.marketPlaceDetailModel.result?[0].url
                        .toString() ??
                    "",
              );
            },
            child: Container(
              width: 120,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: white,
              ),
              child: MyText(
                color: black,
                text: "buynow",
                textalign: TextAlign.center,
                fontsizeNormal: Dimens.textBig,
                fontsizeWeb: Dimens.textBig,
                maxline: 1,
                multilanguage: true,
                fontwaight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
