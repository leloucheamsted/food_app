import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../provider/generalprovider.dart';

class Otp extends StatefulWidget {
  final String fullnumber, countrycode, countryName, number;
  const Otp({
    super.key,
    required this.fullnumber,
    required this.countrycode,
    required this.countryName,
    required this.number,
  });

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
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
    log('Mobile==> ');
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeSend(false);
    });
    _getDeviceToken();
    super.initState();
  }

  _getDeviceToken() async {
    if (kIsWeb) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        printLog('Permission granted');
        await messaging.getToken().then((token) {
          strDeviceToken = token;
        });
        strDeviceType = "";
        printLog("===>strDeviceToken $strDeviceToken");
      } else {
        printLog('Permission denied');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  // color: colorPrimaryDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      alignment: Alignment.bottomCenter,
                      child: MyImage(
                        width: MediaQuery.of(context).size.width * 0.60,
                        height: MediaQuery.of(context).size.height * 0.25,
                        imagePath: "appicon.png",
                      ),
                    ),
                    MyText(
                      color: white,
                      text: "pleaseenteryourotp",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textlargeBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      color: white,
                      text: "we have sent an otp to your number",
                      textalign: TextAlign.center,
                      multilanguage: true,
                      fontsizeNormal: Dimens.textDesc,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 15),
                    MyText(
                      color: white,
                      text: widget.fullnumber.toString(),
                      textalign: TextAlign.center,
                      fontsizeNormal: 14,
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
                        textInputAction: TextInputAction.done,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        onCompleted: (value) {
                          if (pinPutController.text.toString().isEmpty) {
                            Utils.showSnackbar(context, "pleaseenterotp", true);
                          } else {
                            if (verificationId == null ||
                                verificationId == "") {
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
                        defaultPinTheme: PinTheme(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border.all(color: colorAccent, width: 1),
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
                          fontwaight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    InkWell(
                      onTap: () {
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
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Consumer<GeneralProvider>(
                          builder: (context, generalprovider, child) {
                            if (generalprovider.isProgressLoading) {
                              return const CircularProgressIndicator(
                                color: black,
                                strokeWidth: 2,
                              );
                            } else {
                              return MyText(
                                color: black,
                                text: "login",
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: MyImage(
                      width: 30,
                      height: 30,
                      imagePath: "ic_roundback.png",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    setState(() {
      pinPutController.text = authCredential.smsCode ?? "";
    });
    // User? user = FirebaseAuth.instance.currentUser;
    // log("user phoneNumber =====> ${user?.phoneNumber}");
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      log("The phone number entered is invalid!");
      Utils.showSnackbar(context, "invalidphonenumberotp", true);
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
      /* Update in Firebase */
      // Check is already sign up
      final QuerySnapshot result =
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.pathUserCollection)
              .where(
                FirestoreConstants.userid,
                isEqualTo: userCredential.user?.uid ?? "",
              )
              .get();
      final List<DocumentSnapshot> documents = result.docs;
      printLog("userCredential uid ==========> ${userCredential.user?.uid}");
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(userCredential.user?.uid ?? "")
            .set({
              FirestoreConstants.appchannelid: "",
              FirestoreConstants.appuserid: "",
              FirestoreConstants.email: userCredential.user?.email ?? "",
              FirestoreConstants.deviceToken: strDeviceToken,
              FirestoreConstants.name:
                  (userCredential.user?.displayName ?? "").isEmpty
                      ? (userCredential.user?.phoneNumber ?? "")
                      : (userCredential.user?.displayName ?? ""),
              FirestoreConstants.profileurl:
                  userCredential.user?.photoURL ?? Constant.userPlaceholder,
              FirestoreConstants.userid: userCredential.user?.uid ?? "",
              FirestoreConstants.createdAt:
                  DateTime.now().millisecondsSinceEpoch.toString(),
              FirestoreConstants.bioData:
                  "Hey!!! there I'm using ${Constant.appName} app.",
              FirestoreConstants.username: "",
              FirestoreConstants.mobileNumber:
                  userCredential.user?.phoneNumber ?? "",
              FirestoreConstants.chattingWith: null,
            });
      } else {
        updateDataInFirestore(firebasedid: userCredential.user?.uid ?? "");
      }
      _login(
        widget.number.toString(),
        userCredential.user?.uid.toString() ?? "",
      );
    } else {
      if (!mounted) return;
      generalProvider.setLoading(false);
    }
  }

  updateDataInFirestore({required String firebasedid}) {
    printLog('strDeviceToken ....==>> $strDeviceToken');
    printLog('firebasedid ....==>> $firebasedid');
    // Update data to Firestore
    FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(firebasedid)
        .update({FirestoreConstants.deviceToken: strDeviceToken})
        .then((value) => printLog("User Updated"))
        .onError((error, stackTrace) {
          printLog("updateDataFirestore error ===> ${error.toString()}");
          printLog(
            "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
          );
        });
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
    if (!generalProvider.loading) {
      if (!mounted) return;
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

        /* Update UserId And ChannelId in Firebase */
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebaseId)
            .update({
              FirestoreConstants.appchannelid:
                  generalProvider.loginModel.result?[0].channelId.toString(),
              FirestoreConstants.appuserid:
                  generalProvider.loginModel.result?[0].id.toString(),
            })
            .then((value) => printLog("User Updated"))
            .onError((error, stackTrace) {
              printLog("updateDataFirestore error ===> ${error.toString()}");
              printLog(
                "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
              );
            });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Bottombar()),
          (Route<dynamic> route) => false,
        );
      } else {
        generalProvider.setLoading(false);
        Utils.showSnackbar(context, "Error", false);
      }
    }
  }
}
