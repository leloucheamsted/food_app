import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class Dimens {
  /*------- (Font Size)/--------*/
  static double textExtraSmall = 10;
  static double textSmall = 12;
  static double textMedium = 14;
  static double textTitle = 16;
  static double textDesc = 15;
  static double textBig = 18;
  static double textlargeBig = 20;
  static double textExtraBig = 24;
  static double textExtralargeBig = 36;

  /*-------BottomBar Page/--------*/
  static double iconbottomNav = 25;
  static double centerIconbottomNav = 42;
  static double textbottomNav = 12;

  /* Feed Height Width */
  static double feeditemHeightWeb = 240;
  static double feeditemWidthWeb = 155;
  static double feeditemHeightMobile = 200;
  static double feeditemWidthMobile = 120;

  /* Music Section Page Height App */
  static double roundheight = 170;
  static double portraitheight = 200;
  static double playlistheight = 200;
  static double squareheight = 135;
  static double listviewLayoutheight = 280;
  static double categoryheight = 50;
  static double languageheight = 45;
  static double podcastbannerheight = 210;
  static double landscapPodcastheight = 400;
  static double podcastListviewheight = 300;
  static double musicdetailAnimateContainerheightNormal = 80;
  static double musicdetailAnimateContainerheightExpand = 700;
  static double contentDetailImageheight = 230;
  static double contentDetailImagewidth = 230;

  /* Music Section Page Height Web*/
  static double roundheightWeb = 200;
  static double portraitheightWeb = 250;
  static double playlistheightWeb = 250;
  static double squareheightWeb = 220;
  static double listviewLayoutheightWeb = 280;
  static double categoryheightWeb = 100;
  static double languageheightWeb = 60;
  static double podcastbannerheightWeb = 300;
  static double landscapPodcastheightWeb = 450;
  static double podcastListviewheightWeb = 280;
  static double contentDetailImageheightWeb = 280;
  static double contentDetailImagewidthWeb = 280;

  /* Minimum Screen size for Tablet/iPad START */
  static double minWidth = 550;
  /* Minimum Screen size for Tablet/iPad END */

  static double heightGift = 100;
  static double widthGift = 100;
  static double widthLive = 100;
  static double heightLive = 100;

  /* LiveSTream Height Width */

  static double hostHeight = 300;

  static double landRatio = 1.91;

  static double getResponsiveBox(BuildContext context, double sideMargins) {
    return ((((html.window.screen?.height as double) * 0.70) - sideMargins) /
        Dimens.landRatio);
  }
}
