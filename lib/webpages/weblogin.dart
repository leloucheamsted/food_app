import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/webpages/weblatestfeed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';

class WebLogin extends StatefulWidget {
  const WebLogin({super.key});

  @override
  State<WebLogin> createState() => _WebLoginState();
}

class _WebLoginState extends State<WebLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late GeneralProvider generalProvider;
  SharedPre sharePref = SharedPre();
  bool passwordVisible = false;
  File? mProfileImg;
  dynamic strDeviceToken;
  String? deviceType;
  bool isagreeCondition = false;

  TextEditingController numberController = TextEditingController();
  String mobilenumber = "", countrycode = "", countryname = "";
  int? forceResendingToken;
  String? verificationId;
  String? initialcountryCode = "IN";
  String countryCode = "";
  // ignore: deprecated_member_use

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    _getDeviceToken();
  }

  _getDeviceToken() async {
    try {
      if (kIsWeb) {
        deviceType = "3";
        strDeviceToken = Constant.webToken;
      } else {
        if (Platform.isAndroid) {
          deviceType = "1";
          strDeviceToken = await FirebaseMessaging.instance.getToken();
        } else {
          deviceType = "2";
          strDeviceToken = OneSignal.User.pushSubscription.id.toString();
        }
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>diviceType $deviceType");
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
              padding: const EdgeInsets.all(15),
              scrollDirection: Axis.vertical,
              child: Column(children: [loginItem()]),
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

  Widget loginItem() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyImage(
          imagePath: "appicon.png",
          width: 250,
          height: 200,
          fit: BoxFit.fitWidth,
        ),
        const SizedBox(height: 20),
        MyText(
          color: white,
          text: "hello",
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textExtraBig,
          fontsizeWeb: Dimens.textExtraBig,
          multilanguage: true,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w800,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
        const SizedBox(height: 10),
        MyText(
          color: white,
          fontsizeWeb: Dimens.textlargeBig,
          fontsizeNormal: Dimens.textlargeBig,
          text: "loginyouraccount",
          fontwaight: FontWeight.w600,
          maxline: 1,
          multilanguage: true,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.center,
          fontstyle: FontStyle.normal,
        ),
        const SizedBox(height: 10),
        MyText(
          color: white,
          fontsizeWeb: Dimens.textTitle,
          text: "logindisciption",
          fontsizeNormal: Dimens.textTitle,
          fontwaight: FontWeight.w400,
          maxline: 5,
          multilanguage: true,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.center,
          fontstyle: FontStyle.normal,
        ),
        const SizedBox(height: 20),
        // SizedBox(
        //   width: kIsWeb && MediaQuery.of(context).size.width > 1200
        //       ? MediaQuery.of(context).size.width * 0.35
        //       : kIsWeb && MediaQuery.of(context).size.width > 800
        //           ? MediaQuery.of(context).size.width * 0.50
        //           : MediaQuery.of(context).size.width * 0.75,
        //   child: IntlPhoneField(
        //     keyboardType: TextInputType.number,
        //     cursorColor: white,
        //     textInputAction: TextInputAction.done,
        //     controller: numberController,
        //     initialCountryCode: initialcountryCode,
        //     showCountryFlag: true,
        //     dropdownTextStyle: GoogleFonts.inter(
        //         fontSize: Dimens.textMedium,
        //         fontStyle: FontStyle.normal,
        //         color: white,
        //         fontWeight: FontWeight.w500),
        //     onChanged: (phone) {
        //       mobilenumber = phone.completeNumber;
        //       countryname = phone.countryISOCode;
        //       countrycode = phone.countryCode;
        //       log('mobile number==> $mobilenumber');
        //       log('countryCode number==> $countryname');
        //       log('countryISOCode==> $countrycode');
        //     },
        //     onCountryChanged: (country) {
        //       countryname = country.code.replaceAll('+', '');
        //       countrycode = "+${country.dialCode.toString()}";
        //       log('countryname===> $countryname');
        //       log('countrycode===> $countrycode');
        //     },
        //     style: GoogleFonts.inter(
        //         fontSize: Dimens.textMedium,
        //         fontStyle: FontStyle.normal,
        //         color: white,
        //         fontWeight: FontWeight.w500),
        //     decoration: InputDecoration(
        //       hintText: Locales.string(context, "mobilenumber"),
        //       hintStyle: GoogleFonts.inter(
        //           fontSize: Dimens.textMedium,
        //           fontStyle: FontStyle.normal,
        //           color: white,
        //           fontWeight: FontWeight.w400),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(5),
        //         borderSide: const BorderSide(width: 0.5, color: gray),
        //       ),
        //       disabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(5),
        //         borderSide: const BorderSide(width: 0.5, color: gray),
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(5),
        //         borderSide: const BorderSide(width: 0.5, color: gray),
        //       ),
        //       contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        //       border:
        //           OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        //       fillColor: white,
        //       filled: false,
        //     ),
        //     onSubmitted: (newValue) {
        //       if (numberController.text.isEmpty) {
        //         Utils.showSnackbar(
        //             context, "pleaseenteryourmobilenumber", true);
        //       } else if (isagreeCondition != true) {
        //         Utils.showSnackbar(
        //             context, "pleaseaccepttermsandcondition", true);
        //       } else {
        //         Navigator.push(
        //           context,
        //           PageRouteBuilder(
        //             pageBuilder: (context, animation1, animation2) => WebOTP(
        //               fullnumber: mobilenumber,
        //               countrycode: countrycode,
        //               countryName: countryname,
        //               number: numberController.text,
        //             ),
        //             transitionDuration: Duration.zero,
        //             reverseTransitionDuration: Duration.zero,
        //           ),
        //         );
        //       }
        //     },
        //   ),
        // ),
        // const SizedBox(height: 15),
        // InkWell(
        //   onTap: () {
        //     if (numberController.text.isEmpty) {
        //       Utils.showSnackbar(context, "pleaseenteryourmobilenumber", true);
        //     } else if (isagreeCondition != true) {
        //       Utils.showSnackbar(
        //           context, "pleaseaccepttermsandcondition", true);
        //     } else {
        //       Navigator.push(
        //         context,
        //         PageRouteBuilder(
        //           pageBuilder: (context, animation1, animation2) => WebOTP(
        //             fullnumber: mobilenumber,
        //             countrycode: countrycode,
        //             countryName: countryname,
        //             number: numberController.text,
        //           ),
        //           transitionDuration: Duration.zero,
        //           reverseTransitionDuration: Duration.zero,
        //         ),
        //       );
        //     }
        //   },
        //   child: Container(
        //     width: kIsWeb && MediaQuery.of(context).size.width > 1200
        //         ? MediaQuery.of(context).size.width * 0.35
        //         : kIsWeb && MediaQuery.of(context).size.width > 800
        //             ? MediaQuery.of(context).size.width * 0.50
        //             : MediaQuery.of(context).size.width * 0.75,
        //     height: 50,
        //     alignment: Alignment.center,
        //     decoration: BoxDecoration(
        //       color: colorAccent,
        //       borderRadius: BorderRadius.circular(5),
        //     ),
        //     child: MyText(
        //         color: black,
        //         fontsizeWeb: 16,
        //         text: "login",
        //         fontsizeNormal: 16,
        //         fontwaight: FontWeight.w500,
        //         maxline: 1,
        //         multilanguage: true,
        //         overflow: TextOverflow.ellipsis,
        //         textalign: TextAlign.center,
        //         fontstyle: FontStyle.normal),
        //   ),
        // ),
        // const SizedBox(height: 20),
        // /* Accept Terms & Consition */
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Theme(
        //       data: ThemeData(
        //         unselectedWidgetColor: white,
        //       ),
        //       child: Checkbox(
        //         value: isagreeCondition,
        //         activeColor: colorAccent,
        //         checkColor: black,
        //         onChanged: (bool? isagreeCondition) {
        //           setState(() {
        //             this.isagreeCondition = isagreeCondition!;
        //           });
        //         },
        //       ),
        //     ),
        //     Row(
        //       children: [
        //         MyText(
        //             color: white,
        //             text: "termconditionfirst",
        //             textalign: TextAlign.center,
        //             fontsizeNormal: Dimens.textSmall,
        //             multilanguage: true,
        //             inter: false,
        //             fontsizeWeb: Dimens.textSmall,
        //             maxline: 1,
        //             fontwaight: FontWeight.w400,
        //             overflow: TextOverflow.ellipsis,
        //             fontstyle: FontStyle.normal),
        //         MyText(
        //             color: colorAccent,
        //             text: "terms",
        //             textalign: TextAlign.center,
        //             fontsizeNormal: Dimens.textSmall,
        //             fontsizeWeb: Dimens.textSmall,
        //             multilanguage: true,
        //             inter: false,
        //             maxline: 2,
        //             fontwaight: FontWeight.w400,
        //             overflow: TextOverflow.ellipsis,
        //             fontstyle: FontStyle.normal),
        //         MyText(
        //             color: colorAccent,
        //             text: "condition",
        //             textalign: TextAlign.center,
        //             fontsizeNormal: Dimens.textSmall,
        //             fontsizeWeb: Dimens.textSmall,
        //             multilanguage: true,
        //             inter: false,
        //             maxline: 2,
        //             fontwaight: FontWeight.w400,
        //             overflow: TextOverflow.ellipsis,
        //             fontstyle: FontStyle.normal),
        //         MyText(
        //             color: colorAccent,
        //             text: "privacy_policy",
        //             textalign: TextAlign.left,
        //             fontsizeNormal: Dimens.textSmall,
        //             fontsizeWeb: Dimens.textSmall,
        //             multilanguage: true,
        //             inter: false,
        //             maxline: 1,
        //             fontwaight: FontWeight.w400,
        //             overflow: TextOverflow.ellipsis,
        //             fontstyle: FontStyle.normal),
        //       ],
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 20),
        InkWell(
          focusColor: white,
          hoverColor: colorPrimary.withOpacity(0.20),
          splashColor: white,
          highlightColor: white,
          borderRadius: BorderRadius.circular(50),
          onTap: () async {
            if (!generalProvider.isProgressLoading) {
              gmailLogin();
            }
          },
          child: Container(
            width:
                MediaQuery.of(context).size.width > 600
                    ? MediaQuery.of(context).size.width * 0.35
                    : MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(width: 0.5, color: gray),
              borderRadius: BorderRadius.circular(5),
            ),
            child:
                MediaQuery.of(context).size.width > 250
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyImage(
                          width: 20,
                          imagePath: "ic_google.png",
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 15),
                        MyText(
                          color: black,
                          fontsizeWeb: Dimens.textMedium,
                          text: "loginwithgoogle",
                          fontsizeNormal: Dimens.textMedium,
                          fontwaight: FontWeight.w400,
                          maxline: 1,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    )
                    : MyImage(
                      width: 20,
                      imagePath: "ic_google.png",
                      height: 20,
                      fit: BoxFit.cover,
                    ),
          ),
        ),
        const SizedBox(height: 20),
        Consumer<GeneralProvider>(
          builder: (context, generalprovider, child) {
            if (generalprovider.isProgressLoading) {
              return const CircularProgressIndicator(color: colorAccent);
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  /* Google(Gmail) Login */
  Future<void> gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    printLog('GoogleSignIn ===> id : ${user.id}');
    printLog('GoogleSignIn ===> email : ${user.email}');
    printLog('GoogleSignIn ===> displayName : ${user.displayName}');
    printLog('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    generalProvider.setLoading(true);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      String firebasedid = userCredential.user?.uid ?? "";
      printLog("User Name: ${userCredential.user?.displayName}");
      printLog("User Email ${userCredential.user?.email}");
      printLog("User photoUrl ${userCredential.user?.photoURL}");
      printLog("uid ===> ${userCredential.user?.uid}");

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
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(userCredential.user?.uid ?? "")
            .set({
              FirestoreConstants.appchannelid: "",
              FirestoreConstants.appuserid: "",
              FirestoreConstants.email: userCredential.user?.email,
              FirestoreConstants.deviceToken: strDeviceToken,
              FirestoreConstants.name: userCredential.user?.displayName,
              FirestoreConstants.profileurl: userCredential.user?.photoURL,
              FirestoreConstants.userid: userCredential.user?.uid ?? "",
              FirestoreConstants.createdAt:
                  DateTime.now().millisecondsSinceEpoch.toString(),
              FirestoreConstants.bioData:
                  "Hey! there I'm using ${Constant.appName} app.",
              FirestoreConstants.username: "",
              FirestoreConstants.mobileNumber:
                  userCredential.user?.phoneNumber ?? "",
              FirestoreConstants.chattingWith: null,
            });
      } else {
        updateDataInFirestore(firebaseId: firebasedid);
      }

      if (!mounted) return;
      generalProvider.setLoading(true);
      checkAndNavigate(
        user.email,
        user.displayName ?? "",
        "",
        "",
        "2",
        firebasedid,
      );
    } on FirebaseAuthException catch (e) {
      printLog('FirebaseAuthException ===CODE====> ${e.code.toString()}');
      printLog('FirebaseAuthException ==MESSAGE==> ${e.message.toString()}');
      // Hide Progress Dialog
      generalProvider.setLoading(false);
    }
  }

  checkAndNavigate(
    String email,
    String userName,
    String profileImg,
    String password,
    String type,
    String firebaseId,
  ) async {
    final loginItem = Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.setLoading(true);
    File? userProfileImg = await Utils.saveImageInStorage(profileImg);
    printLog("userProfileImg ===========> $userProfileImg");

    await loginItem.login(
      type,
      email,
      "",
      deviceType ?? "",
      strDeviceToken ?? "",
      "",
      "",
      firebaseId,
    );

    printLog('checkAndNavigate loading ==>> ${loginItem.loading}');

    if (!loginItem.loading) {
      if (loginItem.loginModel.status == 200 &&
          loginItem.loginModel.result!.isNotEmpty) {
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
        ); // Set UserID With Chennal ID for Next

        /* Update UserId And ChannelId in Firebase */
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebaseId)
            .update({
              FirestoreConstants.appchannelid:
                  loginItem.loginModel.result?[0].channelId.toString(),
              FirestoreConstants.appuserid:
                  loginItem.loginModel.result?[0].id.toString(),
            })
            .then((value) => printLog("User Updated"))
            .onError((error, stackTrace) {
              printLog("updateDataFirestore error ===> ${error.toString()}");
              printLog(
                "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
              );
            });

        generalProvider.setLoading(false);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WebLatestFeed()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        generalProvider.setLoading(false);
      }
    }
  }

  updateDataInFirestore({required String firebaseId}) {
    printLog('strDeviceToken ....==>> $strDeviceToken');
    printLog('firebasedid ....==>> $firebaseId');
    // Update data to Firestore
    FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(firebaseId)
        .update({FirestoreConstants.deviceToken: strDeviceToken})
        .then((value) => printLog("User Updated"))
        .onError((error, stackTrace) {
          printLog("updateDataFirestore error ===> ${error.toString()}");
          printLog(
            "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
          );
        });
  }
}
