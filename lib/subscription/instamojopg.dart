import 'package:slike/utils/color.dart';
import 'package:slike/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstamojoPG extends StatefulWidget {
  final String? paymentId;
  final String? paymentUrl;

  const InstamojoPG({
    super.key,
    required this.paymentId,
    required this.paymentUrl,
  });

  @override
  State<InstamojoPG> createState() => _InstamojoPGState();
}

class _InstamojoPGState extends State<InstamojoPG> {
  //replace with webview_flutter.InAppWebViewController
  WebViewController? webViewController;
  String finalPaymentId = "";

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return PopScope(
      onPopInvoked: (didPop) {
        printLog("finalPaymentId =========> $finalPaymentId");
        if (finalPaymentId != "") {
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context, false);
        }
      },
      child: Scaffold(
        backgroundColor: colorPrimaryDark,
        appBar: Utils.myAppBarWithBack(context, "Instamojo", false),
        body: const SafeArea(
          child: Text('data'),
          //  webViewController(
          //   initialUrl: widget.paymentUrl ?? "",
          //   javascriptMode: JavascriptMode.unrestricted,
          //   onWebViewCreated: (controller) {
          //     webViewController = controller;
          //   },
          //   onPageStarted: (url) {
          //     printLog("onPageStarted url =========> $url");
          //   },
          //   navigationDelegate: (NavigationRequest request) {
          //     return NavigationDecision.navigate;
          //   },
          //   onPageFinished: (url) {
          //     printLog("onPageFinished url =========> $url");
          //     if (url.contains('instamojo.com/order/status')) {
          //       finalPaymentId = widget.paymentId ?? "";
          //       printLog(
          //           "onPageFinished finalPaymentId =========> $finalPaymentId");
          //       Navigator.pop(context, true);
          //     } else {
          //       finalPaymentId = "";
          //     }
          //   },
          //   onProgress: (progress) {
          //     printLog("onProgress progress =========> $progress");
          //   },
          //   onWebResourceError: (error) {
          //     printLog("onWebResourceError error =========> $error");
          //   },
          //   onPageCommitVisible: (url) {
          //     printLog("onPageCommitVisible url =========> $url");
          //   },
          // ),
        ),
      ),
    );
  }
}
