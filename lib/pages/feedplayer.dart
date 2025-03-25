import 'dart:async';
import 'package:slike/pages/videoplaypause.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeedPlayer extends StatefulWidget {
  final int pagePos, index;
  final String videoUrl, videoId, thumbnailImg;
  const FeedPlayer({
    super.key,
    required this.pagePos,
    required this.index,
    required this.videoUrl,
    required this.videoId,
    required this.thumbnailImg,
  });

  @override
  State<FeedPlayer> createState() => FeedPlayerState();
}

class FeedPlayerState extends State<FeedPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? videoController;
  bool? showPrevious;
  bool? showNext;
  bool showForwardIcon = false;
  bool showBackwardIcon = false;
  late AnimationController _animationController;
  late Animation<double> fadeAnimation;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    initController();
    printLog("current videoUrl =======> ${widget.videoUrl}");
    printLog("current pagePos ===> ${widget.pagePos}");

    // Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> initController() async {
    videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      )
      ..initialize().then((_) {
        setState(() {});
        if (isVisible) {
          videoController!.play();
          videoController!.setLooping(true);
        }

        // Listen for video completion to replay the video
        videoController!.addListener(() {
          if (videoController!.value.position ==
              videoController!.value.duration) {
            resetVideo();
          }
        });
      });
  }

  void playVideo() {
    if (videoController != null && isVisible) {
      videoController!.play();
    }
  }

  void pauseVideo() {
    if (videoController != null) {
      videoController!.pause();
    }
  }

  void resetVideo() {
    if (videoController != null) {
      videoController!.seekTo(Duration.zero); // Reset video to the beginning
      playVideo();
    }
  }

  void clearController() {
    videoController?.pause();
    videoController?.dispose();
    videoController = null;
  }

  @override
  void dispose() {
    clearController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reel_${widget.pagePos}'),
      onVisibilityChanged: (visibilityInfo) async {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        setState(() {
          isVisible = visiblePercentage > 80;
        });

        if (isVisible) {
          playVideo();
        } else {
          pauseVideo();
        }
      },
      child: _buildFuture(),
    );
  }

  Widget _buildFuture() {
    return _buildPlayer();
  }

  Widget _buildPlayer() {
    if (videoController == null) {
      return _buildImage();
    } else {
      return GestureDetector(
        onDoubleTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final tapPosition = details.globalPosition.dx;
          if (tapPosition < screenWidth / 2) {
            // Double tap on the left side
            _seekVideo(forward: false);
          } else {
            // Double tap on the right side
            _seekVideo(forward: true);
          }
        },
        onTapDown: (_) {
          pauseVideo();
        },
        onTapUp: (_) {
          playVideo();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController?.value.size.width,
                  height: videoController?.value.size.height,
                  child: AspectRatio(
                    aspectRatio: videoController?.value.aspectRatio ?? 16 / 9,
                    child: VideoPlayer(videoController!),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: VideoPlayPause(controller: videoController!),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (showBackwardIcon)
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: const Icon(Icons.replay_5, size: 50, color: white),
                  )
                else
                  const SizedBox.shrink(),
                if (showForwardIcon)
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: const Icon(Icons.forward_5, size: 50, color: white),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          MyNetworkImage(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            imagePath: widget.thumbnailImg,
            fit: BoxFit.cover,
          ),

          /* Play Button */
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 60,
              width: 60,
              decoration: Utils.setGradTTBBGWithBorder(
                colorPrimaryDark.withOpacity(0.45),
                colorPrimary.withOpacity(0.45),
                transparent,
                40,
                0,
              ),
              child: InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: MyImage(
                    imagePath: "ic_play.png",
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _seekVideo({required bool forward}) {
    final currentPosition =
        videoController?.value.position ?? const Duration(milliseconds: 0);
    const seekDuration = Duration(seconds: 5);

    if (forward) {
      setState(() {
        showForwardIcon = true;
      });

      _animationController.forward(from: 0.0);

      videoController?.seekTo(currentPosition + seekDuration);

      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showForwardIcon = false;
          });
        }
      });
    } else {
      setState(() {
        showBackwardIcon = true;
      });

      _animationController.forward(from: 0.0);

      final newPosition =
          currentPosition - seekDuration >= Duration.zero
              ? currentPosition - seekDuration
              : Duration.zero;
      videoController?.seekTo(newPosition);

      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showBackwardIcon = false;
          });
        }
      });
    }
  }
}
