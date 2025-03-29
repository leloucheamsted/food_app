import 'package:slike/model/getadsmodel.dart';
import 'package:slike/model/introscreenmodel.dart';
import 'package:slike/model/successmodel.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:slike/model/generalsettingmodel.dart';
import 'package:slike/model/loginmodel.dart';
import 'package:slike/webservice/apiservice.dart';

class GeneralProvider extends ChangeNotifier {
  SharedPre sharedPre = SharedPre();
  GeneralsettingModel generalsettingModel = GeneralsettingModel();
  IntroScreenModel introScreenModel = IntroScreenModel();
  LoginModel loginModel = LoginModel();
  bool socoalLoading = false;
  GetAdsModel getBannerAdsModel = GetAdsModel();
  GetAdsModel getInterstialAdsModel = GetAdsModel();
  GetAdsModel getRewardAdsModel = GetAdsModel();
  SuccessModel successModel = SuccessModel();
  bool loading = false;
  bool isProgressLoading = false;
  int duration = 0;
  /* Side Panel */
  bool isPanel = true;
  bool isNotification = false;
  bool isHover = false;
  String isHoverType = "";
  // bool isSelect = false;
  // String isSelectType = "";

  /* CustomAds Fields */
  bool showSkip = false;
  bool isCloseRewardAds = false;

  bool isLiteMode = false;
  bool get isDarkMode => isLiteMode;

  getGeneralsetting() async {
    loading = true;
    generalsettingModel = await ApiService().generalsetting();
    loading = false;
    notifyListeners();
  }

  getIntroPages() async {
    loading = true;
    introScreenModel = await ApiService().getOnboardingScreen();
    loading = false;
    notifyListeners();
  }

  login(
    String type,
    String email,
    String mobile,
    String devicetype,
    String devicetoken,
    String countrycode,
    String countryName,
    String firebaseId,
  ) async {
    loading = true;
    loginModel = await ApiService().login(
      type,
      email,
      mobile,
      devicetype,
      devicetoken,
      countrycode,
      countryName,
      firebaseId,
    );
    loading = false;
    notifyListeners();
  }

  Future<LoginModel> loginWithNam(String email, String password) async {
    loading = true;
    loginModel = await ApiService().loginWithName(email, password).then((value) {
      loading = false;
      notifyListeners();
      return value;
    });
    return loginModel;
  }

  setLoading(loading) {
    isProgressLoading = loading;
    notifyListeners();
  }

  /* get All Custom Ads Start */

  getAds(type) async {
    loading = true;
    if (type == 1) {
      getBannerAdsModel = await ApiService().getAds(type);
    } else if (type == 2) {
      getInterstialAdsModel = await ApiService().getAds(type);
    } else if (type == 3) {
      getRewardAdsModel = await ApiService().getAds(type);
    } else {
      printLog("Invalid Type");
    }

    loading = false;
    notifyListeners();
  }

  /* Ads Click And View Count APi Start */
  getAdsViewClickCount(
    adsType,
    adsId,
    diviceType,
    diviceToken,
    type,
    contentId,
  ) async {
    loading = true;
    successModel = await ApiService().adsViewClickCount(
      adsType,
      adsId,
      diviceType,
      diviceToken,
      type,
      contentId,
    );
    loading = false;
    notifyListeners();
  }

  /* Web App Methods */

  Future<void> getWebGeneralsetting(context) async {
    generalsettingModel = await ApiService().generalsetting();
    if (generalsettingModel.status == 200) {
      if (generalsettingModel.result != null) {
        for (var i = 0; i < (generalsettingModel.result?.length ?? 0); i++) {
          await sharedPre.save(
            generalsettingModel.result?[i].key.toString() ?? "",
            generalsettingModel.result?[i].value.toString() ?? "",
          );
        }
        /* Get Ads Init */
        if (context.mounted) {
          Utils.getCustomAdsStatus();
          Utils.getCurrencySymbol();
          Constant.userID = await sharedPre.read('userid');
          Constant.isAdsfree = await sharedPre.read('isAdsFree');
          Constant.isDownload = await sharedPre.read('isDownload');
          Constant.channelID = await sharedPre.read('channelid');
          Constant.channelName = await sharedPre.read('channelname');
          Constant.userImage = await sharedPre.read('image');
          Constant.isBuy = await sharedPre.read('userIsBuy');
          printLog("***********userId==> ${Constant.userID}");
          printLog("***********channelID==> ${Constant.channelID}");
          printLog("***********channelName==> ${Constant.channelName}");
        }
      }
    }

    /* Live Streaming END */
    notifyListeners();
  }

  getOnOffSidePanel(panel) {
    isPanel = panel;
    notifyListeners();
  }

  isHoverSideMenu(String type, bool hover) {
    isHoverType = type;
    isHover = hover;
    notifyListeners();
  }

  clearHover() {
    isHover = false;
    isHoverType = "";
    notifyListeners();
  }

  getNotificationSectionShowHide(notification) {
    isNotification = notification;
    notifyListeners();
  }

  /* Reward Ads Methods */

  getSetRewardAds({close, skip}) {
    isCloseRewardAds = close;
    showSkip = skip;
    notifyListeners();
  }

  clearProvider() {
    isCloseRewardAds = false;
    showSkip = false;
  }
}
