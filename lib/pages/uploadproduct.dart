import 'dart:io';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/provider/uploadproductprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';

class Uploadproduct extends StatefulWidget {
  const Uploadproduct({super.key});

  @override
  State<Uploadproduct> createState() => _UploadproductState();
}

class _UploadproductState extends State<Uploadproduct> {
  final ImagePicker picker = ImagePicker();
  XFile? productImage;
  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();
  final productUrlController = TextEditingController();
  final discriptionController = TextEditingController();
  late UploadProductProvider uploadProductProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    uploadProductProvider = Provider.of<UploadProductProvider>(
      context,
      listen: false,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchDataCategory(0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (uploadProductProvider.categorycurrentPage ?? 0) <
            (uploadProductProvider.categorytotalPage ?? 0)) {
      _fetchDataCategory(uploadProductProvider.categorycurrentPage);
    }
  }

  Future<void> _fetchDataCategory(int? nextPage) async {
    printLog("isMorePage  ======> ${uploadProductProvider.categoryisMorePage}");
    printLog(
      "currentPage ======> ${uploadProductProvider.categorycurrentPage}",
    );
    printLog("totalPage   ======> ${uploadProductProvider.categorytotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await uploadProductProvider.getVideoCategory((nextPage ?? 0) + 1);
    await uploadProductProvider.selectCategory(
      0,
      uploadProductProvider.categorydataList?[0].id.toString() ?? "",
      uploadProductProvider.categorydataList?[0].name.toString() ?? "",
    );
  }

  @override
  void dispose() {
    uploadProductProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        elevation: 0,
        centerTitle: false,
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
          multilanguage: true,
          text: "uploadproduct",
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            selectProductImage(),
            const SizedBox(height: 15),
            selectCategory(),
            const SizedBox(height: 20),
            myTextField(
              controller: productNameController,
              keyboardType: TextInputType.text,
              labletext: "productname",
              hintText: "enterproductname",
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            myTextField(
              controller: productPriceController,
              keyboardType: TextInputType.number,
              labletext: "productprice",
              hintText: "enterproductprice",
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            myTextField(
              controller: productUrlController,
              keyboardType: TextInputType.text,
              labletext: "producturl",
              hintText: "enterproducturl",
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            myTextField(
              controller: discriptionController,
              keyboardType: TextInputType.text,
              labletext: "discription",
              hintText: "discription",
              textInputAction:
                  Platform.isIOS ? TextInputAction.next : TextInputAction.done,
            ),
            const SizedBox(height: 20),
            uploadButton(),
          ],
        ),
      ),
    );
  }

  Widget myTextField({
    controller,
    textInputAction,
    keyboardType,
    labletext,
    hintText,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          color: white,
          text: labletext,
          fontwaight: FontWeight.w600,
          fontsizeNormal: Dimens.textTitle,
          maxline: 1,
          multilanguage: true,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.center,
          fontstyle: FontStyle.normal,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 55,
          child: TextFormField(
            textAlign: TextAlign.left,
            obscureText: false,
            keyboardType: keyboardType,
            maxLines: 1,
            controller: controller,
            textInputAction: textInputAction,
            cursorColor: white,
            style: GoogleFonts.montserrat(
              fontSize: Dimens.textMedium,
              fontStyle: FontStyle.normal,
              color: white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: Locales.string(context, hintText),
              hintStyle: GoogleFonts.montserrat(
                fontSize: Dimens.textMedium,
                fontStyle: FontStyle.normal,
                color: colorAccent,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.all(15),
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
        ),
      ],
    );
  }

  Widget selectProductImage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            color: white,
            text: "Select Image",
            fontwaight: FontWeight.w600,
            fontsizeNormal: Dimens.textTitle,
            maxline: 1,
            multilanguage: false,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () async {
              try {
                var coverImage = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 100,
                );
                setState(() {
                  productImage = coverImage;
                });
              } catch (e) {
                printLog("Error ==>${e.toString()}");
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: colorAccent),
              ),
              child:
                  productImage == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: white),
                          const SizedBox(height: 8),
                          MyText(
                            color: white,
                            text: "uploadproduct",
                            fontwaight: FontWeight.w600,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            multilanguage: true,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      )
                      : Image.file(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        File(productImage?.path ?? ""),
                        fit: BoxFit.cover,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadButton() {
    return Consumer<UploadProductProvider>(
      builder: (context, uploadproductprovider, child) {
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
              final price = double.tryParse(productPriceController.text);
              if (productNameController.text.isEmpty ||
                  productNameController.text == "") {
                Utils.showSnackbar(context, "enterproductname", true);
              } else if (productPriceController.text.isEmpty ||
                  productPriceController.text == "") {
                Utils.showSnackbar(context, "enterproductprice", true);
              } else if (discriptionController.text.isEmpty ||
                  discriptionController.text == "") {
                Utils.showSnackbar(context, "enteryourpostdiscription", true);
              } else if (price == null) {
                Utils.showSnackbar(context, "pleaseentervalidnumber", true);
              } else if (price <= 0) {
                Utils.showSnackbar(context, "pricemustbegraterthanzero", true);
              } else if (productUrlController.text.isEmpty ||
                  productUrlController.text == "") {
                Utils.showSnackbar(context, "enterproducturl", true);
              } else if (productImage == null) {
                Utils.showSnackbar(context, "productimageisempty", true);
              } else if (uploadProductProvider.categoryId == "") {
                Utils.showSnackbar(context, "selectcategory", true);
              } else {
                Utils.showProgress(context);
                await uploadProductProvider.uploadProduct(
                  productNameController.text,
                  uploadProductProvider.categoryId,
                  productPriceController.text,
                  discriptionController.text,
                  productUrlController.text,
                  File(productImage?.path ?? ""),
                );

                if (!uploadProductProvider.uploadLoading) {
                  if (uploadProductProvider.successModel.status == 200) {
                    if (!context.mounted) return;
                    Utils().hideProgress(context);
                    Utils.showSnackbar(
                      context,
                      uploadProductProvider.successModel.message.toString(),
                      false,
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const Bottombar(),
                      ),
                      (Route<dynamic> route) => false,
                    ).then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const Bottombar(),
                        ),
                      );
                    });
                  } else {
                    if (!context.mounted) return;
                    Utils().hideProgress(context);
                    Utils.showSnackbar(
                      context,
                      uploadProductProvider.successModel.message.toString(),
                      false,
                    );
                  }
                }
              }
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: colorAccent,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: MyText(
              color: black,
              text: "uploadproduct",
              fontwaight: FontWeight.w600,
              fontsizeNormal: Dimens.textTitle,
              maxline: 1,
              multilanguage: true,
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

  Widget selectCategory({String? name, amount}) {
    return Consumer<UploadProductProvider>(
      builder: (context, uploadproductprovider, child) {
        if (uploadproductprovider.categoryloading &&
            !uploadproductprovider.categoryloadMore) {
          return Utils.pageLoader(context);
        } else {
          if (uploadproductprovider.categorymodel.status == 200 &&
              uploadproductprovider.categorydataList != null) {
            if ((uploadproductprovider.categorydataList?.length ?? 0) > 0) {
              return ExpandableNotifier(
                controller: ExpandableController(
                  initialExpanded: uploadProductProvider.isExpanded,
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
                                    uploadproductprovider.categoryName == null
                                        ? "selectcategory"
                                        : uploadproductprovider.categoryName ??
                                            "",
                                multilanguage:
                                    uploadproductprovider.categoryName == null
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
            if (uploadProductProvider.categoryloadMore)
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
      itemCount: uploadProductProvider.categorydataList?.length ?? 0,
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
            await uploadProductProvider.manageExpandableController();
            await uploadProductProvider.selectCategory(
              index,
              uploadProductProvider.categorydataList?[index].id.toString(),
              uploadProductProvider.categorydataList?[index].name.toString(),
            );
          },
          child: Container(
            height: 35,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            decoration: BoxDecoration(
              color:
                  uploadProductProvider.catindex == index
                      ? colorAccent
                      : transparent,
            ),
            child: MyText(
              color: uploadProductProvider.catindex == index ? black : white,
              text: uploadProductProvider.categorydataList?[index].name ?? "",
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
}
