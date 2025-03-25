import 'package:flutter/material.dart';
import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:slike/model/addremovesubscribemodel.dart';
import 'package:slike/model/marketplacedetailmodel.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/webservice/apiservice.dart';

class MarketPlaceDetailProvider extends ChangeNotifier {
  MarketPlaceDetailModel marketPlaceDetailModel = MarketPlaceDetailModel();
  bool loading = false, addCommentLoading = false;

  /* Add Remove Subscriber */
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();

  /* Delete Post Comment */
  SuccessModel successModel = SuccessModel();

  /* Add Remove Like Difood_app */
  AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel =
      AddRemoveLikeDifood_appModel();

  getShopDetail(marketPlaceId) async {
    loading = true;
    marketPlaceDetailModel = await ApiService().productDetail(marketPlaceId);
    loading = false;
    notifyListeners();
  }

  /* ================================== Add Comment Post Start ================================== */

  addRemoveSubscriber(touserid, type) {
    if (marketPlaceDetailModel.result?[0].userId.toString() ==
        touserid.toString()) {
      if ((marketPlaceDetailModel.result?[0].isSubscribe ?? 0) == 0) {
        marketPlaceDetailModel.result?[0].isSubscribe = 1;
      } else {
        marketPlaceDetailModel.result?[0].isSubscribe = 0;
      }
    }
    notifyListeners();
    getaddremoveSubscribe(touserid, type);
  }

  Future<void> getaddremoveSubscribe(touserid, type) async {
    addremoveSubscribeModel = await ApiService().addremoveSubscribe(
      touserid,
      type,
    );
  }

  profileAddRemoveSubscription(touserid, type) async {
    if ((marketPlaceDetailModel.result?[0].isSubscribe ?? 0) == 0) {
      marketPlaceDetailModel.result?[0].isSubscribe = 1;
    } else {
      marketPlaceDetailModel.result?[0].isSubscribe = 0;
    }

    notifyListeners();
    await getaddremoveSubscribe(touserid, type);
  }

  /* ================================== Add Comment Post End ================================== */

  clearProvider() {
    marketPlaceDetailModel = MarketPlaceDetailModel();
    loading = false;
    addCommentLoading = false;

    /* Add Remove Subscriber */
    addremoveSubscribeModel = AddremoveSubscribeModel();
    /* Delete Post Comment */
    successModel = SuccessModel();
    /* Add Remove Like Difood_app */
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel();
  }
}
