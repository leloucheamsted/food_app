import 'package:slike/model/addcontenttohistorymodel.dart';
import 'package:slike/model/addviewmodel.dart';
import 'package:slike/model/removecontenttohistorymodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:slike/webservice/apiservice.dart';

class PlayerProvider extends ChangeNotifier {
  AddViewModel addViewModel = AddViewModel();

  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();

  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();
  bool loading = false;

  Future<void> addVideoView(contenttype, contentid) async {
    printLog("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    printLog("addPostView status :==> ${addViewModel.status}");
    printLog("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  Future<void> addContentHistory(
    contenttype,
    contentid,
    stoptime,
    episodeid,
  ) async {
    loading = true;
    addcontenttoHistoryModel = await ApiService().addContentToHistory(
      contenttype,
      contentid,
      stoptime,
      episodeid,
    );
    loading = false;
  }

  Future<void> removeContentHistory(contenttype, contentid, episodeid) async {
    loading = true;
    removeContentHistoryModel = await ApiService().removeContentToHistory(
      contenttype,
      contentid,
      episodeid,
    );
    loading = false;
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    addViewModel = AddViewModel();
    addcontenttoHistoryModel = AddcontenttoHistoryModel();
    removeContentHistoryModel = RemoveContentHistoryModel();
    loading = false;
  }
}
