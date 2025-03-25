import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/music/musicdetails.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/detailprovider.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/provider/playerprovider.dart';
import 'package:slike/utils/customads.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:slike/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Detail extends StatefulWidget {
  final String videoid;
  final int? stoptime;
  final bool iscontinueWatching;
  const Detail({
    super.key,
    required this.videoid,
    required this.iscontinueWatching,
    required this.stoptime,
  });

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> with RouteAware {
  late PlayerProvider playerProvider;
  ChewieController? _chewieController;
  late VideoPlayerController _videoPlayerController;
  YoutubePlayerController? controller;

  double? playerCPosition, videoDuration;
  double? youtubecurrentTime, youtubeTotalDuration;

  /* Trailer init */
  late DetailProvider detailsProvider;
  late GeneralProvider generalProvider;
  late ScrollController _scrollController;
  late ScrollController replaycommentController;
  final commentController = TextEditingController();
  String savePath = "";

  @override
  void initState() {
    detailsProvider = Provider.of<DetailProvider>(context, listen: false);
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    replaycommentController = ScrollController();
    replaycommentController.addListener(_scrollListenerReplayComment);
    /* Fetch Custom Reward Ads */
    // getRewardAds();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playerInitialize();
      _fetchCommentData(0);
      _fetchRelatedVideo(widget.videoid, 0);
    });
  }

  playerInitialize() async {
    await detailsProvider.getvideodetails(widget.videoid.toString(), "1");
    if (detailsProvider.detailsModel.status == 200 &&
        detailsProvider.detailsModel.result != null &&
        (detailsProvider.detailsModel.result?.length ?? 0) > 0) {
      if (detailsProvider.detailsModel.result?[0].contentUploadType
              .toString() ==
          "youtube") {
        _initYoutubePlayer(
          detailsProvider.detailsModel.result?[0].content.toString() ?? "",
        );
      } else {
        /* Video Player */
        _playerInit(
          detailsProvider.detailsModel.result?[0].content.toString() ?? "",
        );
      }
    }
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if ((detailsProvider.currentPageComment ?? 0) <
          (detailsProvider.totalPageComment ?? 0)) {
        await detailsProvider.setCommentLoadMore(true);
        _fetchCommentData(detailsProvider.currentPageComment ?? 0);
      }

      if ((detailsProvider.relatedVideocurrentPage ?? 0) <
          (detailsProvider.relatedVideototalPage ?? 0)) {
        await detailsProvider.setRelatedLoadMore(true);
        _fetchRelatedVideo(
          widget.videoid,
          detailsProvider.relatedVideocurrentPage ?? 0,
        );
      }
    }
  }

  Future<void> _fetchCommentData(int? nextPage) async {
    printLog("isMorePage  ======> ${detailsProvider.morePageComment}");
    printLog("currentPage ======> ${detailsProvider.currentPageComment}");
    printLog("totalPage   ======> ${detailsProvider.totalPageComment}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getComment("1", widget.videoid, (nextPage ?? 0) + 1);
    await detailsProvider.setCommentLoading(false);
  }

  _scrollListenerReplayComment() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (detailsProvider.currentPageReplayComment ?? 0) <
            (detailsProvider.totalPageReplayComment ?? 0)) {
      await detailsProvider.setReplayCommentLoadMore(true);
      _fetchReplayCommentData(
        detailsProvider.commentId,
        detailsProvider.currentPageReplayComment ?? 0,
      );
    }
  }

  Future<void> _fetchReplayCommentData(commentid, int? nextPage) async {
    printLog("isMorePage  ======> ${detailsProvider.morePageReplayComment}");
    printLog("currentPage ======> ${detailsProvider.currentPageReplayComment}");
    printLog("totalPage   ======> ${detailsProvider.totalPageReplayComment}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await detailsProvider.getReplayComment(commentid, (nextPage ?? 0) + 1);
    await detailsProvider.setReplayCommentLoadMore(false);
  }

  Future<void> _fetchRelatedVideo(contentId, int? nextPage) async {
    await detailsProvider.getRelatedVideo(contentId, (nextPage ?? 0) + 1);
    await detailsProvider.setRelatedLoadMore(false);
  }

  /* =====================Video Player======================= */

  /* Youtube Player Start */

  _initYoutubePlayer(String videoUrl) async {
    controller = YoutubePlayerController(
      initialVideoId: Utils.convertUrlToId(videoUrl) ?? "",
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    // Api Call CourseView
    await playerProvider.addVideoView("1", widget.videoid);
  }

  /* Youtube Player End */

  /* Server Video And External Video Player Start */

  _playerInit(String videoUrl) async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );
    await Future.wait([_videoPlayerController.initialize()]);

    /* Chewie Controller */
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      autoInitialize: true,
      looping: false,
      fullScreenByDefault: false,
      allowFullScreen: true,
      hideControlsTimer: const Duration(seconds: 1),
      showControls: true,
      allowedScreenSleep: false,
      cupertinoProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorAccent,
        backgroundColor: gray,
        bufferedColor: colorAccent,
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: colorPrimary,
        handleColor: colorAccent,
        backgroundColor: gray,
        bufferedColor: colorAccent,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: MyText(
            color: white,
            text: errorMessage,
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textMedium,
            fontwaight: FontWeight.w600,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        );
      },
    );
    await playerProvider.addVideoView("1", widget.videoid);

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  /* Server Video And External Video Player End */
  /* =====================Video Player====================== */

  getRewardAds() async {
    await generalProvider.getAds(3);
  }

  @override
  void dispose() {
    detailsProvider.clearProvider();
    generalProvider.clearProvider();
    _chewieController?.dispose();
    // _chewieController?.exitFullScreen();
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SafeArea(child: player()),
    );
  }

  Widget ads() {
    if (Constant.rewardadStatus == "1" &&
        (((Constant.isAdsfree != "1") ||
            (Constant.isAdsfree == null) ||
            (Constant.isAdsfree == "")))) {
      return Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
          if (generalprovider.loading) {
            return Utils.pageLoader(context);
          } else {
            if (generalprovider.getRewardAdsModel.status == 200 &&
                generalprovider.getRewardAdsModel.result != null &&
                (generalprovider.isCloseRewardAds == false) &&
                (generalprovider.showSkip == false) &&
                ((generalprovider.getRewardAdsModel.result?.isHide ?? 0) ==
                    0)) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 225,
                    width: MediaQuery.of(context).size.width,
                    child: AdsPlayer(
                      contentId: widget.videoid,
                      videoUrl:
                          generalprovider.getRewardAdsModel.result?.video
                              .toString() ??
                          "",
                    ),
                  ),
                  Expanded(child: buildOtherDetail()),
                ],
              );
            } else {
              return player();
            }
          }
        },
      );
    } else {
      return player();
    }
  }

  Widget player() {
    return Consumer<DetailProvider>(
      builder: (context, detailsProvider, child) {
        if (detailsProvider.loading) {
          return shimmer();
        }
        if (detailsProvider.detailsModel.status == 200 &&
            detailsProvider.detailsModel.result != null &&
            (detailsProvider.detailsModel.result?.length ?? 0) > 0) {
          if (detailsProvider.detailsModel.result?[0].content.toString() !=
              "") {
            if (detailsProvider.detailsModel.result?[0].contentUploadType
                    .toString() ==
                "youtube") {
              if (controller == null) {
                return shimmer();
              } else {
                /* Youtube Player */
                return YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    aspectRatio: 16 / 9,
                    controller: controller!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: colorAccent,
                    onReady: () {},
                  ),
                  builder: (context, player) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Player
                        Stack(
                          children: [
                            player,
                            if (!kIsWeb)
                              Positioned(
                                top: 15,
                                left: 15,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  focusColor: gray.withOpacity(0.5),
                                  onTap: () {
                                    onBackPressed();
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
                                ),
                              ),
                          ],
                        ),
                        Expanded(child: buildOtherDetail()),
                      ],
                    );
                  },
                );
              }
            } else {
              /* Video Player */
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (_chewieController != null &&
                      _chewieController?.videoPlayerController.value != null &&
                      _chewieController!
                          .videoPlayerController
                          .value
                          .isInitialized)
                    SizedBox(
                      height: 225,
                      width: MediaQuery.of(context).size.width,
                      child: AspectRatio(
                        aspectRatio:
                            _chewieController?.aspectRatio ??
                            (_chewieController
                                    ?.videoPlayerController
                                    .value
                                    .aspectRatio ??
                                16 / 9),
                        child: Chewie(controller: _chewieController!),
                      ),
                    )
                  else
                    buildImageShimmer(),
                  Expanded(child: buildOtherDetail()),
                ],
              );
            }
          } else {
            return buildImage();
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /* =====================Video Player================ */

  Widget buildImage() {
    return Consumer<DetailProvider>(
      builder: (context, detailsProvider, child) {
        if (detailsProvider.loading) {
          return buildImageShimmer();
        } else {
          return Stack(
            children: [
              MyNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: 300,
                fit: BoxFit.fill,
                imagePath:
                    detailsProvider.detailsModel.result?[0].portraitImg
                        .toString() ??
                    "",
              ),
              /* Back Button */
              Positioned.fill(
                top: 35,
                left: 15,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      if (!mounted) return;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: MyImage(
                        width: 30,
                        height: 30,
                        imagePath: "ic_roundback.png",
                      ),
                    ),
                  ),
                ),
              ),
              /* Play Button */
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      Utils().showInterstitalAds(
                        context,
                        Constant.rewardAdType,
                        () {
                          if (Constant.userID == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Login();
                                },
                              ),
                            );
                          } else {
                            printLog("StopTime====>${widget.stoptime}");
                            /* StopTime Converted Milisecond To Second */
                            double stopTime = 0.0;
                            if (widget.stoptime == 0) {
                              stopTime = 0.0;
                            } else {
                              double convertTime =
                                  (widget.stoptime ?? 0.0) / 1000;
                              stopTime = convertTime;
                            }
                            printLog("StopTime====>${widget.stoptime}");

                            audioPlayer.pause();
                            Utils.openPlayer(
                              isDownloadVideo: false,
                              iscontinueWatching: widget.iscontinueWatching,
                              stoptime: stopTime,
                              context: context,
                              videoId:
                                  detailsProvider.detailsModel.result?[0].id
                                      .toString() ??
                                  "",
                              videoUrl:
                                  detailsProvider
                                      .detailsModel
                                      .result?[0]
                                      .content
                                      .toString() ??
                                  "",
                              vUploadType:
                                  detailsProvider
                                      .detailsModel
                                      .result?[0]
                                      .contentUploadType
                                      .toString() ??
                                  "",
                              videoThumb:
                                  detailsProvider
                                      .detailsModel
                                      .result?[0]
                                      .landscapeImg
                                      .toString() ??
                                  "",
                            );
                          }
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: MyImage(
                        width: 50,
                        height: 50,
                        imagePath: "pause.png",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget buildImageShimmer() {
    return CustomWidget.rectangular(
      width: MediaQuery.of(context).size.width,
      height: 250,
    );
  }

  Widget buildOtherDetail() {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 190),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildDiscription(),
          const SizedBox(height: 15),
          channelItem(),
          const SizedBox(height: 25),
          functionList(),
          const SizedBox(height: 20),
          addComment(),
          const SizedBox(height: 15),
          buildComment(),
          const SizedBox(height: 15),
          relatedVideo(),
        ],
      ),
    );
  }

  // Video Image End

  /* =====================Video Player================ */

  // build Title Discription With view Count

  Widget buildDiscription() {
    if (detailsProvider.loading) {
      return buildDiscriptionShimmer();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
            color: white,
            text:
                detailsProvider.detailsModel.result?[0].title.toString() ?? "",
            multilanguage: false,
            textalign: TextAlign.left,
            fontsizeNormal: Dimens.textBig,
            maxline: 5,
            fontwaight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(minHeight: 0),
            alignment: Alignment.centerLeft,
            child: ExpandableText(
              detailsProvider.detailsModel.result?[0].description.toString() ??
                  "",
              expandText: "Read More",
              collapseText: "Read less",
              maxLines: 2,
              expandOnTextTap: true,
              collapseOnTextTap: true,
              linkStyle: TextStyle(
                fontSize: Dimens.textDesc,
                fontStyle: FontStyle.normal,
                color: colorAccent,
                fontWeight: FontWeight.w600,
              ),
              style: TextStyle(
                fontSize: Dimens.textMedium,
                fontStyle: FontStyle.normal,
                color: gray,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              MyText(
                color: gray,
                text: Utils.kmbGenerator(
                  detailsProvider.detailsModel.result?[0].totalView ?? 0,
                ),
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textSmall,
                inter: false,
                multilanguage: false,
                maxline: 2,
                fontwaight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(width: 5),
              MyText(
                color: gray,
                text: "views",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textSmall,
                inter: false,
                multilanguage: true,
                maxline: 2,
                fontwaight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(width: 15),
              // MyText(
              //     color: gray,
              //     text: Utils.timeAgoCustom(DateTime.parse(detailsProvider
              //             .detailsModel.result?[0].createdAt
              //             .toString() ??
              //         "")),
              //     textalign: TextAlign.left,
              //     fontsizeNormal: Dimens.textMedium,
              //     fontsizeWeb: Dimens.textMedium,
              //     inter: false,
              //     multilanguage: false,
              //     maxline: 2,
              //     fontwaight: FontWeight.w400,
              //     overflow: TextOverflow.ellipsis,
              //     fontstyle: FontStyle.normal),
            ],
          ),
        ],
      );
    }
  }

  Widget buildDiscriptionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width,
        ),
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width * 0.75,
        ),
        CustomWidget.roundrectborder(
          height: 12,
          width: MediaQuery.of(context).size.width * 0.30,
        ),
        const SizedBox(height: 10),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width,
        ),
        CustomWidget.roundrectborder(
          height: 5,
          width: MediaQuery.of(context).size.width * 0.50,
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            CustomWidget.circular(height: 10, width: 10),
            SizedBox(width: 5),
            CustomWidget.roundrectborder(height: 5, width: 60),
            SizedBox(width: 15),
            CustomWidget.roundrectborder(height: 5, width: 60),
          ],
        ),
      ],
    );
  }

  // Add Comment Seaction
  Widget addComment() {
    if (detailsProvider.loading) {
      return addCommentShimmer();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            color: white,
            text: "comments",
            textalign: TextAlign.left,
            fontsizeNormal: Dimens.textSmall,
            inter: false,
            maxline: 2,
            multilanguage: true,
            fontwaight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Constant.userID == null
                  ? MyImage(
                    width: 35,
                    height: 35,
                    imagePath: "ic_user.png",
                    color: colorAccent,
                  )
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                      width: 35,
                      height: 35,
                      imagePath: Constant.userImage ?? "",
                      fit: BoxFit.fill,
                    ),
                  ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextFormField(
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    controller: commentController,
                    textInputAction: TextInputAction.done,
                    cursorColor: lightgray,
                    style: Utils.googleFontStyle(
                      4,
                      14,
                      FontStyle.normal,
                      white,
                      FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintStyle: Utils.googleFontStyle(
                        4,
                        14,
                        FontStyle.normal,
                        white,
                        FontWeight.w400,
                      ),
                      hintText: "Add Your comment here...",
                      filled: true,
                      fillColor: colorPrimaryDark,
                      contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(width: 1, color: colorPrimary),
                      ),
                      disabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(width: 1, color: colorPrimary),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(width: 1, color: colorPrimary),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(width: 1, color: colorPrimary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () async {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Login();
                        },
                      ),
                    );
                  } else {
                    if (detailsProvider.detailsModel.result?[0].isComment ==
                        0) {
                      Utils.showSnackbar(
                        context,
                        "youcannotcommentthiscontent",
                        false,
                      );
                    } else if (commentController.text.isEmpty) {
                      Utils.showSnackbar(
                        context,
                        "pleaseenteryourcomment",
                        false,
                      );
                    } else {
                      await detailsProvider.getaddcomment(
                        "1",
                        widget.videoid,
                        "0",
                        commentController.text.toString(),
                        "0",
                      );
                      commentController.clear();
                    }
                  }
                },
                child: Consumer<DetailProvider>(
                  builder: (context, detailsProvider, child) {
                    if (detailsProvider.addcommentloading) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: colorAccent,
                          strokeWidth: 1,
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: colorAccent,
                          shape: BoxShape.circle,
                        ),
                        child: MyImage(
                          width: 20,
                          height: 20,
                          imagePath: "ic_send.png",
                          color: black,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget addCommentShimmer() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomWidget.roundrectborder(height: 5, width: 60),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomWidget.circular(width: 35, height: 35),
            SizedBox(width: 10),
            Expanded(child: CustomWidget.roundcorner(height: 35)),
            SizedBox(width: 10),
            CustomWidget.circular(width: 35, height: 35),
          ],
        ),
      ],
    );
  }

  // Channel Section
  Widget channelItem() {
    if (detailsProvider.loading) {
      return channelItemShimmer();
    } else {
      return InkWell(
        onTap: () {
          if (Constant.userID == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Login();
                },
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Profile(
                    isBottomBar: false,
                    toUserId:
                        detailsProvider.detailsModel.result?[0].userId
                            .toString() ??
                        "",
                    toChannelId:
                        detailsProvider.detailsModel.result?[0].channelId
                            .toString() ??
                        "",
                  );
                },
              ),
            );
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: MyNetworkImage(
                width: 35,
                height: 35,
                imagePath:
                    detailsProvider.detailsModel.result?[0].channelImage
                        .toString() ??
                    "",
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: white,
                    text:
                        detailsProvider.detailsModel.result?[0].channelName
                            .toString() ??
                        "",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textDesc,
                    multilanguage: false,
                    maxline: 1,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      MyText(
                        color: white,
                        text: Utils.kmbGenerator(
                          detailsProvider
                                  .detailsModel
                                  .result?[0]
                                  .totalSubscriber ??
                              0,
                        ),
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textSmall,
                        inter: false,
                        maxline: 1,
                        multilanguage: false,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(width: 5),
                      MyText(
                        color: white,
                        text: "subscriber",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textSmall,
                        inter: false,
                        maxline: 1,
                        multilanguage: true,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            detailsProvider.detailsModel.result?[0].userId.toString() ==
                    Constant.userID
                ? const SizedBox.shrink()
                : InkWell(
                  onTap: () async {
                    if (Constant.userID == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const Login();
                          },
                        ),
                      );
                    } else {
                      await detailsProvider.addremoveSubscribe(
                        detailsProvider.detailsModel.result?[0].userId
                                .toString() ??
                            "",
                        "1",
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          detailsProvider.detailsModel.result?[0].isSubscribe ==
                                  0
                              ? colorAccent
                              : colorPrimary,
                      border: Border.all(width: 1, color: colorAccent),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: MyText(
                      color:
                          detailsProvider.detailsModel.result?[0].isSubscribe ==
                                  0
                              ? black
                              : white,
                      text:
                          detailsProvider.detailsModel.result?[0].isSubscribe ==
                                  0
                              ? "follow"
                              : "following",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textSmall,
                      inter: false,
                      maxline: 2,
                      multilanguage: true,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
          ],
        ),
      );
    }
  }

  Widget channelItemShimmer() {
    return const Row(
      children: [
        CustomWidget.circular(width: 35, height: 35),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(height: 8),
              SizedBox(height: 5),
              CustomWidget.roundrectborder(height: 8, width: 100),
            ],
          ),
        ),
        SizedBox(width: 15),
        CustomWidget.roundcorner(height: 18, width: 65),
      ],
    );
  }

  // Like Difood_app Button
  Widget functionList() {
    if (detailsProvider.loading) {
      return functionListShimmer();
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            detailsProvider.detailsModel.result?[0].ifood_app == 1
                ? Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: colorPrimaryDark,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          if (Constant.userID == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Login();
                                },
                              ),
                            );
                          } else {
                            if (detailsProvider
                                    .detailsModel
                                    .result?[0]
                                    .ifood_app ==
                                0) {
                              Utils.showSnackbar(
                                context,
                                "youcannotlikethiscontent",
                                true,
                              );
                            } else {
                              if ((detailsProvider
                                          .detailsModel
                                          .result?[0]
                                          .isUserLikeDifood_app ??
                                      0) ==
                                  1) {
                                printLog("Remove Api");
                                await detailsProvider.like(
                                  "1",
                                  detailsProvider.detailsModel.result?[0].id
                                          .toString() ??
                                      "",
                                  "0",
                                  "0",
                                );
                              } else {
                                await detailsProvider.like(
                                  "1",
                                  detailsProvider.detailsModel.result?[0].id
                                          .toString() ??
                                      "",
                                  "1",
                                  "0",
                                );
                              }
                            }
                          }
                        },
                        child: Row(
                          children: [
                            (detailsProvider
                                            .detailsModel
                                            .result?[0]
                                            .isUserLikeDifood_app ??
                                        0) ==
                                    1
                                ? MyImage(
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                  color: colorAccent,
                                  imagePath: "ic_muscle.png",
                                )
                                : MyImage(
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                  color: white,
                                  imagePath: "ic_muscle.png",
                                ),
                            const SizedBox(width: 8),
                            MyText(
                              color: white,
                              text: Utils.kmbGenerator(
                                int.parse(
                                  detailsProvider
                                          .detailsModel
                                          .result?[0]
                                          .totalLike
                                          .toString() ??
                                      "",
                                ),
                              ),
                              multilanguage: false,
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textTitle,
                              inter: false,
                              maxline: 6,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(width: 10),
                      // Container(
                      //   width: 1,
                      //   height: 20,
                      //   color: white,
                      // ),
                      // const SizedBox(width: 10),
                      // InkWell(
                      //   onTap: () async {
                      //     if (Constant.userID == null) {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) {
                      //             return const Login();
                      //           },
                      //         ),
                      //       );
                      //     } else {
                      //       // Difood_app APi Call
                      //       if (detailsProvider
                      //               .detailsModel.result?[0].ifood_app ==
                      //           0) {
                      //         Utils.showSnackbar(context,
                      //             "youcannotlikethiscontent", true);
                      //       } else {
                      //         if ((detailsProvider.detailsModel.result?[0]
                      //                     .isUserLikeDifood_app ??
                      //                 2) ==
                      //             0) {
                      //           printLog("Remove Api");
                      //           await detailsProvider.difood_app(
                      //               "1",
                      //               detailsProvider
                      //                       .detailsModel.result?[0].id
                      //                       .toString() ??
                      //                   "",
                      //               "0",
                      //               "0");
                      //         } else {
                      //           await detailsProvider.difood_app(
                      //               "1",
                      //               detailsProvider
                      //                       .detailsModel.result?[0].id
                      //                       .toString() ??
                      //                   "",
                      //               "2",
                      //               "0");
                      //         }
                      //       }
                      //     }
                      //   },
                      //   child: (detailsProvider.detailsModel.result?[0]
                      //                   .isUserLikeDifood_app ??
                      //               0) ==
                      //           2
                      //       ? MyImage(
                      //           width: 25,
                      //           height: 25,
                      //           color: colorAccent,
                      //           imagePath: "ic_difood_appfill.png",
                      //         )
                      //       : MyImage(
                      //           width: 25,
                      //           height: 25,
                      //           imagePath: "ic_difood_app.png",
                      //         ),
                      // ),
                      // const SizedBox(width: 10),
                    ],
                  ),
                )
                : const SizedBox.shrink(),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Utils.shareApp(
                  Platform.isIOS
                      ? "Hey! I'm Listening ${detailsProvider.detailsModel.result?[0].id.toString()}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                      : "Hey! I'm Listening ${detailsProvider.detailsModel.result?[0].id.toString()}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorPrimaryDark,
                ),
                child: Row(
                  children: [
                    MyImage(
                      width: 10,
                      height: 10,
                      imagePath: "ic_share.png",
                      color: white,
                    ),
                    const SizedBox(width: 5),
                    MyText(
                      color: white,
                      text: "share",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      inter: false,
                      maxline: 6,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ((detailsProvider.detailsModel.result?[0].contentUploadType ==
                        "external") ||
                    (detailsProvider
                                .detailsModel
                                .result?[0]
                                .contentUploadType ==
                            "server_video") &&
                        (detailsProvider
                                .detailsModel
                                .result?[0]
                                .isUserDownload ==
                            1))
                ? InkWell(
                  onTap: () async {
                    /* Download Video With All Related Item Start */
                    await ApiService().downloadContent(
                      context: context,
                      contentId:
                          detailsProvider.detailsModel.result?[0].id ?? 0,
                      title:
                          detailsProvider.detailsModel.result?[0].title
                              .toString() ??
                          "",
                      channelName:
                          detailsProvider.detailsModel.result?[0].channelName
                              .toString() ??
                          "",
                      image:
                          detailsProvider.detailsModel.result?[0].landscapeImg
                              .toString() ??
                          "",
                      videoUrl:
                          detailsProvider.detailsModel.result?[0].content
                              .toString() ??
                          "",
                      videoUploadType:
                          detailsProvider
                              .detailsModel
                              .result?[0]
                              .contentUploadType
                              .toString() ??
                          "",
                    );

                    /* Download Video With All Related Item End */
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorPrimaryDark,
                    ),
                    child: Row(
                      children: [
                        MyImage(
                          width: 10,
                          height: 10,
                          imagePath: "ic_share.png",
                          color: white,
                        ),
                        const SizedBox(width: 5),
                        MyText(
                          color: white,
                          text: "download",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
                          inter: false,
                          maxline: 6,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  ),
                )
                : const SizedBox.shrink(),
          ],
        ),
      );
    }
  }

  Widget functionListShimmer() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomWidget.roundcorner(height: 25, width: 90),
        SizedBox(width: 10),
        CustomWidget.roundcorner(height: 25, width: 90),
        SizedBox(width: 10),
        CustomWidget.roundcorner(height: 25, width: 90),
      ],
    );
  }

  // Comments
  Widget buildComment() {
    if (detailsProvider.commentloading && !detailsProvider.commentloadmore) {
      return commentShimmer();
    } else {
      return Column(
        children: [
          commentList(),
          if (detailsProvider.commentloadmore)
            Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
              child: Utils.pageLoader(context),
            )
          else
            const SizedBox.shrink(),
        ],
      );
    }
  }

  Widget commentList() {
    if (detailsProvider.commentList != null) {
      if ((detailsProvider.commentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: detailsProvider.commentList?.length ?? 0,
            itemBuilder: (BuildContext ctx, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        width: 35,
                        height: 35,
                        imagePath:
                            detailsProvider.commentList?[index].image
                                .toString() ??
                            "",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            color: white,
                            text:
                                detailsProvider.commentList?[index].channelName
                                    .toString() ??
                                "",
                            fontsizeNormal: Dimens.textTitle,
                            fontwaight: FontWeight.w500,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            inter: false,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                          const SizedBox(height: 5),
                          MyText(
                            color: gray,
                            text:
                                detailsProvider.commentList?[index].comment
                                    .toString() ??
                                "",
                            fontsizeNormal: Dimens.textMedium,
                            fontwaight: FontWeight.w400,
                            multilanguage: false,
                            inter: false,
                            maxline: 2,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.left,
                            fontstyle: FontStyle.normal,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  detailsProvider.storeReplayCommentId(
                                    detailsProvider.commentList?[index].id
                                            .toString() ??
                                        "",
                                  );
                                  _fetchReplayCommentData(
                                    detailsProvider.commentList?[index].id
                                            .toString() ??
                                        "",
                                    0,
                                  );
                                  replayCommentBottomSheet(
                                    index,
                                    detailsProvider.detailsModel.result?[0].id
                                            .toString() ??
                                        "",
                                    detailsProvider.commentList?[index].id
                                            .toString() ??
                                        "",
                                    detailsProvider.commentList?[index].image
                                            .toString() ??
                                        "",
                                    detailsProvider
                                            .commentList?[index]
                                            .channelName
                                            .toString() ??
                                        "",
                                    detailsProvider.commentList?[index].comment
                                            .toString() ??
                                        "",
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: colorPrimaryDark,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: MyImage(
                                    width: 12,
                                    height: 12,
                                    imagePath: "ic_comment.png",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              if (detailsProvider.commentList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                                if (detailsProvider.deletecommentLoading)
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorAccent,
                                      strokeWidth: 1,
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () async {
                                      if (Constant.userID == null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const Login();
                                            },
                                          ),
                                        );
                                      } else {
                                        await detailsProvider.getDeleteComment(
                                          detailsProvider.commentList?[index].id
                                                  .toString() ??
                                              "",
                                          true,
                                          index,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: colorPrimaryDark,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: MyImage(
                                        width: 12,
                                        height: 12,
                                        imagePath: "ic_delete.png",
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget commentShimmer() {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (BuildContext ctx, index) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.circular(width: 35, height: 35),
                SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(width: 200, height: 5),
                      SizedBox(height: 5),
                      CustomWidget.roundrectborder(width: 200, height: 5),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          CustomWidget.circular(width: 10, height: 10),
                          SizedBox(width: 15),
                          CustomWidget.circular(width: 10, height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Replay Comment
  replayCommentBottomSheet(
    int index,
    videoid,
    commentid,
    commentUserImage,
    commentUsername,
    comment,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            buildReplayComment(
              index,
              videoid,
              commentid,
              commentUserImage,
              commentUsername,
              comment,
            ),
          ],
        );
      },
    ).whenComplete(() {
      printLog(
        "comment count ====>>> ${detailsProvider.getcommentModel.result?.length}",
      );
    });
  }

  Widget buildReplayComment(
    index,
    videoid,
    commentId,
    commentUserImage,
    commentUsername,
    comment,
  ) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                        color: white,
                        text: "replay",
                        fontsizeNormal: Dimens.textTitle,
                        fontwaight: FontWeight.w500,
                        multilanguage: true,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        inter: false,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        commentController.clear();
                        detailsProvider.clearComment();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: white),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        imagePath: commentUserImage,
                        fit: BoxFit.fill,
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        color: white,
                        text: commentUsername,
                        fontsizeNormal: Dimens.textMedium,
                        fontwaight: FontWeight.w500,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        inter: false,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 5),
                      MyText(
                        color: white,
                        text: comment,
                        fontsizeNormal: Dimens.textSmall,
                        fontwaight: FontWeight.w400,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        inter: false,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: buildreplayCommentList()),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Replay Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: white,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else if (commentController.text.isEmpty) {
                          Utils.showSnackbar(
                            context,
                            "pleaseenteryourcomment",
                            true,
                          );
                        } else {
                          printLog("videoid==> $videoid");
                          printLog("comment==> ${commentController.text}");
                          printLog("comment==> $commentId");
                          await detailsProvider.getaddReplayComment(
                            "1",
                            videoid,
                            "0",
                            commentController.text,
                            commentId,
                          );
                          commentController.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<DetailProvider>(
                            builder: (context, detailsProvider, child) {
                              if (detailsProvider.addreplaycommentloading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorAccent,
                                    strokeWidth: 1,
                                  ),
                                );
                              } else {
                                return MyImage(
                                  width: 20,
                                  height: 20,
                                  color: white,
                                  imagePath: "ic_send.png",
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildreplayCommentList() {
    return SingleChildScrollView(
      controller: replaycommentController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child: Consumer<DetailProvider>(
        builder: (context, detailsProvider, child) {
          if (detailsProvider.replaycommentloding &&
              !detailsProvider.replayCommentloadmore) {
            return Utils.pageLoader(context);
          } else {
            return Column(
              children: [
                replayCommentList(),
                if (detailsProvider.replayCommentloadmore)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Utils.pageLoader(context),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget replayCommentList() {
    if (detailsProvider.replayCommentModel.status == 200 &&
        detailsProvider.replaycommentList != null) {
      if ((detailsProvider.replaycommentList?.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: detailsProvider.replaycommentList?.length ?? 0,
                itemBuilder: (BuildContext ctx, index) {
                  return Container(
                    // color: gray,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 1, color: white),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              imagePath:
                                  detailsProvider
                                      .replaycommentList?[index]
                                      .image
                                      .toString() ??
                                  "",
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              detailsProvider
                                          .replaycommentList?[index]
                                          .fullName ==
                                      ""
                                  ? MyText(
                                    color: white,
                                    text:
                                        detailsProvider
                                            .replaycommentList?[index]
                                            .fullName
                                            .toString() ??
                                        "",
                                    fontsizeNormal: Dimens.textDesc,
                                    fontwaight: FontWeight.w600,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    inter: false,
                                    textalign: TextAlign.center,
                                    fontstyle: FontStyle.normal,
                                  )
                                  : MyText(
                                    color: white,
                                    text:
                                        detailsProvider
                                            .replaycommentList?[index]
                                            .channelName
                                            .toString() ??
                                        "",
                                    fontsizeNormal: Dimens.textMedium,
                                    fontwaight: FontWeight.w500,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    inter: false,
                                    textalign: TextAlign.center,
                                    fontstyle: FontStyle.normal,
                                  ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: MyText(
                                  color: white,
                                  text:
                                      detailsProvider
                                          .replaycommentList?[index]
                                          .comment
                                          .toString() ??
                                      "",
                                  fontsizeNormal: Dimens.textSmall,
                                  fontwaight: FontWeight.w400,
                                  multilanguage: false,
                                  maxline: 3,
                                  overflow: TextOverflow.ellipsis,
                                  inter: false,
                                  textalign: TextAlign.left,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (detailsProvider.replaycommentList?[index].userId
                                .toString() ==
                            Constant.userID)
                          if (detailsProvider.deletecommentLoading &&
                              detailsProvider.deleteItemIndex == index)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: colorAccent,
                                strokeWidth: 1,
                              ),
                            )
                          else
                            InkWell(
                              onTap: () async {
                                if (Constant.userID == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const Login();
                                      },
                                    ),
                                  );
                                } else {
                                  await detailsProvider.getDeleteComment(
                                    detailsProvider.replaycommentList?[index].id
                                            .toString() ??
                                        "",
                                    false,
                                    index,
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyImage(
                                  width: 16,
                                  height: 16,
                                  color: colorAccent,
                                  imagePath: "ic_delete.png",
                                ),
                              ),
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (detailsProvider.commentloading)
              const CircularProgressIndicator(color: colorAccent)
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const Expanded(child: NoData(title: "", subTitle: ""));
      }
    } else {
      return const Expanded(child: NoData(title: "", subTitle: ""));
    }
  }

  Future<bool> onBackPressed() async {
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    double? curPos = youtubecurrentTime;
    double? duration = youtubeTotalDuration;
    Duration curPosDuration = Duration(seconds: (curPos ?? 0).round());
    int? currentPosition = curPosDuration.inMilliseconds;
    Duration totalDuration = Duration(seconds: (duration ?? 0).round());
    int? totalvidoeDuration = totalDuration.inMilliseconds;
    printLog("cpos :===> $curPos");
    printLog("Duration :===> $duration");
    playerCPosition = double.parse(currentPosition.toString());
    videoDuration = double.parse(totalvidoeDuration.toString());
    printLog("onBackPressed playerCPosition :===> $playerCPosition");
    printLog("onBackPressed videoDuration :===> $videoDuration");

    if ((playerCPosition ?? 0) > 0 &&
        (playerCPosition == videoDuration ||
            (playerCPosition ?? 0) > (videoDuration ?? 0))) {
      playerProvider.removeContentHistory("1", widget.videoid, "0");
      if (!mounted) return Future.value(false);
      Navigator.pop(context, true);
      return Future.value(true);
    } else if ((playerCPosition ?? 0) > 0) {
      playerProvider.addContentHistory(
        "1",
        widget.videoid,
        "$playerCPosition",
        "0",
      );
      if (!mounted) return Future.value(false);
      Navigator.pop(context, true);
      return Future.value(true);
    } else {
      if (!mounted) return Future.value(false);
      Navigator.pop(context, false);
      return Future.value(true);
    }
  }

  Widget relatedVideo() {
    if (detailsProvider.loading && !detailsProvider.relatedVideoLoadMore) {
      return Utils.pageLoader(context);
    } else {
      if (detailsProvider.relatedVideoList != null) {
        if ((detailsProvider.relatedVideoList?.length ?? 0) > 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                color: white,
                text: "relatedvideos",
                fontwaight: FontWeight.w500,
                fontsizeNormal: Dimens.textMedium,
                maxline: 2,
                multilanguage: true,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(height: 15),
              relatedVideoItem(),
              if (detailsProvider.relatedVideoLoadMore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget relatedVideoItem() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 2,
        maxItemsPerRow: 2,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
        ),
        children: List.generate(detailsProvider.relatedVideoList?.length ?? 0, (
          index,
        ) {
          return InkWell(
            onTap: () async {
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Login();
                    },
                  ),
                );
              } else {
                Utils.moveToDetail(
                  context,
                  0,
                  false,
                  detailsProvider.relatedVideoList?[index].id.toString() ?? "",
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        imagePath:
                            detailsProvider
                                .relatedVideoList?[index]
                                .landscapeImg
                                .toString() ??
                            "",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: MyImage(
                          width: 25,
                          height: 25,
                          imagePath: "pause.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MyText(
                  color: white,
                  text:
                      detailsProvider.relatedVideoList?[index].title
                          .toString() ??
                      "",
                  fontwaight: FontWeight.w500,
                  fontsizeNormal: Dimens.textMedium,
                  maxline: 2,
                  multilanguage: false,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget shimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildImageShimmer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 190),
            child: Column(
              children: [
                buildDiscriptionShimmer(),
                channelItemShimmer(),
                commentShimmer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
