import 'dart:io';
import 'package:slike/model/categorymodel.dart' as category;
import 'package:flutter/material.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';

class UploadProductProvider extends ChangeNotifier {
  /* Upload Product Field */
  SuccessModel successModel = SuccessModel();
  bool uploadLoading = false;

  /* Category Field */
  category.CategoryModel categorymodel = category.CategoryModel();
  List<category.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;

  int catindex = 0;
  String? categoryId;
  String? categoryName;

  /* isExpand */
  bool isExpanded = true;

  /* ============================== Caterory Start ============================== */

  selectCategory(int index, catid, name) {
    catindex = index;
    categoryId = catid;
    categoryName = name;
    notifyListeners();
  }

  manageExpandableController() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  Future<void> getVideoCategory(pageNo) async {
    categoryloading = true;
    categorymodel = await ApiService().videoCategory(pageNo);
    if (categorymodel.status == 200) {
      setCategoryPaginationData(
        categorymodel.totalRows,
        categorymodel.totalPage,
        categorymodel.currentPage,
        categorymodel.morePage,
      );
      if (categorymodel.result != null &&
          (categorymodel.result?.length ?? 0) > 0) {
        printLog(
          "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}",
        );
        if (categorymodel.result != null &&
            (categorymodel.result?.length ?? 0) > 0) {
          printLog(
            "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (categorymodel.result?.length ?? 0); i++) {
            categorydataList?.add(
              categorymodel.result?[i] ?? category.Result(),
            );
          }
          final Map<int, category.Result> postMap = {};
          categorydataList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          categorydataList = postMap.values.toList();
          printLog(
            "CategoryModel length :==> ${(categorydataList?.length ?? 0)}",
          );
          setCategoryLoadMore(false);
        }
      }
    }
    categoryloading = false;
    notifyListeners();
  }

  setCategoryPaginationData(
    int? categorytotalRows,
    int? categorytotalPage,
    int? categorycurrentPage,
    bool? videolistisMorePage,
  ) {
    this.categorycurrentPage = categorycurrentPage;
    this.categorytotalRows = categorytotalRows;
    this.categorytotalPage = categorytotalPage;
    categoryisMorePage = categoryisMorePage;
    notifyListeners();
  }

  setCategoryLoadMore(categoryloadMore) {
    this.categoryloadMore = categoryloadMore;
    notifyListeners();
  }

  /* ============================== Category End ============================== */

  /* ======================== Product Upload Api ======================== */

  uploadProduct(
    productName,
    categoryId,
    price,
    disciption,
    url,
    File image,
  ) async {
    uploadLoading = true;
    successModel = await ApiService().uploadProduct(
      productName,
      categoryId,
      price,
      disciption,
      url,
      image,
    );
    uploadLoading = false;
    notifyListeners();
  }

  /* ======================== Product Upload Api ======================== */

  clearProvider() {
    /* Upload Product Field */
    successModel = SuccessModel();
    uploadLoading = false;

    /* Category Field */
    categorymodel = category.CategoryModel();
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;

    catindex = 0;
    categoryId;

    /* isExpand */
    isExpanded = true;
  }
}
