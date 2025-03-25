import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/utils.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  bool loading = false;

  ChatProvider({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  setLoading(bool value) {
    printLog("setLoading value ====> $value");
    loading = value;
    notifyListeners();
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage
        .ref()
        .child(FirestoreConstants.pathImages)
        .child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> addFieldsInFirestore(
    String collectionPath,
    String convId,
    String myFireId,
    String toFireId,
  ) async {
    if (await checkInFirestore(
      collectionPath,
      convId,
      FirestoreConstants.lastMessage,
    )) {
      printLog("============== TRUE ==============");
      await firebaseFirestore
          .collection(collectionPath)
          .doc(convId)
          .update({
            FirestoreConstants.convId: convId,
            FirestoreConstants.users: [myFireId, toFireId],
          })
          .onError((error, stackTrace) {
            printLog("addFieldInFirestore error ===> ${error.toString()}");
            printLog(
              "addFieldInFirestore stackTrace ===> ${stackTrace.toString()}",
            );
          });
    } else {
      printLog("============== FALSE ==============");
      await firebaseFirestore
          .collection(collectionPath)
          .doc(convId)
          .set({
            FirestoreConstants.convId: convId,
            FirestoreConstants.users: [myFireId, toFireId],
            FirestoreConstants.lastMessage: {
              FirestoreConstants.content: "",
              FirestoreConstants.idFrom: myFireId,
              FirestoreConstants.idTo: toFireId,
              FirestoreConstants.read: false,
              FirestoreConstants.timestamp:
                  DateTime.now().millisecondsSinceEpoch.toString(),
              FirestoreConstants.type: 0,
            },
          })
          .onError((error, stackTrace) {
            printLog("addFieldInFirestore error ===> ${error.toString()}");
            printLog(
              "addFieldInFirestore stackTrace ===> ${stackTrace.toString()}",
            );
          });
    }
  }

  Future<void> updateDataFirestore(
    String collectionPath,
    String docPath,
    Map<String, dynamic> dataNeedUpdate,
  ) async {
    printLog("collectionPath ===> $collectionPath");
    printLog("docPath ===> $docPath");
    await firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate)
        .onError((error, stackTrace) {
          printLog("updateDataFirestore error ===> ${error.toString()}");
          printLog(
            "updateDataFirestore stackTrace ===> ${stackTrace.toString()}",
          );
        });
  }

  Stream<QuerySnapshot>? getChatStream(String groupChatId, int limit) {
    printLog("getChatStream groupChatId ===> $groupChatId");
    if (groupChatId != "") {
      return firebaseFirestore
          .collection(FirestoreConstants.pathMessageCollection)
          .doc(groupChatId)
          .collection(groupChatId)
          .orderBy(FirestoreConstants.timestamp, descending: true)
          .limit(limit)
          .snapshots();
    } else {
      return null;
    }
  }

  Future sendMessage(
    String content,
    int type,
    String convoID,
    String currentUserId,
    String toUserId,
    String timestamp,
  ) async {
    final DocumentReference convoDoc = FirebaseFirestore.instance
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(convoID);

    convoDoc
        .update(<String, dynamic>{
          FirestoreConstants.lastMessage: <String, dynamic>{
            FirestoreConstants.idFrom: currentUserId,
            FirestoreConstants.idTo: toUserId,
            FirestoreConstants.timestamp: timestamp,
            FirestoreConstants.content: content,
            FirestoreConstants.read: false,
            FirestoreConstants.type: type,
          },
        })
        .then((dynamic success) {
          final DocumentReference messageDoc = FirebaseFirestore.instance
              .collection(FirestoreConstants.pathMessageCollection)
              .doc(convoID)
              .collection(convoID)
              .doc(timestamp);

          FirebaseFirestore.instance.runTransaction((
            Transaction transaction,
          ) async {
            transaction.set(messageDoc, <String, dynamic>{
              FirestoreConstants.idFrom: currentUserId,
              FirestoreConstants.idTo: toUserId,
              FirestoreConstants.timestamp:
                  DateTime.now().millisecondsSinceEpoch.toString(),
              FirestoreConstants.content: content,
              FirestoreConstants.read: false,
              FirestoreConstants.type: type,
            });
          });
        });
  }

  Future updateMessageRead(DocumentSnapshot? document, String convoID) async {
    printLog("updateMessageRead documentId ===> ${document?.id ?? ""}");
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(convoID)
        .collection(convoID)
        .doc(document?.id ?? "");
    documentReference.update(<String, dynamic>{FirestoreConstants.read: true});
  }

  Future<void> updateLastMessageStatus(String convoID) async {
    printLog("convoID ===> $convoID");
    await firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(convoID)
        .update({
          "${FirestoreConstants.lastMessage}.${FirestoreConstants.content}": "",
          "${FirestoreConstants.lastMessage}.${FirestoreConstants.timestamp}":
              DateTime.now().millisecondsSinceEpoch.toString(),
          "${FirestoreConstants.lastMessage}.${FirestoreConstants.read}": true,
        });
  }

  Future<bool> checkInFirestore(
    String collectionPath,
    String docId,
    String fieldName,
  ) async {
    var doc =
        await firebaseFirestore.collection(collectionPath).doc(docId).get();
    if (doc.exists) {
      if (doc.data()!.containsKey(fieldName)) {
        return true;
      }
      return false;
    }
    return false;
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
  static const video = 3;
}
