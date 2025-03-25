import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/selectprofileavtar.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:slike/provider/updateprofileprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  final String channelid;
  const UpdateProfile({super.key, required this.channelid});

  @override
  State<UpdateProfile> createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  final ImagePicker picker = ImagePicker();
  SharedPre sharedPre = SharedPre();
  late UpdateprofileProvider updateprofileProvider;
  late ProfileProvider profileProvider;
  String userid = "", name = "", countrycode = "", countryname = "";
  String gendarvalue = 'Male';
  XFile? _image;
  bool iseditimg = false;
  bool iseditcoverImg = false;
  final nameController = TextEditingController();
  final channelNameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  String mobilenumber = "";

  /* Bio controller */
  final bio1Controller = TextEditingController();

  XFile? field1;

  @override
  void initState() {
    updateprofileProvider = Provider.of<UpdateprofileProvider>(
      context,
      listen: false,
    );
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    getApi();
  }

  getApi() async {
    await profileProvider.getprofile(context, Constant.userID);
    if (!mounted) return;
    nameController.text =
        profileProvider.profileModel.result?[0].fullName.toString() ?? "";
    emailController.text =
        profileProvider.profileModel.result?[0].email.toString() ?? "";
    numberController.text =
        profileProvider.profileModel.result?[0].mobileNumber.toString() ?? "";
    channelNameController.text =
        profileProvider.profileModel.result?[0].channelName.toString() ?? "";

    if (profileProvider.profileModel.result?[0].field1 != null) {
      bio1Controller.text =
          profileProvider.profileModel.result?[0].field1?[0].text.toString() ??
          "";
    }

    /* ================================= Multiple Profile ======================================= */

    for (
      var i = 0;
      i < (profileProvider.profileModel.result?[0].socialLink?.length ?? 0);
      i++
    ) {
      // /* Add Controller in ArrayList */
      await updateprofileProvider.addTextField();
      /* Set Data in ArrayList */
      /* Id Set in List */
      log("============>Add Ids==========>");
      // await updateprofileProvider.addUpdateIconIds(
      //     profileProvider.profileModel.result?[0].socialLink?[i].id
      //             .toString() ??
      //         "",
      //     i);
      // /* Image Set in List */
      await updateprofileProvider.addMultipleAttechment(
        profileProvider.profileModel.result?[0].socialLink?[i].id.toString() ??
            "",
        profileProvider.profileModel.result?[0].socialLink?[i].image
                .toString() ??
            "",
        profileProvider.profileModel.result?[0].socialLink?[i].socialMediaId
                .toString() ??
            "",
        i,
      );

      await updateprofileProvider.oldIcon(
        profileProvider.profileModel.result?[0].socialLink?[i].id.toString() ??
            "",
        i,
      );

      updateprofileProvider.urlControllers?[i].text =
          profileProvider.profileModel.result?[0].socialLink?[i].url
              .toString() ??
          "";
    }
    printLog(
      "Total Lengh=========>${profileProvider.profileModel.result?[0].socialLink?.length}",
    );

    /* ================================= Multiple Profile ======================================= */
  }

  getSocialMedia() async {
    await updateprofileProvider.getSocialLink();
  }

  @override
  void dispose() {
    updateprofileProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Consumer2<ProfileProvider, UpdateprofileProvider>(
        builder: (context, profileprovider, updateprofileprovider, child) {
          if (profileprovider.profileloading) {
            return Utils.pageLoader(context);
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.32,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorPrimary,
                              colorPrimary.withOpacity(0.1),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          color: white,
                        ),
                        child:
                            _image == null
                                ? MyNetworkImage(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  imagePath:
                                      profileProvider
                                          .profileModel
                                          .result?[0]
                                          .image
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                )
                                : Image.file(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  File(_image?.path ?? ""),
                                  fit: BoxFit.cover,
                                ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        child: MyImage(
                                          width: 25,
                                          height: 25,
                                          imagePath: "ic_roundback.png",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    MyText(
                                      color: white,
                                      text: "editprofile",
                                      multilanguage: true,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 16,
                                      maxline: 6,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const SelectProfileAvatar();
                                      },
                                    ),
                                  );
                                },
                                child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "ic_camera.png",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Positioned.fill(
                      //   child: Align(
                      //     alignment: Alignment.bottomCenter,
                      //     child: Container(
                      //       width: 100,
                      //       height: 100,
                      //       decoration: BoxDecoration(
                      //         border: Border.all(color: white, width: 1),
                      //         borderRadius: BorderRadius.circular(60),
                      //       ),
                      //       child: Stack(
                      //         children: [
                      //           ClipRRect(
                      //             borderRadius: BorderRadius.circular(60),
                      //             child: _image == null
                      //                 ? ClipRRect(
                      //                     borderRadius: BorderRadius.circular(100),
                      //                     child: MyNetworkImage(
                      //                       imagePath: profileProvider
                      //                               .profileModel.result?[0].image
                      //                               .toString() ??
                      //                           "",
                      //                       fit: BoxFit.cover,
                      //                     ),
                      //                   )
                      //                 : ClipRRect(
                      //                     borderRadius: BorderRadius.circular(100),
                      //                     child: Image.file(
                      //                       height: 151,
                      //                       width: 151,
                      //                       File(_image?.path ?? ""),
                      //                       fit: BoxFit.cover,
                      //                     ),
                      //                   ),
                      //           ),
                      //           Positioned.fill(
                      //             child: Align(
                      //               alignment: Alignment.center,
                      //               child: InkWell(
                      //                 onTap: () async {
                      //                   try {
                      //                     var image = await picker.pickImage(
                      //                         source: ImageSource.gallery,
                      //                         imageQuality: 100);
                      //                     setState(() {
                      //                       _image = image;
                      //                       iseditimg = true;
                      //                     });
                      //                   } catch (e) {
                      //                     printLog("Error ==>${e.toString()}");
                      //                   }
                      //                 },
                      //                 child: MyImage(
                      //                     width: 30,
                      //                     height: 30,
                      //                     imagePath: "ic_camera.png"),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      children: [
                        myTextField(
                          nameController,
                          TextInputAction.next,
                          TextInputType.text,
                          "full_name",
                          false,
                        ),
                        const SizedBox(height: 10),
                        myTextField(
                          channelNameController,
                          TextInputAction.next,
                          TextInputType.text,
                          "channel_name",
                          false,
                        ),
                        const SizedBox(height: 10),
                        myTextField(
                          emailController,
                          TextInputAction.next,
                          TextInputType.text,
                          "email_address",
                          false,
                        ),
                        const SizedBox(height: 10),
                        // myTextField(numberController, TextInputAction.next,
                        //     TextInputType.number, "mobile_number", true),
                        // const SizedBox(height: 25),
                        /* ====== Multiple Profile ======== */
                        bioProfile(),
                        const SizedBox(height: 15),
                        buildSocialProfiles(),
                        const SizedBox(height: 50),
                        multipleProfile(),
                        const SizedBox(height: 15),
                        /* ====== Multiple Profile ======== */
                        updateBtn(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildSocialProfiles() {
    if ((updateprofileProvider.iconUrlControllers?.length ?? 0) > 0 &&
        (updateprofileProvider.urlControllers?.length ?? 0) > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            color: white,
            text: "socialprofiles",
            multilanguage: true,
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textBig,
            maxline: 1,
            fontwaight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: updateprofileProvider.iconUrlControllers?.length ?? 0,
              itemBuilder: (BuildContext ctx, index) {
                log(
                  "icon lenght==> ${updateprofileProvider.iconUrlControllers?.length}",
                );
                return SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () async {
                            socialLinkBottomSheet(context, index);

                            // final pickedFile = await picker.pickImage(
                            //     source: ImageSource.gallery);
                            // if (pickedFile != null) {
                            //   File image = File(pickedFile.path);

                            //   await updateprofileProvider.imageUpload(image);

                            //   if (updateprofileProvider
                            //           .imageUploadModel.status ==
                            //       200) {
                            //     await updateprofileProvider
                            //         .addMultipleAttechment(
                            //             updateprofileProvider.imageUploadModel
                            //                     .result?.imageName
                            //                     .toString() ??
                            //                 "",
                            //             updateprofileProvider.imageUploadModel
                            //                     .result?.imageUrl
                            //                     .toString() ??
                            //                 "",
                            //             index);

                            //     await updateprofileProvider.addUpdateIconIds(
                            //         "", index);
                            // }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 1, color: white),
                            ),
                            child:
                                ((updateprofileProvider
                                                .iconUrlControllers?[index] ==
                                            null) ||
                                        (updateprofileProvider
                                                .iconUrlControllers?[index] ==
                                            ""))
                                    ? const Icon(
                                      Icons.add,
                                      color: colorAccent,
                                      size: 18,
                                    )
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: MyNetworkImage(
                                        height: 50,
                                        width: 50,
                                        imagePath:
                                            updateprofileProvider
                                                .iconUrlControllers?[index]
                                                .toString() ??
                                            "",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 5,
                        child: urlTextField(
                          updateprofileProvider.urlControllers?[index],
                          TextInputAction.next,
                          TextInputType.multiline,
                          "url",
                        ),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        onPressed: () {
                          updateprofileProvider.removeTextField(index);
                        },
                        icon: const Icon(Icons.close, color: white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget myTextField(
    controller,
    textInputAction,
    keyboardType,
    labletext,
    isMobile,
  ) {
    return SizedBox(
      height: 55,
      child:
          isMobile == false
              ? TextFormField(
                textAlign: TextAlign.left,
                obscureText: false,
                keyboardType: keyboardType,
                controller: controller,
                textInputAction: textInputAction,
                cursorColor: white,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  color: white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: Locales.string(context, labletext),
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    color: colorAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: white, width: 1.5),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: white, width: 1.5),
                  ),
                ),
              )
              : IntlPhoneField(
                disableLengthCheck: true,
                textAlignVertical: TextAlignVertical.center,
                autovalidateMode: AutovalidateMode.disabled,
                controller: controller,
                style: Utils.googleFontStyle(
                  4,
                  16,
                  FontStyle.normal,
                  white,
                  FontWeight.w500,
                ),
                showCountryFlag: true,
                showDropdownIcon: false,
                initialCountryCode:
                    profileProvider.profileModel.result?[0].countryName == "" ||
                            profileProvider
                                    .profileModel
                                    .result?[0]
                                    .countryName ==
                                null
                        ? "IN"
                        : profileProvider.profileModel.result?[0].countryName
                                .toString() ??
                            "IN",
                dropdownTextStyle: Utils.googleFontStyle(
                  4,
                  16,
                  FontStyle.normal,
                  white,
                  FontWeight.w500,
                ),
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                decoration: InputDecoration(
                  labelText: Locales.string(context, labletext),
                  fillColor: transparent,
                  border: InputBorder.none,
                  labelStyle: Utils.googleFontStyle(
                    4,
                    14,
                    FontStyle.normal,
                    white,
                    FontWeight.w500,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: white, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: white, width: 1),
                  ),
                ),
                onChanged: (phone) {
                  mobilenumber = phone.number;
                  countryname = phone.countryISOCode;
                  countrycode = phone.countryCode;
                  log('mobile number==> $mobilenumber');
                  log('countryCode number==> $countryname');
                  log('countryISOCode==> $countrycode');
                },
                onCountryChanged: (country) {
                  countryname = country.code.replaceAll('+', '');
                  countrycode = "+${country.dialCode.toString()}";
                  log('countryname===> $countryname');
                  log('countrycode===> $countrycode');
                },
              ),
    );
  }

  Widget urlTextField(controller, textInputAction, keyboardType, labletext) {
    return TextFormField(
      textAlign: TextAlign.left,
      obscureText: false,
      keyboardType: keyboardType,
      minLines: 1,
      maxLines: 1,
      controller: controller,
      textInputAction: textInputAction,
      cursorColor: white,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontStyle: FontStyle.normal,
        color: white,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        constraints: const BoxConstraints(minHeight: 100),
        labelText: Locales.string(context, labletext),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontStyle: FontStyle.normal,
          color: colorAccent,
          fontWeight: FontWeight.w500,
        ),
        // contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: white, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: white, width: 1.5),
        ),
      ),
    );
  }

  Widget multipleProfile() {
    return InkWell(
      onTap: () async {
        updateprofileProvider.addTextField();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(7)),
          gradient: LinearGradient(
            colors: [colorAccent, colorPrimaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: MyText(
          color: white,
          text: "addmore",
          multilanguage: true,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          maxline: 6,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget bioProfile() {
    return Consumer<ProfileProvider>(
      builder: (context, profileprovider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              color: white,
              text: "bio",
              multilanguage: true,
              textalign: TextAlign.center,
              fontsizeNormal: 16,
              maxline: 1,
              fontwaight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 10),
            /* Field 1 */
            TextFormField(
              textAlign: TextAlign.left,
              obscureText: false,
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 10,
              controller: bio1Controller,
              textInputAction: TextInputAction.newline,
              cursorColor: white,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.normal,
                color: white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                hintText: Locales.string(context, "bio"),
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  color: colorAccent,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget updateBtn() {
    return InkWell(
      onTap: () async {
        convertToJsonMultipleProfile();
        convertToJsonBio();
        updateProfileApi();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(7)),
          color: colorAccent,
        ),
        child: MyText(
          color: black,
          text: "submit",
          multilanguage: true,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          maxline: 6,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  convertToJsonMultipleProfile() async {
    /* Mutliple Profile */
    updateprofileProvider.socialLinkList = [];
    updateprofileProvider.socialLinkList?.clear();
    for (
      int i = 0;
      i < (updateprofileProvider.iconUrlControllers?.length ?? 0);
      i++
    ) {
      updateprofileProvider.socialLinkList?.add({
        'id': updateprofileProvider.iconId?[i],
        'social_media_id': updateprofileProvider.socialMediaId?[i],
        'url': updateprofileProvider.urlControllers?[i].text.toString(),
      });
    }

    for (
      var i = 0;
      i < (updateprofileProvider.socialLinkList?.length ?? 0);
      i++
    ) {
      if (updateprofileProvider.socialLinkList?[i]['id'] == null ||
          updateprofileProvider.socialLinkList?[i]['id'] == "") {
        updateprofileProvider.socialLinkList?[i]['id'] = "";
      }
    }

    debugPrint("combineList==> ${updateprofileProvider.socialLinkList}");
  }

  updateProfileApi() async {
    String fullname = nameController.text.toString();
    String channelName = channelNameController.text.toString();
    String email = emailController.text.toString();

    final updateprofileProvider = Provider.of<UpdateprofileProvider>(
      context,
      listen: false,
    );
    Utils.showProgress(context);

    await updateprofileProvider.getupdateprofile(
      Constant.userID ?? "",
      fullname,
      channelName,
      email,
    );

    if (!updateprofileProvider.loading) {
      if (updateprofileProvider.updateprofileModel.status == 200) {
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          "${updateprofileProvider.updateprofileModel.message}",
          false,
        );

        Utils().hideProgress(context);

        updateprofileProvider.clearArray();
        getApi();

        updateDataInFirestore(
          firebaseId:
              profileProvider.profileModel.result?[0].firebaseId.toString() ??
              "",
          fullName: nameController.text,
          imageUrl:
              profileProvider.profileModel.result?[0].image.toString() ?? "",
        );
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          "${updateprofileProvider.updateprofileModel.message}",
          false,
        );

        Utils().hideProgress(context);
      }
    }
  }

  updateDataInFirestore({
    required String firebaseId,
    required String fullName,
    required String imageUrl,
  }) {
    printLog('firebasedid ....==>> $firebaseId');
    // Update data to Firestore
    FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(firebaseId)
        .update({
          FirestoreConstants.name: fullName,
          FirestoreConstants.profileurl: imageUrl,
        })
        .then((value) => printLog("User Updated"))
        .onError((error, stackTrace) {
          printLog("updateDataFirestore error ===> ${error.toString()}");
          printLog(
            "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
          );
        });
  }

  /* Bio */
  picBio(String oldImage) async {
    updateprofileProvider.bioIconUrlName.clear();
    updateprofileProvider.bioIcon1Name.clear();
    updateprofileProvider.oldIcon1Name.clear();
    updateprofileProvider.iconFile.clear();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);

      await updateprofileProvider.imageUpload(image);

      if (updateprofileProvider.imageUploadModel.status == 200) {
        await updateprofileProvider.addFieldBio(
          true,
          File(pickedFile.path),
          updateprofileProvider.imageUploadModel.result?.imageUrl.toString() ??
              "",
          updateprofileProvider.imageUploadModel.result?.imageName.toString() ??
              "",
          oldImage,
        );
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          updateprofileProvider.imageUploadModel.message.toString(),
          false,
        );
      }
    }
  }

  convertToJsonBio() async {
    /* Mutliple Profile */
    updateprofileProvider.field1 = [];
    updateprofileProvider.field1?.clear();
    updateprofileProvider.field1?.add({
      'text': bio1Controller.text,
      'icon': "",
      'old_icon': "",
    });
  }

  /* Select Social Media Platform */

  void socialLinkBottomSheet(BuildContext context, index) {
    getSocialMedia();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: const BoxDecoration(
              color: colorPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: buildSocialMedia(index),
          ),
    );
  }

  Widget buildSocialMedia(index) {
    return Consumer<UpdateprofileProvider>(
      builder: (context, updateprofileprovider, child) {
        if (updateprofileprovider.socialLinkLoading) {
          return Utils.pageLoader(context);
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(15),
            physics: const AlwaysScrollableScrollPhysics(),
            // controller: _categoryScrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      color: white,
                      text: "choosesocialprofile",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textBig,
                      maxline: 1,
                      fontwaight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: white, size: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                buildSocialMediaItem(index),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildSocialMediaItem(int index) {
    if (updateprofileProvider.getSocialLinkModel.result != null &&
        (updateprofileProvider.getSocialLinkModel.result?.length ?? 0) > 0) {
      return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 5,
        maxItemsPerRow: 5,
        horizontalGridSpacing: 15,
        verticalGridSpacing: 30,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
        ),
        children: List.generate(
          updateprofileProvider.getSocialLinkModel.result?.length ?? 0,
          (contentIndex) {
            return InkWell(
              autofocus: false,
              splashColor: transparent,
              highlightColor: transparent,
              focusColor: transparent,
              hoverColor: transparent,
              onTap: () async {
                Navigator.pop(context);
                await updateprofileProvider.addMultipleAttechment(
                  updateprofileProvider.oldIconId != null &&
                          updateprofileProvider.oldIconId?[index] == ""
                      ? ""
                      : updateprofileProvider.oldIconId?[index] ?? "",
                  updateprofileProvider
                          .getSocialLinkModel
                          .result?[contentIndex]
                          .image
                          .toString() ??
                      "",
                  updateprofileProvider
                          .getSocialLinkModel
                          .result?[contentIndex]
                          .id
                          .toString() ??
                      "",
                  index,
                );

                // await updateprofileProvider.addUpdateIconIds("", index);
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imagePath:
                          updateprofileProvider
                              .getSocialLinkModel
                              .result?[contentIndex]
                              .image
                              .toString() ??
                          "",
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
  }
}
