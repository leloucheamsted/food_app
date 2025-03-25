import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';
import 'package:slike/utils/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/weblatestfeed.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../provider/generalprovider.dart';

class WebOTP extends StatefulWidget {
  final String fullnumber, countrycode, countryName, number;
  const WebOTP({
    super.key,
    required this.fullnumber,
    required this.countrycode,
    required this.countryName,
    required this.number,
  });

  @override
  State<WebOTP> createState() => _WebOTPState();
}

class _WebOTPState extends State<WebOTP> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final pinPutController = TextEditingController();
  String? strDeviceType, strDeviceToken;
  bool codeResended = false;
  int? forceResendingToken;
  String? verificationId;

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeSend(false);
    });
    _getDeviceToken();
    super.initState();
  }

  _getDeviceToken() async {
    try {
      if (kIsWeb) {
        strDeviceType = "3";
        strDeviceToken = Constant.webToken;
      } else {
        if (Platform.isAndroid) {
          strDeviceType = "1";
          strDeviceToken = await FirebaseMessaging.instance.getToken();
        } else {
          strDeviceType = "2";
          strDeviceToken = OneSignal.User.pushSubscription.id.toString();
        }
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>diviceType $strDeviceType");
    printLog("===>diviceToken $strDeviceToken");
  }

  @override
  Widget build(BuildContext context) {
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
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyImage(
                    imagePath: "appicon.png",
                    width: 200,
                    height: 200,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 20),
                  MyText(
                    color: white,
                    text: "pleaseenteryourotp",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textBig,
                    fontsizeWeb: Dimens.textBig,
                    multilanguage: true,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    color: white,
                    text: "we have sent an otp to your number",
                    textalign: TextAlign.center,
                    multilanguage: true,
                    fontsizeNormal: Dimens.textDesc,
                    fontsizeWeb: Dimens.textDesc,
                    inter: false,
                    maxline: 2,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    color: colorAccent,
                    text: widget.fullnumber.toString(),
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    fontsizeWeb: Dimens.textMedium,
                    inter: false,
                    multilanguage: false,
                    maxline: 2,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 55,
                    child: Pinput(
                      length: 6,
                      keyboardType: TextInputType.number,
                      controller: pinPutController,
                      onCompleted: (value) {
                        if (pinPutController.text.toString().isEmpty) {
                          Utils.showSnackbar(context, "pleaseenterotp", true);
                        } else {
                          if (verificationId == null || verificationId == "") {
                            Utils.showSnackbar(
                              context,
                              "otp_not_working",
                              true,
                            );
                            return;
                          }
                          generalProvider.setLoading(true);
                          _checkOTPAndLogin();
                        }
                      },
                      textInputAction: TextInputAction.done,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      defaultPinTheme: PinTheme(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorAccent, width: 0.5),
                          color: colorPrimaryDark,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textStyle: GoogleFonts.roboto(
                          color: white,
                          fontSize: Dimens.textBig,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      codeSend(true);
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 70),
                      padding: const EdgeInsets.all(5),
                      child: MyText(
                        color: white,
                        text: "resend",
                        multilanguage: true,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        fontwaight: FontWeight.w700,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  InkWell(
                    onTap: () {
                      if (pinPutController.text.toString().isEmpty) {
                        Utils.showSnackbar(context, "pleaseenterotp", true);
                      } else {
                        if (verificationId == null || verificationId == "") {
                          Utils.showSnackbar(context, "otp_not_working", true);
                          return;
                        }
                        generalProvider.setLoading(true);
                        _checkOTPAndLogin();
                      }
                    },
                    child: Container(
                      width:
                          kIsWeb && MediaQuery.of(context).size.width > 1200
                              ? MediaQuery.of(context).size.width * 0.35
                              : kIsWeb &&
                                  MediaQuery.of(context).size.width > 800
                              ? MediaQuery.of(context).size.width * 0.50
                              : MediaQuery.of(context).size.width * 0.75,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                        color: black,
                        fontsizeWeb: 16,
                        text: "login",
                        fontsizeNormal: 16,
                        fontwaight: FontWeight.w500,
                        maxline: 1,
                        multilanguage: true,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Consumer<GeneralProvider>(
                    builder: (context, generalprovider, child) {
                      if (generalprovider.isProgressLoading) {
                        return const CircularProgressIndicator(
                          color: colorAccent,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
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
  }

  codeSend(bool isResend) async {
    generalProvider.setLoading(true);
    log("================>>Code send Successfully<<<============");
    await phoneSignIn(phoneNumber: widget.fullnumber);
    if (!mounted) return;
    generalProvider.setLoading(false);
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    log("================>>Verify Your Mobile Number <<<============");
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    log("verification completed ======> ${authCredential.smsCode}");
    // User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      pinPutController.text = authCredential.smsCode ?? "";
    });
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      Utils.showSnackbar(context, "invalidphonenumberotp", true);
      log("invalidphonenumberotp");
      generalProvider.setLoading(false);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    log("verificationId =======> $verificationId");
    log("resendingToken =======> ${forceResendingToken.toString()}");
    log("code sent");
    Utils.showSnackbar(context, "coderesendsuccessfully", true);
    generalProvider.setLoading(false);
    _checkOTPAndLogin();
  }

  _onCodeTimeout(String verificationId) {
    log("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
    generalProvider.setLoading(false);
    return null;
  }

  _checkOTPAndLogin() async {
    bool error = false;
    UserCredential? userCredential;

    printLog("_checkOTPAndLogin verificationId =====> $verificationId");
    printLog("_checkOTPAndLogin smsCode =====> ${pinPutController.text}");
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId ?? "",
      smsCode: pinPutController.text.toString(),
    );

    printLog(
      "phoneAuthCredential.smsCode        =====> ${phoneAuthCredential.smsCode}",
    );
    printLog(
      "phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}",
    );
    try {
      userCredential = await auth.signInWithCredential(phoneAuthCredential);
      printLog(
        "_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}",
      );
    } on FirebaseAuthException catch (e) {
      generalProvider.setLoading(false);
      log("_checkOTPAndLogin error Code =====> ${e.code}");
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        if (!mounted) return;
        // Utils.showSnackbar(context, "otpinvalid");
        return;
      } else if (e.code == 'session-expired') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpsessionexpired", true);
        return;
      } else {
        error = true;
      }
    }
    printLog(
      "Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error",
    );
    if (!error && userCredential != null) {
      _login(
        widget.number.toString(),
        userCredential.user?.uid.toString() ?? "",
      );
    } else {
      if (!mounted) return;
      generalProvider.setLoading(false);
    }
  }

  _login(String mobile, String firebaseId) async {
    printLog("click on Submit mobile =====> $mobile");
    printLog("click on Submit firebaseId => $firebaseId");
    final generalProvider = Provider.of<GeneralProvider>(
      context,
      listen: false,
    );
    generalProvider.setLoading(true);
    await generalProvider.login(
      "1",
      "",
      mobile,
      strDeviceType ?? "",
      strDeviceToken ?? "",
      widget.countrycode,
      widget.countryName,
      firebaseId,
    );
    printLog('test');
    if (!generalProvider.loading) {
      generalProvider.setLoading(false);
      if (generalProvider.loginModel.status == 200) {
        /* Save Users Credentials */
        Utils.saveUserCreds(
          userID: generalProvider.loginModel.result?[0].id.toString(),
          firebaseId:
              generalProvider.loginModel.result?[0].firebaseId.toString(),
          channeId: generalProvider.loginModel.result?[0].channelId.toString(),
          channelName:
              generalProvider.loginModel.result?[0].channelName.toString(),
          fullName: generalProvider.loginModel.result?[0].fullName.toString(),
          email: generalProvider.loginModel.result?[0].email.toString(),
          mobileNumber:
              generalProvider.loginModel.result?[0].mobileNumber.toString(),
          image: generalProvider.loginModel.result?[0].image.toString(),
          coverImg: generalProvider.loginModel.result?[0].coverImg.toString(),
          deviceType:
              generalProvider.loginModel.result?[0].deviceType.toString(),
          deviceToken:
              generalProvider.loginModel.result?[0].deviceToken.toString(),
          userIsBuy: generalProvider.loginModel.result?[0].isBuy.toString(),
          isAdsFree: generalProvider.loginModel.result?[0].adsFree.toString(),
          isDownload:
              generalProvider.loginModel.result?[0].isDownload.toString(),
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WebLatestFeed()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        generalProvider.setLoading(false);
        Utils.showSnackbar(context, "Error", false);
      }
    }
  }
}
