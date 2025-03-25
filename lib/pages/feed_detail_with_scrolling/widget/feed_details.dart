// import 'package:flutter/material.dart';
//
// import '../../../provider/feed_detail_with_scrolling_provider.dart';
// import '../../../utils/color.dart';
// import '../../../utils/dimens.dart';
// import '../../../widget/mytext.dart';
//
// Widget feedDetail(
//     {String? title,
//     required int index,
//     required BuildContext context,
//     required FeedDetailWithScrollingProvider feedDetailWithScrollingProvider,PageController imageController}) {
//   return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Padding(
//       padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
//       child: MyText(
//           color: white,
//           text: title.toString() ?? "",
//           textalign: TextAlign.center,
//           fontsizeNormal: Dimens.textBig,
//           maxline: 5,
//           multilanguage: false,
//           fontwaight: FontWeight.w700,
//           overflow: TextOverflow.ellipsis,
//           fontstyle: FontStyle.normal),
//     ),
//     (feedDetailWithScrollingProvider.feedDetailModel.result?[index].postContent != null &&
//             ((feedDetailWithScrollingProvider.feedDetailModel.result?[index].postContent?.length ?? 0) > 0))
//         ? Container(
//             margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
//             height: MediaQuery.of(context).size.height * 0.70,
//             child: PageView.builder(
//                 controller: imageController,
//                 itemCount: (feedDetailWithScrollingProvider.feedDetailModel.result?[index].postContent?.length ?? 0),
//                 scrollDirection: Axis.horizontal,
//                 allowImplicitScrolling: true,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 onPageChanged: (index) {
//                   if (index == feedDetailWithScrollingProvider.feedDetailModel.result?[index].postContent?.length) {
//                     moveToNextPage();
//                   }
//                 },
//                 itemBuilder: (context, contentIndex) {
//                   return Stack(children: [
//                     feedDetailWithScrollingProvider
//                                 .feedDetailModel.result?[index].postContent?[contentIndex].contentType ==
//                             1
//                         ? MyNetworkImage(
//                             width: MediaQuery.of(context).size.width,
//                             height: MediaQuery.of(context).size.height,
//                             fit: BoxFit.cover,
//                             imagePath: feedDetailWithScrollingProvider
//                                     .feedDetailModel.result?[index].postContent?[contentIndex].contentUrl
//                                     .toString() ??
//                                 "")
//                         : FeedPlayer(
//                             index: contentIndex,
//                             pagePos: contentIndex,
//                             thumbnailImg: feedDetailWithScrollingProvider
//                                     .feedDetailModel.result?[index].postContent?[contentIndex].thumbnailImage
//                                     .toString() ??
//                                 "",
//                             videoId: feedDetailWithScrollingProvider
//                                     .feedDetailModel.result?[index].postContent?[contentIndex].id
//                                     .toString() ??
//                                 "",
//                             videoUrl: feedDetailWithScrollingProvider
//                                     .feedDetailModel.result?[index].postContent?[contentIndex].contentUrl
//                                     .toString() ??
//                                 "")
//                   ]);
//                 }))
//         : const SizedBox.shrink(),
//     (feedDetailWithScrollingProvider.feedDetailModel.result?[index].postContent != null &&
//             ((feedDetailWithScrollingProvider.feedDetailModel.result?[index].postContent?.length ?? 0) > 0))
//         ? Container(
//             margin: const EdgeInsets.only(top: 10),
//             alignment: Alignment.center,
//             child: SmoothPageIndicator(
//                 controller: _imageController,
//                 count: feedDetailWithScrollingProvider.feedDetailModel.result?[index].postContent?.length ?? 0,
//                 effect: const ExpandingDotsEffect(
//                   activeDotColor: colorAccent,
//                   dotColor: lightgray,
//                   dotHeight: 8,
//                   dotWidth: 8,
//                 ),
//                 onDotClicked: (index) {
//                   _pageController.animateToPage(index,
//                       duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
//                 }))
//         : const SizedBox.shrink(),
//     feedDetailWithScrollingProvider.feedDetailModel.result?[index].descripation == ""
//         ? const SizedBox.shrink()
//         : Padding(
//             padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
//             child: ExpandableText(
//                 expandOnTextTap: true,
//                 collapseOnTextTap: true,
//                 linkStyle: GoogleFonts.inter(
//                     fontSize: Dimens.textMedium, fontStyle: FontStyle.normal, color: gray, fontWeight: FontWeight.w500),
//                 style: GoogleFonts.inter(
//                     fontSize: Dimens.textMedium,
//                     fontStyle: FontStyle.normal,
//                     color: white,
//                     fontWeight: FontWeight.w400),
//                 feedDetailWithScrollingProvider.feedDetailModel.result?[0].descripation.toString() ?? "",
//                 expandText: 'Read More',
//                 collapseText: "Read Less",
//                 linkColor: colorAccent,
//                 maxLines: 5)),
//     (feedDetailWithScrollingProvider.feedDetailModel.result?[index].hastegs != null &&
//             ((feedDetailWithScrollingProvider.feedDetailModel.result?[index].hastegs?.length ?? 0) > 0))
//         ? SizedBox(
//             height: 50,
//             child: ListView.separated(
//                 separatorBuilder: (context, index) => const SizedBox(width: 10),
//                 itemCount: feedDetailWithScrollingProvider.feedDetailModel.result?[index].hastegs?.length ?? 0,
//                 padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//                 scrollDirection: Axis.horizontal,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemBuilder: (context, hashtagIndex) {
//                   return Container(
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(50),
//                         border: Border.all(width: 0.8, color: gray),
//                       ),
//                       child: MyText(
//                           color: gray,
//                           multilanguage: false,
//                           text:
//                               "# ${feedDetailWithScrollingProvider.feedDetailModel.result?[index].hastegs?[hashtagIndex].name.toString() ?? ""}",
//                           textalign: TextAlign.center,
//                           fontsizeNormal: Dimens.textSmall,
//                           inter: true,
//                           maxline: 10,
//                           fontwaight: FontWeight.w500,
//                           overflow: TextOverflow.ellipsis,
//                           fontstyle: FontStyle.normal));
//                 }))
//         : const SizedBox.shrink()
//   ]);
// }
