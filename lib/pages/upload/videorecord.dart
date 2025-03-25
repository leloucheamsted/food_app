import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:camera_filters/videoPlayer.dart';
import 'package:countdown_progress_indicator/countdown_progress_indicator.dart';
import 'package:flutter/services.dart';
import 'package:slike/pages/upload/custom/custom_thumbnail.dart';
import 'package:slike/pages/upload/previewreels.dart';
import 'package:slike/pages/upload/uploadvideo.dart';
import 'package:slike/provider/videorecordprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/log.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../camera_filter/camera_filters.dart';

class VideoRecord extends StatefulWidget {
  final String? contestId, contestImg, hashtagName, hashtagId;

  const VideoRecord({
    super.key,
    required this.contestId,
    required this.contestImg,
    required this.hashtagName,
    required this.hashtagId,
  });

  @override
  State<VideoRecord> createState() => _VideoRecordState();
}

class _VideoRecordState extends State<VideoRecord> {
  late ProgressDialog prDialog;
  final audioPlayer = AudioPlayer();
  late VideoRecordProvider videoRecordProvider;
  final ImagePicker picker = ImagePicker();
  File? finalVfile;
  List<CameraDescription>? cameras = [];
  FlashMode flashMode = FlashMode.off;
  CountDownController? _countDownController;
  bool loading = false;
  CameraController? _cameraController;
  double progress = 0;
  int timerProgress = Constant.recordDuration;
  List<String>? selectedAudioDetails;
  ValueNotifier<bool> isVideoMode = ValueNotifier(
    true,
  ); // Default is Video mode

  void switchCameraMode() {
    isVideoMode.value = !isVideoMode.value; // Toggle the mode
  }

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    videoRecordProvider = Provider.of<VideoRecordProvider>(
      context,
      listen: false,
    );
    _countDownController = CountDownController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initCamera(null);
    });
    audioPlayer.onPlayerStateChanged.listen(
      (s) async {
        if (s == PlayerState.playing) {
          printLog("PLAYING s :===> ${s.name}");
        } else if (s == PlayerState.stopped) {
          printLog("STOPPED s :===> ${s.name}");
        } else if (s == PlayerState.completed) {
          printLog("COMPLETED s :=> ${s.name}");
        }
      },
      onError: (msg) {
        printLog("onError msg :=> $msg");
      },
    );

    // audioPlayer.onDurationChanged
    //     .listen((d) => Constant.recordDuration = d.inSeconds);

    super.initState();
  }

  _initCamera(cameraDescription) async {
    try {
      cameras = await availableCameras();

      printLog("cameras ==============> ${cameras?.length}");
      if ((cameras?.length ?? 0) == 0) {
        if (!mounted) return;
        Utils.showSnackbar(context, "no_camera_msg", true);
        return;
      } else {
        cameraDescription ??= cameras?.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
      }

      _cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        fps: 30,
        enableAudio: true,
      );
      await _cameraController?.initialize();
      _cameraController?.setFocusMode(FocusMode.auto);
      _cameraController?.setExposureMode(ExposureMode.auto);
      _cameraController?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await _cameraController?.prepareForVideoRecording();
      Future.delayed(const Duration(milliseconds: 100)).then((onValue) {
        _cameraController?.setFlashMode(videoRecordProvider.flashMode);
      });
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {
          videoRecordProvider.setLoading(false);
        });
      });
    } on CameraException catch (e) {
      printLog(
        "CameraException  code :=> ${e.code} , description :=> ${e.description}",
      );
    }
  }

  @override
  void dispose() {
    printLog("============== dispose ==============");
    _cameraController?.dispose();

    super.dispose();
  }

  void _toggleCameraLens() async {
    // get current lens direction (front / rear)
    final lensDirection = _cameraController?.description.lensDirection;
    CameraDescription? newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras?.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.back,
      );
    } else {
      newDescription = cameras?.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.front,
      );
    }

    printLog('CAMERA direction =>>>>>> ${newDescription?.lensDirection.name}');
    if (newDescription?.lensDirection.name != "") {
      _cameraController?.setDescription(newDescription!);
      await _cameraController?.prepareForVideoRecording();
      if (!mounted) return;
      setState(() {});
      _initCamera(newDescription);
    } else {
      printLog('Asked camera not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoRecordProvider.isLoading) {
      return Utils.pageLoader(context);
    } else {
      return Scaffold(
        backgroundColor: colorPrimary,
        body: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // _cameraController != null && _cameraController!.value.isInitialized
              //     ? SizedBox(
              //         height: MediaQuery.of(context).size.height,
              //         width: MediaQuery.of(context).size.width,
              //         child: AspectRatio(
              //           aspectRatio: _cameraController?.value.aspectRatio ?? 16 / 9,
              //           child: CameraPreview(_cameraController!),
              //         ),
              //       )
              //     : SizedBox(
              //         height: MediaQuery.of(context).size.height,
              //         width: MediaQuery.of(context).size.width,
              //       ),
              _cameraController != null &&
                      _cameraController!.value.isInitialized
                  ? CameraScreenPlugin(
                    cameraController: _cameraController!,
                    galleryWidget: ValueListenableBuilder(
                      valueListenable: isVideoMode,
                      builder: (context, value, Widget? c) {
                        return value != null
                            ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Consumer<VideoRecordProvider>(
                                builder: (context, videoRecordProvider, child) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      /* Gallery */
                                      // (!videoRecordProvider.isRecording)
                                      // ?
                                      InkWell(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                        onTap: () {
                                          openGallery();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: MyImage(
                                            width: 27,
                                            height: 27,
                                            imagePath: "ic_gallery.png",
                                            color: white,
                                          ),
                                        ),
                                      ),
                                      // : Container(
                                      //     padding: const EdgeInsets.all(8),
                                      //     width: 27,
                                      //     height: 27,
                                      //   ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        width: 27,
                                        height: 27,
                                      ),

                                      /* Record ON/OFF */
                                      InkWell(
                                        onTap: () => _startStopRecording(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child:
                                          //  !videoRecordProvider.isRecording
                                          //     ?
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: colorAccent,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                width: 3,
                                                color:
                                                    videoRecordProvider
                                                            .isRecording
                                                        ? colorAccent
                                                        : transparent,
                                              ),
                                            ),
                                            child: CountDownProgressIndicator(
                                              autostart: false,
                                              strokeWidth: 4,
                                              controller: _countDownController,
                                              valueColor: colorPrimary,
                                              backgroundColor: transparent,
                                              duration: Constant.recordDuration,
                                              timeFormatter: (seconds) {
                                                printLog(
                                                  "seconds ==> $seconds",
                                                );
                                                timerProgress = seconds;
                                                return seconds.toString();
                                              },
                                              timeTextStyle: GoogleFonts.cairo(
                                                textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: transparent,
                                                ),
                                              ),
                                              onComplete: () {
                                                _recordingDone();
                                              },
                                            ),
                                          ),
                                          //     : SizedBox(
                                          //         height: 80,
                                          //         width: 80,
                                          //         child: CountDownProgressIndicator(
                                          //           autostart: false,
                                          //           strokeWidth: 4,
                                          //           controller: _countDownController,
                                          //           valueColor: colorPrimary,
                                          //           backgroundColor: transparent,
                                          //           duration: Constant.recordDuration,
                                          //           timeFormatter: (seconds) {
                                          //             printLog("seconds ==> $seconds");
                                          //             timerProgress = seconds;
                                          //             return seconds.toString();
                                          //           },
                                          //           timeTextStyle: GoogleFonts.cairo(
                                          //             textStyle: const TextStyle(
                                          //               fontWeight: FontWeight.w500,
                                          //               fontSize: 15,
                                          //               color: transparent,
                                          //             ),
                                          //           ),
                                          //           onComplete: () {
                                          //             _recordingDone();
                                          //           },
                                          //         ),
                                          //       ),

                                          //     MyImage(
                                          //   width: 80,
                                          //   height: 80,
                                          //   imagePath: !videoRecordProvider.isRecording
                                          //       ? "ic_recoding_no.png"
                                          //       : "ic_recoding_yes.png",
                                          // ),
                                        ),
                                      ),

                                      /* Exit Recording */
                                      (videoRecordProvider.isRecordDone)
                                          ? InkWell(
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                            onTap: () async {
                                              await showAlert(
                                                context,
                                                "remove_last_record_text",
                                                "cancel_",
                                                "delete",
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: MyImage(
                                                width: 27,
                                                height: 27,
                                                imagePath: "ic_exit.png",
                                                color: white,
                                              ),
                                            ),
                                          )
                                          : Container(
                                            padding: const EdgeInsets.all(8),
                                            width: 27,
                                            height: 27,
                                          ),

                                      /* Done */
                                      InkWell(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                        onTap: () async {
                                          printLog(
                                            "Clicked on Done! timeProgress ===> $timerProgress",
                                          );
                                          if ((_cameraController
                                                      ?.value
                                                      .isRecordingVideo ??
                                                  false) &&
                                              timerProgress <
                                                  (Constant.maxRecordDuration -
                                                      Constant
                                                          .minRecordDuration)) {
                                            _countDownController?.pause();
                                            final XFile? file =
                                                await _cameraController
                                                    ?.stopVideoRecording();
                                            finalVfile = File(file?.path ?? "");
                                            printLog(
                                              "finalVfile path ===> $finalVfile",
                                            );
                                            mergeAudioVideo(finalVfile);
                                          } else if (finalVfile != null) {
                                            printLog(
                                              "finalVfile path ===> $finalVfile",
                                            );
                                            mergeAudioVideo(finalVfile);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: MyImage(
                                            width: 27,
                                            height: 27,
                                            imagePath:
                                                (videoRecordProvider
                                                            .isRecording &&
                                                        timerProgress <
                                                            (Constant
                                                                    .maxRecordDuration -
                                                                Constant
                                                                    .minRecordDuration))
                                                    ? "ic_done.png"
                                                    : "ic_not_done.png",
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                            : const SizedBox.shrink();
                      },
                    ),
                    cameraOptions: Column(
                      children: [
                        /* Toggle Camera */
                        InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                          onTap: _toggleCameraLens,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: MyImage(
                              width: 27,
                              height: 27,
                              imagePath: "camera_toggle.png",
                              color: white,
                            ),
                          ),
                        ),
                        /* Flash ON/OFF */
                        InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                          onTap: () {
                            printLog(
                              "Clicked on Flash! flashMode ===> ${videoRecordProvider.flashMode}",
                            );
                            if (_cameraController != null) {
                              videoRecordProvider.toggleFlash(
                                _cameraController!,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Consumer<VideoRecordProvider>(
                              builder: (context, videoRecordProvider, child) {
                                return MyImage(
                                  width: 27,
                                  height: 27,
                                  imagePath:
                                      videoRecordProvider.flashMode ==
                                              FlashMode.off
                                          ? "flash_on.png"
                                          : "flash_off.png",
                                  color: white,
                                );
                              },
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            /* Toggle Camera Mode (Photo/Video) */
                            InkWell(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              onTap: () {
                                switchCameraMode(); // Toggle between Camera and Video mode
                                printLog(
                                  "Switched mode to: ${isVideoMode.value ? "Camera" : "Video"}",
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ValueListenableBuilder(
                                  valueListenable: isVideoMode,
                                  builder: (context, value, Widget? c) {
                                    return MyImage(
                                      width: 27,
                                      height: 27,
                                      imagePath:
                                          value != null
                                              ? "shutter-camera.png" // Icon for Video mode
                                              : "cam-recorder.png", // Icon for Camera mode
                                      color: white,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onDone: (value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UploadVideo(
                                videoFile: File(value),
                                fileType: "image",
                                videoImageFile: File(value),
                              ),
                        ),
                      );
                    },
                    videoTimeLimit: 10,
                    cameraChange: isVideoMode,
                    sendButtonWidget: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  )
                  : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
            ],
          ),
        ),
      );
    }
  }

  _startStopRecording() async {
    printLog("timerProgress ===> $timerProgress");
    printLog(
      "isRecordingVideo ===> ${_cameraController?.value.isRecordingVideo}",
    );
    printLog(
      "isRecordingPaused ===> ${_cameraController?.value.isRecordingPaused}",
    );
    if (!(_cameraController?.value.isRecordingVideo ?? false)) {
      if (selectedAudioDetails != null &&
          (selectedAudioDetails?.length ?? 0) > 0) {
        audioPlayer.setSourceDeviceFile(selectedAudioDetails?[0] ?? "");
        play();
      }
      _countDownController?.resume();
      await videoRecordProvider.setRecording(true);
      await _cameraController?.startVideoRecording();
    } else if ((_cameraController?.value.isRecordingVideo ?? false) &&
        !(_cameraController?.value.isRecordingPaused ?? false)) {
      if (selectedAudioDetails != null &&
          (selectedAudioDetails?.length ?? 0) > 0) {
        pause();
      }
      _countDownController?.pause();
      await videoRecordProvider.setRecording(false);
      await _cameraController?.pauseVideoRecording();
    } else if (_cameraController?.value.isRecordingPaused ?? false) {
      if (selectedAudioDetails != null &&
          (selectedAudioDetails?.length ?? 0) > 0) {
        play();
      }
      _countDownController?.resume();
      await videoRecordProvider.setRecording(true);
      await _cameraController?.resumeVideoRecording();
    }
  }

  Future<bool> onBackPress() async {
    await showAlert(context, "video_record_exit_note", "cancel_", "okay");
    return Future.value(false);
  }

  _recordingDone() async {
    try {
      if ((_cameraController?.value.isRecordingVideo ?? false) &&
          timerProgress == 0) {
        _countDownController?.pause();
        final XFile? file = await _cameraController?.stopVideoRecording();
        printLog("file path ===> $file");
        finalVfile = File(file?.path ?? "");
        printLog("_recordVideo finalVfile ===> ${finalVfile?.path ?? ""}");
        await videoRecordProvider.setRecording(false);
        await videoRecordProvider.setRecordingDone(true);
      }
    } catch (e) {
      printLog("cameraException ==> $e");
    }
  }

  Future openGallery() async {
    final XFile? pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
    );
    printLog("openGallery _videoFile ===> $pickedFile");

    int maxFileSize = 50 * 1024 * 1024; // 20 MB

    if (pickedFile != null) {
      String? videoImage = await CustomThumbnail.onGet(pickedFile.path);
      printLog("finalVfile ===> ${finalVfile?.path ?? ""}");
      int? fileLength = await pickedFile.length();
      printLog("fileLength =========> $fileLength");
      if ((fileLength) <= 0) {
        if (!mounted) return;
        Utils.showSnackbar(context, "no_file_fetch", true);
        return;
      }
      if ((fileLength) > maxFileSize) {
        if (!mounted) return;
        Utils.showSnackbar(context, "max_file_length_msg", true);
        return;
      }
      finalVfile = File(pickedFile.path);
      printLog("Gallery finalVfile ==> ${finalVfile?.path}");
      pause();

      if (!mounted) return;
      goToPreview(finalVfile);
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return PreviewReels(
      //         filePath: finalVfile?.path ?? "",
      //         fileType: "video",
      //         videoImageFile: videoImage ?? "",
      //       );
      //     },
      //   ),
      // );
      _countDownController?.pause();
      if (_cameraController?.value.isRecordingVideo ?? false) {
        await _cameraController?.pauseVideoRecording();
      }
    }
  }

  void mergeAudioVideo(File? finalVideo) async {
    printLog("mergeAudioVideo finalVideo =========> $finalVideo");
    if (videoRecordProvider.selectedAudioPath.toString().isNotEmpty &&
        (p.extension(videoRecordProvider.selectedAudioPath ?? "") == ".mp3" ||
            p.extension(videoRecordProvider.selectedAudioPath ?? "") ==
                ".aac")) {
      Utils.showProgress(context);
      await mixAudioVideo(
        videoPath: finalVideo?.path ?? "",
        audioPath: videoRecordProvider.selectedAudioPath ?? "",
      );
    } else {
      goToPreview(finalVideo);
    }
  }

  Future mixAudioVideo({
    required String videoPath,
    required String audioPath,
  }) async {
    String? output = "";
    Directory? documentDirectory;
    if (Platform.isAndroid) {
      documentDirectory = await getExternalStorageDirectory();
    } else {
      documentDirectory = await getApplicationDocumentsDirectory();
    }
    File mergeFile = File(
      p.join(
        documentDirectory?.path ?? "",
        '${DateTime.now().millisecondsSinceEpoch.toString()}.mp4',
      ),
    );
    output = mergeFile.path;
    printLog("mixAudioVideo output ===> $output");
    printLog("mixAudioVideo videoPath ===> $videoPath");
    printLog("mixAudioVideo audioPath ===> $audioPath");

    await FFmpegKit.executeAsync(
      "-y -i $videoPath -i $audioPath -map 0:v -map 1:a -c:v copy -shortest $output",
      (session) async {
        printLog(
          "=============================== EXECUTED ===============================",
        );
        final returnCode = await session.getReturnCode();
        printLog("mergingExecuted returnCode ===> $returnCode");
        if (ReturnCode.isSuccess(returnCode)) {
          // SUCCESS
          // Console output generated for this execution
          try {
            printLog("mergeFile =========> ${mergeFile.path}");
          } catch (e) {
            printLog("mergingExecuted Exception ===> $e");
          } finally {
            await prDialog.hide();
            session.cancel;
            goToPreview(mergeFile);
          }
        } else if (ReturnCode.isCancel(returnCode)) {
          // CANCEL
          await prDialog.hide();
          printLog("mergingExecuted CANCEL ===> ${session.getLogsAsString()}");
        } else {
          // ERROR
          await prDialog.hide();
          printLog("Error");
          final failStackTrace = await session.getFailStackTrace();
          printLog("failStackTrace ===> $failStackTrace");
          List<Log> logs = await session.getLogs();
          for (var element in logs) {
            printLog("Message ===> ${element.getMessage()}");
          }
          printLog(
            "Command failed with state ${await session.getState()} and rc ${await session.getReturnCode()}.${await session.getFailStackTrace()}  ${await session.getAllLogsAsString()}",
          );
        }
      },
      (logs) {
        printLog("logs ====> ${logs.getMessage()}");
      },
    );
  }

  void goToPreview(File? videoFile) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VideoPlayer(
              sendButtonWidget: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: colorAccent,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
              videoFile?.path,
              applyFilters: true,
              onVideoDone: (path) {
                Navigator.pop(context);
                videoFile = File(path);
              },
            ),
      ),
    );

    printLog("videoFile ===> ${videoFile?.path ?? ""}");
    String soundId = videoRecordProvider.selectedAudioId ?? "0";
    printLog("soundId =====> $soundId");
    String? videoImage = await CustomThumbnail.onGet(videoFile?.path ?? "");
    final route = MaterialPageRoute(
      maintainState: false,
      fullscreenDialog: true,
      builder:
          (_) => PreviewReels(
            filePath: videoFile?.path ?? "",
            videoImageFile: videoImage ?? "",
            fileType: 'video',
          ),
    );
    pause();
    videoRecordProvider.clearProvider();
    Navigator.push(context, route);
    _countDownController?.pause();
    if (_cameraController?.value.isRecordingVideo ?? false) {
      await _cameraController?.pauseVideoRecording();
    }
  }

  Future play() async {
    await audioPlayer.resume();
  }

  Future pause() async {
    await audioPlayer.pause();
  }

  Future release() async {
    await audioPlayer.release();
  }

  Future<void> showAlert(
    BuildContext context,
    String msg,
    String negative,
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
                backgroundColor: lightgray, // foreground
              ),
              child: MyText(
                multilanguage: true,
                color: black,
                text: negative,
                fontsizeNormal: 15,
                fontwaight: FontWeight.normal,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
              onPressed: () async {
                _countDownController?.pause();
                await videoRecordProvider.clearProvider();
                await release();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
