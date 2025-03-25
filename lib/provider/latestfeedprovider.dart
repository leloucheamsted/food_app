import 'package:flutter/material.dart';
import 'package:slike/model/subscribechannelpostmodel.dart' as subscribepost;
import 'package:slike/model/subscribechannelpostmodel.dart' as mostviewpost;
import 'package:slike/model/subscribechannelpostmodel.dart' as postbycategory;
import 'package:slike/model/categorymodel.dart' as category;
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';

class LatestFeedProvider extends ChangeNotifier {
  /* FeedList 1 */
  subscribepost.SubscribeChannelPostModel subscribeChannelPostModel =
      subscribepost.SubscribeChannelPostModel();
  bool subscribeChannelPostLoading = false,
      subscribeChannelPostLoadMore = false;
  bool? subscribeChannelPostisMorePage;
  int? subscribeChannelPosttotalRows,
      subscribeChannelPosttotalPage,
      subscribeChannelPostcurrentPage;
  List<subscribepost.Result>? subscribeChannelPostList = [];

  /* FeedList 2 */
  mostviewpost.SubscribeChannelPostModel mostViewPostModel =
      mostviewpost.SubscribeChannelPostModel();
  bool? mostviewpostisMorePage;
  bool mostviewpostLoading = false, mostviewpostLoadMore = false;
  int? mostviewposttotalRows, mostviewposttotalPage, mostviewpostcurrentPage;
  List<mostviewpost.Result>? mostViewPostList = [];

  /* FeedList 3 */
  postbycategory.SubscribeChannelPostModel postByCategoryModel =
      mostviewpost.SubscribeChannelPostModel();
  int? postbycategorytotalRows,
      postbycategorytotalPage,
      postbycategorycurrentPage;
  bool? postbycategoryisMorePage;
  bool postbycategoryLoading = false, postbycategoryLoadMore = false;
  List<postbycategory.Result>? postByCategoryList = [];

  /* Category */
  /* Category List */
  category.CategoryModel categorymodel = category.CategoryModel();
  List<category.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;
  bool uploadLoading = false;
  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;
  int? categoryId;

  setLoading(bool isLoading) {
    subscribeChannelPostLoading = isLoading;
    mostviewpostLoading = isLoading;
    postbycategoryLoading = isLoading;
    notifyListeners();
  }

  /* SubscribeChannelPost Api */
  Future<void> getSubscribeChannelPost(pageNo) async {
    subscribeChannelPostLoading = true;
    subscribeChannelPostModel = await ApiService().subcribeChannelPost(pageNo);
    if (subscribeChannelPostModel.status == 200) {
      setSubscribePostPaginationData(
        subscribeChannelPostModel.totalRows,
        subscribeChannelPostModel.totalPage,
        subscribeChannelPostModel.currentPage,
        subscribeChannelPostModel.morePage,
      );
      if (subscribeChannelPostModel.result != null &&
          (subscribeChannelPostModel.result?.length ?? 0) > 0) {
        subscribeChannelPostList?.addAll(
          subscribeChannelPostModel.result ?? [],
        );
        printLog(
          "SubscribeChannelPostList length :==> ${(subscribeChannelPostList?.length ?? 0)}",
        );
        setSubscribePostLoadMore(false);
      }
    }
    subscribeChannelPostLoading = false;
    notifyListeners();
  }

  setSubscribePostPaginationData(
    int? subscribeChannelPosttotalRows,
    int? subscribeChannelPosttotalPage,
    int? subscribeChannelPostcurrentPage,
    bool? subscribeChannelPostisMorePage,
  ) {
    this.subscribeChannelPostcurrentPage = subscribeChannelPostcurrentPage;
    this.subscribeChannelPosttotalRows = subscribeChannelPosttotalRows;
    this.subscribeChannelPosttotalPage = subscribeChannelPosttotalPage;
    subscribeChannelPostisMorePage = subscribeChannelPostisMorePage;
    notifyListeners();
  }

  setSubscribePostLoadMore(subscribeChannelPostLoadMore) {
    this.subscribeChannelPostLoadMore = subscribeChannelPostLoadMore;
    notifyListeners();
  }
  /* SubscribeChannelPost Api */

  /* MostViewPost Api */
  Future<void> getMostViewPost(pageNo) async {
    mostviewpostLoading = true;
    mostViewPostModel = await ApiService().mostViewPost(pageNo);
    if (mostViewPostModel.status == 200) {
      setMostViewPostPaginationData(
        mostViewPostModel.totalRows,
        mostViewPostModel.totalPage,
        mostViewPostModel.currentPage,
        mostViewPostModel.morePage,
      );
      if (mostViewPostModel.result != null &&
          (mostViewPostModel.result?.length ?? 0) > 0) {
        mostViewPostList?.addAll(mostViewPostModel.result ?? []);
        printLog(
          "MostViewPostList length :==> ${(mostViewPostList?.length ?? 0)}",
        );
        setMostViewPostLoadMore(false);
      }
    }
    mostviewpostLoading = false;
    notifyListeners();
  }

  setMostViewPostPaginationData(
    int? mostviewposttotalRows,
    int? mostviewposttotalPage,
    int? mostviewpostcurrentPage,
    bool? subscribeChannelPostisMorePage,
  ) {
    this.mostviewpostcurrentPage = mostviewpostcurrentPage;
    this.mostviewposttotalRows = mostviewposttotalRows;
    this.mostviewposttotalPage = mostviewposttotalPage;
    mostviewpostisMorePage = mostviewpostisMorePage;
    notifyListeners();
  }

  setMostViewPostLoadMore(mostviewpostLoadMore) {
    this.mostviewpostLoadMore = mostviewpostLoadMore;
    notifyListeners();
  }
  /* MostViewPost Api */

  /* getPostByCategory Api */
  Future<void> getPostByCategory(categoryId, pageNo) async {
    postbycategoryLoading = true;
    postByCategoryModel = await ApiService().postByCategory(categoryId, pageNo);
    if (mostViewPostModel.status == 200) {
      setPostByCategoryPaginationData(
        postByCategoryModel.totalRows,
        postByCategoryModel.totalPage,
        postByCategoryModel.currentPage,
        postByCategoryModel.morePage,
      );
      if (postByCategoryModel.result != null &&
          (postByCategoryModel.result?.length ?? 0) > 0) {
        postByCategoryList?.addAll(postByCategoryModel.result ?? []);
        printLog(
          "PostByCategoryList length :==> ${(postByCategoryList?.length ?? 0)}",
        );
        setPostByCategoryLoadMore(false);
      }
    }
    postbycategoryLoading = false;
    notifyListeners();
  }

  setPostByCategoryPaginationData(
    int? postbycategorytotalRows,
    int? postbycategorytotalPage,
    int? postbycategorycurrentPage,
    bool? postbycategoryisMorePage,
  ) {
    this.postbycategorycurrentPage = postbycategorycurrentPage;
    this.postbycategorytotalRows = postbycategorytotalRows;
    this.postbycategorytotalPage = postbycategorytotalPage;
    postbycategoryisMorePage = postbycategoryisMorePage;
    notifyListeners();
  }

  setPostByCategoryLoadMore(postbycategoryLoadMore) {
    this.postbycategoryLoadMore = postbycategoryLoadMore;
    notifyListeners();
  }
  /* getPostByCategory Api */

  /* CategoryList Api Start */
  List<int> selectedCategoryIds = [0];
  void toggleCategory(int id) {
    if (id == 0) {
      selectedCategoryIds = [0];
    } else {
      if (selectedCategoryIds.contains(id)) {
        selectedCategoryIds.remove(id);
      } else {
        selectedCategoryIds.add(id);
      }
      if (selectedCategoryIds.isNotEmpty) {
        selectedCategoryIds.remove(0);
      }
    }
    if (selectedCategoryIds.isEmpty) {
      selectedCategoryIds = [0];
    }

    notifyListeners();
  }

  void selectCategory(int index, int catId) {
    _selectedIndex = index;
    categoryId = catId;
    notifyListeners();
  }

  Future<void> getCategory(pageNo) async {
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
        printLog('Now on page ==========> $categorycurrentPage');
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
            "CategoryList length :==> ${(categorydataList?.length ?? 0)}",
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
  /* CategoryList Api End */

  /* ======================== Clear Provider ================================ */

  clearPostByCategory() {
    /* FeedList 3 */
    postByCategoryModel = mostviewpost.SubscribeChannelPostModel();
    postbycategorytotalRows;
    postbycategorytotalPage;
    postbycategorycurrentPage;
    postbycategoryisMorePage;
    postbycategoryLoading = false;
    postbycategoryLoadMore = false;
    postByCategoryList = [];
    postByCategoryList?.clear();
  }

  clearProvider() {
    /* FeedList 1 */
    subscribeChannelPostModel = subscribepost.SubscribeChannelPostModel();
    subscribeChannelPostLoading = false;
    subscribeChannelPostLoadMore = false;
    subscribeChannelPostisMorePage;
    subscribeChannelPosttotalRows;
    subscribeChannelPosttotalPage;
    subscribeChannelPostcurrentPage;
    subscribeChannelPostList = [];
    subscribeChannelPostList?.clear();
    /* FeedList 2 */
    mostViewPostModel = mostviewpost.SubscribeChannelPostModel();
    mostviewpostisMorePage;
    mostviewpostLoading = false;
    mostviewpostLoadMore = false;
    mostviewposttotalRows;
    mostviewposttotalPage;
    mostviewpostcurrentPage;
    mostViewPostList = [];
    mostViewPostList?.clear();
    /* FeedList 3 */
    postByCategoryModel = mostviewpost.SubscribeChannelPostModel();
    postbycategorytotalRows;
    postbycategorytotalPage;
    postbycategorycurrentPage;
    postbycategoryisMorePage;
    postbycategoryLoading = false;
    postbycategoryLoadMore = false;
    postByCategoryList = [];
    postByCategoryList?.clear();
    /* Category  */
    categorymodel = category.CategoryModel();
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;
    uploadLoading = false;
    _selectedIndex = -1;
    _selectedIndex;
    categoryId;
  }
}
