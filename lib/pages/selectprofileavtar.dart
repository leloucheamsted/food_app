import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/provider/updateprofileprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';

class SelectProfileAvatar extends StatefulWidget {
  const SelectProfileAvatar({super.key});

  @override
  State<SelectProfileAvatar> createState() => _SelectProfileAvatarState();
}

class _SelectProfileAvatarState extends State<SelectProfileAvatar> {
  late UpdateprofileProvider updateprofileProvider;
  late ProfileProvider profileProvider;
  final ImagePicker _picker = ImagePicker();
  late ScrollController _scrollController;

  @override
  void initState() {
    updateprofileProvider = Provider.of<UpdateprofileProvider>(
      context,
      listen: false,
    );
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchData(0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (updateprofileProvider.currentPage ?? 0) <
            (updateprofileProvider.totalPage ?? 0)) {
      await updateprofileProvider.setLoadMore(true);
      _fetchData(updateprofileProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await updateprofileProvider.getAvatarList((nextPage ?? 0) + 1);
    await updateprofileProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    updateprofileProvider.clearAvatarList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: transparent,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        leading: InkWell(
          focusColor: transparent,
          highlightColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () {
            Navigator.of(context).pop(false);
          },
          child: Align(
            alignment: Alignment.center,
            child: MyImage(
              width: 30,
              height: 30,
              imagePath: "ic_roundback.png",
            ),
          ),
        ),
        title: MyText(
          color: white,
          text: "selectavatar",
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textBig,
          multilanguage: true,
          inter: true,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
      body: Consumer<UpdateprofileProvider>(
        builder: (context, updateprofileprovider, child) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Column(
              children: [
                selectGalleryImage(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(children: [buildAvatar()]),
                  ),
                ),
                submitBtn(),
              ],
            ),
          );
        },
      ),
    );
  }

  /* Select Image Using Gallary */

  Widget selectGalleryImage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: DottedBorder(
          dashPattern: const [5, 5],
          radius: const Radius.circular(5),
          borderType: BorderType.RRect,
          color: colorAccent,
          child: InkWell(
            onTap: () async {
              if (!updateprofileProvider.avatarloading) {
                _pickImage();
              }
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: transparent,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: white, size: 25),
                  const SizedBox(width: 5),
                  MyText(
                    color: white,
                    text: "gallery",
                    textalign: TextAlign.center,
                    fontsizeNormal: Dimens.textMedium,
                    multilanguage: true,
                    inter: true,
                    maxline: 1,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        updateprofileProvider.saveProfileImage(
          imageType: 1,
          image: File(pickedFile.path),
        );
        updateAvatarApi();
      } else {
        debugPrint("No image selected.");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  /* Select Image Using Gallary */

  Widget buildAvatar() {
    if (updateprofileProvider.avatarLoading &&
        !updateprofileProvider.avatarLoadMore) {
      return avatarShimmer();
    } else {
      if (updateprofileProvider.avatarList != null &&
          (updateprofileProvider.avatarList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
          child: Column(
            children: [
              buildAvatarListItem(),
              if (updateprofileProvider.avatarLoadMore)
                SizedBox(height: 50, child: Utils.pageLoader(context))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget buildAvatarListItem() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      itemCount: updateprofileProvider.avatarList?.length ?? 0,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          focusColor: transparent,
          splashColor: transparent,
          highlightColor: transparent,
          hoverColor: transparent,
          onTap: () {
            if (!updateprofileProvider.avatarloading) {
              updateprofileProvider.saveProfileImage(
                imageType: 2,
                avatarImg:
                    updateprofileProvider.avatarList?[index].imageName
                        .toString() ??
                    "",
                avatarIndex: index,
              );
            }
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: MyNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: 220,
                  imagePath:
                      updateprofileProvider.avatarList?[index].image
                          .toString() ??
                      "",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                top: 15,
                left: 15,
                right: 15,
                child: Align(
                  alignment: Alignment.topRight,
                  child:
                      index == updateprofileProvider.selectedIndex
                          ? Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorAccent,
                              border: Border.all(width: 1.5, color: black),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: black,
                              size: 15,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget avatarShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        itemCount: 10,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return const CustomWidget.roundrectborder(height: 220, width: 100);
        },
      ),
    );
  }

  /* Avtar Submit Button */
  Widget submitBtn() {
    return InkWell(
      focusColor: transparent,
      highlightColor: transparent,
      hoverColor: transparent,
      splashColor: transparent,
      onTap: () async {
        if (!updateprofileProvider.avatarloading) {
          if (updateprofileProvider.avatarImage != "") {
            updateAvatarApi();
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 45,
        alignment: Alignment.center,
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        decoration: BoxDecoration(
          color: colorAccent,
          borderRadius: BorderRadius.circular(50),
        ),
        child:
            updateprofileProvider.avatarloading
                ? const CircularProgressIndicator(color: black, strokeWidth: 2)
                : MyText(
                  multilanguage: true,
                  color: black,
                  text: "submit",
                  fontsizeNormal: Dimens.textTitle,
                  fontsizeWeb: Dimens.textTitle,
                  fontwaight: FontWeight.w700,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
      ),
    );
  }

  updateAvatarApi() async {
    await updateprofileProvider.updateAvatar(Constant.userID ?? "");
    if (updateprofileProvider.updateprofileModel.status == 200) {
      if (!mounted) return;
      await profileProvider.getprofile(context, Constant.userID);

      updateDataInFirestore(
        firebaseId:
            profileProvider.profileModel.result?[0].firebaseId.toString() ?? "",
        imageUrl:
            profileProvider.profileModel.result?[0].image.toString() ?? "",
      );

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  updateDataInFirestore({
    required String firebaseId,
    required String imageUrl,
  }) {
    printLog('firebasedid ....==>> $firebaseId');
    // Update data to Firestore
    FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(firebaseId)
        .update({FirestoreConstants.profileurl: imageUrl})
        .then((value) => printLog("User Updated"))
        .onError((error, stackTrace) {
          printLog("updateDataFirestore error ===> ${error.toString()}");
          printLog(
            "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
          );
        });
  }
}
