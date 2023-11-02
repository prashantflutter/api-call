import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../utils/sharPreferenceUtils.dart';

var getFCMToken;

var sharePref = SharedPrefs.instance;

Future<void> handleBackGroundMassage(RemoteMessage message) async {
  var data1 = json.decode(
    message.data["content"],
  );

  if (data1["bigPicture"] != null && data1["bigPicture"] != "") {
    ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(await _getByteArrayFromUrl(data1["bigPicture"] != null ? data1["bigPicture"] : ''));

    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(bigPicture!,
        contentTitle: data1["title"], htmlFormatContentTitle: true, summaryText: data1["body"], htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails('basic_channel', 'High Importance Notifications',
        channelDescription: 'big text channel description', styleInformation: bigPictureStyleInformation);
    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _localNotification.show(DateTime.timestamp().millisecond, data1["title"], data1["body"], notificationDetails);
  } else {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      data1["body"],
      htmlFormatBigText: true,
      contentTitle: data1["title"],
      htmlFormatContentTitle: true,
      htmlFormatSummaryText: true,
    );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails('basic_channel', 'High Importance Notifications',
        channelDescription: 'big text channel description', styleInformation: bigTextStyleInformation);
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _localNotification.show(DateTime.timestamp().millisecond, data1["title"], data1["body"], notificationDetails);
  }

  // Future<String> _downloadAndSaveFile(String url, String fileName) async {
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   final String filePath = '${directory.path}/$fileName';
  //   final http.Response response = await http.get(Uri.parse(url));
  //   final File file = File(filePath);
  //   await file.writeAsBytes(response.bodyBytes);
  //   return filePath;
  // }
  //
  // final String bigPicturePath = await _downloadAndSaveFile(
  //   "${data1["bigPicture"]}",
  //   'bigPicture',
  // );
  // print("date time millisecound:::::${DateTime.timestamp().millisecond}");
  // _localNotification.show(
  //   DateTime.timestamp().millisecond,
  //   data1["title"],
  //   data1["body"],
  //   NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       _androidChannel.id,
  //       _androidChannel.name,
  //       fullScreenIntent: true,
  //       styleInformation: BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath!)),
  //       channelDescription: _androidChannel.description,
  //       icon: '@mipmap/ic_launcher',
  //       channelShowBadge: true,
  //     ),
  //   ),
  //   payload: jsonEncode(
  //     message.toMap(),
  //   ),
  // );
  // print("this is title in background:::${message.data["content"]}/${data1["title"]}//${data1["title"]}/${json.decode(message.data["content"])}");
}

final _androidChannel = const AndroidNotificationChannel(
  'basic_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);
final _localNotification = FlutterLocalNotificationsPlugin();

void handleMassage(RemoteMessage? message) {
  if (message == null) return;
}

Future initLocalNotification() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const setting = InitializationSettings(android: android);
  await _localNotification.initialize(setting, onDidReceiveNotificationResponse: (payload) {
    final message = RemoteMessage.fromMap(
      jsonDecode(payload! as String),
    );
    handleMassage(message);
  });
  final plaform = _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await plaform?.createNotificationChannel(_androidChannel);
}

Future initPushNotification() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.getInitialMessage().then((value) => handleMassage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMassage);
  FirebaseMessaging.onBackgroundMessage(handleBackGroundMassage);
  FirebaseMessaging.onMessage.listen(
    (message) async {
      var data1 = json.decode(
        message.data["content"],
      );

      print("Response Get : ${message.data["content"]}");

      if (data1["bigPicture"] != null && data1["bigPicture"] != "") {
        ByteArrayAndroidBitmap bigPicture =
            ByteArrayAndroidBitmap(await _getByteArrayFromUrl(data1["bigPicture"] != null ? data1["bigPicture"] : ''));

        final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(bigPicture!,
            contentTitle: data1["title"], htmlFormatContentTitle: true, summaryText: data1["body"], htmlFormatSummaryText: true);
        final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(_androidChannel.id, _androidChannel.name,
            channelDescription: 'big text channel description', styleInformation: bigPictureStyleInformation);
        final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
        await _localNotification.show(DateTime.timestamp().millisecond, data1["title"], data1["body"], notificationDetails);
      } else {
        BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          data1["body"],
          htmlFormatBigText: true,
          contentTitle: data1["title"],
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
        );
        AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(_androidChannel.id, _androidChannel.name,
            channelDescription: 'big text channel description', styleInformation: bigTextStyleInformation);
        NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
        await _localNotification.show(DateTime.timestamp().millisecond, data1["title"], data1["body"], notificationDetails);
      }

      // _localNotification.show(
      //   DateTime.timestamp().millisecond,
      //   data1["title"],
      //   data1["body"],
      //   NotificationDetails(
      //     android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name,
      //         channelDescription: _androidChannel.description,
      //         icon: '@mipmap/ic_launcher',
      //         channelShowBadge: true,
      //         fullScreenIntent: true,
      //         styleInformation: BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath!))),
      //   ),
      //   payload: jsonEncode(
      //     message.toMap(),
      //   ),
      // );
    },
  );
}

Future<Uint8List> _getByteArrayFromUrl(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}

class FirebaseApi {
  final _firebaseMassage = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMassage.requestPermission();
    final fcmToken = await _firebaseMassage.getToken();
    // sharePref.setString('fcmToken', '${fcmToken}');
    // print("this is save token:::::${sharePref.setString('fcmToken', '${fcmToken}')}");
    getFCMToken = fcmToken;
    print('Token : $fcmToken');
    initPushNotification();
    initLocalNotification();
    // FirebaseMessaging.onBackgroundMessage((message) => handleBackGroundMassage(message));
    // FirebaseMessaging.onBackgroundMessage(handleBackGroundMassage);
  }
}
