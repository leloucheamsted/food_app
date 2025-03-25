import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:slike/utils/color.dart';
import 'package:slike/utils/utils.dart';

class Commonpage extends StatefulWidget {
  final String url, title;
  final bool multilanguage;
  const Commonpage({
    super.key,
    required this.url,
    required this.title,
    required this.multilanguage,
  });

  @override
  State<Commonpage> createState() => CommonpageState();
}

class CommonpageState extends State<Commonpage> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    log("URL===> ${widget.url}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(
        context,
        widget.title,
        widget.multilanguage,
      ),
      body: const Column(
        children: [
          Expanded(
            child: Text('data'),
            // InAppWebView(
            //   onLoadStart: (controller, url) {},
            //   onLoadStop: (controller, url) {},
            //   key: webViewKey,
            //   initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            // ),
          ),
        ],
      ),
    );
  }
}
