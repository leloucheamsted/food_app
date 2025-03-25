import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/provider/rentprovider.dart';
import 'package:slike/provider/subscriptionprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/weblatestfeed.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutterwave_standard_smart/flutterwave.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:uuid/uuid.dart';

final bool _kAutoConsume = Platform.isIOS || true;

class AllPayment extends StatefulWidget {
  final String? payType,
      itemId,
      price,
      coin,
      itemTitle,
      typeId,
      videoType,
      productPackage,
      currency,
      roomId;

  final int? rentSectionIndex, rentVideoIndex;
  const AllPayment({
    super.key,
    required this.payType,
    required this.itemId,
    required this.price,
    required this.coin,
    required this.itemTitle,
    required this.typeId,
    required this.videoType,
    required this.productPackage,
    required this.currency,
    required this.roomId,
    this.rentVideoIndex,
    this.rentSectionIndex,
  });

  @override
  State<AllPayment> createState() => AllPaymentState();
}

class AllPaymentState extends State<AllPayment> {
  final couponController = TextEditingController();
  late ProgressDialog prDialog;
  late SubscriptionProvider subscriptionProvider;
  late RentProvider rentProvider;
  SharedPre sharedPref = SharedPre();
  String? userId, userName, userEmail, userMobileNo, paymentId;
  String? strCouponCode = "";
  bool isPaymentDone = false;

  /* InApp Purchase */
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late List<String> _kProductIds;
  final List<PurchaseDetails> _purchases = <PurchaseDetails>[];

  /* Paytm */
  String paytmResult = "";

  /* Flutterwave */
  String selectedCurrency = "";
  bool isTestMode = true;

  /* Stripe */
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    _getData();
    if (!kIsWeb) {
      /* InApp Purchase */
      _kProductIds = <String>[widget.productPackage ?? ""];
      prDialog = ProgressDialog(context);
      _getData();
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        (List<PurchaseDetails> purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription.cancel();
        },
        onError: (Object error) {
          // handle error here.
          printLog("onError ============> ${error.toString()}");
        },
      );
      initStoreInfo();
    }
    super.initState();
  }

  _getData() async {
    subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );
    rentProvider = Provider.of<RentProvider>(context, listen: false);
    await subscriptionProvider.getPaymentOption();
    await subscriptionProvider.setFinalAmount(widget.price ?? "");

    if (subscriptionProvider.paymentOptionModel.status == 200) {
      if (subscriptionProvider.paymentOptionModel.result != null) {
        if (subscriptionProvider.paymentOptionModel.result?.flutterwave !=
            null) {}
      }
    }

    /* PaymentID */
    paymentId = Utils.generateRandomOrderID();
    printLog('paymentId =====================> $paymentId');

    userId = await sharedPref.read("userid");
    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");
    printLog('getUserData userId ==> $userId');
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    if (!kIsWeb) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        iosPlatformAddition.setDelegate(null);
      }
      _subscription.cancel();
    }
    couponController.dispose();
    super.dispose();
  }

  /* add_transaction API */
  Future addTransaction(
    packageId,
    description,
    amount,
    paymentId,
    currencyCode,
  ) async {
    Utils.showProgress(context);
    await subscriptionProvider.addTransaction(packageId, amount, description);

    if (!subscriptionProvider.payLoading) {
      await prDialog.hide();

      if (subscriptionProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;

        if (!mounted) return;
        Utils.showSnackbar(
          context,
          subscriptionProvider.successModel.message ?? "",
          false,
        );
        if (kIsWeb) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WebLatestFeed()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Bottombar()),
            (Route route) => false,
          );
        }
        // Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          subscriptionProvider.successModel.message ?? "",
          false,
        );
      }
    }
  }

  /* add_rent_transaction API */
  Future addRentTransaction(videoId, amount, typeId, videoType) async {
    Utils.showProgress(context);
    await rentProvider.getRentTransaction(
      widget.rentSectionIndex,
      widget.rentVideoIndex,
      videoId,
      amount,
      "",
      "",
    );

    if (!rentProvider.payLoading) {
      await prDialog.hide();

      if (rentProvider.rentTransectionModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;

        Utils.showSnackbar(
          context,
          rentProvider.rentTransectionModel.message ?? "",
          false,
        );
        if (kIsWeb) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WebLatestFeed()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Bottombar()),
            (Route route) => false,
          );
        }
        // Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          rentProvider.rentTransectionModel.message ?? "",
          false,
        );
      }
    }
  }

  /* ads_transaction API */
  Future adsTransaction(
    packageId,
    amount,
    coin,
    transectionId,
    discription,
  ) async {
    Utils.showProgress(context);
    await subscriptionProvider.getAdsTransaction(
      packageId,
      amount,
      coin,
      transectionId,
      discription,
    );

    if (!subscriptionProvider.payLoading) {
      await prDialog.hide();

      if (subscriptionProvider.adsTransectionModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;

        Utils.showSnackbar(
          context,
          subscriptionProvider.adsTransectionModel.message ?? "",
          false,
        );
        if (kIsWeb) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WebLatestFeed()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Bottombar()),
            (Route route) => false,
          );
        }
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          subscriptionProvider.adsTransectionModel.message ?? "",
          false,
        );
      }
    }
  }

  openPayment({required String pgName}) async {
    printLog("finalAmount =============> ${subscriptionProvider.finalAmount}");
    if (subscriptionProvider.finalAmount != "0") {
      if (pgName == "paypal") {
        _paypalInit();
      } else if (pgName == "inapp") {
        _initInAppPurchase();
      } else if (pgName == "razorpay") {
        _initializeRazorpay();
      } else if (pgName == "flutterwave") {
        _flutterwaveInit();
      } else if (pgName == "stripe") {
        _stripeInit();
      } else if (pgName == "cash") {
        if (!mounted) return;
        Utils.showSnackbar(context, "cash_payment_msg", true);
      }
    } else {
      if (widget.payType == "Package") {
        addTransaction(
          widget.itemId,
          widget.itemTitle,
          subscriptionProvider.finalAmount,
          paymentId,
          widget.currency,
        );
      } else if (widget.payType == "Rent") {
        addRentTransaction(
          widget.itemId,
          subscriptionProvider.finalAmount,
          widget.typeId,
          widget.videoType,
        );
      } else if (widget.payType == "AdsPackage") {
        adsTransaction(
          widget.itemId,
          subscriptionProvider.finalAmount,
          widget.coin,
          paymentId,
          widget.itemTitle,
        );
      }
    }
  }

  bool checkKeysAndContinue({
    required String isLive,
    required bool isBothKeyReq,
    required String liveKey1,
    required String liveKey2,
    required String testKey1,
    required String testKey2,
  }) {
    if (isLive == "1") {
      if (isBothKeyReq) {
        if (liveKey1 == "" || liveKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      } else {
        if (liveKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      }
      return true;
    } else {
      if (isBothKeyReq) {
        if (testKey1 == "" || testKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      } else {
        if (testKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar:
          !kIsWeb
              ? Utils().otherPageAppBar(context, "payment_methods", true)
              : null,
      body:
          kIsWeb
              ? _buildWebPayments()
              : SafeArea(child: Center(child: _buildMobilePage())),
    );
  }

  Widget _buildMobilePage() {
    return Container(
      width:
          ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 720)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width,
      margin:
          (kIsWeb || Constant.isTV)
              ? const EdgeInsets.fromLTRB(50, 0, 50, 50)
              : const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Coupon Code Box & Total Amount */
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              color: colorPrimaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(minHeight: 50),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(minHeight: 50),
                      decoration: Utils.setBackground(colorPrimary, 0),
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.centerLeft,
                      child: Consumer<SubscriptionProvider>(
                        builder: (context, paymentProvider, child) {
                          return RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: "Amount : ",
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: colorAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${Constant.currencySymbol}${paymentProvider.finalAmount ?? ""}",
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /* PGs */
          Expanded(
            child: SingleChildScrollView(
              child:
                  subscriptionProvider.payLoading
                      ? Container(
                        height: 230,
                        padding: const EdgeInsets.all(20),
                        child: Utils.pageLoader(context),
                      )
                      : subscriptionProvider.paymentOptionModel.status == 200
                      ? subscriptionProvider.paymentOptionModel.result != null
                          ? _buildPaymentPage()
                          : const NoData(
                            title: 'no_payment',
                            subTitle: 'no_payment_desc',
                          )
                      : const NoData(
                        title: 'no_payment',
                        subTitle: 'no_payment_desc',
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPage() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: white,
            text: "payment_methods",
            fontsizeNormal: Dimens.textTitle,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: white,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsizeNormal: Dimens.textMedium,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: white,
            text: "pay_with",
            multilanguage: true,
            fontsizeNormal: Dimens.textTitle,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* /* Payments */ */
          (!kIsWeb)
              ? ( /* Platform.isIOS ? buildIOSPG() : */ _buildAndroidPG())
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget buildIOSPG() {
    /* In-App purchase */
    return _buildIOSPGButton(
      "In-App Purchase",
      35,
      110,
      onClick: () async {
        await subscriptionProvider.setCurrentPayment("inapp");
        _initInAppPurchase();
      },
    );
  }

  Widget _buildIOSPGButton(
    String pgName,
    double imgHeight,
    double imgWidth, {
    required Function() onClick,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: colorPrimaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: MyText(
                    color: white,
                    text: pgName,
                    multilanguage: false,
                    fontsizeNormal: Dimens.textSmall,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                MyImage(
                  imagePath: "ic_right.png",
                  fit: BoxFit.contain,
                  height: 22,
                  width: 20,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidPG() {
    return Column(
      children: [
        /* In-App purchase */
        subscriptionProvider.paymentOptionModel.result?.inapppurchage != null
            ? subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.inapppurchage
                        ?.visibility ==
                    "1"
                ? _buildPGButton(
                  "pg_inapp.png",
                  "InApp Purchase",
                  35,
                  110,
                  onClick: () async {
                    await subscriptionProvider.setCurrentPayment("inapp");
                    openPayment(pgName: "inapp");
                  },
                )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paypal */
        subscriptionProvider.paymentOptionModel.result?.paypal != null
            ? subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.paypal
                        ?.visibility ==
                    "1"
                ? _buildPGButton(
                  "pg_paypal.png",
                  "Paypal",
                  35,
                  130,
                  onClick: () async {
                    await subscriptionProvider.setCurrentPayment("paypal");
                    openPayment(pgName: "paypal");
                  },
                )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Razorpay */
        subscriptionProvider.paymentOptionModel.result?.razorpay != null
            ? subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.razorpay
                        ?.visibility ==
                    "1"
                ? _buildPGButton(
                  "pg_razorpay.png",
                  "Razorpay",
                  35,
                  130,
                  onClick: () async {
                    await subscriptionProvider.setCurrentPayment("razorpay");
                    openPayment(pgName: "razorpay");
                  },
                )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paytm */
        subscriptionProvider.paymentOptionModel.result?.paytm != null
            ? subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.paytm
                        ?.visibility ==
                    "1"
                ? _buildPGButton(
                  "pg_paytm.png",
                  "Paytm",
                  30,
                  90,
                  onClick: () async {
                    await subscriptionProvider.setCurrentPayment("paytm");
                    openPayment(pgName: "paytm");
                  },
                )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Flutterwave */
        subscriptionProvider.paymentOptionModel.result?.flutterwave != null
            ? subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.flutterwave
                        ?.visibility ==
                    "1"
                ? _buildPGButton(
                  "pg_flutterwave.png",
                  "Flutterwave",
                  35,
                  130,
                  onClick: () async {
                    await subscriptionProvider.setCurrentPayment("flutterwave");
                    openPayment(pgName: "flutterwave");
                  },
                )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* PayUMoney */
        subscriptionProvider.paymentOptionModel.result?.payumoney != null
            ? subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.payumoney
                        ?.visibility ==
                    "1"
                ? _buildPGButton(
                  "pg_payumoney.png",
                  "PayU Money",
                  35,
                  130,
                  onClick: () async {
                    await subscriptionProvider.setCurrentPayment("payumoney");
                    openPayment(pgName: "payumoney");
                  },
                )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildPGButton(
    String imageName,
    String pgName,
    double imgHeight,
    double imgWidth, {
    required Function() onClick,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: colorPrimaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MyImage(
                  imagePath: imageName,
                  fit: BoxFit.contain,
                  height: imgHeight,
                  width: imgWidth,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    text: pgName,
                    multilanguage: false,
                    fontsizeNormal: Dimens.textMedium,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    textalign: TextAlign.end,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 15),
                MyImage(
                  imagePath: "ic_right.png",
                  fit: BoxFit.fill,
                  height: 22,
                  width: 20,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebPayments() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyImage(
                width: 400,
                height: 100,
                fit: BoxFit.cover,
                imagePath: "appicon.png",
              ),
              const SizedBox(height: 25),
              MyText(
                color: white,
                text: "payment_methods",
                maxline: 1,
                fontsizeNormal: Dimens.textExtralargeBig,
                fontsizeWeb: Dimens.textExtralargeBig,
                multilanguage: true,
                overflow: TextOverflow.ellipsis,
                fontwaight: FontWeight.w700,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(height: 15),
              MyText(
                color: white,
                text: "choose_a_payment_methods_to_pay_disc",
                multilanguage: true,
                fontsizeNormal: Dimens.textTitle,
                fontsizeWeb: Dimens.textTitle,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                fontwaight: FontWeight.w500,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(height: 50),
              /* Price */
              Consumer<SubscriptionProvider>(
                builder: (context, paymentProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText(
                        color: white,
                        text: "total",
                        multilanguage: true,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w600,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                      MyText(
                        color: white,
                        text: ":",
                        multilanguage: false,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w600,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(width: 20),
                      MyText(
                        color: white,
                        text:
                            "${Constant.currencySymbol} ${paymentProvider.finalAmount ?? ""}",
                        multilanguage: false,
                        fontsizeNormal: Dimens.textExtralargeBig,
                        fontsizeWeb: Dimens.textExtralargeBig,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w700,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
              /* Razorpay */
              InkWell(
                onTap: () async {
                  await subscriptionProvider.setCurrentPayment("razorpay");
                  openPayment(pgName: "razorpay");
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: colorPrimaryDark),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyImage(
                        width: 100,
                        height: 50,
                        imagePath: "pg_razorpay.png",
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 15),
                      MyText(
                        color: white,
                        text: "continuewithrazorpay",
                        multilanguage: true,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w600,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    );
  }

  /* ********* InApp purchase START ********* */
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {});
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse = await _inAppPurchase
        .queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {});
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {});
  }

  _initInAppPurchase() async {
    printLog(
      "_initInAppPurchase _kProductIds ============> ${_kProductIds[0].toString()}",
    );
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails(_kProductIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      Utils().showToast("Please check SKU");
      return;
    }
    printLog("productID ============> ${response.productDetails[0].id}");
    late PurchaseParam purchaseParam;
    if (Platform.isAndroid) {
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: response.productDetails[0],
      );
    } else {
      purchaseParam = PurchaseParam(productDetails: response.productDetails[0]);
    }
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          printLog(
            "purchaseDetails ============> ${purchaseDetails.error.toString()}",
          );
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          printLog("===> status ${purchaseDetails.status}");
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kProductIds[0]) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase
                    .getPlatformAddition<
                      InAppPurchaseAndroidPlatformAddition
                    >();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          printLog(
            "===> pendingCompletePurchase ${purchaseDetails.pendingCompletePurchase}",
          );
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    printLog("===> productID ${purchaseDetails.productID}");
    if (purchaseDetails.productID == _kProductIds[0]) {
      if (widget.payType == "Package") {
        addTransaction(
          widget.itemId,
          widget.itemTitle,
          subscriptionProvider.finalAmount,
          paymentId,
          widget.currency,
        );
      } else if (widget.payType == "Rent") {
        addRentTransaction(
          widget.itemId,
          subscriptionProvider.finalAmount,
          widget.typeId,
          widget.videoType,
        );
      } else if (widget.payType == "AdsPackage") {
        adsTransaction(
          widget.itemId,
          subscriptionProvider.finalAmount,
          widget.coin,
          paymentId,
          widget.itemTitle,
        );
      }
      setState(() {});
    } else {
      printLog("===> consumables else $purchaseDetails");
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void showPendingUI() {
    setState(() {});
  }

  void handleError(IAPError error) {
    setState(() {});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    printLog("invalid Purchase ===> $purchaseDetails");
  }
  /* ********* InApp purchase END ********* */

  /* ********* Razorpay START ********* */
  void _initializeRazorpay() {
    if (subscriptionProvider.paymentOptionModel.result?.razorpay != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (subscriptionProvider.paymentOptionModel.result?.razorpay?.isLive ??
                ""),
        isBothKeyReq: false,
        liveKey1:
            (subscriptionProvider.paymentOptionModel.result?.razorpay?.key1 ??
                ""),
        liveKey2: "",
        testKey1:
            (subscriptionProvider.paymentOptionModel.result?.razorpay?.key1 ??
                ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */

      Razorpay razorpay = Razorpay();
      var options = {
        'key':
            (subscriptionProvider.paymentOptionModel.result?.razorpay?.isLive ==
                    "1")
                ? (subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.razorpay
                        ?.key1 ??
                    "")
                : (subscriptionProvider
                        .paymentOptionModel
                        .result
                        ?.razorpay
                        ?.key1 ??
                    ""),
        'currency': Constant.currency,
        'amount': (double.parse(subscriptionProvider.finalAmount ?? "") * 100),
        'name': widget.itemTitle ?? "",
        'description': widget.itemTitle ?? "",
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': userMobileNo, 'email': userEmail},
        'external': {
          'wallets': ['paytm'],
        },
      };
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

      try {
        razorpay.open(options);
      } catch (e) {
        printLog('Razorpay Error :=========> $e');
      }
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    Utils.showSnackbar(context, "payment_fail", true);
    await subscriptionProvider.setCurrentPayment("");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    paymentId = response.paymentId.toString();
    printLog("paymentId ========> $paymentId");
    Utils.showSnackbar(context, "payment_success", true);
    if (widget.payType == "Package") {
      addTransaction(
        widget.itemId,
        widget.itemTitle,
        subscriptionProvider.finalAmount,
        paymentId,
        widget.currency,
      );
    } else if (widget.payType == "Rent") {
      addRentTransaction(
        widget.itemId,
        subscriptionProvider.finalAmount,
        widget.typeId,
        widget.videoType,
      );
    } else if (widget.payType == "AdsPackage") {
      adsTransaction(
        widget.itemId,
        subscriptionProvider.finalAmount,
        widget.coin,
        paymentId,
        widget.itemTitle,
      );
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    printLog("============ External Wallet Selected ============");
  }
  /* ********* Razorpay END ********* */

  /* ********* Paypal START ********* */
  Future<void> _paypalInit() async {
    if (subscriptionProvider.paymentOptionModel.result?.paypal != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.isLive ??
                ""),
        isBothKeyReq: true,
        liveKey1:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key1 ??
                ""),
        liveKey2:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key2 ??
                ""),
        testKey1:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key1 ??
                ""),
        testKey2:
            (subscriptionProvider.paymentOptionModel.result?.paypal?.key2 ??
                ""),
      );
      if (!isContinue) return;
      /* Check Keys */

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => const Text('data'),
        ),
        //   UsePaypal(
        //       sandboxMode: (subscriptionProvider.paymentOptionModel.result?.paypal
        //                       ?.isLive ??
        //                   "") ==
        //               "1"
        //           ? false
        //           : true,
        //       clientId: (subscriptionProvider
        //                   .paymentOptionModel.result?.paypal?.isLive ==
        //               "1")
        //           ? (subscriptionProvider
        //                   .paymentOptionModel.result?.paypal?.key1 ??
        //               "")
        //           : (subscriptionProvider
        //                   .paymentOptionModel.result?.paypal?.key1 ??
        //               ""),
        //       secretKey:
        //           (subscriptionProvider
        //                       .paymentOptionModel.result?.paypal?.isLive ==
        //                   "1")
        //               ? (subscriptionProvider
        //                       .paymentOptionModel.result?.paypal?.key2 ??
        //                   "")
        //               : (subscriptionProvider
        //                       .paymentOptionModel.result?.paypal?.key2 ??
        //                   ""),
        //       returnURL: "return.example.com",
        //       cancelURL: "cancel.example.com",
        //       transactions: [
        //         {
        //           "amount": {
        //             "total": '${subscriptionProvider.finalAmount}',
        //             "currency": Constant.currency,
        //             "details": {
        //               "subtotal": '${subscriptionProvider.finalAmount}',
        //               "shipping": '0',
        //               "shipping_discount": 0
        //             }
        //           },
        //           "description": widget.payType ?? "",
        //           "item_list": {
        //             "items": [
        //               {
        //                 "name": "${widget.itemTitle}",
        //                 "quantity": 1,
        //                 "price": '${subscriptionProvider.finalAmount}',
        //                 "currency": Constant.currency
        //               }
        //             ],
        //           }
        //         }
        //       ],
        //       note: "Contact us for any questions on your order.",
        //       onSuccess: (params) async {
        //         printLog("onSuccess: ${params["paymentId"]}");
        //         if (widget.payType == "Package") {
        //           addTransaction(
        //               widget.itemId,
        //               widget.itemTitle,
        //               subscriptionProvider.finalAmount,
        //               params["paymentId"],
        //               widget.currency);
        //         } else if (widget.payType == "Rent") {
        //           addRentTransaction(
        //               widget.itemId,
        //               subscriptionProvider.finalAmount,
        //               widget.typeId,
        //               widget.videoType);
        //         } else if (widget.payType == "AdsPackage") {
        //           adsTransaction(
        //               widget.itemId,
        //               subscriptionProvider.finalAmount,
        //               widget.coin,
        //               paymentId,
        //               widget.itemTitle);
        //         }
        //       },
        //       onError: (params) {
        //         printLog("onError: ${params["message"]}");
        //         Utils.showSnackbar(
        //             context, params["message"].toString(), false);
        //       },
        //       onCancel: (params) {
        //         printLog('cancelled: $params');
        //         Utils.showSnackbar(context, params.toString(), false);
        //       }),
        // ),
      );
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }
  /* ********* Paypal END ********* */

  /* ********* Stripe START ********* */
  Future<void> _stripeInit() async {
    if (subscriptionProvider.paymentOptionModel.result?.stripe != null) {
      stripe.Stripe.publishableKey =
          (subscriptionProvider.paymentOptionModel.result?.stripe?.isLive ==
                  "1")
              ? (subscriptionProvider.paymentOptionModel.result?.stripe?.key1 ??
                  "")
              : (subscriptionProvider.paymentOptionModel.result?.stripe?.key1 ??
                  "");
      try {
        //STEP 1: Create Payment Intent
        paymentIntent = await createPaymentIntent(
          subscriptionProvider.finalAmount ?? "",
          Constant.currency,
        );

        //STEP 2: Initialize Payment Sheet
        await stripe.Stripe.instance
            .initPaymentSheet(
              paymentSheetParameters: stripe.SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntent?['client_secret'],
                style: ThemeMode.light,
                merchantDisplayName: Constant.appName,
              ),
            )
            .then((value) {});

        //STEP 3: Display Payment sheet
        displayPaymentSheet();
      } catch (err) {
        throw Exception(err);
      }
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'description': widget.itemTitle,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer ${(subscriptionProvider.paymentOptionModel.result?.stripe?.isLive == "1") ? (subscriptionProvider.paymentOptionModel.result?.stripe?.key1 ?? "") : (subscriptionProvider.paymentOptionModel.result?.stripe?.key2 ?? "")}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  displayPaymentSheet() async {
    try {
      await stripe.Stripe.instance
          .presentPaymentSheet()
          .then((value) {
            Utils.showSnackbar(context, "payment_success", true);
            if (widget.payType == "Package") {
              addTransaction(
                widget.itemId,
                widget.itemTitle,
                subscriptionProvider.finalAmount,
                paymentId,
                widget.currency,
              );
            } else if (widget.payType == "Rent") {
              addRentTransaction(
                widget.itemId,
                subscriptionProvider.finalAmount,
                widget.typeId,
                widget.videoType,
              );
            } else if (widget.payType == "AdsPackage") {
              adsTransaction(
                widget.itemId,
                subscriptionProvider.finalAmount,
                widget.coin,
                paymentId,
                widget.itemTitle,
              );
            }

            paymentIntent = null;
          })
          .onError((error, stackTrace) {
            throw Exception(error);
          });
    } on stripe.StripeException catch (e) {
      printLog('Error is:---> $e');
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      printLog('$e');
    }
  }
  /* ********* Stripe END ********* */

  /* ********* Flutterwave START ********* */
  _flutterwaveInit() async {
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive:
          (subscriptionProvider
                  .paymentOptionModel
                  .result
                  ?.flutterwave
                  ?.isLive ??
              ""),
      isBothKeyReq: false,
      liveKey1:
          (subscriptionProvider.paymentOptionModel.result?.flutterwave?.key1 ??
              ""),
      liveKey2: "",
      testKey1:
          (subscriptionProvider.paymentOptionModel.result?.flutterwave?.key1 ??
              ""),
      testKey2: "",
    );
    if (!isContinue) return;
    /* Check Keys */

    final Customer customer = Customer(
      email: userEmail ?? "",
      name: userName ?? "",
      phoneNumber: userMobileNo ?? '',
    );

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey:
          (subscriptionProvider
                      .paymentOptionModel
                      .result
                      ?.flutterwave
                      ?.isLive ==
                  "1")
              ? (subscriptionProvider
                      .paymentOptionModel
                      .result
                      ?.flutterwave
                      ?.key1 ??
                  "")
              : (subscriptionProvider
                      .paymentOptionModel
                      .result
                      ?.flutterwave
                      ?.key1 ??
                  ""),
      currency: Constant.currency,
      redirectUrl: 'https://www.divinetechs.com',
      txRef: const Uuid().v1(),
      amount: widget.price.toString().trim(),
      customer: customer,
      paymentOptions: "card, payattitude, barter, bank transfer, ussd",
      customization: Customization(title: widget.itemTitle),
      isTestMode:
          subscriptionProvider.paymentOptionModel.result?.flutterwave?.isLive !=
          "1",
    );
    ChargeResponse? response = await flutterwave.charge();
    printLog("Flutterwave response =====> ${response.toJson()}");
    if (response.status == "success" && response.success == true) {
      paymentId = response.transactionId.toString();
      printLog("paymentId ========> $paymentId");
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_success", true);

      if (widget.payType == "Package") {
        addTransaction(
          widget.itemId,
          widget.itemTitle,
          subscriptionProvider.finalAmount,
          paymentId,
          widget.currency,
        );
      } else if (widget.payType == "Rent") {
        addRentTransaction(
          widget.itemId,
          subscriptionProvider.finalAmount,
          widget.typeId,
          widget.videoType,
        );
      } else if (widget.payType == "AdsPackage") {
        adsTransaction(
          widget.itemId,
          subscriptionProvider.finalAmount,
          widget.coin,
          paymentId,
          widget.itemTitle,
        );
      }
    } else if (response.status == "cancel" && response.status == "cancelled") {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_cancel", true);
    } else {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_fail", true);
    }
  }
  /* ********* Flutterwave END ********* */

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context, isPaymentDone);
    }
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
