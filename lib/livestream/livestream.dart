import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/livestream/comment.dart';
import 'package:slike/livestream/livestreamprovider.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/subscription/adspackage.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/socketmanager.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class LiveStream extends StatefulWidget {
  final String? userId, image, name, userName, roomId;
  final bool isHost;
  const LiveStream({
    super.key,
    required this.userId,
    required this.roomId,
    required this.image,
    required this.name,
    required this.userName,
    required this.isHost,
  });

  @override
  State<LiveStream> createState() => LiveStreamState();
}

class LiveStreamState extends State<LiveStream> with WidgetsBindingObserver {
  late LiveStreamProvider liveStreamProvider;
  SocketManager socketManager = SocketManager();
  io.Socket? socket;
  bool isHost = false;
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;
  String roomId = "";
  final FocusNode _focusNode = FocusNode();
  TextEditingController commentController = TextEditingController();
  late ScrollController _giftScrollController;

  @override
  void initState() {
    liveStreamProvider = Provider.of<LiveStreamProvider>(
      context,
      listen: false,
    );
    _giftScrollController = ScrollController();
    _giftScrollController.addListener(_scrollListener);
    isHost = widget.isHost;
    if (isHost) {
      roomId = Utils.generateRoomId();
      log("===> roomId:$roomId ==> isHost:$isHost");
    } else {
      roomId = widget.roomId ?? "";
      log("===> roomIdelse:$roomId ==> isHost:$isHost");
    }
    startListenEvent();
    loginRoom();
    socketIO();

    if (isHost) {
      liveStreamProvider.onChangeTime();
    } else {
      Timer(const Duration(seconds: 5), () {
        if (remoteView == null) {
          if (!mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      });
    }
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void socketIO() {
    SocketManager socketManager = SocketManager();
    socket = socketManager.socket;

    if (socket?.connected == true) {
      log("=====================Socket Connect====================");

      socketManager.removeListner();

      /* User ViewCount */
      socket?.on('addViewCountToClient', (data) async {
        debugPrint('ViewCount==>: $data');
        await liveStreamProvider.liveCountUpdate(data);
      });

      /* Fetch Live Comment */
      socket?.on('liveChatToClient', (data) async {
        log('comment==>: $data');
        await liveStreamProvider.storeComment(data: data);
      });

      /* Receive Gift */
      socket?.on('sendGiftToClient', (data) async {
        log('giftReceive==>: $data');
        await liveStreamProvider.showGift(data: data);
      });

      /* Host Exit When Call This Socket And Close Audiance View And BackPage Redirect */
      socket?.on('roomDeleted', (data) async {
        if (data["room_id"] == widget.roomId) {
          logoutRoom();
          liveStreamProvider.clearComment();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (BuildContext context) => const Bottombar(isLiveStream: true),
            ),
            (Route<dynamic> route) => false,
          ).then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (BuildContext context) =>
                        const Bottombar(isLiveStream: true),
              ),
            );
          });
        }
      });

      if (isHost) {
        socketManager.goLive(widget.userId, roomId);
      } else {
        socketManager.addView(widget.userId, roomId);
      }
    } else {
      log("=====================Socket Not Connect====================");
    }
  }

  /* ======= Fetch All Gift Start ============ */

  _scrollListener() async {
    if (!_giftScrollController.hasClients) return;
    if (_giftScrollController.offset >=
            _giftScrollController.position.maxScrollExtent &&
        !_giftScrollController.position.outOfRange &&
        (liveStreamProvider.currentPage ?? 0) <
            (liveStreamProvider.totalPage ?? 0)) {
      await liveStreamProvider.setLoadMore(true);
      _fetchGift(liveStreamProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchGift(int? nextPage) async {
    printLog("isMorePage  ======> ${liveStreamProvider.isMorePage}");
    printLog("currentPage ======> ${liveStreamProvider.currentPage}");
    printLog("totalPage   ======> ${liveStreamProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await liveStreamProvider.getProfile(context, widget.userId);
    await liveStreamProvider.fetchGift((nextPage ?? 0) + 1);
    await liveStreamProvider.setLoadMore(false);
  }

  /* ======= Fetch All Gift Stop ============ */

  /* Activity LifeCycle Start */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      log("remove Bg===>");
      // if (isHost) {
      //   socket?.emit('endLive', {
      //     "user_id": widget.userId,
      //     "room_id": roomId,
      //   });
      //   liveStreamProvider.clearCount();
      // } else {
      //   socket?.emit('lessView', {
      //     "user_id": widget.userId,
      //     "room_id": roomId,
      //   });
      // }
    } else {
      log("Other Bg===>");
    }
  } /* Activity LifeCycle Stop */

  @override
  void dispose() {
    log("======>Call Dispose===>");
    if (isHost == false) {
      stopListenEvent();
    }
    logoutRoom();
    liveStreamProvider.clearComment();
    // SocketServices.onLiveRoomExit(isHost: isHost, liveHistoryId: roomID);
    liveStreamProvider.isLivePage = false;
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: black,
        child:
            isHost
                ? hostUI(liveScreen: localView ?? const SizedBox.shrink())
                : audianceUI(
                  liveScreen: remoteView ?? Utils.pageLoader(context),
                  liveRoomId: roomId,
                  liveUserId: widget.userId,
                ),
      ),
    );
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(
        int.parse(Constant.liveAppId.toString()),
        ZegoScenario.Default,
        appSign: Constant.liveAppSign,
        enablePlatformView: true,
      ),
    );

    final user = ZegoUser(widget.userId ?? "", widget.userName ?? "");

    ZegoRoomConfig roomConfig =
        ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;

    log("Pass StreamId in Login===> $roomId");
    return ZegoExpressEngine.instance
        .loginRoom(roomId, user, config: roomConfig)
        .then((ZegoRoomLoginResult loginRoomResult) {
          debugPrint(
            'loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}',
          );
          if (loginRoomResult.errorCode == 0) {
            if (isHost) {
              startPreview();
              startPublish();
              // SocketServices.userWatchCount.value = 0;
              // SocketServices.userChats.clear();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('loginRoom failed: ${loginRoomResult.errorCode}'),
              ),
            );
          }
          return loginRoomResult;
        });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(roomId);
  }

  void startListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = (
      roomID,
      updateType,
      List<ZegoUser> userList,
    ) {
      debugPrint(
        'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}',
      );
    };

    ZegoExpressEngine.onRoomStreamUpdate = (
      roomID,
      updateType,
      List<ZegoStream> streamList,
      extendedData,
    ) {
      debugPrint(
        'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData',
      );
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (BuildContext context) => const Bottombar(isLiveStream: true),
            ),
            (Route<dynamic> route) => false,
          ).then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (BuildContext context) =>
                        const Bottombar(isLiveStream: true),
              ),
            );
          });
        }
      }
    };
    ZegoExpressEngine.onRoomStateUpdate = (
      roomID,
      state,
      errorCode,
      extendedData,
    ) {
      debugPrint(
        'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData',
      );
    };

    ZegoExpressEngine.onPublisherStateUpdate = (
      streamID,
      state,
      errorCode,
      extendedData,
    ) {
      debugPrint(
        'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData',
      );
    };
  }

  void stopListenEvent() {
    // SocketServices.onLessView(
    //     loginUserId: Database.loginUserId, liveHistoryId: roomID);

    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance
        .createCanvasView((viewID) {
          localViewID = viewID;
          ZegoCanvas previewCanvas = ZegoCanvas(
            viewID,
            viewMode: ZegoViewMode.AspectFill,
          );

          ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
        })
        .then((canvasViewWidget) {
          setState(() => localView = canvasViewWidget);
        });
  }

  Future<void> stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
      localViewID = null;
      localView = null;
    }
  }

  Future<void> startPublish() async {
    String streamID = '${roomId}_${widget.userId}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayStream(String streamID) async {
    await ZegoExpressEngine.instance
        .createCanvasView((viewID) {
          remoteViewID = viewID;
          ZegoCanvas canvas = ZegoCanvas(
            viewID,
            viewMode: ZegoViewMode.AspectFill,
          );
          ZegoPlayerConfig config = ZegoPlayerConfig.defaultConfig();
          config.resourceMode = ZegoStreamResourceMode.Default;
          ZegoExpressEngine.instance.enableCamera(
            true,
            channel: ZegoPublishChannel.Main,
          );
          ZegoExpressEngine.instance.startPlayingStream(
            streamID,
            canvas: canvas,
            config: config,
          );
        })
        .then((canvasViewWidget) {
          setState(() => remoteView = canvasViewWidget);
        });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
      setState(() {
        remoteViewID = null;
        remoteView = null;
      });
    }
  }

  /* ================= UI Start ===============  */

  Widget hostUI({required liveScreen}) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showExitDialog(context);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          liveScreen,
          showGift(),
          Positioned(
            bottom: 0,
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: transparent),
            ),
          ),
          Positioned(
            top: 45,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<LiveStreamProvider>(
                          builder: (context, livestreamprovider, child) {
                            return Container(
                              height: 30,
                              width: 76,
                              decoration: BoxDecoration(
                                color: black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    size: 20,
                                    color: white,
                                  ),
                                  const SizedBox(width: 8),
                                  MyText(
                                    color: white,
                                    multilanguage: false,
                                    text:
                                        livestreamprovider.totalViewCount
                                            .toString(),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Consumer<LiveStreamProvider>(
                          builder: (context, livestreamprovider, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer, size: 20, color: white),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 2,
                                    right: 35,
                                  ),
                                  child: MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: livestreamprovider
                                        .onConvertSecondToHMS(
                                          livestreamprovider.countTime,
                                        ),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textDesc,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        circleIconWithButton(
                          color: colorAccent,
                          icon: "ic_close.webp",
                          iconColor: black,
                          onTap: () {
                            showExitDialog(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<LiveStreamProvider>(
                      builder: (context, livestreamprovider, child) {
                        return circleIconWithButton(
                          circleSize: 40,
                          iconSize: 20,
                          color: colorAccent,
                          icon:
                              livestreamprovider.isMicOn
                                  ? "ic_mic_on.webp"
                                  : "ic_mic_off.webp",
                          iconColor: black,
                          onTap: livestreamprovider.onSwitchMic,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Consumer<LiveStreamProvider>(
                      builder: (context, livestreamprovider, child) {
                        return circleIconWithButton(
                          circleSize: 40,
                          iconSize: 20,
                          color: colorAccent,
                          icon: "ic_rotate_camera.webp",
                          iconColor: black,
                          onTap: livestreamprovider.onSwitchCamera,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          /* ================ Send Comment ================ */
          Positioned(
            bottom: 15,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: sendComment(
                  controller: commentController,
                  onTap: () {
                    if (commentController.text.trim().isNotEmpty) {
                      if (socket?.connected == true) {
                        socket?.emit('liveChat', {
                          "user_id": widget.userId,
                          "room_id": roomId,
                          "comment": commentController.text,
                        });
                        log("send Chat Emmit ==>");
                      } else {
                        log(
                          "=====================Socket Not Connect====================",
                        );
                      }
                      log("send Chat==>");
                      commentController.clear();
                    }
                  },
                ),
              ),
            ),
          ),
          /* ================ Send Comment ================ */
          /* ============== Comment Show Live Stream =================== */
          Consumer<LiveStreamProvider>(
            builder: (context, livestreamprovider, child) {
              return Positioned(
                left: 0,
                bottom: 70,
                child: Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width / 1.8,
                  color: transparent,
                  child: SingleChildScrollView(
                    controller: livestreamprovider.scrollController,
                    child: ListView.builder(
                      itemCount: livestreamprovider.commentList?.length ?? 0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Comment(
                          userName:
                              livestreamprovider.commentList?[index].userName
                                  .toString() ??
                              "",
                          comment:
                              livestreamprovider.commentList?[index].comment
                                  .toString() ??
                              "",
                          userImage:
                              livestreamprovider.commentList?[index].image
                                  .toString() ??
                              "",
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          /* ==============Comment Show Live Stream =================== */
        ],
      ),
    );
  }

  Widget audianceUI({required liveScreen, required liveRoomId, liveUserId}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        liveScreen,
        showGift(),
        Positioned(
          top: 50,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer<LiveStreamProvider>(
                    builder: (context, livestreamprovider, child) {
                      return GestureDetector(
                        child: Container(
                          height: 50,
                          width: 200,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(56),
                            color: white.withOpacity(0.20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: MyNetworkImage(
                                      width: 40,
                                      height: 40,
                                      imagePath: widget.image.toString(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: widget.userName ?? "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textMedium,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  circleIconWithButton(
                    color: colorAccent,
                    icon: "ic_close.webp",
                    iconColor: black,
                    onTap: () {
                      if (socket?.connected == true) {
                        socket?.emit('lessView', {
                          "user_id": widget.userId,
                          "room_id": roomId,
                        });
                      }
                      liveStreamProvider.clearComment();
                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [transparent, black.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 15,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  /* ==============Send Comment Show Live Stream =================== */
                  Expanded(
                    child: sendComment(
                      controller: commentController,
                      onTap: () {
                        if (commentController.text.trim().isNotEmpty) {
                          if (socket?.connected == true) {
                            socket?.emit('liveChat', {
                              "user_id": widget.userId,
                              "room_id": roomId,
                              "comment": commentController.text,
                            });
                          } else {
                            log(
                              "=====================Socket Not Connect====================",
                            );
                          }
                          log("send Chat==>");
                          commentController.clear();
                        }
                      },
                    ),
                  ),
                  /* ==============Send Comment Show Live Stream =================== */
                  const SizedBox(width: 15),
                  circleIconWithButton(
                    circleSize: 50,
                    iconSize: 48,
                    color: white.withOpacity(0.20),
                    icon: "ic_gift.gif",
                    onTap: () {
                      openGift();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        /* ==============Comment Show Live Stream =================== */
        Consumer<LiveStreamProvider>(
          builder: (context, livestreamprovider, child) {
            return Positioned(
              left: 0,
              bottom: 70,
              child: Container(
                height: 250,
                width: MediaQuery.of(context).size.width / 1.8,
                color: transparent,
                child: SingleChildScrollView(
                  controller: livestreamprovider.scrollController,
                  child: ListView.builder(
                    itemCount: livestreamprovider.commentList?.length ?? 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Comment(
                        userName:
                            livestreamprovider.commentList?[index].userName
                                .toString() ??
                            "",
                        comment:
                            livestreamprovider.commentList?[index].comment
                                .toString() ??
                            "",
                        userImage:
                            livestreamprovider.commentList?[index].image
                                .toString() ??
                            "",
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        //   /* ==============Comment Show Live Stream =================== */
      ],
    );
  }

  showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: black.withOpacity(0.9),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: transparent,
          elevation: 0,
          child: Container(
            height: 385,
            width: 310,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(45),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  MyImage(width: 90, height: 90, imagePath: "ic_logout.webp"),
                  const SizedBox(height: 10),
                  MyText(
                    color: black,
                    multilanguage: true,
                    text: "stoplive",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textExtraBig,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    color: gray,
                    multilanguage: true,
                    text: "stoplivedisc",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textSmall,
                    inter: false,
                    maxline: 4,
                    fontwaight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (socket?.connected == true) {
                        socket?.emit('endLive', {
                          "user_id": widget.userId,
                          "room_id": roomId,
                        });
                        liveStreamProvider.clearCount();
                        liveStreamProvider.clearComment();
                      }

                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (BuildContext context) =>
                                  const Bottombar(isLiveStream: true),
                        ),
                        (Route<dynamic> route) => false,
                      ).then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (BuildContext context) =>
                                    const Bottombar(isLiveStream: true),
                          ),
                        );
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: gray.withOpacity(0.20),
                      ),
                      alignment: Alignment.center,
                      height: 52,
                      width: MediaQuery.of(context).size.width,
                      child: MyText(
                        color: black,
                        multilanguage: true,
                        text: "stop",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: gray.withOpacity(0.20),
                      ),
                      height: 52,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: MyText(
                        color: gray,
                        multilanguage: true,
                        text: "cancel",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  sendComment({onTap, controller}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.comment_rounded, color: black, size: 20),
          const SizedBox(width: 5),
          VerticalDivider(
            indent: 12,
            endIndent: 12,
            color: gray.withOpacity(0.3),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: gray,
              maxLines: 1,
              onChanged: (value) {
                if (value.isEmpty) {
                  _focusNode.unfocus();
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 3),
                hintText: "Type Comment...",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: Dimens.textDesc,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              width: 40,
              color: transparent,
              child: const Center(
                child: Icon(Icons.send, size: 20, color: gray),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget circleIconWithButton({
    String? icon,
    onTap,
    double? circleSize,
    double? iconSize,
    Color? color,
    Color? iconColor,
    BoxBorder? border,
    EdgeInsetsGeometry? padding,
    Function(LongPressStartDetails)? onLongPressStart,
    Function(LongPressEndDetails)? onLongPressEnd,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPress: () {},
      onLongPressEnd: onLongPressEnd,
      child: Container(
        height: circleSize ?? 42,
        width: circleSize ?? 42,
        padding: padding,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: border,
        ),
        child: Center(
          child: MyImage(
            width: iconSize ?? 22,
            height: iconSize ?? 22,
            imagePath: icon ?? "",
            color: iconColor,
          ),
        ),
      ),
    );
  }

  void openGift() {
    _fetchGift(0);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),
      builder:
          (context) => Container(
            height: 500,
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 65,
                  decoration: const BoxDecoration(color: colorAccent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Consumer<LiveStreamProvider>(
                        builder: (context, livestreamprovider, child) {
                          return Container(
                            height: 34,
                            padding: const EdgeInsets.only(left: 5, right: 10),
                            decoration: BoxDecoration(
                              color: white.withOpacity(0.1),
                              border: Border.all(color: black.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                MyImage(
                                  width: 22,
                                  height: 22,
                                  imagePath: "ic_coin.png",
                                ),
                                const SizedBox(width: 5),
                                MyText(
                                  color: black,
                                  multilanguage: false,
                                  text:
                                      livestreamprovider
                                          .profileModel
                                          .result?[0]
                                          .walletBalance
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textSmall,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 4,
                              width: 35,
                              decoration: BoxDecoration(
                                color: black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 15),
                            MyText(
                              color: black,
                              multilanguage: true,
                              text: "sendgift",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textTitle,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!mounted) return;
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: transparent,
                            border: Border.all(color: black),
                          ),
                          child: Center(
                            child: MyImage(
                              width: 15,
                              color: black,
                              height: 15,
                              imagePath: "ic_close.webp",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<LiveStreamProvider>(
                  builder: (context, livestreamprovider, child) {
                    return Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: _giftScrollController,
                        child: Column(
                          children: [
                            ResponsiveGridList(
                              minItemWidth: 120,
                              minItemsPerRow: 3,
                              maxItemsPerRow: 3,
                              horizontalGridSpacing: 10,
                              verticalGridSpacing: 10,
                              listViewBuilderOptions: ListViewBuilderOptions(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                              children: List.generate(
                                livestreamprovider.giftList?.length ?? 0,
                                (index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: colorPrimaryDark,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: MyNetworkImage(
                                            width: 45,
                                            height: 45,
                                            imagePath:
                                                livestreamprovider
                                                    .giftList?[index]
                                                    .image
                                                    .toString() ??
                                                "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: gray.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: MyText(
                                            color: white,
                                            multilanguage: false,
                                            text:
                                                "${livestreamprovider.giftList?[index].price.toString() ?? ""} Coins",
                                            textalign: TextAlign.center,
                                            fontsizeNormal: Dimens.textSmall,
                                            inter: false,
                                            maxline: 1,
                                            fontwaight: FontWeight.w700,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            if (socket?.connected == true) {
                                              if (((livestreamprovider
                                                              .giftList?[index]
                                                              .price ??
                                                          0) ==
                                                      (livestreamprovider
                                                              .profileModel
                                                              .result?[0]
                                                              .walletBalance ??
                                                          0)) ||
                                                  ((livestreamprovider
                                                              .giftList?[index]
                                                              .price ??
                                                          0)) <
                                                      (livestreamprovider
                                                              .profileModel
                                                              .result?[0]
                                                              .walletBalance ??
                                                          0)) {
                                                socket?.emit('sendGift', {
                                                  "user_id": widget.userId,
                                                  "room_id": roomId,
                                                  "gift_id":
                                                      livestreamprovider
                                                          .giftList?[index]
                                                          .id
                                                          .toString() ??
                                                      "",
                                                });
                                                log(
                                                  "=====================Send Gift====================",
                                                );

                                                if (!mounted) return;
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                              } else {
                                                /* Move TO Recharge Page */
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return const AdsPackage();
                                                    },
                                                  ),
                                                );
                                              }
                                            } else {
                                              Utils.showSnackbar(
                                                context,
                                                "Socket Connection Faild Please Check Connection!!!",
                                                false,
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: 35,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              color: colorAccent,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    bottom: Radius.circular(24),
                                                  ),
                                            ),
                                            child: MyText(
                                              color: black,
                                              multilanguage: true,
                                              text: "send",
                                              textalign: TextAlign.center,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal,
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
                    );
                  },
                ),
                const SizedBox(height: 10),
                /* Recharge Button */
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const AdsPackage();
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 55,
                          width: 130,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: MyImage(
                                    width: 22,
                                    height: 22,
                                    imagePath: "ic_coin.png",
                                  ),
                                ),
                                const SizedBox(width: 5),
                                MyText(
                                  color: white,
                                  multilanguage: true,
                                  text: "addcoins",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textDesc,
                                  inter: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
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
  }

  Widget showGift() {
    return Consumer<LiveStreamProvider>(
      builder: (context, livestreamprovider, child) {
        if (livestreamprovider.giftUrl != null) {
          return Align(
            alignment: Alignment.center,
            child: Image.network(
              livestreamprovider.giftUrl ?? "",
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /* ================ UI Stop ================  */
}
