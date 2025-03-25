import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/provider/subscriptionprovider.dart';
import 'package:slike/subscription/allpayment.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slike/model/adspackagemodel.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class AdsPackage extends StatefulWidget {
  const AdsPackage({super.key});

  @override
  State<AdsPackage> createState() => AdsPackageState();
}

class AdsPackageState extends State<AdsPackage> {
  late SubscriptionProvider subscriptionProvider;
  late ProfileProvider profileProvider;
  CarouselSliderController pageController = CarouselSliderController();
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();
  PageController rechargeController = PageController();

  List rechargeBanner = ["ic_gym1.jpg", "ic_gym2.jpg", "ic_gym3.jpg"];

  @override
  void initState() {
    subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    getApi();
  }

  getApi() async {
    await subscriptionProvider.getAdsPackage();
    await _getUserData();
    setState(() {});
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    super.dispose();
  }

  _getUserData() async {
    userName = await sharedPre.read("fullname");
    userEmail = await sharedPre.read("email");
    userMobileNo = await sharedPre.read("mobilenumber");
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar:
          kIsWeb
              ? Utils.webAppbarWithSidePanel(
                context: context,
                contentType: Constant.videoSearch,
              )
              : Utils().otherPageAppBar(context, "recharge", true),
      body:
          kIsWeb
              ? Utils.sidePanelWithBody(
                myWidget: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [showTitleWithBanner(), _buildAdsSubscription()],
                  ),
                ),
              )
              : Stack(
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 190),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        showTitleWithBanner(),
                        _buildAdsSubscription(),
                      ],
                    ),
                  ),
                  Utils.musicAndAdsPanel(context),
                ],
              ),
    );
  }

  Widget showTitleWithBanner() {
    return Consumer<ProfileProvider>(
      builder: (context, profileprovider, child) {
        return kIsWeb
            ? Container(
              padding: const EdgeInsets.fromLTRB(20, 45, 20, 45),
              width:
                  MediaQuery.of(context).size.width > 1200
                      ? MediaQuery.of(context).size.width * 0.50
                      : MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: colorPrimaryDark,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "Current Balance",
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textBig,
                          fontsizeWeb: Dimens.textExtraBig,
                          maxline: 1,
                          multilanguage: false,
                          overflow: TextOverflow.ellipsis,
                          fontwaight: FontWeight.w700,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyImage(
                              width: 22,
                              height: 22,
                              imagePath: "ic_coin.png",
                            ),
                            const SizedBox(width: 8),
                            profileprovider.loading
                                ? MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: "0",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textBig,
                                  fontsizeWeb: Dimens.textBig,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                )
                                : MyText(
                                  color: white,
                                  multilanguage: false,
                                  text:
                                      profileProvider.profileModel.status == 200
                                          ? (profileProvider
                                                  .profileModel
                                                  .result?[0]
                                                  .walletBalance
                                                  .toString() ??
                                              "")
                                          : "0",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textBig,
                                  fontsizeWeb: Dimens.textBig,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                            const SizedBox(width: 5),
                            MyText(
                              color: white,
                              multilanguage: true,
                              text: "coins",
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
                      ],
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       PageRouteBuilder(
                  //         pageBuilder: (context, animation1, animation2) =>
                  //             const WebWallet(),
                  //         transitionDuration: Duration.zero,
                  //         reverseTransitionDuration: Duration.zero,
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  //     decoration: BoxDecoration(
                  //       color: white,
                  //       borderRadius: BorderRadius.circular(5),
                  //     ),
                  //     child: MyText(
                  //       color: black,
                  //       text: "gotowallet",
                  //       textalign: TextAlign.start,
                  //       fontsizeNormal: Dimens.textSmall,
                  //       maxline: 1,
                  //       multilanguage: true,
                  //       overflow: TextOverflow.ellipsis,
                  //       fontwaight: FontWeight.w700,
                  //       fontstyle: FontStyle.normal,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            )
            : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  color: white,
                  text: "adspackagetitle",
                  textalign: TextAlign.start,
                  fontsizeNormal: 26,
                  fontsizeWeb: 26,
                  maxline: 2,
                  multilanguage: true,
                  overflow: TextOverflow.ellipsis,
                  fontwaight: FontWeight.bold,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 10),
                MyText(
                  color: gray,
                  text: "adspackagesubtitle",
                  textalign: TextAlign.start,
                  fontsizeNormal: Dimens.textSmall,
                  fontsizeWeb: Dimens.textSmall,
                  maxline: 3,
                  multilanguage: true,
                  overflow: TextOverflow.ellipsis,
                  fontwaight: FontWeight.w400,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  decoration: BoxDecoration(
                    color: transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: rechargeController,
                        itemCount: rechargeBanner.length,
                        itemBuilder:
                            (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: MyImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: rechargeBanner[index],
                              ),
                            ),
                      ),
                      Positioned.fill(
                        bottom: 10,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SmoothPageIndicator(
                            controller: rechargeController,
                            count: rechargeBanner.length,
                            effect: const ExpandingDotsEffect(
                              dotWidth: 10,
                              dotHeight: 8,
                              dotColor: colorPrimaryDark,
                              expansionFactor: 4,
                              offset: 1,
                              activeDotColor: white,
                              radius: 100,
                              strokeWidth: 1,
                              spacing: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
      },
    );
  }

  Widget _buildAdsSubscription() {
    return Consumer<SubscriptionProvider>(
      builder: (context, adspackageprovider, child) {
        log("Loading===> ${adspackageprovider.adspackageLoading}");
        if (adspackageprovider.adspackageLoading) {
          return commanShimmer();
        } else {
          if (adspackageprovider.adsPackageModel.status == 200) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      kIsWeb
                          ? const EdgeInsets.fromLTRB(0, 50, 0, 0)
                          : const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: MyText(
                    color: white,
                    text: "purchaseplan",
                    textalign: TextAlign.start,
                    fontsizeNormal: Dimens.textDesc,
                    fontsizeWeb: Dimens.textlargeBig,
                    maxline: 1,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                /* Remaining Data */
                buildAdsItem(adspackageprovider.adsPackageModel.result),
                const SizedBox(height: 20),
              ],
            );
          } else {
            return const NoData(title: '', subTitle: '');
          }
        }
      },
    );
  }

  Widget buildAdsItem(List<Result>? packageList) {
    if (packageList != null) {
      return SizedBox(
        width:
            kIsWeb && MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width * 0.50
                : MediaQuery.of(context).size.width,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 14),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow:
                  kIsWeb && MediaQuery.of(context).size.width > 1200 ? 1 : 2,
              maxItemsPerRow:
                  kIsWeb && MediaQuery.of(context).size.width > 1200 ? 1 : 2,
              horizontalGridSpacing: 20,
              verticalGridSpacing: 20,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(packageList.length, (index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  decoration: BoxDecoration(
                    color: colorPrimaryDark,
                    border: Border.all(width: 1.5, color: lightgray),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child:
                      (kIsWeb && MediaQuery.of(context).size.width > 1200)
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyImage(
                                width: 70,
                                height: 70,
                                imagePath: "ic_withdraw_coin.webp",
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      color: colorAccent,
                                      text: packageList[index].coin.toString(),
                                      textalign: TextAlign.start,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      maxline: 1,
                                      multilanguage: false,
                                      overflow: TextOverflow.ellipsis,
                                      fontwaight: FontWeight.w500,
                                      fontstyle: FontStyle.normal,
                                    ),
                                    const SizedBox(width: 5),
                                    MyText(
                                      color: colorAccent,
                                      text: "coins",
                                      textalign: TextAlign.start,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      maxline: 1,
                                      multilanguage: true,
                                      overflow: TextOverflow.ellipsis,
                                      fontwaight: FontWeight.w500,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              MyText(
                                color: white,
                                text:
                                    "${Constant.currencySymbol} ${packageList[index].price.toString()}",
                                textalign: TextAlign.start,
                                fontsizeNormal: Dimens.textlargeBig,
                                fontsizeWeb: Dimens.textlargeBig,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontwaight: FontWeight.w700,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {
                                  _checkAndPay(packageList, index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    25,
                                    8,
                                    25,
                                    8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: MyText(
                                    color: black,
                                    text: "pay_now",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    maxline: 1,
                                    multilanguage: true,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            children: [
                              MyImage(
                                width: 70,
                                height: 70,
                                imagePath: "ic_withdraw_coin.webp",
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    color: colorAccent,
                                    text: packageList[index].coin.toString(),
                                    textalign: TextAlign.start,
                                    fontsizeNormal: Dimens.textSmall,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w400,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(width: 5),
                                  MyText(
                                    color: colorAccent,
                                    text: "coins",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: Dimens.textSmall,
                                    maxline: 1,
                                    multilanguage: true,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w400,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              MyText(
                                color: white,
                                text:
                                    "${Constant.currencySymbol} ${packageList[index].price.toString()}",
                                textalign: TextAlign.start,
                                fontsizeNormal: Dimens.textlargeBig,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontwaight: FontWeight.w700,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  _checkAndPay(packageList, index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    25,
                                    8,
                                    25,
                                    8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: MyText(
                                    color: black,
                                    text: "pay_now",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: Dimens.textMedium,
                                    maxline: 1,
                                    multilanguage: true,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                );
              }),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget commanShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: CustomWidget.roundrectborder(height: 8, width: 100),
        ),
        /* Remaining Data */
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 14,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(8, (index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  decoration: BoxDecoration(
                    color: colorPrimaryDark,
                    border: Border.all(width: 0.4, color: gray),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CustomWidget.circular(height: 20, width: 20),
                            SizedBox(width: 5),
                            CustomWidget.roundrectborder(height: 8, width: 150),
                          ],
                        ),
                      ),
                      CustomWidget.roundrectborder(height: 35, width: 70),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  _checkAndPay(List<Result>? packageList, int index) async {
    if (Constant.userID != null) {
      /* Update Required data for payment */

      if ((userName ?? "").isEmpty ||
          (userEmail ?? "").isEmpty ||
          (userMobileNo ?? "").isEmpty) {
        if (kIsWeb) {
          updateDataDialogWeb(
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
          return;
        } else {
          updateDataDialogMobile(
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
          return;
        }
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AllPayment(
              coin: packageList?[index].coin.toString() ?? '',
              payType: 'AdsPackage',
              itemId: packageList?[index].id.toString() ?? '',
              price: packageList?[index].price.toString() ?? '',
              itemTitle: packageList?[index].name.toString() ?? '',
              typeId: '',
              videoType: '',
              productPackage:
                  (!kIsWeb)
                      ? (Platform.isIOS
                          ? (packageList?[index].iosProductPackage.toString() ??
                              '')
                          : (packageList?[index].androidProductPackage
                                  .toString() ??
                              ''))
                      : '',
              currency: '',
              roomId: '',
            );
          },
        ),
      );
      /* Update Required data for payment */
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Login();
          },
        ),
      );
    }
  }

  updateDataDialogMobile({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!context.mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: colorPrimary,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!context.mounted) return;
        setState(() {});
      });
    }
  }

  updateDataDialogWeb({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!context.mounted) return;
    dynamic result = await showDialog<dynamic>(
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
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: 400,
              maxHeight: 450,
            ),
            child: Wrap(
              children: [
                Utils.dataUpdateDialog(
                  context,
                  isNameReq: isNameReq,
                  isEmailReq: isEmailReq,
                  isMobileReq: isMobileReq,
                  nameController: nameController,
                  emailController: emailController,
                  mobileController: mobileController,
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!context.mounted) return;
        setState(() {});
      });
    }
  }
}
