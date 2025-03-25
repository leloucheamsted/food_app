import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slike/pages/profile.dart';
import 'package:slike/pages/shorts.dart';
import 'package:slike/provider/shortprovider.dart';
import 'package:slike/utils/adhelper.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:slike/provider/searchprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/widget/myimage.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();
  late SearchProvider searchProvider;

  @override
  void initState() {
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    super.initState();
  }

  getApi() async {
    await searchProvider.getSearch(searchController.text, "3");
  }

  @override
  void dispose() {
    searchProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: 45,
          margin: const EdgeInsets.only(right: 15),
          child: TextFormField(
            obscureText: false,
            onChanged: (value) async {
              getApi();
            },
            keyboardType: TextInputType.text,
            controller: searchController,
            textInputAction: TextInputAction.done,
            cursorColor: lightgray,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontStyle: FontStyle.normal,
              color: white,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintStyle: GoogleFonts.roboto(
                fontSize: 14,
                fontStyle: FontStyle.normal,
                color: white,
                fontWeight: FontWeight.w400,
              ),
              hintText: Locales.string(context, "search"),
              filled: true,
              fillColor: colorPrimary,
              contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: colorAccent),
              ),
              disabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: colorAccent),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: colorAccent),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: colorAccent),
              ),
            ),
          ),
        ),
        centerTitle: false,
        leading: InkWell(
          hoverColor: transparent,
          splashColor: transparent,
          highlightColor: transparent,
          focusColor: transparent,
          onTap: () {
            Navigator.pop(context, false);
          },
          child: Align(
            alignment: Alignment.center,
            child: MyImage(
              width: 25,
              height: 25,
              imagePath: "ic_roundback.png",
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 70),
        child: Column(children: [searchList()]),
      ),
    );
  }

  buildLayout() {
    return shortList();
  }

  Widget searchList() {
    return Consumer<SearchProvider>(
      builder: (context, searchprovider, child) {
        if (searchprovider.loading) {
          return Utils.pageLoader(context);
        } else {
          if (searchprovider.searchModel.result != null &&
              (searchprovider.searchModel.result?.length ?? 0) > 0) {
            return ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 15,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                searchprovider.searchModel.result?.length ?? 0,
                (index) {
                  return InkWell(
                    onTap: () async {
                      if (searchprovider.searchModel.result?[index].isChannel ==
                          1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Profile(
                                isBottomBar: false,
                                toUserId:
                                    searchprovider.searchModel.result?[index].id
                                        .toString() ??
                                    "",
                                toChannelId:
                                    searchprovider
                                        .searchModel
                                        .result?[index]
                                        .channelId
                                        .toString() ??
                                    "",
                              );
                            },
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Shorts(
                                initialIndex: index,
                                searchText: searchController.text,
                                shortType: "search",
                                userId: Constant.userID,
                                channelId: Constant.channelID,
                              );
                            },
                          ),
                        ).then((value) {
                          final shortProvider = Provider.of<ShortProvider>(
                            context,
                            listen: false,
                          );
                          shortProvider.clearProvider();
                        });
                      }
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            imagePath:
                                searchprovider
                                            .searchModel
                                            .result?[index]
                                            .isChannel ==
                                        1
                                    ? (searchprovider
                                            .searchModel
                                            .result?[index]
                                            .image
                                            .toString() ??
                                        "")
                                    : (searchprovider
                                            .searchModel
                                            .result?[index]
                                            .portraitImg
                                            .toString() ??
                                        ""),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                searchprovider
                                            .searchModel
                                            .result?[index]
                                            .isChannel ==
                                        1
                                    ? (searchprovider
                                                .searchModel
                                                .result?[index]
                                                .fullName ==
                                            "")
                                        ? (searchprovider
                                                .searchModel
                                                .result?[index]
                                                .channelName
                                                .toString() ??
                                            "")
                                        : (searchprovider
                                                .searchModel
                                                .result?[index]
                                                .fullName
                                                .toString() ??
                                            "")
                                    : (searchprovider
                                            .searchModel
                                            .result?[index]
                                            .title
                                            .toString() ??
                                        ""),
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        }
      },
    );
  }

  Widget channelList() {
    return Consumer<SearchProvider>(
      builder: (context, searchprovider, child) {
        if (searchprovider.loading) {
          return Utils.pageLoader(context);
        } else {
          if (searchprovider.searchModel.channel != null &&
              (searchprovider.searchModel.channel?.length ?? 0) > 0) {
            return ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 15,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                searchprovider.searchModel.channel?.length ?? 0,
                (index) {
                  return InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Profile(
                              isBottomBar: false,
                              toUserId:
                                  searchprovider.searchModel.channel?[index].id
                                      .toString() ??
                                  "",
                              toChannelId:
                                  searchprovider
                                      .searchModel
                                      .channel?[index]
                                      .channelId
                                      .toString() ??
                                  "",
                            );
                          },
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            imagePath:
                                searchprovider.searchModel.channel?[index].image
                                    .toString() ??
                                "",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                searchprovider
                                            .searchModel
                                            .channel?[index]
                                            .fullName ==
                                        ""
                                    ? (searchprovider
                                            .searchModel
                                            .channel?[index]
                                            .channelName
                                            .toString() ??
                                        "")
                                    : searchprovider
                                            .searchModel
                                            .channel?[index]
                                            .fullName
                                            .toString() ??
                                        "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        }
      },
    );
  }

  Widget shortList() {
    return Consumer<SearchProvider>(
      builder: (context, searchprovider, child) {
        if (searchprovider.loading) {
          return Utils.pageLoader(context);
        } else {
          if (searchprovider.searchModel.reels != null &&
              (searchprovider.searchModel.reels?.length ?? 0) > 0) {
            return ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 10,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(
                searchprovider.searchModel.reels?.length ?? 0,
                (index) {
                  return InkWell(
                    onTap: () {
                      AdHelper.showFullscreenAd(
                        context,
                        Constant.rewardAdType,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Shorts(
                                  initialIndex: index,
                                  searchText: searchController.text,
                                  shortType: "search",
                                  userId: Constant.userID,
                                  channelId: Constant.channelID,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: MyNetworkImage(
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: 250,
                            imagePath:
                                searchprovider
                                    .searchModel
                                    .reels?[index]
                                    .portraitImg
                                    .toString() ??
                                "",
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: MyImage(
                            width: 30,
                            height: 30,
                            imagePath: "pause.png",
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return const NoData(title: "", subTitle: "");
          }
        }
      },
    );
  }
}
