import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:slike/provider/subscriptionprovider.dart';
import 'package:slike/subscription/allpayment.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/weblogin.dart';
import 'package:slike/webwidget/interactivecontainer.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../model/packagemodel.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription> {
  late SubscriptionProvider subscriptionProvider;
  CarouselSliderController pageController = CarouselSliderController();
  SharedPre sharedPre = SharedPre();
  String? userName, userEmail, userMobileNo;

  @override
  void initState() {
    subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );
    super.initState();
    getApi();
  }

  getApi() async {
    await subscriptionProvider.getPackage();
    await _getUserData();
    setState(() {});
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    super.dispose();
  }

  _checkAndPay(List<Result>? packageList, int index) async {
    printLog("Click Primum");
    if (Constant.userID != null) {
      printLog("Enter Dilog");
      /* Update Required data for payment */
      if ((userName ?? "").isEmpty ||
          (userEmail ?? "").isEmpty ||
          (userMobileNo ?? "").isEmpty) {
        if (kIsWeb) {
          printLog("Enter Web");
          updateDataDialogWeb(
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
        } else {
          printLog("Enter Mobile");
          updateDataDialogMobile(
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
        }
      }
      /* Update Required data for payment */
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation1, animation2) => AllPayment(
                payType: 'Package',
                itemId: packageList?[index].id.toString() ?? '',
                price: packageList?[index].price.toString() ?? '',
                itemTitle: packageList?[index].name.toString() ?? '',
                typeId: '',
                videoType: '',
                productPackage:
                    (!kIsWeb)
                        ? (Platform.isIOS
                            ? (packageList?[index].iosProductPackage
                                    .toString() ??
                                '')
                            : (packageList?[index].androidProductPackage
                                    .toString() ??
                                ''))
                        : '',
                currency: '',
                coin: '',
                roomId: '',
              ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      printLog("Enter Login ");
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const WebLogin(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  _getUserData() async {
    userName = await sharedPre.read("fullname");
    userEmail = await sharedPre.read("email");
    userMobileNo = await sharedPre.read("mobilenumber");
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');
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

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: colorPrimary,
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorAccent.withOpacity(0.005),
                    colorPrimary,
                    colorPrimary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    MyImage(
                      width: 200,
                      height: 200,
                      fit: BoxFit.fitWidth,
                      imagePath: "appicon.png",
                    ),
                    MyText(
                      color: white,
                      text: "subscriptionsubdiscription",
                      textalign: TextAlign.start,
                      multilanguage: true,
                      fontsizeNormal: Dimens.textExtraBig,
                      fontsizeWeb: Dimens.textExtraBig,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      fontwaight: FontWeight.w700,
                      fontstyle: FontStyle.normal,
                    ),
                    _buildSubscription(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Utils.buildBackBtn(context),
              ),
            ),
          ],
        ),
      );
    } else {
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
            text: "subscription",
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
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 190),
              child: Column(
                children: [
                  MyImage(
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    imagePath: "appicon.png",
                  ),
                  const SizedBox(height: 15),
                  MyText(
                    color: white,
                    text: "subscriptionsubdiscription",
                    textalign: TextAlign.center,
                    multilanguage: true,
                    fontsizeNormal: Dimens.textDesc,
                    fontsizeWeb: Dimens.textDesc,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w500,
                    fontstyle: FontStyle.normal,
                  ),
                  _buildSubscription(),
                ],
              ),
            ),
            Utils.musicAndAdsPanel(context),
          ],
        ),
      );
    }
  }

  Widget _buildSubscription() {
    if (subscriptionProvider.loading) {
      return SizedBox(height: 100, child: Utils.pageLoader(context));
    } else {
      if (subscriptionProvider.packageModel.status == 200 &&
          subscriptionProvider.packageModel.result!.isNotEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            /* Remaining Data */
            _buildItems(subscriptionProvider.packageModel.result),
            const SizedBox(height: 20),
          ],
        );
      } else {
        return const NoData(title: '', subTitle: '');
      }
    }
  }

  Widget _buildItems(List<Result>? packageList) {
    if (kIsWeb) {
      return buildWebItem(packageList);
    } else {
      return buildMobileItem(packageList);
    }
  }

  Widget buildMobileItem(List<Result>? packageList) {
    if (packageList != null) {
      return CarouselSlider.builder(
        itemCount: packageList.length,
        carouselController: pageController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: packageList.length > 1 ? true : false,
          enlargeFactor: 0.18,
          autoPlay: false,
          autoPlayCurve: Curves.easeInOutQuart,
          enableInfiniteScroll: packageList.length > 1 ? true : false,
          viewportFraction: packageList.length > 1 ? 0.8 : 0.9,
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 3,
                color:
                    (packageList[index].isBuy == 1
                        ? colorAccent
                        : colorPrimaryDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      constraints: const BoxConstraints(minHeight: 55),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MyText(
                              color:
                                  (packageList[index].isBuy == 1
                                      ? black
                                      : colorAccent),
                              text: packageList[index].name ?? "",
                              textalign: TextAlign.start,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              multilanguage: false,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                          const SizedBox(width: 5),
                          MyText(
                            color:
                                (packageList[index].isBuy == 1 ? black : white),
                            text:
                                "${Constant.currencySymbol} ${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w600,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: colorAccent,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
                      constraints: const BoxConstraints(minHeight: 0),
                      child: SingleChildScrollView(
                        child: _buildBenefits(packageList, index),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /* Choose Plan */
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () async {
                          _checkAndPay(packageList, index);
                        },
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: BoxDecoration(
                            color:
                                (packageList[index].isBuy == 1
                                    ? white
                                    : colorAccent),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Consumer<SubscriptionProvider>(
                            builder: (context, subscriptionProvider, child) {
                              return MyText(
                                color: black,
                                text:
                                    (packageList[index].isBuy == 1)
                                        ? "current"
                                        : "chooseplan",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                fontwaight: FontWeight.w700,
                                multilanguage: true,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildWebItem(List<Result>? packageList) {
    if (packageList != null) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemCount: packageList.length,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InteractiveContainer(
              child: (isHovered) {
                return AnimatedScale(
                  scale: isHovered ? 1.05 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Wrap(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width > 800
                                  ? MediaQuery.of(context).size.width * 0.40
                                  : MediaQuery.of(context).size.width * 0.80,
                          decoration: BoxDecoration(
                            color:
                                isHovered
                                    ? colorAccent
                                    : (packageList[index].isBuy == 1
                                        ? colorAccent
                                        : transparent),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: colorAccent),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.only(
                                  left: 18,
                                  right: 18,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 75,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: MyText(
                                        color: white,
                                        text: packageList[index].name ?? "",
                                        textalign: TextAlign.start,
                                        fontsizeNormal: Dimens.textlargeBig,
                                        fontsizeWeb: Dimens.textlargeBig,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontwaight: FontWeight.w800,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    MyText(
                                      color: white,
                                      text:
                                          "${Constant.currencySymbol} ${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                                      textalign: TextAlign.right,
                                      fontsizeNormal: Dimens.textTitle,
                                      fontsizeWeb: Dimens.textTitle,
                                      maxline: 1,
                                      multilanguage: false,
                                      overflow: TextOverflow.ellipsis,
                                      fontwaight: FontWeight.w600,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
                                constraints: const BoxConstraints(minHeight: 0),
                                child: SingleChildScrollView(
                                  child: _buildBenefits(packageList, index),
                                ),
                              ),
                              const SizedBox(height: 20),

                              /* Choose Plan */
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () async {
                                    _checkAndPay(packageList, index);
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 200,
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      0,
                                    ),
                                    margin: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      0,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isHovered
                                              ? white
                                              : (packageList[index].isBuy == 1
                                                  ? white
                                                  : colorAccent),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    alignment: Alignment.center,
                                    child: Consumer<SubscriptionProvider>(
                                      builder: (
                                        context,
                                        subscriptionProvider,
                                        child,
                                      ) {
                                        return MyText(
                                          color:
                                              isHovered
                                                  ? black
                                                  : (packageList[index].isBuy ==
                                                          1
                                                      ? black
                                                      : white),
                                          text:
                                              (packageList[index].isBuy == 1)
                                                  ? "current"
                                                  : "chooseplan",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textTitle,
                                          fontwaight: FontWeight.w700,
                                          multilanguage: true,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBenefits(List<Result>? packageList, int? index) {
    if (packageList?[index ?? 0].data != null &&
        (packageList?[index ?? 0].data?.length ?? 0) > 0) {
      return AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
        itemCount: (packageList?[index ?? 0].data?.length ?? 0),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int position) {
          return Container(
            constraints: const BoxConstraints(minHeight: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        (packageList?[index ?? 0].isBuy == 1
                            ? black
                            : colorAccent),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyText(
                    color:
                        (packageList?[index ?? 0].isBuy == 1 ? black : white),
                    text:
                        packageList?[index ?? 0].data?[position].packageKey ??
                        "",
                    textalign: TextAlign.start,
                    multilanguage: false,
                    fontsizeNormal: Dimens.textSmall,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w500,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                ((packageList?[index ?? 0].data?[position].packageValue ??
                                "") ==
                            "1" ||
                        (packageList?[index ?? 0]
                                    .data?[position]
                                    .packageValue ??
                                "") ==
                            "0")
                    ? Icon(
                      (packageList?[index ?? 0].data?[position].packageValue ??
                                  "") ==
                              "1"
                          ? Icons.check
                          : Icons.close,
                      color:
                          packageList?[index ?? 0].isBuy == 1 ? black : white,
                    )
                    : MyText(
                      color: white,
                      text:
                          packageList?[index ?? 0]
                              .data?[position]
                              .packageValue ??
                          "",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textTitle,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontwaight: FontWeight.bold,
                      fontstyle: FontStyle.normal,
                    ),
              ],
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
