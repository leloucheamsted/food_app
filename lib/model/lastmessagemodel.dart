import 'package:slike/utils/firebaseconstant.dart';
import 'package:slike/utils/utils.dart';

class LastMessage {
  String content;
  String idFrom;
  String idTo;
  bool read;
  String timestamp;
  int type;

  LastMessage({
    required this.content,
    required this.idFrom,
    required this.idTo,
    required this.read,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.content: content,
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.read: read,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.type: type,
    };
  }

  factory LastMessage.fromMap(Map<String, dynamic> doc) {
    String content = "";
    String idFrom = "";
    String idTo = "";
    bool read;
    String timestamp = "";
    int type;
    try {
      content = doc[FirestoreConstants.content] ?? "";
    } catch (e) {
      printLog("content Exception ====> $e");
      content = "";
    }
    try {
      idFrom = doc[FirestoreConstants.idFrom] ?? "";
    } catch (e) {
      printLog("idFrom Exception ====> $e");
      idFrom = "";
    }
    try {
      idTo = doc[FirestoreConstants.idTo] ?? "";
    } catch (e) {
      printLog("idTo Exception ====> $e");
      idTo = "";
    }
    try {
      read = doc[FirestoreConstants.read] ?? "";
    } catch (e) {
      printLog("read Exception ====> $e");
      read = false;
    }
    try {
      timestamp = doc[FirestoreConstants.timestamp] ?? "";
    } catch (e) {
      printLog("timestamp Exception ====> $e");
      timestamp = "";
    }
    try {
      type = doc[FirestoreConstants.type] ?? "";
    } catch (e) {
      printLog("type Exception ====> $e");
      type = 0;
    }
    return LastMessage(
      content: content,
      idFrom: idFrom,
      idTo: idTo,
      read: read,
      timestamp: timestamp,
      type: type,
    );
  }
}
