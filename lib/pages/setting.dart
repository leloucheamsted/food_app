import 'package:slike/pages/commonpage.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/music/musicdetails.dart';
// import 'package:slike/pages/myqrcode.dart';
// import 'package:slike/pages/notificationpage.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/profileprovider.dart';
// import 'package:slike/subscription/adspackage.dart';
import 'package:slike/subscription/subscription.dart';
import 'package:slike/provider/settingprovider.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/musictitle.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:slike/pages/watchlater.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double? width, height;
  late SettingProvider settingProvider;
  late ProfileProvider profileProvider;
  String? userName, userType, userMobileNo;
  final playlistTitleController = TextEditingController();
  bool isPublic = false;
  bool isPrivate = false;
  String playlistType = "0";
  SharedPre sharedPref = SharedPre();
  final passwordController = TextEditingController();

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    super.initState();
    getApi();
  }

  getApi() async {
    await profileProvider.getprofile(context, Constant.userID.toString());
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
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
          text: "settings",
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Profile Page */
            settingItem("ic_user.png", "myprofile", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
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
                        return Profile(
                          isBottomBar: false,
                          toUserId: Constant.userID ?? "",
                          toChannelId: Constant.channelID ?? "",
                        );
                      },
                    ),
                  );
                }
              });
            }),
            /* Notification Page */
            // settingItem("notification.png", "notification", false, () {
            //   AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
            //     if (Constant.userID == null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const Login();
            //           },
            //         ),
            //       );
            //     } else {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const NotificationPage();
            //           },
            //         ),
            //       );
            //     }
            //   });
            // }),

            /* history Page */
            // settingItem("history.png", "history", false, () {
            //   Utils().showInterstitalAds(context, Constant.interstialAdType,
            //       () {
            //     if (Constant.userID == null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const Login();
            //           },
            //         ),
            //       );
            //     } else {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const History();
            //           },
            //         ),
            //       );
            //     }
            //   });
            // }),

            /* Download Page */
            // Constant.isDownload == "1"
            //     ? settingItem("ic_download.png", "download", false, () {
            //         Utils().showInterstitalAds(
            //             context, Constant.interstialAdType, () {
            //           if (Constant.userID == null) {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) {
            //                   return const Login();
            //                 },
            //               ),
            //             );
            //           } else {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) {
            //                   return const Download();
            //                 },
            //               ),
            //             );
            //           }
            //         });
            //       })
            //     : const SizedBox.shrink(),

            /* SubscriberList Page */
            // settingItem("ic_subscriber.png", "subscriber", false, () {
            //   Utils().showInterstitalAds(context, Constant.interstialAdType,
            //       () {
            //     if (Constant.userID == null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const Login();
            //           },
            //         ),
            //       );
            //     } else {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const SubscribedChannel();
            //           },
            //         ),
            //       );
            //     }
            //   });
            // }),

            // Constant.userID != null
            //     ? Consumer<ProfileProvider>(
            //         builder: (context, profileProvider, child) {
            //         return settingItem("ic_qrcode.png", "myqrcode", false, () {
            //           Utils().showInterstitalAds(
            //               context, Constant.interstialAdType, () {
            //             if (Constant.userID == null) {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) {
            //                     return const Login();
            //                   },
            //                 ),
            //               );
            //             } else {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) {
            //                     return const MyQrCode();
            //                   },
            //                 ),
            //               );
            //             }
            //           });
            //         });
            //       })
            //     : const SizedBox.shrink(),

            /* Wallet Page */
            // Consumer<ProfileProvider>(
            //     builder: (context, profileProvider, child) {
            //   return settingItem("ic_walletborder.png", "mywallet", false, () {
            //     Utils().showInterstitalAds(context, Constant.interstialAdType,
            //         () {
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
            //               return const AdsPackage();
            //             },
            //           ),
            //         );
            //       }
            //     });
            //   });
            // }),
            /* subscription Page */
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return settingItem(
                  "ic_subscription.png",
                  "subscription",
                  false,
                  () {
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
                                return const Subscription();
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
            /* rent Page */

            // settingItem("rent.png", "rent", false, () {
            //   Utils().showInterstitalAds(context, Constant.interstialAdType,
            //       () {
            //     if (Constant.userID == null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const Login();
            //           },
            //         ),
            //       );
            //     } else {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const Rent();
            //           },
            //         ),
            //       );
            //     }
            //   });
            // }),
            // /* myplaylist Page */
            // settingItem("ic_playlisttitle.png", "myplaylist", false, () {
            //   AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
            //     if (Constant.userID == null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const Login();
            //           },
            //         ),
            //       );
            //     } else {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const MyPlayList();
            //           },
            //         ),
            //       );
            //     }
            //   });
            // }),

            /* watchlater Page */
            settingItem("ic_watchlater.png", "watchlater", false, () {
              Utils().showInterstitalAds(
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
                          return const WatchLater();
                        },
                      ),
                    );
                  }
                },
              );
            }),
            /* likevideos Page */
            // settingItem("heart.png", "likevideos", false, () {
            //   AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
            //     if (Constant.userID == null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const Login();
            //           },
            //         ),
            //       );
            //     } else {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return const LikeVideos();
            //           },
            //         ),
            //       );
            //     }
            //   });
            // }),

            /* Get Pages Api*/
            buildPages(),
            /* UserPanel Dilog Sheet */
            Consumer<SettingProvider>(
              builder: (context, profileprovider, child) {
                if (Constant.userID == null) {
                  return const SizedBox.shrink();
                } else {
                  if (profileprovider.loading) {
                    return const SizedBox.shrink();
                  } else {
                    return settingItem("userpanel.png", "userpanel", false, () {
                      if (Constant.userPanelStatus == "0" ||
                          Constant.userPanelStatus == "" ||
                          Constant.userPanelStatus == null) {
                        userPanelActiveDilog();
                      } else {
                        edituserPanelDilog();
                      }
                    });
                  }
                }
              },
            ),
            /* chooselanguage Bottom Sheet */
            settingItem("ic_link.png", "chooselanguage", false, () {
              _languageChangeDialog();
            }),
            /* Delete Account */
            Constant.userID != null
                ? settingItem(
                  "ic_delete.png",
                  Constant.userID != null ? "deleteaccount" : "deleteaccount",
                  false,
                  () {
                    deleteConfirmDialog();
                  },
                )
                : Container(),

            /* Login Logout */
            settingItem(
              "ic_logout.png",
              Constant.userID != null ? "logout" : "login",
              false,
              () {
                Constant.userID != null
                    ? logoutConfirmDialog()
                    : Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
              },
            ),
            subsciptionDisc(),
            socialLinkList(),
          ],
        ),
      ),
    );
  }

  Widget buildPages() {
    return Consumer<SettingProvider>(
      builder: (context, settingprovider, child) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ListView.builder(
            itemCount: settingprovider.getpagesModel.result?.length ?? 0,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return settingItem(
                settingprovider.getpagesModel.result?[index].icon.toString() ??
                    "",
                settingprovider.getpagesModel.result?[index].title.toString() ??
                    "",
                true,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Commonpage(
                          title:
                              settingprovider.getpagesModel.result?[index].title
                                  .toString() ??
                              "",
                          url:
                              settingprovider.getpagesModel.result?[index].url
                                  .toString() ??
                              "",
                          multilanguage: false,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget settingItem(String imagepath, String title, bool isPages, onTap) {
    return InkWell(
      hoverColor: colorAccent,
      highlightColor: colorAccent,
      autofocus: true,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Row(
          children: [
            isPages == true
                ? MyNetworkImage(
                  width: 22,
                  height: 22,
                  imagePath: imagepath,
                  color: white,
                  isPagesIcon: false,
                  fit: BoxFit.contain,
                )
                : MyImage(
                  width: 22,
                  height: 22,
                  imagePath: imagepath,
                  color: white,
                ),
            const SizedBox(width: 15),
            MyText(
              color: white,
              text: title,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textTitle,
              multilanguage: isPages == true ? false : true,
              inter: true,
              maxline: 2,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ],
        ),
      ),
    );
  }

  Widget languageItem(onTap, title) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        decoration: BoxDecoration(
          // color: colorAccent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1, color: colorAccent),
        ),
        alignment: Alignment.center,
        child: MyText(
          color: white,
          text: title,
          textalign: TextAlign.left,
          fontsizeNormal: 16,
          multilanguage: true,
          inter: false,
          maxline: 2,
          fontwaight: FontWeight.w500,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  userPanelActiveDilog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 320,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colorAccent.withOpacity(0.10)),
            child: Consumer<SettingProvider>(
              builder: (context, settingprovider, child) {
                return Column(
                  children: [
                    MyText(
                      color: white,
                      text: "userpanel",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textExtraBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      cursorColor: white,
                      obscureText: settingprovider.isPasswordVisible,
                      controller: passwordController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      style: Utils.googleFontStyle(
                        1,
                        Dimens.textBig,
                        FontStyle.normal,
                        white,
                        FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            color: white,
                            settingprovider.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            settingprovider.passwordHideShow();
                          },
                        ),
                        hintText: "Give your User Panel Password",
                        hintStyle: Utils.googleFontStyle(
                          1,
                          Dimens.textBig,
                          FontStyle.normal,
                          gray,
                          FontWeight.w500,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: gray),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: gray),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        MyText(
                          color: white,
                          multilanguage: true,
                          text: "status",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          color: white,
                          multilanguage: false,
                          text: ":",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            settingprovider.selectUserPanel("on", true);
                            printLog("type==>${settingprovider.isActiveType}");
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  settingprovider.isUserpanelType == "on" &&
                                          settingprovider.isActive == true
                                      ? colorAccent
                                      : colorPrimaryDark,
                              shape: BoxShape.circle,
                            ),
                            child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "on",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            settingprovider.selectUserPanel("off", true);
                            printLog("type==>${settingprovider.isActiveType}");
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  settingprovider.isUserpanelType == "off" &&
                                          settingprovider.isActive == true
                                      ? colorAccent
                                      : colorPrimaryDark,
                              shape: BoxShape.circle,
                            ),
                            child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "off",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textTitle,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          radius: 50,
                          autofocus: false,
                          onTap: () {
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            settingprovider.clearUserPanel();
                            passwordController.clear();
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorPrimaryDark,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAccent.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5, //New
                                ),
                              ],
                            ),
                            child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () async {
                              if (passwordController.text.isEmpty) {
                                Utils.showSnackbar(
                                  context,
                                  "pleaseenteryourpassword",
                                  true,
                                );
                              } else if (passwordController.text.length < 6) {
                                Utils.showSnackbar(
                                  context,
                                  "passwordmustbesixcharecter",
                                  true,
                                );
                              } else if (settingprovider.isUserpanelType ==
                                  "off") {
                                Utils.showSnackbar(
                                  context,
                                  "pleaseselectuserpanelstatus",
                                  true,
                                );
                              } else {
                                /* Userpanal Api */
                                await settingProvider.getActiveUserPanel(
                                  passwordController.text,
                                  settingprovider.isActiveType,
                                );
                                if (!context.mounted) return;
                                if (!mounted) return;
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                                settingprovider.clearUserPanel();
                                passwordController.clear();
                                Utils.showSnackbar(
                                  context,
                                  "userpanalactivesuccsessfully",
                                  true,
                                );

                                await profileProvider.getprofile(
                                  context,
                                  Constant.userID,
                                );
                                await sharedPref.save(
                                  "userpanelstatus",
                                  profileProvider
                                          .profileModel
                                          .result?[0]
                                          .userPenalStatus
                                          .toString() ??
                                      "",
                                );
                                Constant.userPanelStatus = await sharedPref
                                    .read("userpanelstatus");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                10,
                              ),
                              decoration: BoxDecoration(
                                color: colorAccent,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorAccent.withOpacity(0.40),
                                    blurRadius: 10.0,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                              child: MyText(
                                color: black,
                                multilanguage: true,
                                text: "active",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textBig,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  edituserPanelDilog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 240,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colorAccent.withOpacity(0.10)),
            child: Consumer<SettingProvider>(
              builder: (context, settingprovider, child) {
                return Column(
                  children: [
                    MyText(
                      color: white,
                      text: "changepassword",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textExtraBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      cursorColor: white,
                      obscureText: settingprovider.isPasswordVisible,
                      controller: passwordController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      style: Utils.googleFontStyle(
                        1,
                        Dimens.textBig,
                        FontStyle.normal,
                        white,
                        FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            color: white,
                            settingprovider.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            settingprovider.passwordHideShow();
                          },
                        ),
                        hintText: "Edit User Panel Password",
                        hintStyle: Utils.googleFontStyle(
                          1,
                          Dimens.textBig,
                          FontStyle.normal,
                          gray,
                          FontWeight.w500,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: gray),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: gray),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          radius: 50,
                          autofocus: false,
                          onTap: () {
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            passwordController.clear();
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorPrimaryDark,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAccent.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5, //New
                                ),
                              ],
                            ),
                            child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () async {
                              if (passwordController.text.isEmpty) {
                                Utils.showSnackbar(
                                  context,
                                  "pleaseenteryourpassword",
                                  true,
                                );
                              } else if (passwordController.text.length < 6) {
                                Utils.showSnackbar(
                                  context,
                                  "passwordmustbesixcharecter",
                                  true,
                                );
                              } else {
                                /* Userpanal Api */
                                await settingProvider.getActiveUserPanel(
                                  passwordController.text,
                                  "1",
                                );
                                if (!context.mounted) return;
                                if (!mounted) return;
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                                passwordController.clear();
                                Utils.showSnackbar(
                                  context,
                                  "passwordchangesuccsessfully",
                                  true,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                10,
                              ),
                              decoration: BoxDecoration(
                                color: colorAccent,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorAccent.withOpacity(0.40),
                                    blurRadius: 10.0,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                              child: MyText(
                                color: black,
                                multilanguage: true,
                                text: "edit",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textBig,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  _languageChangeDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: colorPrimaryDark,
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "selectlanguage",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),

                        /* English */
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "English",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('en');
                                    if (!mounted) return;
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Afrikaans */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Afrikaans",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('af');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Arabic */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Arabic",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('ar');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* German */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "German",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('de');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Spanish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Spanish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('es');
                                    if (!mounted) return;
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* French */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "French",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('fr');
                                    if (!mounted) return;
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Gujarati */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Gujarati",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('gu');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Hindi */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Hindi",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('hi');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Indonesian */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Indonesian",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('id');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Dutch */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Dutch",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('nl');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Portuguese (Brazil) */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Portuguese (Brazil)",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('pt');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Albanian */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Albanian",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('sq');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Turkish */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Turkish",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('tr');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),

                                /* Vietnamese */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Vietnamese",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('vi');
                                //     if (!mounted) return;
                                //     if (Navigator.canPop(context)) {
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                // ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguage({
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: colorAccent, width: .5),
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: white,
          text: langName,
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textTitle,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  logoutConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: colorPrimaryDark,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "confirmsognout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "areyousurewanrtosignout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textSmall,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'logout',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final profileProvider =
                                Provider.of<ProfileProvider>(
                                  context,
                                  listen: false,
                                );
                            await settingProvider.getLogout();
                            await profileProvider.clearProvider();
                            // Firebase Signout
                            await _auth.signOut();
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            audioPlayer.stop();
                            audioPlayer.pause();
                            if (!context.mounted) return;
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (!mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  deleteConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: colorPrimaryDark,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "deleteaccount",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "are_you_sure_want_to_delete_account?",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: Dimens.textSmall,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'deleteaccount',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final profileProvider =
                                Provider.of<ProfileProvider>(
                                  context,
                                  listen: false,
                                );
                            await settingProvider.getLogout();
                            await profileProvider.clearProvider();
                            // Firebase Signout
                            await _auth.signOut();
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            audioPlayer.stop();
                            audioPlayer.pause();
                            if (!context.mounted) return;
                            if (!mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPositive ? colorAccent : transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 0.5, color: white),
        ),
        child: MyText(
          color: isPositive ? black : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsizeNormal: Dimens.textTitle,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget subsciptionDisc() {
    if (Constant.userID != null) {
      return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
          if (profileprovider.loading) {
            return const SizedBox.shrink();
          } else {
            if (profileprovider.profileModel.result?[0].isBuy == 1) {
              return Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                color: colorPrimaryDark,
                margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: yellow,
                          text: "active",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textMedium,
                          multilanguage: true,
                          maxline: 2,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MyText(
                              color: colorAccent,
                              text:
                                  profileprovider
                                      .profileModel
                                      .result?[0]
                                      .packageName
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              multilanguage: false,
                              maxline: 2,
                              fontwaight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: white,
                              ),
                              child: MusicTitle(
                                color: black,
                                text:
                                    "${Constant.currencySymbol}${profileprovider.profileModel.result?[0].packagePrice.toString() ?? ""}",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                multilanguage: false,
                                maxline: 2,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                                    return const Subscription();
                                  },
                                ),
                              );
                            }
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: colorAccent,
                        ),
                        child: MyText(
                          color: black,
                          text: "Upgrade Now",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textSmall,
                          multilanguage: false,
                          maxline: 2,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget socialLinkList() {
    return Consumer<SettingProvider>(
      builder: (context, settingprovider, child) {
        if (settingprovider.loading) {
          return Utils.pageLoader(context);
        } else {
          if (settingprovider.socialLinkModel.status == 200 &&
              settingprovider.socialLinkModel.result != null) {
            if ((settingprovider.socialLinkModel.result?.length ?? 0) > 0) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color: white,
                      multilanguage: true,
                      text: "socialprofiles",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textMedium,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            settingprovider.socialLinkModel.result?.length ?? 0,
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            focusColor: transparent,
                            hoverColor: transparent,
                            highlightColor: transparent,
                            splashColor: transparent,
                            onTap: () {
                              Utils.lanchAdsUrl(
                                settingprovider
                                        .socialLinkModel
                                        .result?[index]
                                        .url
                                        .toString() ??
                                    "",
                              );
                            },
                            child: Container(
                              width: 45,
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.contain,
                                imagePath:
                                    settingprovider
                                        .socialLinkModel
                                        .result?[index]
                                        .image
                                        .toString() ??
                                    "",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }
}
