import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slike/model/chatusermodel.dart';
import 'package:slike/model/conversionmodel.dart';
import 'package:slike/model/lastmessagemodel.dart';
import 'package:slike/pages/chatscreen.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/inboxprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> with TickerProviderStateMixin {
  List<ChatUserModel>? myChatList = [];
  SharedPre sharePref = SharedPre();
  String currentUserFId = "";
  late InboxProvider inboxProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    inboxProvider = Provider.of<InboxProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserData();
    });
    super.initState();
  }

  Future getUserData() async {
    currentUserFId = await sharePref.read("firebaseid") ?? "";
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (inboxProvider.selectedTab == "notification") {
        if ((inboxProvider.currentPage ?? 0) < (inboxProvider.totalPage ?? 0)) {
          await inboxProvider.setLoadMore(true);
          _fetchNotification(inboxProvider.currentPage ?? 0);
        }
      }
    }
  }

  Future<void> _fetchNotification(int? nextPage) async {
    printLog("isMorePage  ======> ${inboxProvider.isMorePage}");
    printLog("currentPage ======> ${inboxProvider.currentPage}");
    printLog("totalPage   ======> ${inboxProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await inboxProvider.getNotification((nextPage ?? 0) + 1);
    await inboxProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    inboxProvider.clearProvider();
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
          text: "inbox",
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          inter: false,
          maxline: 1,
          fontwaight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
        ),
      ),
      body: Consumer<InboxProvider>(
        builder: (context, inboxprovider, child) {
          return Column(
            children: [buildTab(), Expanded(child: buildTabItem())],
          );
        },
      ),
    );
  }

  buildTab() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              hoverColor: transparent,
              splashColor: transparent,
              highlightColor: transparent,
              focusColor: transparent,
              onTap: () async {
                inboxProvider.selectTab("chat");
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          MyText(
                            fontsizeWeb: Dimens.textDesc,
                            color: white,
                            text: "chat",
                            textalign: TextAlign.center,
                            multilanguage: true,
                            fontstyle: FontStyle.normal,
                            fontsizeNormal: Dimens.textDesc,
                            fontwaight: FontWeight.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  inboxProvider.selectedTab == "chat"
                      ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                        color: colorAccent,
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              hoverColor: transparent,
              splashColor: transparent,
              highlightColor: transparent,
              focusColor: transparent,
              onTap: () async {
                await inboxProvider.selectTab("notification");
                inboxProvider.clearNotification();
                _fetchNotification(0);
              },
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_active_outlined,
                            color: white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          MyText(
                            fontsizeWeb: Dimens.textDesc,
                            color: white,
                            text: "notification",
                            textalign: TextAlign.center,
                            multilanguage: true,
                            fontstyle: FontStyle.normal,
                            fontsizeNormal: Dimens.textDesc,
                            fontwaight: FontWeight.normal,
                          ),
                        ],
                      ),
                    ),
                    inboxProvider.selectedTab == "notification"
                        ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: colorAccent,
                        )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildTabItem() {
    if (inboxProvider.selectedTab == "chat") {
      return _buildPage();
    } else {
      return buildNotification();
    }
  }

  /* ==================================== Chat ==================================== */

  Widget _buildPage() {
    return FutureBuilder<List<ConversionModel>>(
      future: _fetch(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<ConversionModel>> snapshot,
      ) {
        if (snapshot.hasError) {
          printLog("snapshot ERROR ==========> ${snapshot.error.toString()}");
          return const NoData();
        }
        if (snapshot.hasData) {
          if ((snapshot.data?.length ?? 0) > 0) {
            return SingleChildScrollView(
              child: AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: 1,
                crossAxisSpacing: 0,
                reverse: true,
                mainAxisSpacing: 15,
                itemCount: snapshot.data?.length ?? 0,
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int position) {
                  return _buildUserItem(
                    position: position,
                    chatUserList: snapshot.data,
                  );
                },
              ),
            );
          } else {
            return const NoData();
          }
        } else {
          return shimmer();
        }
      },
    );
  }

  Widget _buildUserItem({
    required int position,
    required List<ConversionModel>? chatUserList,
  }) {
    return InkWell(
      focusColor: transparent,
      hoverColor: transparent,
      highlightColor: transparent,
      splashColor: transparent,
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        if (Utils.checkLoginUser(context)) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Chatscreen(
                  appuserId:
                      chatUserList?[position].chatUserModel?.appuserid
                          .toString(),
                  appchannelId:
                      chatUserList?[position].chatUserModel?.appchannelid
                          .toString(),
                  toUserName:
                      chatUserList?[position].chatUserModel?.name.toString(),
                  toChatId:
                      chatUserList?[position].chatUserModel?.userid.toString(),
                  profileImg:
                      chatUserList?[position].chatUserModel?.photoUrl
                          .toString(),
                  bioData:
                      chatUserList?[position].chatUserModel?.biodata.toString(),
                );
              },
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: colorPrimaryDark),
              borderRadius: BorderRadius.circular(60),
            ),
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: MyNetworkImage(
                imagePath:
                    chatUserList?[position].chatUserModel?.photoUrl ?? "",
                fit: BoxFit.cover,
                height: 52,
                width: 52,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  color: white,
                  text:
                      chatUserList?[position].chatUserModel?.name == ""
                          ? "New User"
                          : chatUserList?[position].chatUserModel?.name ?? "",
                  fontsizeNormal: Dimens.textTitle,
                  fontwaight: FontWeight.w600,
                  maxline: 1,
                  multilanguage: false,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.start,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 5),
                (chatUserList?[position].lastMessage?.type ?? 0) == 0
                    ? Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: MyText(
                        color:
                            ((chatUserList?[position].lastMessage?.read ??
                                        false) ==
                                    false)
                                ? lightgray
                                : gray,
                        text:
                            (chatUserList?[position].lastMessage?.content ?? "")
                                    .isNotEmpty
                                ? (chatUserList?[position]
                                        .lastMessage
                                        ?.content ??
                                    "")
                                : chatUserList?[position]
                                        .chatUserModel
                                        ?.biodata ??
                                    "",
                        fontsizeNormal: Dimens.textMedium,
                        fontwaight: FontWeight.w400,
                        maxline: 1,
                        multilanguage: false,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                    )
                    : Transform.rotate(
                      angle: 30 * (3.1415926535897932 / 180),
                      child: const Icon(
                        Icons.attach_file_outlined,
                        size: 18,
                        color: colorPrimaryDark,
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Container(
            alignment: Alignment.center,
            child: MyText(
              color:
                  ((chatUserList?[position].lastMessage?.read ?? false) ==
                          false)
                      ? colorAccent
                      : gray,
              text: DateFormat('hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  int.parse(
                    chatUserList?[position].lastMessage?.timestamp ?? "",
                  ),
                ),
              ),
              fontsizeNormal: Dimens.textSmall,
              fontwaight: FontWeight.w600,
              maxline: 1,
              multilanguage: false,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ConversionModel>> _fetch() async {
    var messageIds = <String>[];
    var userIds = <String>[];

    // Fetching All Messages.
    var messageSnapshot =
        await FirebaseFirestore.instance
            .collection(FirestoreConstants.pathMessageCollection)
            .where(FirestoreConstants.users, arrayContains: currentUserFId)
            .get();
    if (messageSnapshot.docs.isNotEmpty) {
      for (int i = 0; i < messageSnapshot.docs.length; i++) {
        messageIds.add(messageSnapshot.docs[i].id.toString());
        printLog("messageIds length ========> ${messageIds.length}");
        printLog("messageIds  ========> $messageIds");
      }
    }

    List<LastMessage> lastMessageList = [];
    /* Get "lastMessage" Documents */
    for (int i = 0; i < messageIds.length; i++) {
      var messagesDoc =
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.pathMessageCollection)
              .doc(messageIds[i])
              .get();

      if ((messagesDoc.data()?.length ?? 0) > 0) {
        printLog("====================== Users fetched ======================");
        if (messagesDoc[FirestoreConstants.users] != null) {
          printLog(
            "users ==========> ${messagesDoc[FirestoreConstants.users]}",
          );
          if (messagesDoc[FirestoreConstants.users][0].toString() != "" ||
              messagesDoc[FirestoreConstants.users][1].toString() != "") {
            printLog("currentUserFId ==========> $currentUserFId");
            if (messagesDoc[FirestoreConstants.users][0].toString() ==
                    currentUserFId ||
                messagesDoc[FirestoreConstants.users][1].toString() ==
                    currentUserFId) {
              userIds.add(messagesDoc[FirestoreConstants.users][0].toString());
              userIds.add(messagesDoc[FirestoreConstants.users][1].toString());
              printLog("userIds length ========> ${userIds.length}");

              /* LastMessage */
              if (messagesDoc.data()?.containsKey(
                    FirestoreConstants.lastMessage,
                  ) ??
                  false) {
                LastMessage lastMessageModel = LastMessage.fromMap(
                  messagesDoc[FirestoreConstants.lastMessage],
                );
                lastMessageList.add(lastMessageModel);
                printLog(
                  "lastMessageModel content ==========> ${lastMessageModel.content}",
                );
                printLog(
                  "lastMessageList length ==========> ${lastMessageList.length}",
                );
              }
            }
          }
        }
      }
    }

    List<ChatUserModel> userList = [];
    /* Get Users Data */
    for (int i = 0; i < userIds.length; i++) {
      if (userIds[i].toString() != currentUserFId) {
        var usersDetails =
            await FirebaseFirestore.instance
                .collection(FirestoreConstants.pathUserCollection)
                .doc(userIds[i].toString())
                .get();
        ChatUserModel chatUserModel = ChatUserModel.fromDocument(usersDetails);
        printLog("chatUserModel mUser name ==========> ${chatUserModel.name}");
        userList.add(chatUserModel);
        printLog("userList length ==========> ${userList.length}");
      }
    }
    printLog("userList Size ====> ${userList.length}");
    printLog("lastMessageList Size ====> ${lastMessageList.length}");

    /* Combine Users & LastMessage */
    List<ConversionModel> conversionList = [];
    for (var i = 0; i < userList.length; i++) {
      ConversionModel conversionModel = ConversionModel();
      conversionModel.chatUserModel = userList[i];
      conversionModel.lastMessage = lastMessageList[i];
      conversionList.add(conversionModel);
    }
    printLog("conversionList length ==========> ${conversionList.length}");

    return conversionList;
  }

  /* ==================================== Chat ==================================== */

  /* ==================================== Notification ==================================== */

  Widget buildNotification() {
    if (inboxProvider.loading && !inboxProvider.loadMore) {
      return shimmer();
    } else {
      if (inboxProvider.notificationList != null &&
          (inboxProvider.notificationList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              notificationList(),
              if (inboxProvider.loadMore)
                SizedBox(height: 50, child: Utils.pageLoader(context))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    }
  }

  Widget notificationList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: inboxProvider.notificationList?.length ?? 0,
      itemBuilder: (BuildContext ctx, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: colorAccent),
                  borderRadius: BorderRadius.circular(50),
                ),
                child:
                    inboxProvider.notificationList?[index].type == 1
                        ? MyImage(
                          width: 50,
                          height: 50,
                          imagePath: "ic_user.png",
                          color: colorAccent,
                        )
                        : InkWell(
                          onTap: () {
                            printLog(
                              "userId===> ${inboxProvider.notificationList?[index].userId.toString() ?? ""}",
                            );
                            printLog(
                              "channlId===> ${inboxProvider.notificationList?[index].channelId.toString() ?? ""}",
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Profile(
                                    isBottomBar: false,
                                    toUserId:
                                        inboxProvider
                                            .notificationList?[index]
                                            .userId
                                            .toString() ??
                                        "",
                                    toChannelId:
                                        inboxProvider
                                            .notificationList?[index]
                                            .channelId
                                            .toString() ??
                                        "",
                                  );
                                },
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                              width: 50,
                              height: 50,
                              imagePath:
                                  inboxProvider
                                      .notificationList?[index]
                                      .userImage
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      inboxProvider.notificationList?[index].type == 1 ||
                              inboxProvider.notificationList?[index].type == 4
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment:
                          inboxProvider.notificationList?[index].type == 1 ||
                                  inboxProvider.notificationList?[index].type ==
                                      4
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          focusColor: transparent,
                          highlightColor: transparent,
                          hoverColor: transparent,
                          splashColor: transparent,
                          onTap: () {
                            if (inboxProvider.notificationList?[index].type !=
                                1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Profile(
                                      isBottomBar: false,
                                      toUserId:
                                          inboxProvider
                                              .notificationList?[index]
                                              .userId
                                              .toString() ??
                                          "",
                                      toChannelId:
                                          inboxProvider
                                              .notificationList?[index]
                                              .channelId
                                              .toString() ??
                                          "",
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          child: MyText(
                            color: white,
                            text:
                                inboxProvider.notificationList?[index].title
                                    ?.toString() ??
                                "",
                            fontsizeNormal: Dimens.textMedium,
                            multilanguage: false,
                            maxline: 2,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.left,
                            fontstyle: FontStyle.normal,
                            fontwaight: FontWeight.w500,
                          ),
                        ),
                        inboxProvider.notificationList?[index].type == 1
                            ? Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints(minHeight: 0),
                              alignment: Alignment.centerLeft,
                              child: ExpandableText(
                                inboxProvider.notificationList?[index].message
                                        .toString() ??
                                    "",
                                expandText: "Read More",
                                collapseText: "Read less",
                                maxLines: 2,
                                expandOnTextTap: true,
                                collapseOnTextTap: true,
                                linkStyle: TextStyle(
                                  fontSize: Dimens.textDesc,
                                  fontStyle: FontStyle.normal,
                                  color: colorAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                                style: TextStyle(
                                  fontSize: Dimens.textSmall,
                                  fontStyle: FontStyle.normal,
                                  color: gray,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 13),
                    inboxProvider.notificationList?[index].type == 1 ||
                            inboxProvider.notificationList?[index].type == 4
                        ? const SizedBox.shrink()
                        : deleteButton(index: index),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child:
                    inboxProvider.notificationList?[index].type == 1 ||
                            inboxProvider.notificationList?[index].type == 4
                        ? deleteButton(index: index)
                        : MyNetworkImage(
                          width: 70,
                          height: 50,
                          imagePath:
                              inboxProvider
                                  .notificationList?[index]
                                  .contentImage
                                  .toString() ??
                              "",
                          fit: BoxFit.cover,
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget deleteButton({required index}) {
    return Consumer<InboxProvider>(
      builder: (context, inboxprovider, child) {
        if (inboxprovider.position == index &&
            inboxprovider.readnotificationloading) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: colorAccent,
              strokeWidth: 1,
            ),
          );
        } else {
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
                await inboxprovider.getReadNotification(
                  index,
                  inboxprovider.notificationList?[index].id?.toString() ?? "",
                  true,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: MyImage(
                width: 16,
                height: 16,
                imagePath: "ic_delete.png",
                color: colorAccent,
              ),
            ),
          );
        }
      },
    );
  }

  Widget shimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (BuildContext ctx, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(15),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidget.circular(width: 55, height: 55),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(width: 250, height: 8),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(width: 250, height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ==================================== Notification ==================================== */
}
