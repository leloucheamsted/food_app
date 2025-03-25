// ignore_for_file: must_be_immutable

library camera_filters;

import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:camera_filters/src/edit_image_screen.dart';
import 'package:camera_filters/src/filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreenPlugin extends StatefulWidget {
  /// this function will return the path of edited picture
  Function(dynamic)? onDone;

  /// this function will return the path of edited video
  Function(dynamic)? onVideoDone;

  /// list of filters
  List<Color>? filters;

  int? videoTimeLimit;

  bool applyFilters;
  ValueNotifier<bool> cameraChange;

  /// notify color to change
  ValueNotifier<Color>? filterColor;

  ///circular gradient color
  List<Color>? gradientColors;

  /// profile widget if you want to use profile widget on camera
  Widget? profileIconWidget;

  /// profile widget if you want to use profile widget on camera
  Widget? sendButtonWidget;
  Widget galleryWidget;
  Widget cameraOptions;
  CameraController cameraController;

  CameraScreenPlugin(
      {super.key,
      this.onDone,
      this.onVideoDone,
      this.filters,
      this.videoTimeLimit,
      this.profileIconWidget,
      this.applyFilters = true,
      required this.cameraChange,
      this.gradientColors,
      this.sendButtonWidget,
      required this.galleryWidget,
      required this.cameraOptions,
      required this.cameraController,
      this.filterColor});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreenPlugin> with TickerProviderStateMixin, WidgetsBindingObserver {
  ///animation controller for circular progress indicator
  late AnimationController controller;

  /// Camera Controller
  CameraController? _controller;

  /// initializer of controller
  Future<void>? _initializeControllerFuture;

  /// local storage for mobile
  GetStorage sp = GetStorage();

  /// flash mode changer
  ValueNotifier<int> flashCount = ValueNotifier(0);

  /// flash mode changer
  ValueNotifier<String> time = ValueNotifier("");

  /// condition check that picture is taken or not
  bool capture = false;

  ///Timer initialize
  Timer? t;

  /// camera list, this list will tell user that he/she is on front camera or back
  List<CameraDescription> cameras = [];

  /// bool to change picture to video or video to picture

  AnimationController? _rotationController;
  double _rotation = 0;
  double _scale = 0.85;

  bool get _showWaves => !controller.isDismissed;

  void _updateRotation() {
    _rotation = (_rotationController!.value * 2) * pi;
    print("_rotation is $_rotation");
  }

  void _updateScale() {
    _scale = (controller.value * 0.2) + 0.85;
    print("scale is $_scale");
  }

  ///list of filters color
  final _filters = [
    Colors.transparent,
    ...List.generate(
      Colors.primaries.length,
      (index) => Colors.primaries[(index) % Colors.primaries.length],
    )
  ];

  ///filter color notifier
  final _filterColor = ValueNotifier<Color>(Colors.transparent);

  ///filter color change function
  void _onFilterChanged(Color value) {
    widget.filterColor == null ? _filterColor.value = value : widget.filterColor!.value = value;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3500),
    )..addListener(() async {
        setState(_updateScale);
      });
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..addListener(() {
        setState(_updateRotation);
        if (_rotation > 5) {
          _rotationController!.reset();
          _rotationController!.forward();
        }
      });

    super.initState();
    if (sp.read("flashCount") != null) {
      flashCount.value = sp.read("flashCount");
    }
    if (widget.filterColor != null) {
      widget.filterColor = ValueNotifier<Color>(Colors.transparent);
    }
    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller != null
          ? _initializeControllerFuture = _controller!.initialize()
          : null; //on pause camera is disposed, so we need to call again "issue is only for android"
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller!.dispose();
    super.dispose();
  }

  showInSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
  }

  bool longPressEnd = false;

  ///timer function
  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  ///this function will initialize camera
  initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    /// this condition check that camera is available on your device
    cameras = await availableCameras();

    ///put camera in camera controller
    _controller = widget.cameraController;
    _initializeControllerFuture = _controller!.initialize().then((_) async {
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      _controller!.setFlashMode(FlashMode.off);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: _controller != null && _controller!.value.isInitialized && _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        /// If the Future is complete, display the preview.
                        return ValueListenableBuilder(
                            valueListenable: widget.cameraChange,
                            builder: (context, value, Widget? c) {
                              return widget.cameraChange.value == false
                                  ? ValueListenableBuilder(
                                      valueListenable: widget.filterColor ?? _filterColor,
                                      builder: (context, value, child) {
                                        return ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                              widget.filterColor == null
                                                  ? _filterColor.value
                                                  : widget.filterColor!.value,
                                              BlendMode.softLight),
                                          child: CameraPreview(_controller!),
                                        );
                                      })
                                  : CameraPreview(_controller!);
                            });
                      } else {
                        /// Otherwise, display a loading indicator.
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: ValueListenableBuilder(
                      valueListenable: widget.cameraChange,
                      builder: (context, value, Widget? c) {
                        return widget.cameraChange.value == false ? _buildFilterSelector() : const SizedBox.shrink();
                      }),
                ),
                Positioned(
                  right: 10.0,
                  top: 30.0,
                  child: widget.profileIconWidget ?? Container(),
                ),
                Positioned(
                  bottom: 25,
                  child: widget.galleryWidget,
                ),
                Positioned(
                  top: 40,
                  right: 15,
                  child: widget.cameraOptions,
                ),
              ],
            ),
    );
  }

  flashCheck() {
    if (sp.read("flashCount") == 1) {
      _controller!.setFlashMode(FlashMode.off);
    }
  }

  /// function will call when user tap on picture button
  void onTakePictureButtonPressed(context) {
    takePicture(context).then((String? filePath) async {
      if (_controller!.value.isInitialized) {
        if (filePath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditImageScreen(
                      path: filePath,
                      applyFilters: widget.applyFilters,
                      sendButtonWidget: widget.sendButtonWidget,
                      filter: ColorFilter.mode(
                          widget.filterColor == null ? _filterColor.value : widget.filterColor!.value,
                          BlendMode.softLight),
                      onDone: widget.onDone,
                    )),
          ).then((value) {
            // _controller = CameraController(cameras[0], ResolutionPreset.high);
            if (sp.read("flashCount") == 1) {
              _controller!.setFlashMode(FlashMode.torch);
            }
          });
          flashCheck();
        }
      }
    });
  }

  /// compress the picture from bigger size to smaller
  // Future<String> compressFile(File file, {takePicture = false}) async {
  //   final File compressedFile = await FlutterNativeImage.compressImage(
  //     file.path,
  //     quality: 70,
  //   );
  //   final List<int> imageBytes = await file.readAsBytes();
  //
  //   imglib.Image? originalImage = imglib.decodeImage(imageBytes);
  //
  //   if (_controller!.description.lensDirection == CameraLensDirection.front) {
  //     originalImage = imglib.flipHorizontal(originalImage!);
  //   }
  //
  //   final File files = File(compressedFile.path);
  //
  //   final File fixedFile = await files.writeAsBytes(
  //     imglib.encodePng(originalImage!),
  //     flush: true,
  //   );
  //   return fixedFile.path;
  // }

  /// function will call when user take picture
  Future<String> takePicture(context) async {
    if (!_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: camera is not initialized')));
    }
    final dirPath = await getTemporaryDirectory();
    String filePath = '${dirPath.path}/${timestamp()}.jpg';

    try {
      final picture = await _controller!.takePicture();
      filePath = picture.path;
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.description}')));
    }
    return filePath;
  }

  /// timestamp for image creation date
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// widget will build the filter selector
  Widget _buildFilterSelector() {
    return FilterSelector(
      onFilterChanged: _onFilterChanged,
      filters: widget.applyFilters == false ? [] : widget.filters ?? _filters,
      onTap: () {
        if (capture == false) {
          capture = true;
          onTakePictureButtonPressed(context);
          Future.delayed(const Duration(seconds: 3), () {
            capture = false;
          });
        }
      },
    );
  }
}
