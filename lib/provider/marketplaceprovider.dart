import 'package:slike/model/marketplacemodel.dart' as product;
import 'package:flutter/material.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/model/categorymodel.dart' as category;

class MarketPlaceProvider extends ChangeNotifier {
  product.MarketPlaceModel marketPlaceModel = product.MarketPlaceModel();
  category.CategoryModel categorymodel = category.CategoryModel();
  SuccessModel successModel = SuccessModel();

  /* Pagination With Api Calling */
  List<product.Result>? marketplaceList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  bool loading = false;

  /* Video List Data */
  List<category.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;

  int catindex = 0;
  String? categoryId;

  selectCategory(int index, String catid) {
    catindex = index;
    categoryId = catid;
    printLog("catIndex====>$catindex");
    printLog("catId====>$categoryId");
    notifyListeners();
  }

  setLoading(bool isLoading) {
    categoryloading = isLoading;
    loading = isLoading;
    notifyListeners();
  }

  /* ============================== Caterory Start ============================== */

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
            categorydataList?.add(category.Result(id: 0, name: "Home"));
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

  clearCategory() {
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;
  }

  /* ============================== Category End ============================== */

  /* ============================== Get Market Place Product Start ============================== */

  Future<void> getMarketPlace(name, categoryId, pageNo) async {
    printLog("Call Api Provider:==> ${(marketPlaceModel.result?.length ?? 0)}");
    loading = true;
    marketPlaceModel = await ApiService().getMarketPlace(
      name,
      categoryId,
      pageNo,
    );
    if (marketPlaceModel.status == 200) {
      setPaginationData(
        marketPlaceModel.totalRows,
        marketPlaceModel.totalPage,
        marketPlaceModel.currentPage,
        marketPlaceModel.morePage,
      );
      if (marketPlaceModel.result != null &&
          (marketPlaceModel.result?.length ?? 0) > 0) {
        printLog(
          "MarketPlaceModel length :==> ${(marketPlaceModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $currentPage');
        if (marketPlaceModel.result != null &&
            (marketPlaceModel.result?.length ?? 0) > 0) {
          printLog(
            "MarketPlaceModel length :==> ${(marketPlaceModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (marketPlaceModel.result?.length ?? 0); i++) {
            marketplaceList?.add(
              marketPlaceModel.result?[i] ?? product.Result(),
            );
          }
          printLog(
            "MarketPlaceList length :==> ${(marketplaceList?.length ?? 0)}",
          );
          final Map<int, product.Result> postMap = {};
          marketplaceList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          marketplaceList = postMap.values.toList();
          printLog(
            "MarketPlaceList length :==> ${(marketplaceList?.length ?? 0)}",
          );
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPaginationData(
    int? totalRows,
    int? totalPage,
    int? currentPage,
    bool? morePage,
  ) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  clearData() {
    marketplaceList = [];
    marketplaceList?.clear();
    marketPlaceModel = product.MarketPlaceModel();
  }

  /* ============================== Get Market Place Product End ============================== */

  clearProvider() {
    marketPlaceModel = product.MarketPlaceModel();
    categorymodel = category.CategoryModel();
    successModel = SuccessModel();
    /* Pagination With Api Calling */
    marketplaceList = [];
    marketplaceList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    loading = false;
    /* Video List Data */
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
  }
}
