import 'dart:developer';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:slike/pages/latestfeed.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/marketplace.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/pages/upload/videorecord.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/provider/latestfeedprovider.dart';
import 'package:slike/provider/marketplaceprovider.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/provider/shortprovider.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customads.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slike/pages/shorts.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/webservice/socketmanager.dart';
import 'package:slike/widget/myimage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
double playerMinHeight = (!kIsWeb) ? 70 : 90;
const miniplayerPercentageDeclaration = 0.7;

class Bottombar extends StatefulWidget {
  final bool? isLiveStream;
  const Bottombar({super.key, this.isLiveStream});

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> {
  // final ImagePicker _picker = ImagePicker();
  int selectedIndex = 0;
  SharedPre sharedPre = SharedPre();
  late GeneralProvider generalsetting;
  late ProfileProvider profileProvider;
  late LatestFeedProvider latestFeedProvider;
  late ShortProvider shortProvider;
  late MarketPlaceProvider marketPlaceProvider;
  bool cameraPermissionGranted = false;
  bool microphonePermissionGranted = false;
  io.Socket? socket;
  double? videoTime;
  String? videoImage;

  @override
  void initState() {
    generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    latestFeedProvider = Provider.of<LatestFeedProvider>(
      context,
      listen: false,
    );
    shortProvider = Provider.of<ShortProvider>(context, listen: false);
    marketPlaceProvider = Provider.of<MarketPlaceProvider>(
      context,
      listen: false,
    );
    super.initState();

    AdHelper().initGoogleMobileAds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
      getFeedApi();
      if (widget.isLiveStream == true) {
        /* Live Streaming Page */
        _onItemTapped(3);
      }
    });
  }

  void socketIO() {
    SocketManager socketManager = SocketManager();
    socket = socketManager.socket;

    socket?.emit('fetchNotificationCount', {
      "user_id": Constant.userID == null ? 0 : Constant.userID ?? 0,
    });

    printLog("callsocket");
  }

  getData() async {
    pushNotification();
    if (Constant.userID != null) {
      await profileProvider.getprofile(context, Constant.userID);
      if (profileProvider.profileModel.status == 200 &&
          profileProvider.profileModel.result != null) {
        await sharedPre.save(
          "userpanelstatus",
          profileProvider.profileModel.result?[0].userPenalStatus.toString() ??
              "",
        );
        Constant.userID =
            profileProvider.profileModel.result?[0].id.toString() ?? "";
        Constant.channelID =
            profileProvider.profileModel.result?[0].channelId.toString() ?? "";
        Constant.userPanelStatus = await sharedPre.read("userpanelstatus");
        Constant.isAdsfree =
            profileProvider.profileModel.result?[0].adsFree.toString() ?? "";
        Constant.isDownload =
            profileProvider.profileModel.result?[0].isDownload.toString() ?? "";
        Constant.userImage =
            profileProvider.profileModel.result?[0].image.toString() ?? "";

        log("UserId==> ${Constant.userID}");
      }
    } else {
      Utils.loadAds(context);
    }
    await generalsetting.getGeneralsetting();
    // socketIO();
    setState(() {});
  }

  pushNotification() async {
    Constant.oneSignalAppId = await sharedPre.read(Constant.oneSignalAppIdKey);
    printLog("OneSignal===>${Constant.oneSignalAppId}");
    /*  Push Notification Method OneSignal Start */
    if (!kIsWeb) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      // Initialize OneSignal
      printLog("OneSignal PushNotification===> ${Constant.oneSignalAppId}");
      OneSignal.initialize(Constant.oneSignalAppId ?? "");
      OneSignal.Notifications.requestPermission(false);
      OneSignal.Notifications.addPermissionObserver((state) {
        printLog("Has permission ==> $state");
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        printLog(
          "pushSubscription state ==> ${state.current.jsonRepresentation()}",
        );
      });
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.preventDefault();
        event.notification.display();
      });
    }
    /*  Push Notification Method OneSignal End */
  }

  static List<Widget> widgetOptions = <Widget>[
    const LatestFeed(),
    const Shorts(initialIndex: 0),
    const VideoRecord(
      contestId: '',
      contestImg: '',
      hashtagId: '',
      hashtagName: '',
    ),
    const MarketPlace(),
    Profile(
      isBottomBar: true,
      toUserId: Constant.userID ?? "",
      toChannelId: Constant.channelID ?? "",
    ),
  ];

  void _onItemTapped(int index) async {
    if (!mounted) return;
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      switch (index) {
        case 0:
          getFeedApi();
          setState(() {
            selectedIndex = index;
          });
          break;

        case 1:
          getShortApi();
          setState(() {
            selectedIndex = index;
          });
          break;

        case 2:
          if (Constant.userID != null) {
            setState(() {
              selectedIndex = index;
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Login();
                },
              ),
            );
          }
          break;

        case 3:
          getMearketPlaceApi();
          setState(() {
            selectedIndex = index;
          });
          break;

        case 4:
          if (Constant.userID != null) {
            setState(() {
              selectedIndex = index;
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Login();
                },
              ),
            );
          }
          break;
      }
    });
  }

  getFeedApi() async {
    latestFeedProvider.clearProvider();
    await latestFeedProvider.setLoading(true);
    await latestFeedProvider.getSubscribeChannelPost(1);
    await latestFeedProvider.getMostViewPost(1);
    await latestFeedProvider.getPostByCategory(0, 1);
    await latestFeedProvider.setLoading(false);
  }

  getShortApi() async {
    shortProvider.clearProvider();
    await shortProvider.setLoading(true);
    await shortProvider.getShortList(false, "", 1);
  }

  getMearketPlaceApi() async {
    marketPlaceProvider.clearProvider();
    await marketPlaceProvider.setLoading(true);
    await marketPlaceProvider.getVideoCategory(0);
    if (marketPlaceProvider.categorymodel.status == 200 &&
        marketPlaceProvider.categorydataList != null) {
      if ((marketPlaceProvider.categorydataList?.length ?? 0) > 0) {
        await marketPlaceProvider.selectCategory(0, "");
        await marketPlaceProvider.getMarketPlace("", "", 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimaryDark,
      body: Stack(
        children: [
          Center(child: widgetOptions.elementAt(selectedIndex)),
          selectedIndex == 1 || selectedIndex == 2
              ? const SizedBox.shrink()
              : Utils.buildMusicPanel(context),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          selectedIndex == 1 || selectedIndex == 2
              ? const SizedBox.shrink()
              : Column(
                children: [
                  CustomAds(adType: Constant.bannerAdType),
                  Utils.showBannerAd(context),
                ],
              ),
          BottomNavigationBar(
            backgroundColor: colorPrimary,
            selectedFontSize: Dimens.textbottomNav,
            unselectedFontSize: Dimens.textbottomNav,
            selectedIconTheme: const IconThemeData(color: colorAccent),
            unselectedIconTheme: const IconThemeData(color: white),
            elevation: 5,
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: Dimens.textbottomNav,
              color: gray,
              fontWeight: FontWeight.w400,
            ),
            selectedLabelStyle: GoogleFonts.inter(
              fontSize: Dimens.textbottomNav,
              color: gray,
              fontWeight: FontWeight.w500,
            ),
            currentIndex: selectedIndex,
            unselectedItemColor: white,
            selectedItemColor: colorAccent,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                label: Locales.string(context, "home"),
                backgroundColor: colorPrimary,
                activeIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    imagePath: "ic_homeTab.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: colorAccent,
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    imagePath: "ic_homeTab.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: white,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: Locales.string(context, "play"),
                backgroundColor: colorPrimary,
                activeIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    imagePath: "ic_shorts.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: colorAccent,
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    imagePath: "ic_shorts.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: white,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: "",
                backgroundColor: colorPrimary,
                icon: MyImage(
                  width: Dimens.centerIconbottomNav,
                  height: Dimens.centerIconbottomNav,
                  color: colorAccent,
                  imagePath: "ic_post.png",
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: colorPrimary,
                label: Locales.string(context, "marketplace"),
                activeIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    imagePath: "ic_market.png",
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: colorAccent,
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: white,
                    imagePath: "ic_market.png",
                  ),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: colorPrimary,
                label: Locales.string(context, "profile"),
                activeIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    imagePath: "ic_profileuser.png",
                    fit: BoxFit.cover,
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: colorAccent,
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyImage(
                    fit: BoxFit.cover,
                    width: Dimens.iconbottomNav,
                    height: Dimens.iconbottomNav,
                    color: white,
                    imagePath: "ic_profileuser.png",
                  ),
                ),
              ),
            ],
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }

  // Future<void> _captureVideo() async {
  //   final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     if (!mounted) return;
  //     LoadingOverlay().show(context);
  //     videoImage = await CustomThumbnail.onGet(pickedFile.path);
  //     printLog("Video captured: ${pickedFile.path}");
  //     LoadingOverlay().hide();
  //     printLog("Video Path => ${pickedFile.path}");
  //     printLog("Video Image => $videoImage");
  //     printLog("Video Time => $videoTime");
  //     printLog("Capture filePath =========> ${pickedFile.path}");
  //     final route = MaterialPageRoute(
  //       maintainState: false,
  //       fullscreenDialog: true,
  //       builder: (_) => PreviewReels(
  //         filePath: pickedFile.path,
  //         videoImageFile: videoImage ?? "",
  //         fileType: 'video',
  //       ),
  //     );
  //     if (!mounted) return;
  //     Navigator.push(context, route);
  //   }
  // }
}
