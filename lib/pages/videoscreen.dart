import 'package:flutter/material.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoScreen extends StatefulWidget {
  final int index, pagePos;
  final String videoUrl, thumbnailImg, videoId;

  const VideoScreen({
    super.key,
    required this.index,
    required this.videoId,
    required this.pagePos,
    required this.videoUrl,
    required this.thumbnailImg,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? videoController;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    initController();
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

  @override
  void dispose() {
    videoController?.pause();
    videoController?.dispose();
    videoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_screen_${widget.index}'),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        isVisible = visiblePercentage > 80;
        if (isVisible) {
          playVideo();
        } else {
          pauseVideo();
        }
      },
      child:
          videoController != null && videoController!.value.isInitialized
              ? GestureDetector(
                onTap: () {
                  if (videoController != null &&
                      !(videoController!.value.isPlaying)) {
                    playVideo();
                  } else {
                    pauseVideo();
                  }
                },
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: videoController?.value.size.width,
                          height: videoController?.value.size.height,
                          child: AspectRatio(
                            aspectRatio:
                                videoController?.value.aspectRatio ?? 16 / 9,
                            child: VideoPlayer(videoController!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : _buildImage(),
    );
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
}
