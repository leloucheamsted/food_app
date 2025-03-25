import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/musictitle.dart';
import 'package:slike/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/widget/myimage.dart';
import 'package:slike/widget/mytext.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:slike/model/introscreenmodel.dart';

class Intro extends StatefulWidget {
  final List<Result>? introList;
  const Intro({super.key, required this.introList});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  SharedPre sharedPre = SharedPre();
  Constant constant = Constant();
  PageController pageController = PageController();
  final currentPageNotifier = ValueNotifier<int>(0);
  int position = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: widget.introList?.length ?? 0,
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        color: colorPrimary,
                        border: Border.all(width: 2, color: colorPrimary),
                        gradient: const LinearGradient(
                          colors: [colorPrimary, transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: MyNetworkImage(
                        imagePath:
                            widget.introList?[index].image.toString() ?? "",
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MusicTitle(
                        color: white,
                        text: widget.introList?[index].title.toString() ?? "",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textlargeBig,
                        multilanguage: false,
                        maxline: 4,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              );
            },
            onPageChanged: (index) {
              position = index;
              currentPageNotifier.value = index;
              printLog("position :==> $position");
              setState(() {});
            },
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                splashColor: transparent,
                onTap: () async {
                  if (position == ((widget.introList?.length ?? 0) - 1)) {
                    await sharedPre.save("seen", "1");
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Bottombar();
                        },
                      ),
                    );
                  }
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  );
                },
                child: Stack(
                  children: [
                    MyImage(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.15,
                      imagePath: "ic_halfcir.png",
                    ),
                    Positioned.fill(
                      top: 10,
                      left: 10,
                      child: Align(
                        alignment: Alignment.center,
                        child: MyText(
                          color: white,
                          text:
                              position == ((widget.introList?.length ?? 0) - 1)
                                  ? "Finish"
                                  : "Next",
                          textalign: TextAlign.center,
                          fontsizeNormal: 20,
                          multilanguage: true,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 40,
            right: 20,
            child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                splashColor: transparent,
                onTap: () async {
                  await sharedPre.save("seen", "1");
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Bottombar();
                      },
                    ),
                  );
                },
                child: MyText(
                  color: white,
                  text: "skip",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textTitle,
                  inter: false,
                  multilanguage: true,
                  fontwaight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
          ),
          Positioned.fill(
            bottom: 50,
            left: 20,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SmoothPageIndicator(
                controller: pageController,
                count: widget.introList?.length ?? 0,
                effect: const ExpandingDotsEffect(
                  dotWidth: 10,
                  dotHeight: 8,
                  dotColor: colorPrimaryDark,
                  expansionFactor: 4,
                  offset: 1,
                  activeDotColor: colorAccent,
                  radius: 100,
                  strokeWidth: 1,
                  spacing: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
