import 'package:flutter/material.dart';
import 'package:slike/model/searchmodel.dart';
import 'package:slike/webservice/apiservice.dart';

class SearchProvider extends ChangeNotifier {
  /* Search Api  */
  SearchModel searchModel = SearchModel();
  bool loading = false;

  getSearch(name, type) async {
    loading = true;
    searchModel = await ApiService().search(name, type);
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    /* Search Api  */
    loading = false;
    searchModel = SearchModel();
  }
}
