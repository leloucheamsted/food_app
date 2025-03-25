import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slike/provider/myqrprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';

class MyQrCode extends StatefulWidget {
  const MyQrCode({super.key});

  @override
  State<MyQrCode> createState() => _MyQrCodeState();
}

class _MyQrCodeState extends State<MyQrCode> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "myqrcode", true),
      body: Consumer<MyQRProvider>(
        builder: (context, myqrprovider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Screenshot(
                    controller: myqrprovider.screenshotController,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 11,
                      ),
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
                          const Divider(
                            indent: 30,
                            endIndent: 30,
                            thickness: 0.5,
                            color: black,
                          ),
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
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: MyText(
                      color: white,
                      text: "scanqrcode",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textBig,
                      fontsizeWeb: Dimens.textBig,
                      inter: false,
                      multilanguage: true,
                      maxline: 1,
                      fontwaight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: MyText(
                      color: white,
                      text: "myqrcodedisc",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textSmall,
                      fontsizeWeb: Dimens.textSmall,
                      inter: false,
                      multilanguage: true,
                      maxline: 10,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget qrCodeItem({icon, onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 52,
        decoration: const BoxDecoration(
          color: colorPrimaryDark,
          shape: BoxShape.circle,
        ),
        child: Center(child: MyImage(width: 24, height: 24, imagePath: icon)),
      ),
    );
  }
}
