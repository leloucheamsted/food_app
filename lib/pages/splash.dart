import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:slike/provider/homeprovider.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/pages/intro.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:provider/provider.dart';
// import 'package:slike/widget/myimage.dart';
import 'package:video_player/video_player.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  SharedPre sharedpre = SharedPre();
  late VideoPlayerController _controller;
  late HomeProvider homeProvider;
  late GeneralProvider splashdata;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    splashdata = Provider.of<GeneralProvider>(context, listen: false);
    _controller = VideoPlayerController.asset("assets/images/splashvideo1.mp4");
    _controller.initialize().then((_) {
      printLog("Enter Play");
      if (!mounted) return;
      setState(() {
        _controller.play();
      });
    });
    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (!mounted) return;
      ischeckFirstTime();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        // MyImage(
        //     width: MediaQuery.of(context).size.width,
        //     height: MediaQuery.of(context).size.height,
        //     fit: BoxFit.fill,
        //     imagePath: "splash.png"),
      ),
    );
  }

  Future ischeckFirstTime() async {
    await splashdata.getGeneralsetting();

    if (!splashdata.loading) {
      for (var i = 0; i < splashdata.generalsettingModel.result!.length; i++) {
        sharedpre.save(
          splashdata.generalsettingModel.result?[i].key.toString() ?? "",
          splashdata.generalsettingModel.result?[i].value.toString() ?? "",
        );
      }

      /* Login UserInfo Local Save Get */
      Utils.getCurrencySymbol();
      Constant.userID = await sharedpre.read('userid');
      Constant.isAdsfree = await sharedpre.read('isAdsFree');
      Constant.isDownload = await sharedpre.read('isDownload');
      Constant.channelID = await sharedpre.read('channelid');
      Constant.channelName = await sharedpre.read('channelname');
      Constant.userImage = await sharedpre.read('image');
      Constant.isBuy = await sharedpre.read('userIsBuy');
      printLog("Userid===>${Constant.userID}");
      printLog("Channalid===>${Constant.channelID}");
      printLog("isAdsfree===>${Constant.isAdsfree}");
      printLog("isDownload===>${Constant.isDownload}");

      /* Live Streaming START */
      // String? liveAppID, liveAppSign, liveServerSecret;
      // liveAppID = await sharedpre.read("live_appid");
      // liveAppSign = await sharedpre.read("live_appsign");
      // liveServerSecret = await sharedpre.read("live_serversecret");
      // if (liveAppID != null) {
      //   Constant.liveAppId = int.parse(liveAppID);
      //   printLog("liveAppId :=========> ${Constant.liveAppId}");
      // }
      // if (liveAppSign != null) {
      //   Constant.liveAppSign = liveAppSign;
      //   printLog("liveAppSign :=======> ${Constant.liveAppSign}");
      // }
      // if (liveServerSecret != null) {
      //   Constant.liveServerSecret = liveServerSecret;
      //   printLog("liveServerSecret :==> ${Constant.liveServerSecret}");
      // }
      /* Live Streaming END */

      String? seen = await sharedpre.read("seen") ?? "";
      log("seen:---$seen");
      /* Get Ads Init */
      if (mounted && !kIsWeb) {
        AdHelper.getAds(context);
        Utils.getCustomAdsStatus();

        printLog("isAdsfree.com===>${Constant.isAdsfree}");
      }

      await splashdata.getIntroPages();

      if (seen == "1") {
        printLog("Boolian statement if Condition : $seen");
        await homeProvider.setLoading(true);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Bottombar();
            },
          ),
        );
      } else {
        if (!splashdata.loading &&
            splashdata.introScreenModel.status == 200 &&
            (splashdata.introScreenModel.result != null ||
                ((splashdata.introScreenModel.result?.length ?? 0) > 0))) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Intro(
                  introList: splashdata.introScreenModel.result ?? [],
                );
              },
            ),
          );
        } else {
          printLog("Boolian statement if Condition : $seen");
          await homeProvider.setLoading(true);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Bottombar();
              },
            ),
          );
        }
      }
    }
  }
}
