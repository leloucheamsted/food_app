import 'package:slike/pages/inbox.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/notificationpage.dart';
import 'package:slike/pages/scanqr.dart';
import 'package:slike/pages/setting.dart';
import 'package:slike/provider/homeprovider.dart';
import 'package:slike/provider/profileprovider.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/widget/musictitle.dart';
import 'package:slike/widget/myimage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String contentType;
  final bool isSearch;
  const CustomAppBar({
    super.key,
    required this.contentType,
    required this.isSearch,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late HomeProvider homeProvider;
  late ProfileProvider profileProvider;
  SharedPre sharedPre = SharedPre();
  String image = "";
  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getApi();
    super.initState();
  }

  getApi() async {
    if (Constant.userID != null) {
      await homeProvider.getprofile(Constant.userID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        title: Consumer<HomeProvider>(
          builder: (context, homeprovider, child) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      MyImage(width: 55, height: 55, imagePath: "appicon.png"),
                      Consumer<HomeProvider>(
                        builder: (context, profileprovider, child) {
                          return MusicTitle(
                            color: white,
                            text: Constant.isBuy == "1" ? "premium" : "appname",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textBig,
                            fontsizeWeb: Dimens.textBig,
                            multilanguage: true,
                            maxline: 1,
                            fontwaight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // widget.isSearch == true
                      //     ? InkWell(
                      //         onTap: () {
                      //           AdHelper.showFullscreenAd(
                      //               context, Constant.rewardAdType, () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) {
                      //                   return Search(
                      //                     contentType: widget.contentType,
                      //                   );
                      //                 },
                      //               ),
                      //             );
                      //           });
                      //         },
                      //         child: const Icon(
                      //           Icons.search,
                      //           color: white,
                      //           size: 20,
                      //         ),
                      //       )
                      //     : const SizedBox.shrink(),
                      // const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          AdHelper.showFullscreenAd(
                            context,
                            Constant.interstialAdType,
                            () {
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Inbox();
                                    },
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: MyImage(
                          width: 25,
                          height: 25,
                          color: colorAccent,
                          imagePath: "ic_chat.png",
                        ),
                      ),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          AdHelper.showFullscreenAd(
                            context,
                            Constant.interstialAdType,
                            () {
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const NotificationPage();
                                    },
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: MyImage(
                          width: 25,
                          height: 25,
                          color: colorAccent,
                          imagePath: "notification.png",
                        ),
                      ),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          AdHelper.showFullscreenAd(
                            context,
                            Constant.interstialAdType,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Setting();
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.settings,
                          color: colorAccent,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 15),

                      /* UserProfile Image */
                      // InkWell(
                      //   onTap: () {
                      //     AdHelper.showFullscreenAd(
                      //         context, Constant.interstialAdType, () {
                      //       if (Constant.userID == null) {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) {
                      //               return const Login();
                      //             },
                      //           ),
                      //         );
                      //       } else {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) {
                      //               return Profile(
                      //                 isProfile: true,
                      //                 channelUserid: Constant.userID ?? "",
                      //                 channelid: Constant.channelID ?? "",
                      //               );
                      //             },
                      //           ),
                      //         );
                      //       }
                      //     });
                      //   },
                      //   child: Constant.userID == null || Constant.userImage == ""
                      //       ? MyImage(
                      //           width: 30,
                      //           height: 30,
                      //           color: colorAccent,
                      //           imagePath: "ic_user.png")
                      //       : Container(
                      //           padding: const EdgeInsets.all(3),
                      //           decoration: BoxDecoration(
                      //               border: Border.all(color: white, width: 1),
                      //               shape: BoxShape.circle),
                      //           child: ClipRRect(
                      //             borderRadius: BorderRadius.circular(50),
                      //             child: MyNetworkImage(
                      //                 fit: BoxFit.cover,
                      //                 width: 30,
                      //                 height: 30,
                      //                 imagePath: Constant.userImage ?? ""),
                      //           ),
                      //         ),
                      // ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ScanQr();
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: colorAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "#",
                              style: TextStyle(
                                color: black,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimens.textExtraBig,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
