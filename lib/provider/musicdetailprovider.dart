import 'package:slike/model/addcontenttohistorymodel.dart';
import 'package:slike/model/addremovelikedislikemodel.dart';
import 'package:slike/model/addviewmodel.dart';
import 'package:slike/model/episodebyplaylistmodel.dart' as playlist;
import 'package:slike/model/episodebyplaylistmodel.dart';
import 'package:slike/model/episodebypodcastmodel.dart' as podcast;
import 'package:slike/model/episodebypodcastmodel.dart';
import 'package:slike/model/episodebyradio.dart' as radio;
import 'package:slike/model/episodebyradio.dart';
import 'package:slike/model/getrelatedmusicmodel.dart' as relatedmusic;
import 'package:slike/model/getrelatedmusicmodel.dart';
import 'package:slike/model/removecontenttohistorymodel.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class MusicDetailProvider extends ChangeNotifier {
  EpidoseByPodcastModel epidoseByPodcastModel = EpidoseByPodcastModel();
  EpidoseByRadioModel epidoseByRadioModel = EpidoseByRadioModel();
  EpisodebyplaylistModel episodebyplaylistModel = EpisodebyplaylistModel();
  AddViewModel addViewModel = AddViewModel();
  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();
  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();
  AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModel =
      AddRemoveLikeDifood_appModel();
  RelatedMusicModel relatedMusicModel = RelatedMusicModel();

  int tabindex = 0;
  bool isexpend = false;
  String istype = "episode";
  double isheight = Dimens.musicdetailAnimateContainerheightNormal;

  List<podcast.Result>? podcastEpisodeList = [];
  int? podcasttotalRows, podcasttotalPage, podcastcurrentPage;
  bool? podcastisMorePage;

  List<playlist.Result>? playlistEpisodeList = [];
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistisMorePage;

  List<radio.Result>? radioEpisodeList = [];
  int? radiototalRows, radiototalPage, radiocurrentPage;
  bool? radioisMorePage;

  List<relatedmusic.Result>? relatedMusicList = [];
  int? relatedMusictotalRows, relatedMusictotalPage, relatedMusiccurrentPage;
  bool? relatedMusicisMorePage;

  bool loadmore = false, loading = false;

  /* Podcast Episode */
  Future<void> getEpisodeByPodcast(podcastId, pageNo) async {
    loading = true;
    epidoseByPodcastModel = await ApiService().episodeByPodcast(
      podcastId,
      pageNo,
    );
    if (epidoseByPodcastModel.status == 200) {
      setPodcastPaginationData(
        epidoseByPodcastModel.totalRows,
        epidoseByPodcastModel.totalPage,
        epidoseByPodcastModel.currentPage,
        epidoseByPodcastModel.morePage,
      );
      if (epidoseByPodcastModel.result != null &&
          (epidoseByPodcastModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $playlistcurrentPage');
        if (epidoseByPodcastModel.result != null &&
            (epidoseByPodcastModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}",
          );
          for (
            var i = 0;
            i < (epidoseByPodcastModel.result?.length ?? 0);
            i++
          ) {
            podcastEpisodeList?.add(
              epidoseByPodcastModel.result?[i] ?? podcast.Result(),
            );
          }
          final Map<int, podcast.Result> postMap = {};
          podcastEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          podcastEpisodeList = postMap.values.toList();
          printLog(
            "Podcast EpisodeList length :==> ${(podcastEpisodeList?.length ?? 0)}",
          );
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPodcastPaginationData(
    int? podcasttotalRows,
    int? podcasttotalPage,
    int? podcastcurrentPage,
    bool? podcastisMorePage,
  ) {
    this.podcastcurrentPage = podcastcurrentPage;
    this.podcasttotalRows = podcasttotalRows;
    this.podcasttotalPage = podcasttotalPage;
    podcastisMorePage = podcastisMorePage;
    notifyListeners();
  }

  /* Radio Episode */
  Future<void> getEpisodeByRadio(radioId, pageNo) async {
    loading = true;
    epidoseByRadioModel = await ApiService().episodeByRadio(radioId, pageNo);
    if (epidoseByRadioModel.status == 200) {
      setRadioPaginationData(
        epidoseByRadioModel.totalRows,
        epidoseByRadioModel.totalPage,
        epidoseByRadioModel.currentPage,
        epidoseByRadioModel.morePage,
      );
      if (epidoseByRadioModel.result != null &&
          (epidoseByRadioModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(epidoseByRadioModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $playlistcurrentPage');
        if (epidoseByRadioModel.result != null &&
            (epidoseByRadioModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(epidoseByRadioModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (epidoseByRadioModel.result?.length ?? 0); i++) {
            radioEpisodeList?.add(
              epidoseByRadioModel.result?[i] ?? radio.Result(),
            );
          }
          final Map<int, radio.Result> postMap = {};
          radioEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          radioEpisodeList = postMap.values.toList();
          printLog("RadioList length :==> ${(radioEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRadioPaginationData(
    int? radiototalRows,
    int? radiototalPage,
    int? radiocurrentPage,
    bool? radioisMorePage,
  ) {
    this.radiocurrentPage = radiocurrentPage;
    this.radiototalRows = radiototalRows;
    this.radiototalPage = radiototalPage;
    radioisMorePage = radioisMorePage;
    notifyListeners();
  }

  /* PlayList Episode */
  Future<void> getEpisodeByPlaylist(playlistId, contentType, pageNo) async {
    loading = true;
    episodebyplaylistModel = await ApiService().episodeByPlaylist(
      playlistId,
      contentType,
      pageNo,
    );
    if (episodebyplaylistModel.status == 200) {
      setPlaylistPaginationData(
        episodebyplaylistModel.totalRows,
        episodebyplaylistModel.totalPage,
        episodebyplaylistModel.currentPage,
        episodebyplaylistModel.morePage,
      );
      if (episodebyplaylistModel.result != null &&
          (episodebyplaylistModel.result?.length ?? 0) > 0) {
        printLog(
          "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $playlistcurrentPage');
        if (episodebyplaylistModel.result != null &&
            (episodebyplaylistModel.result?.length ?? 0) > 0) {
          printLog(
            "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}",
          );
          for (
            var i = 0;
            i < (episodebyplaylistModel.result?.length ?? 0);
            i++
          ) {
            playlistEpisodeList?.add(
              episodebyplaylistModel.result?[i] ?? playlist.Result(),
            );
          }
          final Map<int, playlist.Result> postMap = {};
          playlistEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          playlistEpisodeList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(playlistEpisodeList?.length ?? 0)}",
          );
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPlaylistPaginationData(
    int? playlisttotalRows,
    int? playlisttotalPage,
    int? playlistcurrentPage,
    bool? playlistisMorePage,
  ) {
    this.playlistcurrentPage = playlistcurrentPage;
    this.playlisttotalRows = playlisttotalRows;
    this.playlisttotalPage = playlisttotalPage;
    playlistisMorePage = playlistisMorePage;
    notifyListeners();
  }

  /* Related Music */
  Future<void> getRelatedMusic(contentType, pageNo) async {
    loading = true;
    relatedMusicModel = await ApiService().getRelatedMusic(contentType, pageNo);
    if (relatedMusicModel.status == 200) {
      setRelatedMusicPaginationData(
        relatedMusicModel.totalRows,
        relatedMusicModel.totalPage,
        relatedMusicModel.currentPage,
        relatedMusicModel.morePage,
      );
      if (relatedMusicModel.result != null &&
          (relatedMusicModel.result?.length ?? 0) > 0) {
        printLog(
          "RelatedMusic length :==> ${(relatedMusicModel.result?.length ?? 0)}",
        );
        printLog('Now on page ==========> $playlistcurrentPage');
        if (relatedMusicModel.result != null &&
            (relatedMusicModel.result?.length ?? 0) > 0) {
          printLog(
            "RelatedMusic length :==> ${(relatedMusicModel.result?.length ?? 0)}",
          );
          for (var i = 0; i < (relatedMusicModel.result?.length ?? 0); i++) {
            relatedMusicList?.add(
              relatedMusicModel.result?[i] ?? relatedmusic.Result(),
            );
          }
          final Map<int, relatedmusic.Result> postMap = {};
          relatedMusicList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          relatedMusicList = postMap.values.toList();
          printLog(
            "followFollowingList length :==> ${(relatedMusicList?.length ?? 0)}",
          );
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRelatedMusicPaginationData(
    int? relatedMusictotalRows,
    int? relatedMusictotalPage,
    int? relatedMusiccurrentPage,
    bool? relatedMusicisMorePage,
  ) {
    this.relatedMusiccurrentPage = relatedMusiccurrentPage;
    this.relatedMusictotalRows = relatedMusictotalRows;
    this.relatedMusictotalPage = relatedMusictotalPage;
    relatedMusicisMorePage = relatedMusicisMorePage;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
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

  Future<void> addLikeDifood_app(
    contenttype,
    contentid,
    status,
    episodeId,
  ) async {
    printLog("addLikeDifood_app postId :==> $contentid");
    addRemoveLikeDifood_appModel = await ApiService().addRemoveLikeDifood_app(
      contenttype,
      contentid,
      status,
      episodeId,
    );
    printLog(
      "addLikeDifood_app status :==> ${addRemoveLikeDifood_appModel.status}",
    );
    printLog(
      "addLikeDifood_app message :==> ${addRemoveLikeDifood_appModel.message}",
    );
  }

  animateSheet(bool expend, double height) {
    isexpend = expend;
    isheight = height;
    notifyListeners();
  }

  changeMusicTab(type) {
    istype = type;
    notifyListeners();
  }

  Future<void> addView(contenttype, contentid) async {
    printLog("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    printLog("addPostView status :==> ${addViewModel.status}");
    printLog("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  clearProvider() {
    epidoseByPodcastModel = EpidoseByPodcastModel();
    epidoseByRadioModel = EpidoseByRadioModel();
    episodebyplaylistModel = EpisodebyplaylistModel();
    addViewModel = AddViewModel();
    addcontenttoHistoryModel = AddcontenttoHistoryModel();
    removeContentHistoryModel = RemoveContentHistoryModel();
    addRemoveLikeDifood_appModel = AddRemoveLikeDifood_appModel();
    loading = false;
    tabindex = 0;
    isexpend = false;
    istype = "episode";
    isheight = Dimens.musicdetailAnimateContainerheightNormal;

    podcastEpisodeList = [];
    podcastEpisodeList?.clear();
    podcasttotalRows;
    podcasttotalPage;
    podcastcurrentPage;
    podcastisMorePage;

    playlistEpisodeList = [];
    playlistEpisodeList?.clear();
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistisMorePage;

    radioEpisodeList = [];
    radioEpisodeList?.clear();
    radiototalRows;
    radiototalPage;
    radiocurrentPage;
    radioisMorePage;

    loadmore = false;
  }
}
