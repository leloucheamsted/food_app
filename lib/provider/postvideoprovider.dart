import 'dart:developer';
import 'dart:io';
import 'package:slike/model/postcontentuploadmodel.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/model/categorymodel.dart' as category;

class UploadProvider extends ChangeNotifier {
  /* Upload Api Field */
  SuccessModel successModel = SuccessModel();
  bool loading = false,
      ifood_app = true,
      isSaveGallery = false,
      uploadLoading = false;
  String? coverTick = "tick1",
      thumbnail1 = "",
      thumbnail2 = "",
      thumbnail3 = "",
      finalThumb = "";
  File? watermarkedFile, videoThumb;

  /* Select tab */
  String tabType = "short";

  /* Category Api Field */
  category.CategoryModel categorymodel = category.CategoryModel();
  List<category.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;
  int catindex = 0;
  String? categoryId, categoryName;
  bool isExpanded = true;

  /* Feed Upload Fields */
  List<String>? selectedContent = [];
  List<String>? selectContentType = [];
  List<String>? selectContentName = [];
  List<String>? selectThambnailImage = [];
  List<Map<String, dynamic>>? combinedList = [];

  /* Post Content Upload Api */
  PostContentUploadModel postContentUploadModel = PostContentUploadModel();

  Future<void> uploadNewVideo(
    categoryId,
    title,
    watermarkFile,
    video,
    portraitImage,
  ) async {
    finalThumb = portraitImage?.path ?? "";
    printLog("Title:=========> $title");
    printLog("Video :===> $video");
    printLog("Image:=======> $portraitImage");
    setSendingComment(true);
    successModel = await ApiService().uploadVideo(
      categoryId,
      title,
      watermarkFile,
      video,
      portraitImage,
    );
    log("uploadNewVideo status :==> ${successModel.status}");
    log("uploadNewVideo message :==> ${successModel.message}");
    setSendingComment(false);
    notifyListeners();
  }

  setSendingComment(isSending) {
    printLog("isSending ==> $isSending");
    uploadLoading = isSending;
    notifyListeners();
  }

  getThumbnailCovers(File? watermarkFile) async {
    loading = true;
    printLog('getThumbnailCovers watermarkFile ===> $watermarkFile');
    thumbnail1 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 10,
    );
    printLog('getThumbnailCovers thumbnail1 ===> $thumbnail1');

    thumbnail2 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 50,
    );
    printLog('getThumbnailCovers thumbnail2 ===> $thumbnail2');

    thumbnail3 = await VideoThumbnail.thumbnailFile(
      video: watermarkFile?.path ?? "",
      thumbnailPath: (await getApplicationDocumentsDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 100,
    );
    printLog('getThumbnailCovers thumbnail3 ===> $thumbnail3');
    loading = false;
    notifyListeners();
  }

  void saveInGallery(String videoPath) async {
    await GallerySaver.saveVideo(videoPath).then((success) {
      printLog("saveInGallery success ===> $success");
    });
  }

  setCoverTick(String tick) {
    coverTick = tick;
    printLog("coverTick ===> $coverTick");
    notifyListeners();
  }

  toggleifood_app(bool value) async {
    if (ifood_app == true) {
      ifood_app = false;
    } else {
      ifood_app = true;
    }
    notifyListeners();
  }

  void toggleGallery(bool value) async {
    if (isSaveGallery == false) {
      isSaveGallery = true;
    } else {
      isSaveGallery = false;
    }
    printLog('toggleSwitch isSaveGallery ==> $isSaveGallery');
    notifyListeners();
  }

  /* ============================== Caterory Start ============================== */

  selectCategory(int index, catid, catName) {
    catindex = index;
    categoryId = catid;
    categoryName = catName;
    notifyListeners();
  }

  manageExpandableController() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  Future<void> getVideoCategory(pageNo) async {
    categoryloading = true;
    categorymodel = await ApiService().videoCategory(pageNo);
    if (categorymodel.status == 200) {
      setCategoryPaginationData(
        categorymodel.totalRows,
        categorymodel.totalPage,
        categorymodel.currentPage,
        categorymodel.morePage,
      );
      if (categorymodel.result != null &&
          (categorymodel.result?.length ?? 0) > 0) {
        printLog(
          "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}",
        );
        if (categorymodel.result != null &&
            (categorymodel.result?.length ?? 0) > 0) {
          printLog(
            "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (categorymodel.result?.length ?? 0); i++) {
            categorydataList?.add(
              categorymodel.result?[i] ?? category.Result(),
            );
          }
          final Map<int, category.Result> postMap = {};
          categorydataList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          categorydataList = postMap.values.toList();
          printLog(
            "CategoryModel length :==> ${(categorydataList?.length ?? 0)}",
          );
          setCategoryLoadMore(false);
        }
      }
    }
    categoryloading = false;
    notifyListeners();
  }

  setCategoryPaginationData(
    int? categorytotalRows,
    int? categorytotalPage,
    int? categorycurrentPage,
    bool? videolistisMorePage,
  ) {
    this.categorycurrentPage = categorycurrentPage;
    this.categorytotalRows = categorytotalRows;
    this.categorytotalPage = categorytotalPage;
    categoryisMorePage = categoryisMorePage;
    notifyListeners();
  }

  setCategoryLoadMore(categoryloadMore) {
    this.categoryloadMore = categoryloadMore;
    notifyListeners();
  }

  /* ============================== Category End ============================== */

  /* ============================== Select Tab ============================== */

  selectTab(type) async {
    tabType = type;
    notifyListeners();
  }

  /* ============================== Select Tab ============================== */

  /* Feed Upload */

  uploadPost(categoryId, title, dynamic postContent, watermarkFile) async {
    loading = true;
    successModel = await ApiService().uploadFeedPost(
      categoryId,
      title,
      postContent,
      watermarkFile,
    );
    loading = false;
    notifyListeners();
  }

  /* Post Content Upload  */
  postContentUpload(String contentType, File content) async {
    loading = true;
    postContentUploadModel = await ApiService().postContentUpload(
      contentType,
      content,
    );
    loading = false;
    notifyListeners();
  }

  /* Save And Remove Multiple Image */
  addRemoveContent({
    String? content,
    String? contentType,
    String? contentName,
    String? thambnailImage,
    required int index,
    required bool isAdd,
  }) {
    if (isAdd == true) {
      selectedContent?.add(content ?? "");
      selectContentType?.add(contentType ?? "");
      selectContentName?.add(contentName ?? "");
      selectThambnailImage?.add(thambnailImage ?? "");
    } else {
      selectedContent?.removeAt(index);
      selectContentType?.removeAt(index);
      selectContentName?.removeAt(index);
      selectThambnailImage?.removeAt(index);
    }
    notifyListeners();
    printLog("selectedContent==>$selectedContent");
    printLog("selectContentType==>$selectContentType");
    printLog("selectContentName==>$selectContentName");
    printLog("ThambnailImage==>$selectThambnailImage");
  }

  clearProvider() {
    /* Upload Api Field */
    successModel = SuccessModel();
    loading = false;
    isSaveGallery = false;
    coverTick = "tick1";
    thumbnail1 = "";
    thumbnail2 = "";
    thumbnail3 = "";
    finalThumb = "";
    watermarkedFile;
    videoThumb;
    /* Category Api Field */
    categorymodel = category.CategoryModel();
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;
    catindex = 0;
    categoryId;
    isExpanded = true;
    /* Select Tab */
    tabType = "short";
    /* Feed Field */
    selectedContent = [];
    selectContentType = [];
    selectContentName = [];
    selectThambnailImage = [];
    combinedList = [];

    /* Post Content Upload Api */
    postContentUploadModel = PostContentUploadModel();
  }

  clearFeedArray() {
    /* Feed Field */
    selectedContent = [];
    selectContentType = [];
    selectContentName = [];
    selectThambnailImage = [];
    combinedList = [];
  }
}
