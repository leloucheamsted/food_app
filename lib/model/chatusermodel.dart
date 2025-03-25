import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/utils.dart';

class ChatUserModel {
  String biodata;
  String chattingWith;
  String createdAt;
  String pushToken;
  String email;
  String name;
  String photoUrl;
  String userid;
  String appuserid;
  String appchannelid;
  String userName;

  ChatUserModel({
    required this.biodata,
    required this.chattingWith,
    required this.createdAt,
    required this.pushToken,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.userid,
    required this.appuserid,
    required this.appchannelid,
    required this.userName,
  });

  Map<String, String> toJson() {
    return {
      FirestoreConstants.bioData: biodata,
      FirestoreConstants.chattingWith: chattingWith,
      FirestoreConstants.createdAt: createdAt,
      FirestoreConstants.deviceToken: pushToken,
      FirestoreConstants.email: email,
      FirestoreConstants.name: name,
      FirestoreConstants.profileurl: photoUrl,
      FirestoreConstants.userid: userid,
      FirestoreConstants.appuserid: appuserid,
      FirestoreConstants.appchannelid: appchannelid,
      FirestoreConstants.username: userName,
    };
  }

  factory ChatUserModel.fromDocument(DocumentSnapshot doc) {
    String biodata = "";
    String chattingWith = "";
    String createdAt = "";
    String pushToken = "";
    String email = "";
    String name = "";
    String photoUrl = "";
    String userid = "";
    String appuserid = "";
    String appchannelid = "";
    String userName = "";
    printLog("doc ====> ${doc.id}");
    try {
      biodata = doc[FirestoreConstants.bioData] ?? "";
    } catch (e) {
      printLog("biodata Exception ====> $e");
      biodata = "";
    }
    try {
      chattingWith = doc[FirestoreConstants.chattingWith] ?? "";
    } catch (e) {
      printLog("chattingWith Exception ====> $e");
      chattingWith = "";
    }
    try {
      pushToken = doc[FirestoreConstants.deviceToken] ?? "";
    } catch (e) {
      printLog("pushToken Exception ====> $e");
      pushToken = "";
    }
    try {
      createdAt = doc[FirestoreConstants.createdAt] ?? "";
    } catch (e) {
      printLog("createdAt Exception ====> $e");
      createdAt = "";
    }
    try {
      email = doc[FirestoreConstants.email] ?? "";
    } catch (e) {
      printLog("email Exception ====> $e");
      email = "";
    }
    try {
      name = doc[FirestoreConstants.name] ?? "";
    } catch (e) {
      printLog("name Exception ====> $e");
      name = "";
    }
    try {
      photoUrl = doc[FirestoreConstants.profileurl] ?? "";
    } catch (e) {
      printLog("photoUrl Exception ====> $e");
      photoUrl = Constant.userPlaceholder;
    }
    try {
      userid = doc[FirestoreConstants.userid] ?? "";
    } catch (e) {
      printLog("userid Exception ====> $e");
      userid = "";
    }
    try {
      appuserid = doc[FirestoreConstants.appuserid] ?? "";
    } catch (e) {
      printLog("userid Exception ====> $e");
      appuserid = "";
    }
    try {
      appchannelid = doc[FirestoreConstants.appchannelid] ?? "";
    } catch (e) {
      printLog("userid Exception ====> $e");
      appchannelid = "";
    }
    try {
      userName = doc[FirestoreConstants.username] ?? "";
    } catch (e) {
      printLog("userName Exception ====> $e");
      userName = "";
    }
    return ChatUserModel(
      biodata: biodata,
      chattingWith: chattingWith,
      createdAt: createdAt,
      pushToken: pushToken,
      email: email,
      name: name,
      photoUrl: photoUrl,
      userid: userid,
      appuserid: appuserid,
      appchannelid: appchannelid,
      userName: userName,
    );
  }
}
