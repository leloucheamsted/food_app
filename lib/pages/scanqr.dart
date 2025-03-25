import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/myqrprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  MobileScannerController mobileScannerController = MobileScannerController();

  @override
  void dispose() {
    mobileScannerController.dispose();
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
          text: "scanqrcode",
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            scanBorderWidget(
              height: 290,
              radius: 25,
              child: Container(
                height: 295,
                width: 295,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: MobileScanner(
                  controller: mobileScannerController,
                  onDetect: (barcodes) async {
                    final userId = barcodes.barcodes.first.rawValue;

                    if (userId != "") {
                      try {
                        final object = userId ?? "";

                        List<String> objectParts = object.split(",");

                        if (bool.parse(objectParts[2]) == true &&
                            objectParts[0] != "" &&
                            objectParts[1] != "" &&
                            objectParts.length == 3) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Profile(
                                  isBottomBar: false,
                                  toUserId: objectParts[0],
                                  toChannelId: objectParts[1],
                                );
                              },
                            ),
                          );
                        }
                      } catch (e) {
                        printLog("Scan Qr Code Is Wrong => $e");
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            MyText(
              color: white,
              multilanguage: true,
              text: "scanqrcodetitle",
              textalign: TextAlign.center,
              fontsizeNormal: Dimens.textBig,
              inter: false,
              maxline: 1,
              fontwaight: FontWeight.w700,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 20),
            Consumer<MyQRProvider>(
              builder: (context, myqrprovider, child) {
                return Screenshot(
                  controller: myqrprovider.screenshotController,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    decoration: BoxDecoration(
                      color: colorAccent,
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        QrImageView(
                          data:
                              "${Constant.userID},${Constant.channelID},${true}",
                          version: QrVersions.auto,
                          size: 160.0,
                          eyeStyle: const QrEyeStyle(
                            color: black,
                            eyeShape: QrEyeShape.square,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            color: black,
                            dataModuleShape: QrDataModuleShape.square,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          color: colorPrimary,
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              imagePath: Constant.userImage ?? "",
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                          color: black,
                          text: Constant.channelName ?? "",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
                          inter: false,
                          multilanguage: false,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),

            // const SizedBox(height: 10),
            // MyImage(width: 230, height: 230, imagePath: "ic_scan_image.webp")
          ],
        ),
      ),
    );
  }

  Widget scanBorderWidget({
    required double height,
    double? width,
    required Widget child,
    required double radius,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorAccent,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: transparent,
          border: Border.all(width: 3, color: colorAccent),
          borderRadius: BorderRadius.circular(radius - 1),
        ),
        child: child,
      ),
    );
  }
}
