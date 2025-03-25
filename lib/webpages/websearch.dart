import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slike/provider/shortprovider.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/webpages/webprofile.dart';
import 'package:slike/webpages/webshorts.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:slike/provider/searchprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebSearch extends StatefulWidget {
  const WebSearch({super.key});

  @override
  State<WebSearch> createState() => WebSearchState();
}

class WebSearchState extends State<WebSearch> {
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
      appBar: Utils.webAppbarWithSidePanel(
        context: context,
        contentType: "search",
        categoryTap: () {},
      ),
      body: Utils.sidePanelWithBody(
        myWidget: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchWithTitle(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [searchList()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchWithTitle() {
    if (MediaQuery.of(context).size.width > 1200) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Utils.pageTitle(title: "search", multilanguage: true),
          searchBar(),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.pageTitle(title: "search", multilanguage: true),
          const SizedBox(height: 20),
          searchBar(),
        ],
      );
    }
  }

  Widget searchBar() {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width > 1200
              ? MediaQuery.of(context).size.width * 0.25
              : MediaQuery.of(context).size.width,
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
          fontSize: Dimens.textTitle,
          fontStyle: FontStyle.normal,
          color: white,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintStyle: GoogleFonts.roboto(
            fontSize: Dimens.textMedium,
            fontStyle: FontStyle.normal,
            color: white,
            fontWeight: FontWeight.w400,
          ),
          hintText: Locales.string(context, "search"),
          filled: true,
          fillColor: colorPrimaryDark,
          contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 1, color: colorPrimaryDark),
          ),
        ),
      ),
    );
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
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation1, animation2) => WebProfile(
                                  isBottomBar: false,
                                  toUserId:
                                      searchprovider
                                          .searchModel
                                          .result?[index]
                                          .id
                                          .toString() ??
                                      "",
                                  toChannelId:
                                      searchprovider
                                          .searchModel
                                          .result?[index]
                                          .channelId
                                          .toString() ??
                                      "",
                                ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation1, animation2) => WebShorts(
                                  initialIndex: index,
                                  searchText: searchController.text,
                                  shortType: "search",
                                  userId: Constant.userID,
                                  channelId: Constant.channelID,
                                ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
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
}
