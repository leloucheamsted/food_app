import 'dart:io';
import 'dart:math';
import 'package:slike/livestream/livestream.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/music/musicdetails.dart';
import 'package:slike/pages/detail.dart';
import 'package:slike/players/player_video.dart';
import 'package:slike/players/player_vimeo.dart';
import 'package:slike/players/player_youtube.dart';
import 'package:slike/provider/detailprovider.dart';
import 'package:slike/provider/downloadprovider.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/provider/latestfeedprovider.dart';
import 'package:slike/provider/marketplaceprovider.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/provider/settingprovider.dart';
import 'package:slike/provider/shortprovider.dart';
import 'package:slike/subscription/subscription.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/customads.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/webpages/weblatestfeed.dart';
import 'package:slike/webpages/weblogin.dart';
import 'package:slike/webpages/webmarketplace.dart';
import 'package:slike/webpages/webnotification.dart';
import 'package:slike/webpages/webprofile.dart';
import 'package:slike/webpages/websearch.dart';
import 'package:slike/webpages/webshorts.dart';
import 'package:slike/webpages/webwatchlater.dart';
import 'package:slike/webwidget/activeuserpanel.dart';
import 'package:slike/widget/musictitle.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as number;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../web_js/js_helper.dart';

printLog(String message) {
  if (kDebugMode) {
    return print(message);
  }
}

class Utils {
  static ProgressDialog? prDialog;

  static TextStyle googleFontStyle(
    int inter,
    double fontsize,
    FontStyle fontstyle,
    Color color,
    FontWeight fontwaight,
  ) {
    if (inter == 1) {
      return GoogleFonts.poppins(
        fontSize: fontsize,
        fontStyle: fontstyle,
        color: color,
        fontWeight: fontwaight,
      );
    } else if (inter == 2) {
      return GoogleFonts.lobster(
        fontSize: fontsize,
        fontStyle: fontstyle,
        color: color,
        fontWeight: fontwaight,
      );
    } else if (inter == 3) {
      return GoogleFonts.rubik(
        fontSize: fontsize,
        fontStyle: fontstyle,
        color: color,
        fontWeight: fontwaight,
      );
    } else if (inter == 4) {
      return GoogleFonts.roboto(
        fontSize: fontsize,
        fontStyle: fontstyle,
        color: color,
        fontWeight: fontwaight,
      );
    } else {
      return GoogleFonts.inter(
        fontSize: fontsize,
        fontStyle: fontstyle,
        color: color,
        fontWeight: fontwaight,
      );
    }
  }

  // Widget Page Loader
  static Widget pageLoader(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: colorAccent),
    );
  }

  static Future<Uint8List?> generateThumbnails(videoUrl) async {
    final data = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400, // specify the width of the thumbnail
      quality: 75, // specify the quality of the thumbnail
    );

    // Check if data is null or empty
    if (data == null || data.isEmpty) {
      throw Exception('No thumbnail data generated');
    }

    return data;
  }

  showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      webShowClose: true,
      backgroundColor: white,
      webBgColor: colorAccent,
      textColor: black,
      fontSize: 14,
    );
  }

  static BoxDecoration setGradTTBBGWithBorder(
    Color colorStart,
    Color colorEnd,
    Color borderColor,
    double radius,
    double border,
  ) {
    return BoxDecoration(
      border: Border.all(color: borderColor, width: border),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static moveToDetail(
    BuildContext context,
    int stopTime,
    bool isContinueWatching,
    String videoId,
  ) async {
    final detailsProvider = Provider.of<DetailProvider>(context, listen: false);
    await detailsProvider.setLoading(true);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Detail(
            stoptime: stopTime,
            iscontinueWatching: isContinueWatching,
            videoid: videoId,
          );
        },
      ),
    );
  }

  // Global SnakBar
  static void showSnackbar(
    BuildContext context,
    String message,
    bool multilanguage,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width:
            kIsWeb
                ? MediaQuery.of(context).size.width * 0.50
                : MediaQuery.of(context).size.width,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: colorAccent,
        content: MyText(
          text: message,
          multilanguage: multilanguage,
          fontsizeNormal: Dimens.textMedium,
          fontsizeWeb: Dimens.textMedium,
          maxline: 3,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
          fontwaight: FontWeight.w500,
          color: black,
          textalign: TextAlign.center,
        ),
      ),
    );
  }

  static BoxDecoration setBGWithBorder(
    Color colorBg,
    Color colorBorder,
    double radius,
    double borderWidth,
  ) {
    return BoxDecoration(
      color: colorBg,
      border: Border.all(color: colorBorder, width: borderWidth),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBGWithRadius(
    Color colorBg,
    double radiusTopLeft,
    double radiusTopRight,
    double radiusBottomLeft,
    double radiusBottomRight,
  ) {
    return BoxDecoration(
      color: colorBg,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radiusTopLeft),
        topRight: Radius.circular(radiusTopRight),
        bottomLeft: Radius.circular(radiusBottomLeft),
        bottomRight: Radius.circular(radiusBottomRight),
      ),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradTTBBorderWithBG(
    Color colorTop,
    Color colorBottom,
    Color bgColor,
    double radius,
    double border,
  ) {
    return BoxDecoration(
      border: Border.all(color: colorAccent, width: border),
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  // Global Progress Dilog
  static void showProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    prDialog = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: false,
      showLogs: false,
    );

    prDialog!.style(
      message: "Please Wait",
      borderRadius: 5,
      progressWidget: Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );

    await prDialog!.show();
  }

  void hideProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    if (prDialog!.isShowing()) {
      prDialog!.hide();
    }
  }

  otherPageAppBar(BuildContext context, String title, bool multilanguage) {
    return AppBar(
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
          if (!context.mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.of(context).pop(false);
        },
        child: Align(
          alignment: Alignment.center,
          child: MyImage(width: 30, height: 30, imagePath: "ic_roundback.png"),
        ),
      ),
      title: MyText(
        color: white,
        multilanguage: multilanguage,
        text: title,
        textalign: TextAlign.center,
        fontsizeNormal: 16,
        inter: false,
        maxline: 1,
        fontwaight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
        fontstyle: FontStyle.normal,
      ),
    );
  }

  divider(BuildContext context, EdgeInsets padding) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1,
      padding: padding,
      color: gray,
    );
  }

  static Widget webDivider(BuildContext context, EdgeInsets padding) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.5,
      margin: padding,
      color: white.withOpacity(0.20),
    );
  }

  static Future<File?> saveImageInStorage(imgUrl) async {
    try {
      var response = await http.get(Uri.parse(imgUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(
        path.join(
          documentDirectory?.path ?? "",
          '${DateTime.now().millisecondsSinceEpoch.toString()}.png',
        ),
      );
      file.writeAsBytesSync(response.bodyBytes);
      // This is a sync operation on a real
      // app you'd probably prefer to use writeAsByte and handle its Future
      return file;
    } catch (e) {
      printLog("saveImageInStorage Exception ===> $e");
      return null;
    }
  }

  static setUserId(userID) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("channelid");
      await sharedPref.remove("channelname");
      await sharedPref.remove("fullname");
      await sharedPref.remove("email");
      await sharedPref.remove("mobilenumber");
      await sharedPref.remove("image");
      await sharedPref.remove("coverimage");
      await sharedPref.remove("devicetype");
      await sharedPref.remove("devicetoken");
      await sharedPref.remove("userIsBuy");
      await sharedPref.remove("isAdsFree");
      await sharedPref.remove("isDownload");
    }
    Constant.userID = await sharedPref.read("userid");

    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static checkLoginUser(BuildContext context) {
    if (Constant.userID != null) {
      return true;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const Login();
        },
      ),
    );
    return false;
  }

  // KMB Text Generator Method
  static String kmbGenerator(int num) {
    if (num > 999 && num < 99999) {
      return "${(num / 1000).toStringAsFixed(1)} K";
    } else if (num > 99999 && num < 999999) {
      return "${(num / 1000).toStringAsFixed(0)} K";
    } else if (num > 999999 && num < 999999999) {
      return "${(num / 1000000).toStringAsFixed(1)} M";
    } else if (num > 999999999) {
      return "${(num / 1000000000).toStringAsFixed(1)} B";
    } else {
      return num.toString();
    }
  }

  static String timeAgoCustom(DateTime d) {
    // <-- Custom method Time Show  (Display Example  ==> 'Today 7:00 PM')     // WhatsApp Time Show Status Shimila
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return DateFormat.E().add_jm().format(d);
    }
    if (diff.inHours > 0) return "Today ${DateFormat('jm').format(d)}";
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }

  static String formatTime(double time) {
    Duration duration = Duration(milliseconds: time.round());
    duration.inHours;
    if (duration.inHours == 00) {
      return [
        duration.inMinutes,
        duration.inSeconds,
      ].map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
    } else {
      return [
        duration.inHours,
        duration.inMinutes,
        duration.inSeconds,
      ].map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
    }
  }

  convertMillisecondsToSeconds(double milliseconds) {
    return milliseconds / 1000;
  }

  static openPlayer({
    required BuildContext context,
    required String videoId,
    required String videoUrl,
    required String vUploadType,
    required String videoThumb,
    required double stoptime,
    required bool iscontinueWatching,
    required bool isDownloadVideo,
  }) {
    if (kIsWeb) {
      /* Normal, Vimeo & Youtube Player */
      if (!context.mounted) return;
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation1, animation2) => PlayerYoutube(
                  videoId,
                  videoUrl,
                  vUploadType,
                  videoThumb,
                  stoptime,
                  iscontinueWatching,
                ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation1, animation2) => PlayerYoutube(
                    videoId,
                    videoUrl,
                    vUploadType,
                    videoThumb,
                    stoptime,
                    iscontinueWatching,
                  ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation1, animation2) => PlayerVideo(
                    videoId,
                    videoUrl,
                    vUploadType,
                    videoThumb,
                    stoptime,
                    iscontinueWatching,
                    isDownloadVideo,
                  ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation1, animation2) => PlayerVideo(
                  videoId,
                  videoUrl,
                  vUploadType,
                  videoThumb,
                  stoptime,
                  iscontinueWatching,
                  isDownloadVideo,
                ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    } else {
      /* Better, Youtube & Vimeo Players */
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(
                videoId,
                videoUrl,
                vUploadType,
                videoThumb,
                stoptime,
                iscontinueWatching,
              );
            },
          ),
        );
      } else if (vUploadType == "vimeo") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVimeo(videoId, videoUrl, vUploadType, videoThumb);
            },
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(
                  videoId,
                  videoUrl,
                  vUploadType,
                  videoThumb,
                  stoptime,
                  iscontinueWatching,
                );
              },
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(
                  videoId,
                  videoUrl,
                  vUploadType,
                  videoThumb,
                  stoptime,
                  iscontinueWatching,
                  isDownloadVideo,
                );
              },
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(
                videoId,
                videoUrl,
                vUploadType,
                videoThumb,
                stoptime,
                iscontinueWatching,
                isDownloadVideo,
              );
            },
          ),
        );
      }
    }
  }

  static Widget buildBackBtnDesign(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: MyImage(
        height: 17,
        width: 17,
        imagePath: "ic_roundback.png",
        color: white,
      ),
    );
  }

  static Widget buildMusicPanel(context) {
    return ValueListenableBuilder(
      valueListenable: currentlyPlaying,
      builder: (BuildContext context, AudioPlayer? audioObject, Widget? child) {
        if (audioObject?.audioSource != null) {
          return MusicDetails(
            ishomepage: false,
            contentid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.album)
                    .toString(),
            episodeid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.id)
                    .toString(),
            stoptime: audioPlayer.position.toString(),
            contenttype:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.genre)
                    .toString(),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  static void getCurrencySymbol() async {
    SharedPre sharedPref = SharedPre();
    Constant.currencySymbol = await sharedPref.read("currency_code") ?? "";
    printLog('Constant currencySymbol ==> ${Constant.currencySymbol}');
    Constant.currency = await sharedPref.read("currency") ?? "";
    printLog('Constant currency ==> ${Constant.currency}');
  }

  static Widget buildGradLine() {
    return Container(
      height: 0.5,
      decoration: Utils.setGradTTBBGWithBorder(
        colorPrimaryDark.withOpacity(0.4),
        colorAccent.withOpacity(0.4),
        transparent,
        0,
        0,
      ),
    );
  }

  static double getPercentage(int totalValue, int usedValue) {
    double percentage = 0.0;
    try {
      if (totalValue != 0) {
        percentage = ((usedValue / totalValue).clamp(0.0, 1.0) * 100);
      } else {
        percentage = 0.0;
      }
    } catch (e) {
      printLog("getPercentage Exception ==> $e");
      percentage = 0.0;
    }
    percentage = (percentage.round() / 100);
    return percentage;
  }

  static String generateRandomOrderID() {
    int getRandomNumber;
    String? finalOID;
    printLog("fixFourDigit =>>> ${Constant.fixFourDigit}");
    printLog("fixSixDigit =>>> ${Constant.fixSixDigit}");

    number.Random r = number.Random();
    int ran5thDigit = r.nextInt(9);
    printLog("Random ran5thDigit =>>> $ran5thDigit");

    int randomNumber = number.Random().nextInt(9999999);
    printLog("Random randomNumber =>>> $randomNumber");
    if (randomNumber < 0) {
      randomNumber = -randomNumber;
    }
    getRandomNumber = randomNumber;
    printLog("getRandomNumber =>>> $getRandomNumber");

    finalOID =
        "${Constant.fixFourDigit.toInt()}"
        "$ran5thDigit"
        "${Constant.fixSixDigit.toInt()}"
        "$getRandomNumber";
    printLog("finalOID =>>> $finalOID");

    return finalOID;
  }

  static AppBar myAppBarWithBack(
    BuildContext context,
    String appBarTitle,
    bool multilanguage,
  ) {
    return AppBar(
      elevation: 5,
      backgroundColor: colorPrimaryDark,
      centerTitle: true,
      leading: IconButton(
        autofocus: true,
        focusColor: white.withOpacity(0.5),
        onPressed: () {
          if (!context.mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        icon: MyImage(
          imagePath: "ic_roundback.png",
          fit: BoxFit.contain,
          height: 17,
          width: 17,
          color: white,
        ),
      ),
      title: MyText(
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsizeNormal: Dimens.textBig,
        fontstyle: FontStyle.normal,
        fontwaight: FontWeight.bold,
        textalign: TextAlign.center,
        color: colorPrimary,
      ),
    );
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradientBG(
    Color colorStart,
    Color colorEnd,
    double radius,
  ) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static Future<void> shareApp(shareMessage) async {
    try {
      await FlutterShare.share(title: Constant.appName, linkUrl: shareMessage);
    } catch (e) {
      printLog("shareFile Exception ===> $e");
      return;
    }
  }

  static Future<File?> saveAudioInStorage(audioUrl, audioTitle) async {
    try {
      var response = await http.get(Uri.parse(audioUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(
        join(
          documentDirectory?.path ?? "",
          '${audioTitle.toString().replaceAll(" ", "").toLowerCase()}.aac',
        ),
      );
      file.writeAsBytesSync(response.bodyBytes);
      printLog("saveAudioInStorage file ===> ${file.path}");
      Fluttertoast.showToast(
        msg: "Download Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: white,
        textColor: black,
        fontSize: 14,
      );
      return file;
    } catch (e) {
      printLog("saveAudioInStorage Exception ===> $e");
      return null;
    }
  }

  Future<void> showAlertSimple(
    BuildContext context,
    String msg,
    String positive,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(15),
          content: MyText(
            multilanguage: true,
            color: black,
            text: msg,
            fontsizeNormal: 16,
            fontwaight: FontWeight.w500,
            maxline: 5,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                foregroundColor: white,
                backgroundColor: colorPrimary, // foreground
              ),
              child: MyText(
                multilanguage: true,
                color: black,
                text: positive,
                fontsizeNormal: 15,
                fontwaight: FontWeight.w600,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              onPressed: () {
                printLog("Clicked on positive!");
                if (!context.mounted) return;
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Widget dataUpdateDialog(
    BuildContext context, {
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController mobileController,
  }) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(23),
        color: colorPrimaryDark,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Title & Subtitle */
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: white,
                    text: "updateprofile",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: Dimens.textTitle,
                    fontwaight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    color: white,
                    text: "editpersonaldetail",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: Dimens.textSmall,
                    fontwaight: FontWeight.w500,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
            ),

            /* Fullname */
            const SizedBox(height: 30),
            if (isNameReq)
              _buildTextFormField(
                controller: nameController,
                hintText: "full_name",
                inputType: TextInputType.name,
                readOnly: false,
              ),

            /* Email */
            if (isEmailReq)
              _buildTextFormField(
                controller: emailController,
                hintText: "email_address",
                inputType: TextInputType.emailAddress,
                readOnly: false,
              ),

            /* Mobile */
            if (isMobileReq)
              _buildTextFormField(
                controller: mobileController,
                hintText: "mobile_number",
                inputType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                readOnly: false,
              ),
            const SizedBox(height: 5),

            /* Cancel & Update Buttons */
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Cancel */
                  InkWell(
                    onTap: () {
                      final profileEditProvider = Provider.of<ProfileProvider>(
                        context,
                        listen: false,
                      );
                      if (!profileEditProvider.loadingUpdate) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 75),
                      height: 50,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: white, width: .5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                        color: white,
                        text: "cancel",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  /* Submit */
                  Consumer<ProfileProvider>(
                    builder: (context, profileEditProvider, child) {
                      if (profileEditProvider.loadingUpdate) {
                        return Container(
                          width: 100,
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          alignment: Alignment.center,
                          child: pageLoader(context),
                        );
                      }
                      return InkWell(
                        onTap: () async {
                          SharedPre sharedPref = SharedPre();
                          final fullName =
                              nameController.text.toString().trim();
                          final emailAddress =
                              emailController.text.toString().trim();
                          final mobileNumber =
                              mobileController.text.toString().trim();

                          printLog(
                            "fullName =======> $fullName ; required ========> $isNameReq",
                          );
                          printLog(
                            "emailAddress ===> $emailAddress ; required ====> $isEmailReq",
                          );
                          printLog(
                            "mobileNumber ===> $mobileNumber ; required ====> $isMobileReq",
                          );
                          if (isNameReq && fullName.isEmpty) {
                            Utils.showSnackbar(context, "enter_fullname", true);
                          } else if (isEmailReq && emailAddress.isEmpty) {
                            Utils.showSnackbar(context, "enter_email", true);
                          } else if (isMobileReq && mobileNumber.isEmpty) {
                            Utils.showSnackbar(
                              context,
                              "enter_mobile_number",
                              true,
                            );
                          } else if (isEmailReq &&
                              !EmailValidator.validate(emailAddress)) {
                            Utils.showSnackbar(
                              context,
                              "enter_valid_email",
                              true,
                            );
                          } else {
                            final profileEditProvider =
                                Provider.of<ProfileProvider>(
                                  context,
                                  listen: false,
                                );
                            await profileEditProvider.setUpdateLoading(true);

                            await profileEditProvider.getUpdateDataForPayment(
                              fullName,
                              emailAddress,
                              mobileNumber,
                            );
                            if (!profileEditProvider.loadingUpdate) {
                              await profileEditProvider.setUpdateLoading(false);
                              if (!context.mounted) return;
                              await profileEditProvider.getprofile(
                                context,
                                Constant.userID,
                              );
                              if (profileEditProvider.successModel.status ==
                                  200) {
                                if (isNameReq) {
                                  await sharedPref.save('fullname', fullName);
                                }
                                if (isEmailReq) {
                                  await sharedPref.save('email', emailAddress);
                                }
                                if (isMobileReq) {
                                  await sharedPref.save(
                                    'mobilenumber',
                                    mobileNumber,
                                  );
                                }
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 75),
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            color: black,
                            text: "submit",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required bool readOnly,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        obscureText: false,
        maxLines: 1,
        readOnly: readOnly,
        cursorColor: colorAccent,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          filled: true,
          isDense: false,
          fillColor: transparent,
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: colorAccent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: colorAccent),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: colorAccent),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: colorAccent),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: colorAccent),
          ),
          label: MyText(
            multilanguage: true,
            color: white,
            text: hintText,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
            fontsizeNormal: Dimens.textMedium,
            fontwaight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 14,
            color: white,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

  static Widget miniPlayerSpace() {
    return Container(height: 60);
  }

  /* Google AdMob Methods Start */
  static Widget showBannerAd(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: AdHelper.bannerAd(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static loadAds(BuildContext context) async {
    if (context.mounted) {
      AdHelper.getAds(context);
      getCustomAdsStatus();
    }
    if (!kIsWeb &&
        (((Constant.isAdsfree != "1") ||
            (Constant.isAdsfree == null) ||
            (Constant.isAdsfree == "")))) {
      AdHelper.createInterstitialAd();
      AdHelper.createRewardedAd();
    }
  }

  /* Google AdMob Methods End */

  static musicAndAdsPanel(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: buildMusicPanel(context)),
          CustomAds(adType: Constant.bannerAdType),
          showBannerAd(context),
        ],
      ),
    );
  }

  static lanchAdsLink(loadingUrl) async {
    final JSHelper jsHelper = JSHelper();
    printLog("loadingUrl -----------> $loadingUrl");
    /*
      _blank => open new Tab
      _self => open in current Tab
    */
    String dataFromJS = await jsHelper.callOpenTab(loadingUrl, '_blank');
    printLog("dataFromJS -----------> $dataFromJS");
  }

  static void lanchAdsUrl(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw Utils().showToast("Could Not Lunch This Url $url");
    }
  }

  static Widget buildBackBtn(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      focusColor: gray.withOpacity(0.5),
      onTap: () {
        if (!context.mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: MyImage(
          height: 23,
          width: 23,
          imagePath: "ic_roundback.png",
          fit: BoxFit.contain,
          color: white,
        ),
      ),
    );
  }

  static saveUserCreds({
    required userID,
    required firebaseId,
    required channeId,
    required channelName,
    required fullName,
    required email,
    required mobileNumber,
    required image,
    required coverImg,
    required deviceType,
    required deviceToken,
    required userIsBuy,
    required isAdsFree,
    required isDownload,
  }) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
      await sharedPref.save("firebaseid", firebaseId);
      await sharedPref.save("channelid", channeId);
      await sharedPref.save("channelname", channelName);
      await sharedPref.save("fullname", fullName);
      await sharedPref.save("email", email);
      await sharedPref.save("mobilenumber", mobileNumber);
      await sharedPref.save("image", image);
      await sharedPref.save("coverimage", coverImg);
      await sharedPref.save("devicetype", deviceType);
      await sharedPref.save("devicetoken", deviceToken);
      await sharedPref.save("userIsBuy", userIsBuy);
      await sharedPref.save("isAdsFree", isAdsFree);
      await sharedPref.save("isDownload", isDownload);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("firebaseid");
      await sharedPref.remove("channelid");
      await sharedPref.remove("channelname");
      await sharedPref.remove("fullname");
      await sharedPref.remove("email");
      await sharedPref.remove("mobilenumber");
      await sharedPref.remove("image");
      await sharedPref.remove("coverimage");
      await sharedPref.remove("devicetype");
      await sharedPref.remove("devicetoken");
      await sharedPref.remove("userIsBuy");
      await sharedPref.remove("isAdsFree");
      await sharedPref.remove("isDownload");
    }

    Constant.userID = await sharedPref.read("userid");
    Constant.isAdsfree = await sharedPref.read("isAdsFree");
    Constant.isDownload = await sharedPref.read("isDownload");
    Constant.channelID = await sharedPref.read("channelid");
    Constant.userImage = await sharedPref.read("image");
    Constant.isBuy = await sharedPref.read("userIsBuy");

    printLog('setUserId userID ==> ${Constant.userID}');
    printLog('setUserId isAdsfree ==> ${Constant.isAdsfree}');
    printLog('setUserId isDownload ==> ${Constant.isDownload}');
    printLog('setUserId channelID ==> ${Constant.channelID}');
    printLog('setUserId userImage ==> ${Constant.userImage}');
    printLog('setUserId isBuy ==> ${Constant.isBuy}');
  }

  /*----------------------------------------------------------------- Web Utils Start ------------------------------------------------------------------ */

  /* Custom Appbar With SidePanel Start */
  static PreferredSize webAppbarWithSidePanel({
    required BuildContext context,
    contentType,
    categoryTap,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
          return AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: transparent,
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: transparent,
            flexibleSpace: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          hoverColor: colorPrimaryDark,
                          splashColor: colorPrimaryDark,
                          highlightColor: colorPrimaryDark,
                          focusColor: colorPrimaryDark,
                          borderRadius: BorderRadius.circular(50.0),
                          onTap: () async {
                            if (generalprovider.isPanel == false) {
                              await generalprovider.getOnOffSidePanel(true);
                            } else {
                              await generalprovider.getOnOffSidePanel(false);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MyImage(
                              width: 20,
                              height: 20,
                              imagePath: "ic_menu.png",
                              color: white,
                            ),
                          ),
                        ),
                        MediaQuery.of(context).size.width > 200
                            ? Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: MyImage(
                                width: 100,
                                height: 50,
                                imagePath: "appicon.png",
                              ),
                            )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    MediaQuery.of(context).size.width > 400
                        ? const SizedBox(width: 25)
                        : const SizedBox(width: 15),
                    MediaQuery.of(context).size.width > 350
                        ? Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              (contentType == "search")
                                  ? const SizedBox.shrink()
                                  : Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      18,
                                      0,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (Constant.userID == null) {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation1,
                                                    animation2,
                                                  ) => const WebLogin(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation1,
                                                    animation2,
                                                  ) => const WebSearch(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Icon(
                                        Icons.search,
                                        color: colorAccent,
                                        size: 30,
                                      ),
                                    ),
                                  ),

                              // InkWell(
                              //   onTap: () async {
                              //     Utils().showInterstitalAds(
                              //         context, Constant.interstialAdType,
                              //         () async {
                              //       if (Constant.userID == null) {
                              //         Navigator.push(
                              //           context,
                              //           PageRouteBuilder(
                              //             pageBuilder: (context, animation1,
                              //                     animation2) =>
                              //                 const WebLogin(),
                              //             transitionDuration: Duration.zero,
                              //             reverseTransitionDuration:
                              //                 Duration.zero,
                              //           ),
                              //         );
                              //       } else {
                              //         if (generalprovider.isNotification ==
                              //             false) {
                              //           await generalprovider
                              //               .getNotificationSectionShowHide(
                              //                   true);
                              //         } else {
                              //           await generalprovider
                              //               .getNotificationSectionShowHide(
                              //                   false);
                              //         }
                              //       }
                              //     });
                              //   },
                              //   child: MyImage(
                              //     width: MediaQuery.of(context).size.width > 400
                              //         ? 25
                              //         : 20,
                              //     height:
                              //         MediaQuery.of(context).size.width > 400
                              //             ? 25
                              //             : 20,
                              //     imagePath: "notification.png",
                              //     color: colorAccent,
                              //   ),
                              // ),
                              // MediaQuery.of(context).size.width > 400
                              //     ? const SizedBox(width: 20)
                              //     : const SizedBox(width: 15),

                              /* Category HashTag */
                              ((contentType == "feeds") ||
                                      (contentType == "play"))
                                  ? InkWell(
                                    onTap: categoryTap,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: colorAccent,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: MyImage(
                                          width: 20,
                                          height: 20,
                                          color: colorAccent,
                                          imagePath: "ic_hashtag.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                  : const SizedBox.shrink(),

                              /* Login User Profile Image */
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                                child: InkWell(
                                  onTap: () {
                                    Utils().showInterstitalAds(
                                      context,
                                      Constant.interstialAdType,
                                      () async {
                                        if (Constant.userID == null) {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation1,
                                                    animation2,
                                                  ) => const WebLogin(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation1,
                                                    animation2,
                                                  ) => const WebProfile(
                                                    isBottomBar: true,
                                                    toUserId: "",
                                                    toChannelId: "",
                                                  ),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child:
                                        (Constant.userID == null ||
                                                Constant.userImage == "" ||
                                                Constant.userImage == null)
                                            ? MyImage(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width,
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height,
                                              color: colorAccent,
                                              fit: BoxFit.cover,
                                              imagePath: "ic_user.png",
                                            )
                                            : Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                border: Border.all(
                                                  width: 0.8,
                                                  color: colorAccent,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: MyNetworkImage(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width,
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height,
                                                  imagePath:
                                                      Constant.userImage ?? "",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget sidePanelWithBody({required Widget myWidget, isProfile}) {
    return Consumer<GeneralProvider>(
      builder: (context, generalprovider, child) {
        return Row(
          children: [
            generalprovider.isPanel == true &&
                    MediaQuery.of(context).size.width > 600
                ? buildOnPanel(context, isProfile)
                : const SizedBox.shrink(),
            Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  MouseRegion(
                    onHover: (value) async {
                      if (MediaQuery.of(context).size.width < 600) {
                        await generalprovider.getOnOffSidePanel(false);
                      }
                      await generalprovider.clearHover();
                      await generalprovider.getNotificationSectionShowHide(
                        false,
                      );
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: myWidget,
                    ),
                  ),
                  generalprovider.isNotification == true
                      ? Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width > 1200
                                  ? 500
                                  : 400,
                          height: 500,
                          margin: const EdgeInsets.only(left: 20, right: 50),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: colorPrimaryDark,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: const WebNotificationPage(),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
                  generalprovider.isPanel == true &&
                          MediaQuery.of(context).size.width < 600
                      ? Align(
                        alignment: Alignment.centerLeft,
                        child: buildOnPanel(context, isProfile),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget buildOnPanel(BuildContext context, isProfile) {
    return Consumer<GeneralProvider>(
      builder: (context, generalprovider, child) {
        return Container(
          width: 250,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
          color: colorPrimary,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                panelItem("home", "ic_homeTab.png", "home", true, () {
                  Utils().showInterstitalAds(
                    context,
                    Constant.interstialAdType,
                    () async {
                      final latestFeedProvider =
                          Provider.of<LatestFeedProvider>(
                            context,
                            listen: false,
                          );
                      latestFeedProvider.clearProvider();
                      await latestFeedProvider.setLoading(true);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation1, animation2) =>
                                  const WebLatestFeed(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  );
                }),
                panelItem("shorts", "ic_shorts.png", "play", true, () {
                  Utils().showInterstitalAds(
                    context,
                    Constant.interstialAdType,
                    () async {
                      final shortProvider = Provider.of<ShortProvider>(
                        context,
                        listen: false,
                      );
                      shortProvider.clearProvider();
                      await shortProvider.setLoading(true);
                      await shortProvider.getShortList(false, "", 1);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation1, animation2) =>
                                  const WebShorts(initialIndex: 0),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  );
                }),
                panelItem(
                  "marketplace",
                  "ic_market.png",
                  "marketplace",
                  true,
                  () {
                    Utils().showInterstitalAds(
                      context,
                      Constant.interstialAdType,
                      () async {
                        final marketPlaceProvider =
                            Provider.of<MarketPlaceProvider>(
                              context,
                              listen: false,
                            );
                        marketPlaceProvider.clearProvider();
                        await marketPlaceProvider.setLoading(true);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation1, animation2) =>
                                    const WebMarketPlace(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    );
                  },
                ),
                Consumer<ProfileProvider>(
                  builder: (context, profileprovider, child) {
                    return panelItem(
                      "subscription",
                      "ic_subscription.png",
                      "subscription",
                      true,
                      () async {
                        Utils().showInterstitalAds(
                          context,
                          Constant.interstialAdType,
                          () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          const WebLogin(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else {
                              await profileprovider.getprofile(
                                context,
                                Constant.userID.toString(),
                              );
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          const Subscription(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
                panelItem(
                  "watchlater",
                  "ic_watchlater.png",
                  "watchlater",
                  true,
                  () {
                    Utils().showInterstitalAds(
                      context,
                      Constant.interstialAdType,
                      () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation1, animation2) =>
                                      const WebLogin(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation1, animation2) =>
                                      const WebWatchLater(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                // Constant.userID == null
                //     ? const SizedBox.shrink()
                //     : panelItem("userpanel", "userpanel.png", "userpanel", true,
                //         () {
                //         Utils().showInterstitalAds(
                //             context, Constant.interstialAdType, () async {
                //           userPanelActiveDilog(context);
                //         });
                //       }),
                // panelItem("chooselanguage", "ic_link.png", "chooselanguage", true,
                //     () {
                //   Utils().showInterstitalAds(context, Constant.interstialAdType,
                //       () async {
                //     _languageChangeDialog(context);
                //   });
                // }),
                panelItem(
                  "login_logout",
                  "ic_logout.png",
                  Constant.userID != null ? "logout" : "login",
                  true,
                  () {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation1, animation2) =>
                                  const WebLogin(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      logoutdilog(context, isProfile);
                    }
                  },
                ),
                webDivider(context, const EdgeInsets.fromLTRB(0, 10, 0, 10)),
                buildWebGetPages(),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget panelItem(type, icon, name, multilanguage, onTap) {
    return Consumer<GeneralProvider>(
      builder: (context, generalprovider, child) {
        return InkWell(
          hoverColor: colorPrimary,
          splashColor: colorPrimary,
          focusColor: colorPrimary,
          highlightColor: colorPrimary,
          onTap: onTap,
          onHover: (value) async {
            await generalprovider.isHoverSideMenu(type, true);
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            decoration: BoxDecoration(
              color: transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            margin: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyImage(width: 20, height: 20, imagePath: icon, color: white),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: MyText(
                      color: white,
                      multilanguage: multilanguage,
                      text: name,
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      maxline: 1,
                      fontwaight: FontWeight.w300,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
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

  static logoutdilog(BuildContext context, isProfile) {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorPrimaryDark,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(
              minWidth: 250,
              maxWidth: 400,
              minHeight: 180,
              maxHeight: 280,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MyImage(
                    imagePath: "appicon.png",
                    width: 130,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                MyText(
                  color: white,
                  text: "areyousurewanrtosignout",
                  multilanguage: true,
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textTitle,
                  fontsizeWeb: Dimens.textTitle,
                  fontwaight: FontWeight.w500,
                  maxline: 2,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        hoverColor: colorAccent,
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          if (!context.mounted) return;
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                          margin: const EdgeInsets.all(1),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: MyText(
                            color: white,
                            text: "cancel",
                            multilanguage: true,
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textDesc,
                            fontsizeWeb: Dimens.textDesc,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      InkWell(
                        borderRadius: BorderRadius.circular(15),
                        hoverColor: colorAccent,
                        onTap: () async {
                          final profileProvider = Provider.of<ProfileProvider>(
                            context,
                            listen: false,
                          );
                          final settingProvider = Provider.of<SettingProvider>(
                            context,
                            listen: false,
                          );
                          if (!context.mounted) return;
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          await settingProvider.getLogout();
                          await profileProvider.clearProvider();
                          // Firebase Signout
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.signOut();
                          await GoogleSignIn().signOut();

                          await Utils.setUserId(null);

                          audioPlayer.stop();
                          audioPlayer.pause();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: MyText(
                            color: white,
                            text: "logout",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textDesc,
                            fontsizeWeb: Dimens.textDesc,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (isProfile == true) {
        if (!context.mounted) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  static pageTitle({title, multilanguage}) {
    return MyText(
      color: white,
      text: title,
      textalign: TextAlign.center,
      fontsizeNormal: Dimens.textExtraBig,
      fontsizeWeb: Dimens.textExtraBig,
      inter: true,
      multilanguage: multilanguage,
      maxline: 1,
      fontwaight: FontWeight.w700,
      overflow: TextOverflow.ellipsis,
      fontstyle: FontStyle.normal,
    );
  }

  static Widget moreFunctionItem(icon, title, onTap) {
    return ListTile(
      iconColor: white,
      textColor: white,
      title: MyText(
        color: white,
        text: title,
        fontwaight: FontWeight.w500,
        fontsizeNormal: Dimens.textTitle,
        maxline: 1,
        multilanguage: true,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.left,
        fontstyle: FontStyle.normal,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: white),
        child: MyImage(
          width: 20,
          height: 20,
          imagePath: icon,
          color: colorPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  /* Custom Appbar With SidePanel Start */

  static int crossAxisCount(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1600) {
      return 5;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return 4;
    } else if (MediaQuery.of(context).size.width > 800) {
      return 2;
    } else if (MediaQuery.of(context).size.width > 400) {
      return 1;
    } else {
      return 1;
    }
  }

  static int crossAxisCountShorts(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1600) {
      return 7;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return 6;
    } else {
      return 4;
    }
  }

  static Color generateRendomColor() {
    final Random random = Random();
    final int red = random.nextInt(256);
    final int green = random.nextInt(256);
    final int blue = random.nextInt(256);
    final Color color = Color.fromARGB(255, red, green, blue);
    return color;
  }

  static int customCrossAxisCount({
    required BuildContext context,
    required int height1600,
    required int height1200,
    required int height800,
    required int height600,
  }) {
    if (MediaQuery.of(context).size.width > 1600) {
      return height1600;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return height1200;
    } else if (MediaQuery.of(context).size.width > 800) {
      return height800;
    } else if (MediaQuery.of(context).size.width > 600) {
      return height600;
    } else {
      return 1;
    }
  }

  static roundTag(width, height) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: gray),
    );
  }

  static _languageChangeDialog(BuildContext context) {
    return showDialog(
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
            color: colorPrimaryDark,
            padding: const EdgeInsets.all(20.0),
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: 350,
              maxHeight: 400,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color: white,
                      text: "selectlanguage",
                      multilanguage: true,
                      textalign: TextAlign.start,
                      fontsizeNormal: Dimens.textBig,
                      fontsizeWeb: Dimens.textBig,
                      fontwaight: FontWeight.w500,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    InkWell(
                      onTap: () {
                        if (!context.mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Icon(Icons.close, size: 25, color: white),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                /* English */
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "English",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('en');
                            if (!context.mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),

                        /* Afrikaans */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Afrikaans",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('af');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Arabic */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Arabic",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('ar');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* German */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "German",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('de');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Spanish */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "Spanish",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('es');
                            if (!context.mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),

                        /* French */
                        const SizedBox(height: 20),
                        _buildLanguage(
                          context: context,
                          langName: "French",
                          onClick: () {
                            LocaleNotifier.of(context)?.change('fr');
                            if (!context.mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),

                        /* Gujarati */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Gujarati",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('gu');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Hindi */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Hindi",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('hi');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Indonesian */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Indonesian",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('id');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Dutch */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Dutch",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('nl');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Portuguese (Brazil) */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Portuguese (Brazil)",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('pt');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Albanian */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Albanian",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('sq');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Turkish */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Turkish",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('tr');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),

                        /* Vietnamese */
                        // const SizedBox(height: 20),
                        // _buildLanguage(
                        //   context: context,
                        //   langName: "Vietnamese",
                        //   onClick: () {
                        //     LocaleNotifier.of(context)?.change('vi');
                        //     if (!context.mounted) return;
                        //     if (Navigator.canPop(context)) {
                        //       Navigator.pop(context);
                        //     }
                        //   },
                        // ),
                        // const SizedBox(height: 20),
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

  static Widget _buildLanguage({
    required BuildContext context,
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: colorAccent, width: .5),
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: white,
          text: langName,
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textTitle,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  static userPanelActiveDilog(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return const ActiveUserPanel();
      },
    );
  }

  static Widget buildBackBtnWeb(BuildContext context) {
    return SafeArea(
      child: InkWell(
        onTap: () {
          if (!context.mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        focusColor: gray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: Utils.setBackground(colorPrimaryDark, 8),
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: MyText(
            color: white,
            text: "Back",
            multilanguage: false,
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

  /* Custom Ads Intastial Start */

  static getCustomAdsStatus() async {
    printLog(">==========get CustomAds Status=======>");
    SharedPre sharePref = SharedPre();

    printLog(">==========get CustomAds Status=======>");

    /* Banner */
    Constant.banneradStatus = await sharePref.read("banner_ads_status") ?? "";
    Constant.banneradCPV = await sharePref.read("banner_ads_cpv") ?? "";
    Constant.banneradCPC = await sharePref.read("banner_ads_cpc") ?? "";

    /* Interstital */
    Constant.interstitaladStatus =
        await sharePref.read("interstital_ads_status") ?? "";
    Constant.interstitaladCPV =
        await sharePref.read("interstital_ads_cpv") ?? "";
    Constant.interstitaladCPC =
        await sharePref.read("interstital_ads_cpc") ?? "";
    /* Reward */
    Constant.rewardadStatus = await sharePref.read("reward_ads_status") ?? "";
    Constant.rewardadCPV = await sharePref.read("reward_ads_cpv") ?? "";
    Constant.rewardadCPC = await sharePref.read("reward_ads_cpc") ?? "";

    printLog("BannerStatus Get Ads===>${Constant.banneradStatus}");
    printLog("Interstial===>${Constant.interstitaladStatus}");
    printLog("Reward===>${Constant.rewardadStatus}");
  }

  showInterstitalAds(context, String adType, VoidCallback callAction) async {
    // Constant.isPremiumCustomAds = await Utils.checkPremiumUser();
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    if (adType == Constant.interstialAdType) {
      await generalsetting.getAds(2);
    }
    if (Constant.isAdsfree == "1") {
      callAction();
      return;
    }
    if (adType == Constant.interstialAdType) {
      if (Constant.interstitaladStatus == "1") {
        if (((Constant.isAdsfree != "1") ||
            (Constant.isAdsfree == null) ||
            (Constant.isAdsfree == ""))) {
          if (generalsetting.getInterstialAdsModel.status == 200 &&
              generalsetting.getInterstialAdsModel.result != null) {
            testDilog(context, callAction);
            // interstitalAd(context, callAction);
          } else {
            callAction();
          }
        }
      } else {
        callAction();
      }
    } else {
      callAction();
    }
    /* Ads View Api Call */
    if (adType == Constant.interstialAdType) {
      await generalsetting.getAdsViewClickCount(
        "2",
        generalsetting.getInterstialAdsModel.result?.id.toString() ?? "",
        "123",
        "1",
        "1" /* "1" CPV & 2 CPC */,
        "",
      );
    }
  }

  void testDilog(BuildContext context, VoidCallback callAction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            alignment: Alignment.center,
            width:
                MediaQuery.of(context).size.width > 800
                    ? MediaQuery.of(context).size.width * 0.50
                    : MediaQuery.of(context).size.width * 0.75,
            height: kIsWeb ? 300 : 350,
            margin:
                kIsWeb ? const EdgeInsets.all(50) : const EdgeInsets.all(15),
            child: Consumer<GeneralProvider>(
              builder: (context, generalprovider, child) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (kIsWeb) {
                      lanchAdsLink(
                        generalprovider
                                .getInterstialAdsModel
                                .result
                                ?.redirectUri
                                .toString() ??
                            "",
                      );
                    } else {
                      lanchAdsUrl(
                        generalprovider
                                .getInterstialAdsModel
                                .result
                                ?.redirectUri
                                .toString() ??
                            "",
                      );
                    }
                    /* Generate DeviceToken */
                    String? diviceType;
                    String? diviceToken;
                    if (kIsWeb) {
                      diviceType = "3";
                      diviceToken = Constant.webToken;
                    } else {
                      if (Platform.isAndroid) {
                        diviceType = "1";
                        diviceToken =
                            await FirebaseMessaging.instance.getToken();
                      } else {
                        diviceType = "2";
                        diviceToken =
                            OneSignal.User.pushSubscription.id.toString();
                      }
                    }
                    /* Call APi */
                    await generalprovider.getAdsViewClickCount(
                      "2",
                      generalprovider.getInterstialAdsModel.result?.id
                              .toString() ??
                          "",
                      diviceType,
                      diviceToken,
                      "1" /* "1" CPV & 2 CPC */,
                      "",
                    );
                  },
                  child:
                      kIsWeb
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: MyNetworkImage(
                                      fit: BoxFit.fill,
                                      width: 400,
                                      height: 300,
                                      imagePath:
                                          generalprovider
                                              .getInterstialAdsModel
                                              .result
                                              ?.image
                                              .toString() ??
                                          "",
                                    ),
                                  ),
                                  Positioned.fill(
                                    right: 15,
                                    bottom: 15,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          4,
                                          10,
                                          4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: MyText(
                                          color: black,
                                          text: "Ads",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textMedium,
                                          fontsizeWeb: Dimens.textMedium,
                                          inter: false,
                                          multilanguage: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      onPressed: () {
                                        if (!context.mounted) return;
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
                                        callAction();
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MusicTitle(
                                      color: white,
                                      text:
                                          generalprovider
                                              .getInterstialAdsModel
                                              .result
                                              ?.title
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textExtraBig,
                                      fontsizeWeb:
                                          MediaQuery.of(context).size.width >
                                                  800
                                              ? Dimens.textExtraBig
                                              : Dimens.textTitle,
                                      maxline: 5,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                    const SizedBox(height: 30),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        15,
                                        10,
                                        15,
                                        10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: MyText(
                                        color: black,
                                        text: "explorebtn",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textMedium,
                                        fontsizeWeb: Dimens.textMedium,
                                        inter: false,
                                        multilanguage: true,
                                        maxline: 1,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: MyNetworkImage(
                                      fit: BoxFit.fill,
                                      width: MediaQuery.of(context).size.width,
                                      height: 200,
                                      imagePath:
                                          generalprovider
                                              .getInterstialAdsModel
                                              .result
                                              ?.image
                                              .toString() ??
                                          "",
                                    ),
                                  ),
                                  Positioned.fill(
                                    right: 15,
                                    bottom: 15,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          4,
                                          10,
                                          4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: MyText(
                                          color: black,
                                          text: "Ads",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textMedium,
                                          fontsizeWeb: Dimens.textMedium,
                                          inter: false,
                                          multilanguage: false,
                                          maxline: 1,
                                          fontwaight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    hoverColor: transparent,
                                    highlightColor: transparent,
                                    splashColor: transparent,
                                    focusColor: transparent,
                                    onTap: () {
                                      if (!context.mounted) return;
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                      callAction();
                                    },
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: const BoxDecoration(
                                            color: colorAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 20,
                                            color: black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: MusicTitle(
                                  color: white,
                                  text:
                                      generalprovider
                                          .getInterstialAdsModel
                                          .result
                                          ?.title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textBig,
                                  fontsizeWeb:
                                      MediaQuery.of(context).size.width > 800
                                          ? Dimens.textExtraBig
                                          : Dimens.textTitle,
                                  maxline: 3,
                                  multilanguage: false,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  15,
                                  10,
                                  15,
                                  10,
                                ),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: MyText(
                                  color: black,
                                  text: "explorebtn",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textMedium,
                                  fontsizeWeb: Dimens.textMedium,
                                  inter: false,
                                  multilanguage: true,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Widget buildWebGetPages() {
    return Consumer<SettingProvider>(
      builder: (context, settingprovider, child) {
        return ListView.builder(
          itemCount: settingprovider.getpagesModel.result?.length ?? 0,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Utils.buildWebGetPagesItem(
              "get_pages",
              settingprovider.getpagesModel.result?[index].icon.toString() ??
                  "",
              settingprovider.getpagesModel.result?[index].title.toString() ??
                  "",
              false,
              () {
                if (settingprovider.getpagesModel.result?[index].url != "") {
                  Utils.lanchAdsLink(
                    settingprovider.getpagesModel.result?[index].url,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  static Widget buildWebSocialLink() {
    return Consumer<SettingProvider>(
      builder: (context, settingprovider, child) {
        return ListView.builder(
          itemCount: settingprovider.socialLinkModel.result?.length ?? 0,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Utils.buildWebGetPagesItem(
              "get_sociallink",
              settingprovider.socialLinkModel.result?[index].image.toString() ??
                  "",
              settingprovider.socialLinkModel.result?[index].name.toString() ??
                  "",
              false,
              () {
                if (settingprovider.socialLinkModel.result?[index].url != "") {
                  Utils.lanchAdsLink(
                    settingprovider.socialLinkModel.result?[index].url,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  static Widget buildWebGetPagesItem(type, icon, name, multilanguage, onTap) {
    return Consumer<GeneralProvider>(
      builder: (context, generalprovider, child) {
        return InkWell(
          hoverColor: colorPrimary,
          splashColor: colorPrimary,
          focusColor: colorPrimary,
          highlightColor: colorPrimary,
          onTap: () async {
            onTap();
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            margin: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: MyNetworkImage(
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    imagePath: icon,
                    isPagesIcon: true,
                    color: white,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: MyText(
                      color: white,
                      multilanguage: multilanguage,
                      text: name,
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      maxline: 1,
                      fontwaight: FontWeight.w300,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
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

  progressDilog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<DownloadProvider>(
              builder: (context, downloadprovider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText(
                      color: white,
                      text: "downloading",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      inter: false,
                      maxline: 6,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorAccent,
                      value: downloadprovider.progress,
                    ),
                    const SizedBox(height: 20),
                    MyText(
                      color: white,
                      text:
                          '${(downloadprovider.progress * 100).toStringAsFixed(0)}%',
                      multilanguage: false,
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      inter: false,
                      maxline: 6,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
  /* Custom Ads Intastial End */

  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    const contentUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?';
    const embedUrlPattern =
        r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/';
    const altUrlPattern = r'^https:\/\/youtu\.be\/';
    const shortsUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/';
    const musicUrlPattern = r'^https:\/\/(?:music\.)?youtube\.com\/watch\?';
    const idPattern = r'([_\-a-zA-Z0-9]{11}).*$';

    for (var regex in [
      '${contentUrlPattern}v=$idPattern',
      '$embedUrlPattern$idPattern',
      '$altUrlPattern$idPattern',
      '$shortsUrlPattern$idPattern',
      '$musicUrlPattern?v=$idPattern',
    ]) {
      Match? match = RegExp(regex).firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  static jumpToLive({
    required BuildContext context,
    required isHost,
    required userId,
    String? userImage,
    String? userName,
    String? name,
    String? roomId,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LiveStream(
            userId: userId,
            roomId: roomId,
            image: userImage,
            name: name,
            userName: userName,
            isHost: isHost,
          );
        },
      ),
    );
  }

  static String generateRoomId() {
    // Create a random instance
    final random = Random();

    // Generate a random number or string
    int randomNumber = random.nextInt(
      1000000,
    ); // Generates a number between 0 and 999999

    // Combine with the "room_" prefix
    String roomId = "room_$randomNumber";

    return roomId;
  }

  /*----------------------------------------------------------------- Web Utils End ------------------------------------------------------------------ */

  /* ======================= Web Device Token Start ============ */
}
