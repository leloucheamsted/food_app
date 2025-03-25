import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:slike/model/avatarlistmodel.dart' as avatar;
import 'package:slike/model/getsociallinkmodel.dart';
import 'package:slike/model/imageuploadmodel.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';

class UpdateprofileProvider extends ChangeNotifier {
  SuccessModel updateprofileModel = SuccessModel();
  ImageUploadModel imageUploadModel = ImageUploadModel();
  bool loading = false;
  bool avatarloading = false;

  /* All TextField */
  List<String>? iconId = [];
  List<String>? oldIconId = [];
  List<String>? socialMediaId = [];
  List<String>? iconUrlControllers = [];
  List<TextEditingController>? urlControllers = [];
  List<Map<String, dynamic>>? socialLinkList = [];
  /* Bio Field ArrayList */
  List<String> bioIconUrlName = [];
  List<String> bioIcon1Name = [];
  List<String> oldIcon1Name = [];
  List<File> iconFile = [];
  List<Map<String, dynamic>>? field1 = [];
  bool isEdit = false;

  /* Social Link */
  GetSocialLinkModel getSocialLinkModel = GetSocialLinkModel();
  bool socialLinkLoading = false;

  /* Select And Pic Image */
  File? userImage;
  String? avatarImage;
  dynamic imageType;

  /* AvatarList */
  /* Pagination With Api Calling */
  int? selectedIndex;
  avatar.AvatatListModel avatatListModel = avatar.AvatatListModel();
  List<avatar.Result>? avatarList = [];
  bool avatarLoadMore = false, avatarLoading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  imageUpload(File image) async {
    loading = true;
    imageUploadModel = await ApiService().imageUpload(image);
    loading = false;
    notifyListeners();
  }

  getupdateprofile(
    String userid,
    String fullname,
    String channelName,
    String email,
  ) async {
    loading = true;
    updateprofileModel = await ApiService().updateprofile(
      userid,
      fullname,
      channelName,
      email,
      /* Multiple Social Link */
      socialLinkList ?? [],
      /* Bio */
      field1 ?? [],
      /* UserImage */
      imageType,
      userImage ?? File(""),
      avatarImage,
    );
    loading = false;
    notifyListeners();
  }

  updateAvatar(String userid) async {
    setAvatarLoading(true);
    updateprofileModel = await ApiService().updateAvatar(
      userid,
      /* UserImage */
      imageType,
      userImage ?? File(""),
      avatarImage,
    );
    setAvatarLoading(false);
    notifyListeners();
  }

  setAvatarLoading(loading) {
    avatarloading = loading;
    notifyListeners();
  }

  addTextField() {
    oldIconId?.add("");
    iconId?.add("");
    iconUrlControllers?.add("");
    socialMediaId?.add("");
    urlControllers?.add(TextEditingController());
    log("iconId==>${iconId?.length}");
    log("iconUrlControllers==>$iconUrlControllers");
    log("urlControllers==>$urlControllers");
    notifyListeners();
  }

  removeTextField(index) {
    oldIconId?.removeAt(index);
    iconId?.removeAt(index);
    iconUrlControllers?.removeAt(index);
    socialMediaId?.removeAt(index);
    urlControllers?.removeAt(index);
    log("iconId==>${iconId?.length}");
    log("iconUrlControllers==>$iconUrlControllers");
    log("urlControllers==>$urlControllers");
    notifyListeners();
  }

  addMultipleAttechment(
    String id,
    String iconUrl,
    String socialMediaid,
    int index,
  ) {
    printLog("id==> $id");
    printLog("iconUrl==> $iconUrl");
    printLog("socialMediaid==> $socialMediaid");
    printLog("index==> $index");
    iconId?[index] = id;
    iconUrlControllers?[index] = iconUrl;
    socialMediaId?[index] = socialMediaid;
    log("iconUrlControllers==>$iconUrlControllers");
    log("iconId==>$iconId");
    notifyListeners();
  }

  addFieldBio(
    bool edit,
    File fileIcon,
    String iconUrl,
    String icon,
    String oldImage,
  ) {
    bioIconUrlName.add(iconUrl);
    bioIcon1Name.add(icon);
    oldIcon1Name.add(oldImage);
    iconFile.add(fileIcon);
    isEdit = edit;
    notifyListeners();
    log("ImageUrl==>$bioIconUrlName");
    log("ImageName==>$bioIcon1Name}");
    log("oldImage==>$oldIcon1Name");
    log("iconFile==>$iconFile");
  }

  addUpdateIconIds(String id, int index) {
    iconId?[index] = id;
    notifyListeners();
    log("iconId==>$iconId");
  }

  oldIcon(String id, int index) {
    oldIconId?[index] = id;
    notifyListeners();
  }

  /* Social Link */

  getSocialLink() async {
    socialLinkLoading = true;
    getSocialLinkModel = await ApiService().socialLink();
    socialLinkLoading = false;
    notifyListeners();
  }

  clearProvider() {
    updateprofileModel = SuccessModel();
    imageUploadModel = ImageUploadModel();
    loading = false;
    socialLinkList = [];
    socialLinkList?.clear();
    /* All TextField */
    iconUrlControllers = [];
    iconUrlControllers?.clear();
    urlControllers = [];
    urlControllers?.clear();
    iconId = [];
    iconId?.clear();
    /* Bio */
    bioIconUrlName = [];
    bioIcon1Name = [];
    oldIcon1Name = [];
    iconFile = [];
    field1 = [];
    isEdit = false;
    /* Social Link */
    getSocialLinkModel = GetSocialLinkModel();
  }

  clearArray() {
    iconUrlControllers = [];
    iconUrlControllers?.clear();
    urlControllers = [];
    urlControllers?.clear();
    socialLinkList = [];
    socialLinkList?.clear();
    iconId = [];
    iconId?.clear();
    /* Bio */
    bioIconUrlName = [];
    bioIcon1Name = [];
    oldIcon1Name = [];
    iconFile = [];
    field1 = [];
    isEdit = false;
  }

  /* Avatar List */

  /* Select Cover Image */

  saveProfileImage({
    required int imageType,
    File? image,
    String? avatarImg,
    avatarIndex,
  }) async {
    /* Image Type 1 ==> GallaryImage */
    /* Image Type 2 ==> AvatarImage */
    if (imageType == 1) {
      userImage = image;
    } else {
      selectedIndex = avatarIndex;
      avatarImage = avatarImg;
    }
    this.imageType = imageType;
    notifyListeners();
    printLog("profileImage==> $userImage");
    printLog("imageType==> $imageType");
  }

  /* Select Cover Image */

  /* AvatarList */

  Future<void> getAvatarList(pageNo) async {
    avatarLoading = true;
    avatatListModel = await ApiService().avatarImage(pageNo);
    if (avatatListModel.status == 200) {
      setPaginationData(
        avatatListModel.totalRows,
        avatatListModel.totalPage,
        avatatListModel.currentPage,
        avatatListModel.morePage,
      );
      if (avatatListModel.result != null &&
          (avatatListModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(avatatListModel.result?.length ?? 0)}",
        );
        if (avatatListModel.result != null &&
            (avatatListModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(avatatListModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (avatatListModel.result?.length ?? 0); i++) {
            avatarList?.add(avatatListModel.result?[i] ?? avatar.Result());
          }
          final Map<int, avatar.Result> postMap = {};
          avatarList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          avatarList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(avatarList?.length ?? 0)}",
          );
          setLoadMore(false);
        }
      }
    }
    avatarLoading = false;
    notifyListeners();
  }

  setPaginationData(
    int? totalRows,
    int? totalPage,
    int? currentPage,
    bool? morePage,
  ) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setLoadMore(avatarLoadMore) {
    this.avatarLoadMore = avatarLoadMore;
    notifyListeners();
  }

  clearAvatarList() {
    /* Pagination With Api Calling */
    avatatListModel = avatar.AvatatListModel();
    avatarList = [];
    selectedIndex;
    avatarList?.clear();
    avatarLoadMore = false;
    avatarLoading = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
