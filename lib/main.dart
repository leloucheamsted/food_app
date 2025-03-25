import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:slike/livestream/golivepreviewprovider.dart';
import 'package:slike/livestream/livestreamprovider.dart';
import 'package:slike/livestream/liveuserlistprovider.dart';
import 'package:slike/model/download_item.dart';
import 'package:slike/provider/allcontentprovider.dart';
import 'package:slike/provider/chatprovider.dart';
import 'package:slike/provider/contentdetailprovider.dart';
import 'package:slike/provider/downloadprovider.dart';
import 'package:slike/provider/feeddetailprovider.dart';
import 'package:slike/provider/feedplayerprovider.dart';
import 'package:slike/provider/feedprovider.dart';
import 'package:slike/provider/inboxprovider.dart';
import 'package:slike/provider/latestfeedprovider.dart';
import 'package:slike/provider/marketplacedetailprovider.dart';
import 'package:slike/provider/marketplaceprovider.dart';
import 'package:slike/provider/myqrprovider.dart';
import 'package:slike/provider/subscribedchannelprovider.dart';
import 'package:slike/provider/uploadproductprovider.dart';
import 'package:slike/provider/withdrawalrequestprovider.dart';
import 'package:slike/provider/galleryvideoprovider.dart';
import 'package:slike/provider/getmusicbycategoryprovider.dart';
import 'package:slike/provider/getmusicbylanguageprovider.dart';
import 'package:slike/provider/historyprovider.dart';
import 'package:slike/provider/likevideosprovider.dart';
import 'package:slike/provider/musicdetailprovider.dart';
import 'package:slike/provider/notificationprovider.dart';
import 'package:slike/provider/playerprovider.dart';
import 'package:slike/provider/playlistcontentprovider.dart';
import 'package:slike/provider/playlistprovider.dart';
import 'package:slike/provider/postvideoprovider.dart';
import 'package:slike/provider/rentprovider.dart';
import 'package:slike/provider/seeallprovider.dart';
import 'package:slike/provider/settingprovider.dart';
import 'package:slike/provider/subscriptionprovider.dart';
import 'package:slike/provider/videopreviewprovider.dart';
import 'package:slike/provider/videorecordprovider.dart';
import 'package:slike/provider/videoscreenprovider.dart';
import 'package:slike/provider/walletprovider.dart';
import 'package:slike/provider/watchlaterprovider.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:slike/firebase_options.dart';
import 'package:slike/pages/splash.dart';
import 'package:slike/provider/detailprovider.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/provider/homeprovider.dart';
import 'package:slike/provider/searchprovider.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/provider/musicprovider.dart';
import 'package:slike/provider/updateprofileprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:slike/webpages/weblatestfeed.dart';
import 'package:slike/webservice/pushnotificationservice.dart';
import 'package:slike/webservice/socketmanager.dart';
import 'provider/feed_detail_with_scrolling_provider.dart';
import 'provider/shortprovider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

Future<void> main() async {
  // Ensure Flutter is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with a small delay to allow Flutter to fully initialize
  await Future.delayed(Duration(milliseconds: 100));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  printLog("Enter Main");
  // Just Audio Player Background Service Set
  /* Initialize Hive Start */
  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(DownloadItemAdapter());
    await Hive.openBox<DownloadItem>('downloads');
  }
  /* Initialize Hive End */

  await JustAudioBackground.init(
    androidNotificationChannelId: Constant.appPackageName,
    androidNotificationChannelName: Constant.appName,
    androidNotificationOngoing: true,
    notificationColor: colorPrimary,
  );

  await Locales.init([
    'en',
    'hi',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi',
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      !kIsWeb && Platform.isLinux
          ? null
          : await flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
  printLog("notificationAppLaunchDetails =====> $notificationAppLaunchDetails");

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage firebaseStorage =
      firebase_storage.FirebaseStorage.instance;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GeneralProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => DetailProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
          ChangeNotifierProvider(create: (_) => UpdateprofileProvider()),
          ChangeNotifierProvider(create: (_) => MusicProvider()),
          ChangeNotifierProvider(create: (_) => ShortProvider()),
          ChangeNotifierProvider(create: (_) => VideoScreenProvider()),
          ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistProvider()),
          ChangeNotifierProvider(create: (_) => WatchLaterProvider()),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
          ChangeNotifierProvider(create: (_) => LikeVideosProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ChangeNotifierProvider(create: (_) => ContentDetailProvider()),
          ChangeNotifierProvider(create: (_) => SeeAllProvider()),
          ChangeNotifierProvider(create: (_) => GetMusicByCategoryProvider()),
          ChangeNotifierProvider(create: (_) => GetMusicByLanguageProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => SettingProvider()),
          ChangeNotifierProvider(create: (_) => RentProvider()),
          ChangeNotifierProvider(create: (_) => AllContentProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistContentProvider()),
          ChangeNotifierProvider(create: (_) => VideoRecordProvider()),
          ChangeNotifierProvider(create: (_) => VideoPreviewProvider()),
          ChangeNotifierProvider(create: (_) => UploadProvider()),
          ChangeNotifierProvider(create: (_) => GalleryVideoProvider()),
          ChangeNotifierProvider(create: (_) => WithdrawalRequestProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => SubscribedChannelProvider()),
          ChangeNotifierProvider(create: (_) => DownloadProvider()),
          ChangeNotifierProvider(create: (_) => MarketPlaceProvider()),
          ChangeNotifierProvider(create: (_) => GoLivePreviewProvider()),
          ChangeNotifierProvider(create: (_) => LiveStreamProvider()),
          ChangeNotifierProvider(create: (_) => LiveUserListProvider()),
          ChangeNotifierProvider(create: (_) => MyQRProvider()),
          ChangeNotifierProvider(create: (_) => FeedProvider()),
          ChangeNotifierProvider(create: (_) => UploadProductProvider()),
          ChangeNotifierProvider(create: (_) => InboxProvider()),
          ChangeNotifierProvider(create: (_) => FeedDetailProvider()),
          ChangeNotifierProvider(
            create: (_) => FeedDetailWithScrollingProvider(),
          ),
          ChangeNotifierProvider(create: (_) => FeedPlayerProvider()),
          ChangeNotifierProvider(create: (_) => MarketPlaceDetailProvider()),
          ChangeNotifierProvider(create: (_) => LatestFeedProvider()),
          ChangeNotifierProvider(
            create:
                (_) => ChatProvider(
                  firebaseFirestore: firebaseFirestore,
                  firebaseStorage: firebaseStorage,
                ),
          ),
        ],
        child: const MyApp(),
      ),
    );
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: black,
      statusBarColor: colorPrimary,
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    PushNotificationService().setupInteractedMessage(context);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _requestPermissions();
    getApi();
    socketIO();
    super.initState();
  }

  void socketIO() {
    // Connect to the Socket.IO server
    SocketManager socketManager = SocketManager();
    io.Socket? socket = socketManager.socket;

    // Listen for messages from the server
    socket?.on('connect', (_) {
      debugPrint('connected to server');
    });
  }

  getApi() async {
    final settingProvider = Provider.of<SettingProvider>(
      context,
      listen: false,
    );
    await settingProvider.getSocialLink();
    await settingProvider.getPages();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isMacOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder:
          (locale) => MaterialApp(
            localizationsDelegates: Locales.delegates,
            supportedLocales: Locales.supportedLocales,
            locale: locale,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            builder:
                (context, child) => ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(
                      start: 1921,
                      end: double.infinity,
                      name: '4K',
                    ),
                  ],
                ),
            home: (kIsWeb) ? const WebLatestFeed() : const Splash(),
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
                PointerDeviceKind.trackpad,
              },
            ),
          ),
    );
  }
}
