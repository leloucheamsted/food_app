import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slike/utils/firebaseconstant.dart';

class ChatMessageModel {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  bool read;
  int type;

  ChatMessageModel({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.read,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.read: read,
      FirestoreConstants.type: type,
    };
  }

  factory ChatMessageModel.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(FirestoreConstants.idFrom);
    String idTo = doc.get(FirestoreConstants.idTo);
    String timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    bool read = doc.get(FirestoreConstants.read);
    int type = doc.get(FirestoreConstants.type);
    return ChatMessageModel(
      idFrom: idFrom,
      idTo: idTo,
      timestamp: timestamp,
      content: content,
      read: read,
      type: type,
    );
  }
}
