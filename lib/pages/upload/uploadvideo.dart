import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/provider/postvideoprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/string.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';

class UploadVideo extends StatefulWidget {
  final String? fileType;
  final File? videoFile, videoImageFile;
  const UploadVideo({
    this.videoFile,
    required this.videoImageFile,
    required this.fileType,
    super.key,
  });

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  late UploadProvider uploadProvider;
  final ImagePicker imagePicker = ImagePicker();
  SharedPre sharePref = SharedPre();

  File? finalVideoFile, pickedCoverFile, pickedWaterMarkFile;
  String? imageFromVideo, userProfile;

  final captionController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    uploadProvider = Provider.of<UploadProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    finalVideoFile = widget.videoFile;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
      _fetchDataCategory(0);
    });
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (uploadProvider.categorycurrentPage ?? 0) <
            (uploadProvider.categorytotalPage ?? 0)) {
      _fetchDataCategory(uploadProvider.categorycurrentPage);
    }
  }

  Future<void> _fetchDataCategory(int? nextPage) async {
    printLog("isMorePage  ======> ${uploadProvider.categoryisMorePage}");
    printLog("currentPage ======> ${uploadProvider.categorycurrentPage}");
    printLog("totalPage   ======> ${uploadProvider.categorytotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await uploadProvider.getVideoCategory((nextPage ?? 0) + 1);
    await uploadProvider.selectCategory(
      0,
      uploadProvider.categorydataList?[0].id.toString() ?? "",
      uploadProvider.categorydataList?[0].name.toString() ?? "",
    );
  }

  _getData() async {
    userProfile = await sharePref.read("coverimage");
    printLog("_getData userProfile ======> $userProfile");
    printLog("_getData videoFile ========> ${finalVideoFile?.path}");
    printLog("_getData videoImageFile ===> ${widget.videoImageFile?.path}");
    pickedCoverFile = widget.videoImageFile;
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    uploadProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: black.withOpacity(0.7),
        title: MyText(
          multilanguage: true,
          color: white,
          text: "uploads",
          fontsizeNormal: 18,
          fontsizeWeb: 18,
          fontwaight: FontWeight.w600,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.center,
          fontstyle: FontStyle.normal,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: white,
          onPressed: () async {
            if (Navigator.canPop(context)) {
              if (!mounted) return;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
        ),
      ),
      body: Consumer<UploadProvider>(
        builder: (context, postvideoprovider, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    postvideoprovider.tabType == "short"
                        ? _buildCovers()
                        : buildSelectedContent(),
                    const SizedBox(height: 15),
                    tabButton(),
                    const SizedBox(height: 15),
                    picWaterMark(),
                    const SizedBox(height: 15),
                    selectCategory(),
                    const SizedBox(height: 20),
                    /* Profile Image & Video description */
                    _buildUserVideoDesc(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              /* Post Video Button */
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  height: 45,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: colorAccent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      if (postvideoprovider.tabType == "short") {
                        uploadShorts();
                      } else {
                        convertToJsonFeed();
                        uploadApi();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.center,
                      child: MyText(
                        multilanguage: true,
                        color: black,
                        text: "upload",
                        fontsizeNormal: 15,
                        fontsizeWeb: 15,
                        fontwaight: FontWeight.w700,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /* Select Tab */

  Widget tabButton() {
    return Consumer<UploadProvider>(
      builder: (context, postvideoprovider, child) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: colorPrimary.withOpacity(0.18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                color: white,
                text: "chooseuploadtype",
                multilanguage: true,
                fontsizeNormal: Dimens.textTitle,
                fontwaight: FontWeight.w600,
                maxline: 3,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.left,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        focusColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        splashColor: transparent,
                        onTap: () async {
                          await postvideoprovider.selectTab("short");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color:
                                postvideoprovider.tabType == "short"
                                    ? colorAccent
                                    : transparent,
                          ),
                          child: MyText(
                            color:
                                postvideoprovider.tabType == "short"
                                    ? black
                                    : white,
                            text: "shorts",
                            multilanguage: true,
                            fontsizeNormal: Dimens.textSmall,
                            fontwaight: FontWeight.w600,
                            maxline: 3,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.left,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        focusColor: transparent,
                        highlightColor: transparent,
                        hoverColor: transparent,
                        splashColor: transparent,
                        onTap: () async {
                          await postvideoprovider.selectTab("feed");
                          postvideoprovider.clearFeedArray();
                          contentUploadApi(finalVideoFile ?? File(""), "2");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color:
                                postvideoprovider.tabType == "feed"
                                    ? colorAccent
                                    : transparent,
                          ),
                          child: MyText(
                            color:
                                postvideoprovider.tabType == "feed"
                                    ? black
                                    : white,
                            text: "feeds",
                            multilanguage: true,
                            fontsizeNormal: Dimens.textSmall,
                            fontwaight: FontWeight.w600,
                            maxline: 3,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.left,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserVideoDesc() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(minHeight: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: Utils.setGradTTBBorderWithBG(
              colorPrimaryDark,
              colorPrimary,
              transparent,
              30,
              1,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: MyNetworkImage(
                width: 45,
                height: 45,
                imagePath: userProfile ?? "",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 130,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                decoration: Utils.setBGWithBorder(
                  transparent,
                  gray.withOpacity(0.7),
                  10,
                  0.5,
                ),
                child: TextFormField(
                  controller: captionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: Locales.string(
                      context,
                      "enteryourtextwithhashtag",
                    ),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      color: white,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: white,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* Cover Image */

  Widget _buildCovers() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: MyText(
            multilanguage: true,
            color: white,
            text: "selectcover",
            fontsizeNormal: Dimens.textTitle,
            fontsizeWeb: Dimens.textTitle,
            fontwaight: FontWeight.w600,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          constraints: BoxConstraints(
            maxHeight: 180,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(15),
            color: colorPrimary.withOpacity(0.7),
            strokeWidth: 0.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (widget.fileType == "video") {
                    imagePickDialog("coverImage");
                  }
                },
                child: Container(
                  decoration: Utils.setBGWithBorder(
                    colorPrimaryDark,
                    transparent,
                    15,
                    0,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child:
                      pickedCoverFile != null
                          ? Image.file(pickedCoverFile!, fit: BoxFit.cover)
                          : Container(
                            margin: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyImage(
                                  imagePath: "ic_no_img.png",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                MyText(
                                  color: white,
                                  text: "browse_file",
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 12,
                                  fontwaight: FontWeight.w400,
                                  fontsizeWeb: 12,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget picWaterMark() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
            multilanguage: true,
            color: white,
            text: "addwatermark",
            fontsizeNormal: Dimens.textTitle,
            fontsizeWeb: Dimens.textTitle,
            fontwaight: FontWeight.w600,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: DottedBorder(
                dashPattern: const [3, 3],
                radius: const Radius.circular(5),
                color: colorAccent,
                child: InkWell(
                  onTap: () async {
                    imagePickDialog("watermarkImage");
                  },
                  child: SizedBox(
                    width: 120,
                    height: 150,
                    child:
                        pickedWaterMarkFile != null
                            ? Image.file(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              pickedWaterMarkFile!,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: transparent,
                              child: const Icon(
                                Icons.add,
                                color: white,
                                size: 35,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ============================================== Select Feed ============================================== */

  Widget buildSelectedContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (uploadProvider.selectedContent != null &&
                  (uploadProvider.selectedContent?.length ?? 0) > 0)
              ? SizedBox(
                height: 180,
                child: ListView.separated(
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 10),
                  itemCount: uploadProvider.selectedContent?.length ?? 0,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  itemBuilder: (context, index) {
                    printLog(
                      "image==>${uploadProvider.selectedContent?[index] ?? ""}",
                    );
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                            imagePath:
                                uploadProvider.selectedContent?[index] ?? "",
                            width: 150,
                            height: MediaQuery.of(context).size.height,
                            fit: BoxFit.cover,
                          ),
                        ),
                        uploadProvider.selectContentType?[index].toString() ==
                                "1"
                            ? const SizedBox.shrink()
                            : Positioned.fill(
                              top: 5,
                              left: 5,
                              right: 5,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () async {
                                    await uploadProvider.addRemoveContent(
                                      index: index,
                                      isAdd: false,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorPrimaryDark,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    );
                  },
                ),
              )
              : const SizedBox.shrink(),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: DottedBorder(
              dashPattern: const [3, 3],
              radius: const Radius.circular(5),
              color: colorAccent,
              child: InkWell(
                onTap: () async {
                  showCustomBottomSheet(context);
                },
                child: Container(
                  height: 180,
                  width: 150,
                  color: transparent,
                  child: const Icon(Icons.add, color: white, size: 35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorPrimaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                    color: white,
                    multilanguage: true,
                    text: "selectimage",
                    textalign: TextAlign.left,
                    fontsizeNormal: Dimens.textBig,
                    inter: false,
                    maxline: 1,
                    fontwaight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library, color: white),
                    title: MyText(
                      color: white,
                      multilanguage: true,
                      text: "gallery",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _pickImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera, color: white),
                    title: MyText(
                      color: white,
                      multilanguage: true,
                      text: "takeaphoto",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _pickImageFromCamera();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.video_call_outlined,
                      color: white,
                    ),
                    title: MyText(
                      color: white,
                      multilanguage: true,
                      text: "picvideofromgallary",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _pickVideoFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.video_call_outlined,
                      color: white,
                    ),
                    title: MyText(
                      color: white,
                      multilanguage: true,
                      text: "takeavideo",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textTitle,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _pickVideoFromCamera();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _pickImageFromGallery() async {
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      contentUploadApi(File(pickedImage.path), "1");
    }
  }

  _pickImageFromCamera() async {
    final XFile? capturedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (capturedImage != null) {
      contentUploadApi(File(capturedImage.path), "1");
    }
  }

  _pickVideoFromGallery() async {
    final XFile? pickedVideo = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedVideo != null) {
      contentUploadApi(File(pickedVideo.path), "2");
    }
  }

  _pickVideoFromCamera() async {
    final XFile? capturedVideo = await imagePicker.pickVideo(
      source: ImageSource.camera,
    );

    if (capturedVideo != null) {
      contentUploadApi(File(capturedVideo.path), "2");
    }
  }

  contentUploadApi(File content, contentType) async {
    /* contentType 1 ===> image */
    /* contentType 2 ===> video */
    if (!mounted) return;
    Utils.showProgress(context);
    await uploadProvider.postContentUpload(contentType, content);
    if (!mounted) return;
    Utils().hideProgress(context);
    if (!uploadProvider.loading) {
      if (uploadProvider.postContentUploadModel.status == 200) {
        await uploadProvider.addRemoveContent(
          content:
              uploadProvider.postContentUploadModel.result?.contentType == "1"
                  ? uploadProvider.postContentUploadModel.result?.contentUrl
                          .toString() ??
                      ""
                  : uploadProvider
                          .postContentUploadModel
                          .result
                          ?.thumbnailImageUrl
                          .toString() ??
                      "",
          contentType:
              uploadProvider.postContentUploadModel.result?.contentType
                  .toString() ??
              "",
          contentName:
              uploadProvider.postContentUploadModel.result?.contentName
                  .toString() ??
              "",
          thambnailImage:
              uploadProvider.postContentUploadModel.result?.thumbnailImage
                  .toString() ??
              "",
          index: 0,
          isAdd: true,
        );
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          uploadProvider.postContentUploadModel.message.toString(),
          false,
        );
      }
    }
  }

  /* ============================================== Select Feed ============================================== */

  Future<void> imagePickDialog(picType) async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /* Gallery */
                  _buildDialogItem(
                    title: "gallery",
                    isMultiLang: true,
                    fontWeight: FontWeight.w400,
                    itemDecoration: Utils.setBGWithRadius(
                      colorPrimaryDark,
                      10,
                      10,
                      0,
                      0,
                    ),
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                      getFromGallery(picType);
                    },
                  ),
                  const SizedBox(height: 1),
                  /* Camera */
                  _buildDialogItem(
                    title: "camera",
                    isMultiLang: true,
                    fontWeight: FontWeight.w400,
                    itemDecoration: Utils.setBGWithRadius(
                      colorPrimaryDark,
                      0,
                      0,
                      10,
                      10,
                    ),
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                      getFromCamera(picType);
                    },
                  ),
                  const SizedBox(height: 10),
                  /* Cancel */
                  _buildDialogItem(
                    title: "cancel",
                    isMultiLang: true,
                    fontWeight: FontWeight.w600,
                    itemDecoration: Utils.setBGWithRadius(
                      colorPrimaryDark,
                      10,
                      10,
                      10,
                      10,
                    ),
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        if (!mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      printLog("============= LOGOUT =============");
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget _buildDialogItem({
    required String title,
    required bool isMultiLang,
    required FontWeight fontWeight,
    required Decoration itemDecoration,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: 50,
        decoration: itemDecoration,
        alignment: Alignment.center,
        child: MyText(
          multilanguage: isMultiLang,
          text: title,
          color: colorAccent,
          fontsizeNormal: 16,
          fontsizeWeb: 16,
          maxline: 1,
          fontstyle: FontStyle.normal,
          fontwaight: fontWeight,
          textalign: TextAlign.center,
        ),
      ),
    );
  }

  /* Pic Watermark & CoverImage (Gallary) */
  getFromGallery(picType) async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      setState(() {
        if (picType == "coverImage") {
          pickedCoverFile = File(pickedFile.path);
          printLog("Gallery pickedCoverFile ==> ${pickedCoverFile?.path}");
        } else {
          pickedWaterMarkFile = File(pickedFile.path);
          printLog(
            "Gallery pickedWaterMarkFile ==> ${pickedWaterMarkFile?.path}",
          );
        }
      });
    }
  }

  /* Pic Watermark & CoverImage (Camera) */
  getFromCamera(picType) async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      setState(() {
        if (picType == "coverImage") {
          pickedCoverFile = File(pickedFile.path);
          printLog("Camera pickedCoverFile ==> ${pickedCoverFile?.path}");
        } else {
          pickedWaterMarkFile = File(pickedFile.path);
          printLog(
            "Gallery pickedWaterMarkFile ==> ${pickedWaterMarkFile?.path}",
          );
        }
      });
    }
  }

  /* Select Category */

  Widget selectCategory({String? name, amount}) {
    return Consumer<UploadProvider>(
      builder: (context, postvideoprovider, child) {
        if (postvideoprovider.categoryloading &&
            !postvideoprovider.categoryloadMore) {
          return Utils.pageLoader(context);
        } else {
          if (postvideoprovider.categorymodel.status == 200 &&
              postvideoprovider.categorydataList != null) {
            if ((postvideoprovider.categorydataList?.length ?? 0) > 0) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: ExpandableNotifier(
                  controller: ExpandableController(
                    initialExpanded: uploadProvider.isExpanded,
                  ),
                  child: Card(
                    color: colorPrimaryDark,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    elevation: 0,
                    child: Column(
                      children: <Widget>[
                        ScrollOnExpand(
                          scrollOnExpand: true,
                          scrollOnCollapse: false,
                          child: ExpandablePanel(
                            theme: const ExpandableThemeData(
                              headerAlignment:
                                  ExpandablePanelHeaderAlignment.center,
                              hasIcon: true,
                              tapBodyToCollapse: false,
                              iconColor: white,
                            ),
                            header: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  15,
                                  15,
                                  15,
                                  15,
                                ),
                                child: MyText(
                                  text:
                                      uploadProvider.categoryName == null
                                          ? "selectcategory"
                                          : uploadProvider.categoryName ?? "",
                                  multilanguage:
                                      uploadProvider.categoryName == null
                                          ? true
                                          : false,
                                  fontsizeNormal: Dimens.textBig,
                                  fontstyle: FontStyle.normal,
                                  fontwaight: FontWeight.w600,
                                  textalign: TextAlign.left,
                                  color: white,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            collapsed: buildCategory(),
                            expanded: const SizedBox.shrink(),
                            builder: (_, collapsed, expanded) {
                              return Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const NoData();
            }
          } else {
            return const NoData();
          }
        }
      },
    );
  }

  Widget buildCategory() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        controller: _scrollController,
        child: Column(
          children: [
            buildCategoryItem(),
            if (uploadProvider.categoryloadMore)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: colorAccent,
                  strokeWidth: 1,
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryItem() {
    return ListView.separated(
      itemCount: uploadProvider.categorydataList?.length ?? 0,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          autofocus: false,
          splashColor: transparent,
          highlightColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          onTap: () async {
            await uploadProvider.manageExpandableController();
            await uploadProvider.selectCategory(
              index,
              uploadProvider.categorydataList?[index].id.toString() ?? "",
              uploadProvider.categorydataList?[index].name.toString() ?? "",
            );
          },
          child: Container(
            height: 35,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            decoration: BoxDecoration(
              color:
                  uploadProvider.catindex == index ? colorAccent : transparent,
            ),
            child: MyText(
              color: uploadProvider.catindex == index ? black : white,
              text: uploadProvider.categorydataList?[index].name ?? "",
              fontwaight: FontWeight.w500,
              fontsizeNormal: Dimens.textMedium,
              maxline: 1,
              multilanguage: false,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
        );
      },
    );
  }

  /* Select Category */

  /* Short Upload Api */

  uploadShorts() async {
    String videoDesc = captionController.text.toString().trim();
    printLog("videoDesc ==> $videoDesc");
    if (videoDesc.isEmpty) {
      Utils.showSnackbar(context, "addacaptionyourshort", true);
      return;
    }
    if (uploadProvider.categoryId == "") {
      Utils.showSnackbar(context, "selectcategory", true);
      return;
    }
    if (pickedCoverFile == null) {
      Utils.showSnackbar(context, "pick_cover_img", true);
      return;
    }
    if (pickedWaterMarkFile == null) {
      Utils.showSnackbar(context, "pleaseselectwatermark", true);
      return;
    }

    printLog("videoFile ==> ${finalVideoFile?.path}");
    printLog("final pickedCoverFile ===> ${pickedCoverFile?.path ?? ""}");
    Utils.showProgress(context);
    await uploadProvider.uploadNewVideo(
      uploadProvider.categoryId,
      videoDesc,
      pickedWaterMarkFile,
      finalVideoFile,
      pickedCoverFile,
    );
    if (!mounted) return;
    Utils().hideProgress(context);
    if (!mounted) return;
    if (uploadProvider.successModel.status == 200) {
      Utils.showSnackbar(context, videoUploadedSuccessMsg, false);
    } else {
      Utils.showSnackbar(context, videoUploadedFailMsg, false);
    }
    uploadProvider.clearProvider();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const Bottombar()),
      (Route<dynamic> route) => false,
    ).then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const Bottombar()),
      );
    });
  }

  /* Feed Upload Api  */

  convertToJsonFeed() async {
    uploadProvider.combinedList = [];
    uploadProvider.combinedList?.clear();
    for (int i = 0; i < (uploadProvider.selectContentType?.length ?? 0); i++) {
      uploadProvider.combinedList?.add({
        'content_type': uploadProvider.selectContentType?[i],
        'content_url': uploadProvider.selectContentName?[i],
        'thumbnail_image': uploadProvider.selectThambnailImage?[i],
      });
    }

    debugPrint("combineList==> ${uploadProvider.combinedList}");
  }

  uploadApi() async {
    if ((uploadProvider.selectedContent?.length ?? 0) == 0) {
      Utils.showSnackbar(context, "pleaseselectcontent", true);
    } else if (captionController.text.isEmpty) {
      Utils.showSnackbar(context, "addacaptionyourpost", true);
    } else if (uploadProvider.categoryId == "") {
      Utils.showSnackbar(context, "selectcategory", true);
    } else if (pickedWaterMarkFile == null) {
      Utils.showSnackbar(context, "pleaseselectwatermark", true);
    } else {
      Utils.showProgress(context);
      await uploadProvider.uploadPost(
        uploadProvider.categoryId,
        captionController.text,
        uploadProvider.combinedList,
        pickedWaterMarkFile,
      );
      if (!mounted) return;
      Utils().hideProgress(context);
      if (!mounted) return;
      if (uploadProvider.successModel.status == 200) {
        Utils.showSnackbar(
          context,
          uploadProvider.successModel.message ?? "",
          false,
        );
      } else {
        Utils.showSnackbar(
          context,
          uploadProvider.successModel.message ?? "",
          false,
        );
      }
      uploadProvider.clearProvider();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const Bottombar()),
        (Route<dynamic> route) => false,
      ).then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const Bottombar(),
          ),
        );
      });
    }
  }
}
