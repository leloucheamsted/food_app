// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'
    show AccessToken, FacebookAuth, LoginResult, LoginStatus;
import 'package:slike/model/loginmodel.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/pages/signup.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String mobilenumber = "", countrycode = "", countryname = "";
  File? mProfileImg;
  bool isagreeCondition = false;
  bool isPasswordVisible = false;
  bool rememberMe = false;
  String? strDeviceType, strDeviceToken;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        strDeviceToken = OneSignal.User.pushSubscription.id.toString();
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>strDeviceType $strDeviceType");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loginbg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70.0),
                    child: Image.asset(
                      "assets/images/appicon.png",
                      height: 90,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Welcome text
                  const Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    "Log in to your account",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // Username field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1,
                      ),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "User name",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            "assets/icons/profile.svg",
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              const Color(0xFFFFD700),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1,
                      ),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: TextField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "••••••••••••",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            "assets/icons/lock.svg",
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              const Color(0xFFFFD700),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: SvgPicture.asset(
                            "assets/icons/eye-slash.svg",
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              isPasswordVisible
                                  ? const Color(0xFFFFD700)
                                  : Colors.white70,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Remember me and Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me checkbox
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                              shape: const CircleBorder(),
                              checkColor: Colors.black,
                              activeColor: const Color(0xFFFFD700),
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Remember me",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),

                      // Forgot password
                      TextButton(
                        onPressed: () {
                          // Handle forgot password
                          _handleForgotPassword();
                        },
                        child: const Text(
                          "Forget password?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement login functionality with validation
                        _loginWithEmailPassword();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Don't have account - Sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have account?",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to the sign up page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUp(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // OR divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.white54, thickness: 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.white54, thickness: 0.5),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social login - Instagram
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implement Facebook login
                        _facebookLogin();
                      },
                      icon: SvgPicture.asset(
                        "assets/icons/facebook.svg",
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        "Facebook",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Social login - Google

                  // Social login - Apple

                  // Loading indicator
                  Consumer<GeneralProvider>(
                    builder: (context, generalprovider, child) {
                      if (generalprovider.isProgressLoading) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: Color(0xFFFFD700),
                            strokeWidth: 2,
                          ),
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
        ),
      ),
    );
  }

  // Login With Google
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

      userCredential = await auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      printLog("User Name: ${userCredential.user?.displayName}");
      printLog("User Email ${userCredential.user?.email}");
      printLog("User photoUrl ${userCredential.user?.photoURL}");
      printLog("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      printLog('firebasedid :===> $firebasedid');
      // Call Login Api
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
        "",
        "",
        firebasedid,
      );
    } on FirebaseAuthException catch (e) {
      printLog('===>Exp${e.code.toString()}');
      printLog('===>Exp${e.message.toString()}');
      generalProvider.setLoading(false);
    }
  }

  // Signin With Apple
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      printLog(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await auth.signInWithCredential(oauthCredential);

      String? displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      String? userEmail = authResult.user?.email.toString() ?? "";
      final firebaseUser = authResult.user;

      String firebasedId = firebaseUser?.uid ?? "";
      if (userEmail.isNotEmpty || userEmail != 'null') {
        await firebaseUser?.updateDisplayName(displayName);
        // await firebaseUser
        //     ?.verifyBeforeUpdateEmail(authResult.user?.email.toString() ?? "");
      } else {
        userEmail = firebaseUser?.email.toString() ?? "";
        displayName = firebaseUser?.displayName.toString();
        printLog("===>userEmail-else $userEmail");
        printLog("===>displayName-else $displayName");
      }

      printLog("userEmail =====FINAL==> $userEmail");
      printLog("firebasedId ===FINAL==> $firebasedId");
      printLog("displayName ===FINAL==> $displayName");
      /*  ************************************/

      // Check is already sign up
      final QuerySnapshot result =
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.pathUserCollection)
              .where(FirestoreConstants.userid, isEqualTo: firebasedId)
              .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebasedId)
            .set({
              FirestoreConstants.email: firebaseUser?.email ?? "",
              FirestoreConstants.deviceToken: strDeviceToken,
              FirestoreConstants.name: displayName ?? "",
              FirestoreConstants.profileurl:
                  firebaseUser?.photoURL ?? Constant.userPlaceholder,
              FirestoreConstants.userid: firebasedId,
              FirestoreConstants.createdAt:
                  DateTime.now().millisecondsSinceEpoch.toString(),
              FirestoreConstants.bioData:
                  "Hey! there I'm using ${Constant.appName} app.",
              FirestoreConstants.username: "",
              FirestoreConstants.mobileNumber: firebaseUser?.phoneNumber ?? "",
              FirestoreConstants.chattingWith: null,
            });
      } else {
        updateDataInFirestore(firebaseId: firebasedId);
      }

      checkAndNavigate(
        userEmail,
        displayName.toString(),
        "",
        "",
        "3",
        "",
        "",
        firebasedId,
      );
    } catch (exception) {
      printLog("Apple Login exception =====> $exception");
    }
    return null;
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

  checkAndNavigate(
    String email,
    String userName,
    String profileImg,
    String password,
    String type,
    String countrycode,
    String countryName,
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
      strDeviceType ?? "",
      strDeviceToken ?? "",
      countrycode,
      countryName,
      firebaseId,
    );

    if (!loginItem.loading) {
      if (loginItem.loginModel.status == 200 &&
          loginItem.loginModel.result!.isNotEmpty) {
        Utils.saveUserCreds(
          userID: loginItem.loginModel.result?[0].id.toString(),
          firebaseId: loginItem.loginModel.result?[0].firebaseId.toString(),
          channeId: loginItem.loginModel.result?[0].channelId.toString(),
          channelName: loginItem.loginModel.result?[0].channelName.toString(),
          fullName: loginItem.loginModel.result?[0].fullName.toString(),
          email: loginItem.loginModel.result?[0].email.toString(),
          mobileNumber: loginItem.loginModel.result?[0].mobileNumber.toString(),
          image: loginItem.loginModel.result?[0].image.toString(),
          coverImg: loginItem.loginModel.result?[0].coverImg.toString(),
          deviceType: loginItem.loginModel.result?[0].deviceType.toString(),
          deviceToken: loginItem.loginModel.result?[0].deviceToken.toString(),
          userIsBuy: loginItem.loginModel.result?[0].isBuy.toString(),
          isAdsFree: loginItem.loginModel.result?[0].adsFree.toString(),
          isDownload: loginItem.loginModel.result?[0].isDownload.toString(),
        );

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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Bottombar()),
          (Route route) => false,
        );
      } else {
        if (!mounted) return;
        generalProvider.setLoading(false);
      }
    }
  }

  // Handle Forgot Password
  void _handleForgotPassword() {
    // Create a text controller for email input
    final TextEditingController emailController = TextEditingController();

    // Show dialog to get email address
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorPrimary,
          title: const Text(
            "Forgot Password",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter your email address to reset your password",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Email address",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate email
                if (emailController.text.isEmpty) {
                  Utils.showSnackbar(
                    context,
                    "Please enter your email address",
                    false,
                  );
                  return;
                }

                if (!EmailValidator.validate(emailController.text)) {
                  Utils.showSnackbar(
                    context,
                    "Please enter a valid email address",
                    false,
                  );
                  return;
                }

                // Close dialog
                Navigator.of(context).pop();

                // Show loading
                generalProvider.setLoading(true);

                // Call password reset API (this would typically be implemented in apiservice.dart)
                // For now, we'll show a success message after a short delay
                Future.delayed(const Duration(seconds: 2), () {
                  generalProvider.setLoading(false);
                  Utils.showSnackbar(
                    context,
                    "Password reset link sent to ${emailController.text}",
                    false,
                  );
                });

                // In a real implementation, you would call a password reset API:
                // try {
                //   await apiService.resetPassword(emailController.text);
                //   generalProvider.setLoading(false);
                //   Utils.showSnackbar(
                //     context,
                //     "Password reset link sent to ${emailController.text}",
                //     false
                //   );
                // } catch (e) {
                //   generalProvider.setLoading(false);
                //   Utils.showSnackbar(
                //     context,
                //     "Failed to send reset link. Please try again.",
                //     false
                //   );
                // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              child: const Text("Reset Password"),
            ),
          ],
        );
      },
    );
  }

  // Email/Password Login Implementation
  Future<void> _loginWithEmailPassword() async {
    // Validate input fields
    if (usernameController.text.isEmpty) {
      Utils.showSnackbar(context, "Please enter your username", false);
      return;
    }

    if (passwordController.text.isEmpty) {
      Utils.showSnackbar(context, "Please enter your password", false);
      return;
    }

    try {
      // Show loading indicator
      generalProvider.setLoading(true);

      // Call the login API
      LoginModel result = await generalProvider.loginWithNam(
        usernameController.text,
        passwordController.text,
      );

      // Check if login was successful
      if (result.status == 200 && result.result!.isNotEmpty) {
        // Save user data
        await Utils.saveUserCreds(
          userID: result.result?[0].id.toString(),
          firebaseId: result.result?[0].firebaseId.toString(),
          channeId: result.result?[0].channelId.toString(),
          channelName: result.result?[0].channelName.toString(),
          fullName: result.result?[0].fullName.toString(),
          email: result.result?[0].email.toString(),
          mobileNumber: result.result?[0].mobileNumber.toString(),
          image: result.result?[0].image.toString(),
          coverImg: result.result?[0].coverImg.toString(),
          deviceType: result.result?[0].deviceType.toString(),
          deviceToken: result.result?[0].deviceToken.toString(),
          userIsBuy: result.result?[0].isBuy.toString(),
          isAdsFree: result.result?[0].adsFree.toString(),
          isDownload: result.result?[0].isDownload.toString(),
        );

        // Update Firebase data if user has a Firebase ID
        if (result.result?[0].firebaseId != null &&
            (result.result?[0].firebaseId?.isNotEmpty ?? false)) {
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.pathUserCollection)
              .doc(result.result?[0].firebaseId)
              .update({
                FirestoreConstants.appchannelid:
                    result.result?[0].channelId.toString(),
                FirestoreConstants.appuserid: result.result?[0].id.toString(),
                FirestoreConstants.deviceToken: strDeviceToken,
              })
              .then((value) => printLog("User Updated"))
              .onError((error, stackTrace) {
                printLog("updateDataFirestore error ===> ${error.toString()}");
                printLog(
                  "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
                );
              });
        }

        // Navigate to home screen
        if (!mounted) return;
        generalProvider.setLoading(false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Bottombar()),
          (Route route) => false,
        );
      } else {
        // Show error message
        if (!mounted) return;
        generalProvider.setLoading(false);
        Utils.showSnackbar(
          context,
          result.message ?? "Login failed. Please check your credentials.",
          false,
        );
      }
    } catch (e) {
      printLog("Login Error: $e");
      generalProvider.setLoading(false);
      if (!mounted) return;
      Utils.showSnackbar(
        context,
        "Failed to sign in. Please try again.",
        false,
      );
    }
  }

  // Facebook Login Implementation
  Future<void> _facebookLogin() async {
    try {
      // Show loading indicator
      generalProvider.setLoading(true);

      final LoginResult result =
          await FacebookAuth.instance
              .login(); // by default we request the email and the public profile

      if (result.status == LoginStatus.success) {
        // Get access token
        final AccessToken accessToken = result.accessToken!;

        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        // Sign in to Firebase with the Facebook credential
        final userCredential = await auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          String firebaseId = user.uid;
          String email = user.email ?? "";
          String displayName = user.displayName ?? "";
          String photoURL = user.photoURL ?? "";

          // Check if user exists in Firestore
          await _checkUserInFirestore(firebaseId, email, displayName, photoURL);

          // Navigate user to the main app
        }
      }

      // For now, we'll show a message that this feature is coming soon

      generalProvider.setLoading(false);
    } catch (e) {
      // Handle errors
      printLog("Facebook Login Error: $e");
      generalProvider.setLoading(false);
      if (!mounted) return;
      Utils.showSnackbar(context, "Failed to sign in with Facebook", false);
    }
  }

  // Helper method to check if user exists in Firestore
  Future<void> _checkUserInFirestore(
    String firebaseId,
    String email,
    String displayName,
    String photoURL,
  ) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.userid, isEqualTo: firebaseId)
            .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      // Create new user in Firestore
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .doc(firebaseId)
          .set({
            FirestoreConstants.appchannelid: "",
            FirestoreConstants.appuserid: "",
            FirestoreConstants.email: email,
            FirestoreConstants.deviceToken: strDeviceToken,
            FirestoreConstants.name: displayName,
            FirestoreConstants.profileurl:
                photoURL.isNotEmpty ? photoURL : Constant.userPlaceholder,
            FirestoreConstants.userid: firebaseId,
            FirestoreConstants.createdAt:
                DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.bioData:
                "Hey! there I'm using ${Constant.appName} app.",
            FirestoreConstants.username: "",
            FirestoreConstants.mobileNumber: "",
            FirestoreConstants.chattingWith: null,
          });
    } else {
      // Update existing user
      updateDataInFirestore(firebaseId: firebaseId);
    }
  }
}
