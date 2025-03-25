import 'dart:io';
import 'package:slike/model/download_item.dart';
import 'package:slike/pages/login.dart';
import 'package:slike/provider/downloadprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/mytext.dart';
import 'package:slike/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class Download extends StatefulWidget {
  const Download({super.key});

  @override
  State<Download> createState() => DownloadState();
}

class DownloadState extends State<Download> {
  /* Create Instance And Initilize Hive */
  late Box<DownloadItem> downloadBox;
  late DownloadProvider downloadProvider;

  @override
  void initState() {
    /* Initilize Hive */
    downloadBox = Hive.box<DownloadItem>('downloads');
    downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "download", true),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [buildDownloadList()],
        ),
      ),
    );
  }

  buildDownloadList() {
    return ValueListenableBuilder(
      valueListenable: downloadBox.listenable(),
      builder: (context, Box<DownloadItem> box, _) {
        if (box.values.isEmpty) {
          return const NoData();
        } else {
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: box.values.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final downloadItem = box.getAt(index);
              return InkWell(
                onTap: () {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Login();
                        },
                      ),
                    );
                  } else {
                    Utils.openPlayer(
                      isDownloadVideo: true,
                      context: context,
                      videoId: downloadItem?.id.toString() ?? "",
                      videoUrl: downloadItem?.videoPath.toString() ?? "",
                      vUploadType:
                          downloadItem?.videoUploadType.toString() ?? "",
                      videoThumb: downloadItem?.imagePath.toString() ?? "",
                      stoptime: 0.0,
                      iscontinueWatching: false,
                    );
                  }
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(downloadItem?.imagePath ?? ""),
                        width: 140,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            color: white,
                            text: downloadItem?.title ?? "",
                            multilanguage: false,
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                          const SizedBox(height: 8),
                          MyText(
                            color: gray,
                            text: downloadItem?.channelName ?? "",
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textMedium,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                          // const SizedBox(height: 15),
                          // Text(
                          //   downloadItem?.videoPath ?? "",
                          //   maxLines: 5,
                          // ),
                          // const SizedBox(height: 15),
                          // Text(
                          //   downloadItem?.imagePath ?? "",
                          //   maxLines: 5,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  progressDilog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<DownloadProvider>(
              builder: (context, downloadprovider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Downloading..."),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      strokeWidth: 1,
                      color: colorAccent,
                      value: downloadprovider.progress,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${(downloadprovider.progress * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
