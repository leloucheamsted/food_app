import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:slike/utils/constant.dart';
import 'package:slike/utils/sharedpre.dart';
import 'package:slike/utils/utils.dart';

class PushNotificationService {
  SharedPre sharedPref = SharedPre();
  String darwinNotificationCategoryPlain = Constant.appName;
  Future<void> setupInteractedMessage(context) async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await Firebase.initializeApp();
    await getAccessToken();
    enableIOSNotifications();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printLog("===> msg $message");
    });
    await registerNotificationListeners(context);
  }

  Future<void> registerNotificationListeners(context) async {
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {
          printLog("onTokenRefresh ======>>> $fcmToken");
        })
        .onError((err) {
          printLog("onTokenRefresh error ======>>> $err");
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      final RemoteNotification? notification = message?.notification;
      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.

      if (notification != null && message != null) {
        printLog("notification title =====> ${notification.title}");
        printLog("notification body ======> ${notification.body}");
        printLog("notification message ===> ${message.data}");
      }
    });
  }

  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      printLog('User granted permission');
      await getToken();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      printLog('User granted provisional permission');
    } else {
      printLog('User declined or has not accepted permission');
    }
  }

  getToken() async {
    SharedPre sharedPre = SharedPre();
    Constant.vapId = await sharedPre.read(Constant.vapIdKey) ?? "";
    // Constant.vapidKey =
    //     "BBZn_rQBHW0UmEi9B0EyPJKnOTjR8W1lbG-vg1t2ysRDoJcjermqbVADQbGbZl546disH98A2W3rupJAzBubw4Y";
    String? token = await FirebaseMessaging.instance.getToken(
      vapidKey: Constant.vapId,
    );

    Constant.webToken = token;
    printLog("FirebaseMessaging token: ${Constant.webToken}");
  }

  static String firebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";
  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "spitch-work",
        "private_key_id": "e19b765453bd7f678d146d20b22e1dc07a305400",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCm+ZS7VLA3aDwY\nbJuslPtwlFsQkAKVvFpUcebR8DSO4+OD8FRlzpoRPAFnnSDjf2yPEZqq0dQqq52w\ne16qaeWbXEQKZrGq/lUirG9U+aKwvevs1BMp3Ocjl3D7eo2GKZ+lT438324tdc9w\nZKnzqrUTuCsdN0nYfiNTMSSHZ71tkKM+85Pe+notENSz0Q6En50ushr1zEs9K6tC\nPzylTnFzI/duU//4GJeIY3x37swUqDDNYl+JgwpRycSK5VJR81lSNJ0k9Hft8eGK\n27LtgnQMp+QGiqmorM8ho05qMdhqF78VkbR0QQoDUHVkHW0p1YOaXfDJDdK0vEku\ndaCSkoI/AgMBAAECggEADdnhVSLi1U3PwmTsCwZ2zzF3Vmnj1QEBa0ThlWO8MGhG\nHNFIZwOa8zgLk8lMi6Kr4jhfILF0TK/czmGFilRriBZAzK4VKe6cKFquh5mHveqb\nUhOLnWrmP6UV6b6SU+FLDX8Kc8IjFSFTOmsXUA/GoqKh7PQDq7JXAtUuRw87fwWg\nv+HeCskth18YszzOjnsbx18qGVZpaCHp+RkmtujdLZtHNSbfbixWvYmNSTLV0HKM\naqOWzIXNcDMLP4F89jTup5DmWP3TTpCbwJhvXf0oKpg/lcqX4BEyVlHgtl7UwkBH\nofDbRxzeJ8oEPmuVzsIEewFQqfQur/gFhOfQ3DkGiQKBgQDPDxbTppMajwKMfe9V\n8mjNXBGT0ytXmwWtZmxgJQHY1TWC/aHJcrMiNTf8w2en66R5zXCmS8fOsWNw7t2u\n5Sz19O3jYhvGv7yhUoCEHbGvDsK83cUBGdbE+HJRk/xvohxfKP+5ShRPz2gbLvKr\nQA3oEubI6SYI8oAAw3QJs242WQKBgQDOcQ07kCTebRPDu6ldcK3LNX5Lo1iojDab\n77B+vm36bCMD2npijBgGOVPo3e/j8N4Au4YCmcksUo/uq+9RgRNKjGjwoAQSGFbP\neqwhfThVr06x27/bzpFdXdm02W6j2cGaEZs5TN9e78j9Tcd1ltEhwXEYyx9w2Owv\nUqs9KkEaVwKBgQCYHdrERUUfJt9VfZOeTcemzzPuqR3Xb4E9QdjuzWFM/l4gzNrW\nF1j5EaX/IUN+vwSHo2FWGqhA9ls69ZGRUra0P2uhOEt1uRkIX4chCHuoQyzX+gko\nZOY+sNOzkQfMr4kuc/1jD8RaWeJ+zf/jxdwxmelIwth5jEZzySPvmI2oiQKBgQCq\nibOvv7zlTeBk8lLQEPRRCWjCnTbxTZsTKGd53GBH3iry1PoDDM4P3i3WEflJKMKM\ngl0LKvWIOtASD1DM2L8R93n9RYL3W8ni7ejiZWozRnXQ8cLFlxh4s73T60a97nZD\ni0XaiQmBiL5VmnoqRqOOqhl+rNXVSC2cTkONbKmJUwKBgGWl1Ji6A2pll8ayZ5ty\nuhk76Ay9DD6uzdRJD1IsohiTR+Gp5FbJ9qKnSMq6TnIIR5vrkKXPPjFKEOw4i7Qj\nLUhcUCu61xcBcvSwWZ7PMv8525tXfpBoSAQfla6YRrKlX5DuqUR+fz50mhACiuMr\n0Zl9hIOCf1ytUbViUiViwysp\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-urvu4@spitch-work.iam.gserviceaccount.com",
        "client_id": "117173731388582235988",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-urvu4%40spitch-work.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      [firebaseMessagingScope],
    );

    final accessToken = client.credentials.accessToken.data;
    printLog("accessToken == $accessToken");
    Constant.accessToken = accessToken;
    return accessToken;
  }
}
