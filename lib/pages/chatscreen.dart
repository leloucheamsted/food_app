import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slike/model/chatmessagemodel.dart';
import 'package:slike/model/chatusermodel.dart';
import 'package:slike/pages/fullphotopage.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/provider/chatprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';

class Chatscreen extends StatefulWidget {
  final String? toUserName,
      toChatId,
      profileImg,
      bioData,
      number,
      appuserId,
      appchannelId;

  const Chatscreen({
    super.key,
    required this.toUserName,
    required this.toChatId,
    required this.profileImg,
    required this.bioData,
    required this.appuserId,
    required this.appchannelId,
    this.number,
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  SharedPre sharePref = SharedPre();
  List<QueryDocumentSnapshot>? listMessage = [];
  ChatUserModel? toUserData;
  ChatUserModel? currentUserData;
  int _limit = 20;
  int limitIncrement = 20;
  String groupChatId = "", currentUserId = "";

  File? imageFile;
  bool isLoading = false;
  String imageUrl = "";

  late ChatProvider chatProvider;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  Future getUserData() async {
    await chatProvider.setLoading(true);

    var userDetails =
        await FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(widget.toChatId)
            .get();
    toUserData = ChatUserModel.fromDocument(userDetails);
    printLog("toUserData ====> ${toUserData?.name}");
    printLog("toUserData ====> ${toUserData?.pushToken}");

    /* Current User Data */
    currentUserId = await sharePref.read("firebaseid");
    printLog("currentUserId ====> $currentUserId");
    var cUserDetails =
        await FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(currentUserId)
            .get();
    currentUserData = ChatUserModel.fromDocument(cUserDetails);
    readLocal();
  }

  @override
  void initState() {
    printLog("Constant.accessToken ====> ${Constant.accessToken}");
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _scrollToBottom();
      getUserData();
    });
    listScrollController.addListener(_scrollListener);
    super.initState();
    _scrollToBottom();
  }

  _scrollListener() async {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= (listMessage?.length ?? 0)) {
      setState(() {
        _limit += limitIncrement;
      });
    }
  }

  void _scrollToBottom() {
    if (listScrollController.hasClients) {
      listScrollController.animateTo(
        listScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future readLocal() async {
    printLog("currentUserId ===========> $currentUserId");
    printLog("toChatId ================> ${widget.toChatId}");
    if (currentUserId.compareTo(widget.toChatId ?? "") > 0) {
      groupChatId = '$currentUserId-${widget.toChatId}';
    } else {
      groupChatId = '${widget.toChatId}-$currentUserId';
    }
    printLog("groupChatId ==============> $groupChatId");

    chatProvider.addFieldsInFirestore(
      FirestoreConstants.pathMessageCollection,
      groupChatId,
      currentUserId,
      widget.toChatId ?? "",
    );

    await chatProvider
        .updateDataFirestore(
          FirestoreConstants.pathUserCollection,
          currentUserId,
          {FirestoreConstants.chattingWith: widget.toChatId},
        )
        .whenComplete(() async {
          await chatProvider.setLoading(false);
        });

    Future.delayed(Duration.zero).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: colorPrimary,
        leading: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Align(
              alignment: Alignment.center,
              child: MyImage(
                width: 30,
                height: 30,
                imagePath: "ic_roundback.png",
              ),
            ),
          ),
        ),
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Profile(
                    isBottomBar: false,
                    toUserId: widget.appuserId ?? '',
                    toChannelId: widget.appchannelId ?? '',
                  );
                },
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MyNetworkImage(
                    imagePath: widget.profileImg ?? "",
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: MyText(
                  fontsizeWeb: Dimens.textDesc,
                  color: white,
                  text: widget.toUserName ?? "",
                  fontsizeNormal: 16,
                  fontwaight: FontWeight.w600,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.start,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: onBackPress,
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Column(
            children: [
              // List of messages
              buildListMessage(),

              // Input content
              buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      Utils.showSnackbar(context, e.message ?? e.toString(), false);
    }
  }

  Future onSendMessage(String content, int type) async {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      await chatProvider.sendMessage(
        content,
        type,
        groupChatId,
        currentUserId,
        widget.toChatId ?? "",
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
      if (listScrollController.hasClients) {
        listScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      ApiService().sendFCMPushNoti(
        currentUserData,
        currentUserId,
        widget.toChatId,
        toUserData,
        content,
      );
    } else {
      Utils.showSnackbar(context, "Nothing to send!", false);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      if (!document[FirestoreConstants.read] &&
          document[FirestoreConstants.idTo] == currentUserId) {
        chatProvider.updateMessageRead(document, groupChatId);
        chatProvider.updateLastMessageStatus(groupChatId);
      }
      ChatMessageModel messageChat = ChatMessageModel.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            messageChat.type == TypeMessage.text
                // Text
                ? Container(
                  constraints: BoxConstraints(
                    minWidth: 0,
                    maxWidth:
                        kIsWeb ? 200 : MediaQuery.of(context).size.width * 0.5,
                  ),
                  margin: EdgeInsets.only(
                    bottom: isLastMessageRight(index) ? 20 : 10,
                    right: 10,
                    top: 3,
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: const BoxDecoration(
                    color: colorAccent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0),
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    messageChat.content,
                    style: GoogleFonts.inter(
                      fontSize: Dimens.textMedium,
                      fontStyle: FontStyle.normal,
                      color: black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )
                : messageChat.type == TypeMessage.image
                // Image
                ? Container(
                  margin: EdgeInsets.only(
                    bottom: isLastMessageRight(index) ? 20 : 10,
                    right: 10,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  FullPhotoPage(url: messageChat.content),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0),
                      ),
                    ),
                    child: Material(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        messageChat.content,
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: const BoxDecoration(
                              color: gray,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colorPrimary,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return Material(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.asset(
                              'images/img_not_available.jpeg',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                // Sticker
                : Container(
                  margin: EdgeInsets.only(
                    bottom: isLastMessageRight(index) ? 20 : 10,
                    right: 10,
                  ),
                  child: Image.asset(
                    'images/${messageChat.content}.gif',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
          ],
        );
      } else {
        // Left (Others message)
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          widget.profileImg ?? "",
                          loadingBuilder: (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: colorPrimary,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 35,
                              color: gray,
                            );
                          },
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Container(
                        constraints: BoxConstraints(
                          minWidth: 0,
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        margin: const EdgeInsets.only(left: 10, top: 3),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: const BoxDecoration(
                          color: colorPrimaryDark,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          messageChat.content,
                          style: GoogleFonts.inter(
                            fontSize: Dimens.textMedium,
                            fontStyle: FontStyle.normal,
                            color: white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )
                      : messageChat.type == TypeMessage.image
                      ? Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        FullPhotoPage(url: messageChat.content),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(0),
                            ),
                          ),
                          child: Material(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: gray,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colorPrimaryDark,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, object, stackTrace) => Material(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: MyImage(
                                      imagePath: "",
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                      : Container(
                        margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20 : 10,
                          right: 10,
                        ),
                        child: Image.asset(
                          'images/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                    margin: const EdgeInsets.only(left: 50, top: 5, bottom: 5),
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(messageChat.timestamp),
                        ),
                      ),
                      style: const TextStyle(
                        color: gray,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage?[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage?[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> onBackPress(didPop) async {
    if (didPop) return;
    await chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: null},
    );

    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Log navigator stack after pop

    return;
  }

  Widget buildLoading() {
    return Positioned(
      child:
          isLoading
              ? Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(color: colorPrimary),
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      height: 53,
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: white),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.add, size: 15, color: white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Edit text
                  Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      controller: textEditingController,
                      onFieldSubmitted: (value) {
                        if (textEditingController.text.toString().isNotEmpty) {
                          onSendMessage(
                            textEditingController.text,
                            TypeMessage.text,
                          );
                        }
                      },
                      textInputAction: TextInputAction.done,
                      cursorColor: white,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontStyle: FontStyle.normal,
                        color: white,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: Locales.string(context, "typemessage"),
                        hintStyle: GoogleFonts.montserrat(
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
                    ),
                  ),
                  // Button send image
                ],
              ),
            ),
          ),

          // Button send message
          InkWell(
            onTap: () {
              onSendMessage(textEditingController.text, TypeMessage.text);
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              child: const Icon(Icons.send, color: white, size: 25),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Expanded(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.loading) {
            return Utils.pageLoader(context);
          } else {
            return SizedBox(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChatStream(groupChatId, _limit),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return Center(
                      child: MyText(
                        fontsizeWeb: Dimens.textDesc,
                        color: colorAccent,
                        text: "somethingwentwronge",
                        textalign: TextAlign.center,
                        multilanguage: true,
                        fontstyle: FontStyle.normal,
                        fontsizeNormal: Dimens.textDesc,
                        fontwaight: FontWeight.normal,
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    listMessage = snapshot.data?.docs;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(); // Scroll to the bottom when new data arrives.
                    });
                    if ((listMessage?.length ?? 0) > 0) {
                      return Container(
                        constraints: const BoxConstraints(minHeight: 0),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: listScrollController,
                          itemCount: snapshot.data?.docs.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return Container(
                              constraints: const BoxConstraints(minHeight: 0),
                              child: buildItem(
                                index,
                                snapshot.data?.docs[index],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: MyText(
                          fontsizeWeb: Dimens.textDesc,
                          text: "nomessage",
                          color: colorPrimaryDark,
                          fontstyle: FontStyle.normal,
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.w500,
                        ),
                      );
                    }
                  } else {
                    // Loading
                    return Utils.pageLoader(context);
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}
