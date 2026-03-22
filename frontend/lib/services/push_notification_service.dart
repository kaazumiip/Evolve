import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Request permissions (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // 2. Initialize Local Notifications for Foreground
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click when app is in foreground
        print("Notification clicked: ${response.payload}");
        // Deep linking logic handled in main.dart or home_screen.dart via listeners
      },
    );

    // 3. Create Android Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      
      // Extract profile image from data or notification
      String? imageUrl = message.data['imageUrl'] ?? message.notification?.android?.imageUrl;

      if (notification != null) {
        final String senderName = notification.title ?? 'Someone';
        
        ByteArrayAndroidIcon? personIcon;
        ByteArrayAndroidBitmap? personBitmap;
        if (imageUrl != null) {
          final bytes = await _downloadImage(imageUrl);
          if (bytes != null) {
            personIcon = ByteArrayAndroidIcon(bytes);
            personBitmap = ByteArrayAndroidBitmap(bytes);
          }
        }

        final Person person = Person(
          name: senderName,
          icon: personIcon,
          important: true,
        );

        _localNotifications.show(
          notification.hashCode,
          senderName,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.max,
              channelDescription: 'This channel is used for important notifications.',
              showWhen: true,
              styleInformation: MessagingStyleInformation(
                person,
                messages: [
                  Message(notification.body ?? '', DateTime.now(), person),
                ],
              ),
              largeIcon: personBitmap,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // 5. Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("A new onMessageOpenedApp event was published!");
      // Logic for deep link is typically handled globally but we log it here
    });
  }

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  static Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Use the 'image' package to manually crop and mask the image to a circle
        final img.Image? originalImage = img.decodeImage(response.bodyBytes);
        if (originalImage == null) return response.bodyBytes;

        // Make it square first by cropping center
        int size = originalImage.width < originalImage.height ? originalImage.width : originalImage.height;
        img.Image cropped = img.copyCrop(originalImage, 
          x: (originalImage.width - size) ~/ 2, 
          y: (originalImage.height - size) ~/ 2, 
          width: size, 
          height: size,
        );

        // Apply a circular mask
        img.Image circle = img.Image(width: size, height: size, numChannels: 4);
        circle.clear(img.ColorRgba8(0, 0, 0, 0)); // Ensure full transparency initially
        int centerX = size ~/ 2;
        int centerY = size ~/ 2;
        int radiusSq = centerX * centerX;

        for (int y = 0; y < size; y++) {
          for (int x = 0; x < size; x++) {
            int dx = x - centerX;
            int dy = y - centerY;
            if (dx * dx + dy * dy <= radiusSq) {
              circle.setPixel(x, y, cropped.getPixel(x, y));
            } else {
              circle.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0)); // Transparent outside
            }
          }
        }
        return Uint8List.fromList(img.encodePng(circle));
      }
      return null;
    } catch (e) {
      print('Image download/clip error: $e');
      return null;
    }
  }

  static Future<void> showLocalNotification({
    int? id,
    required String title, 
    required String body, 
    String? imageUrl,
    List<String>? previousMessages,
    String? payload,
    String? groupKey,
  }) async {
    ByteArrayAndroidIcon? personIcon;
    ByteArrayAndroidBitmap? personBitmap;
    if (imageUrl != null) {
      final bytes = await _downloadImage(imageUrl);
      if (bytes != null) {
         personIcon = ByteArrayAndroidIcon(bytes);
         personBitmap = ByteArrayAndroidBitmap(bytes);
      }
    }

    final person = Person(
      name: title,
      icon: personIcon,
      important: true,
    );

    final List<Message> history = [];
    if (previousMessages != null) {
      for (var msg in previousMessages) {
        history.add(Message(msg, DateTime.now(), person));
      }
    } else {
      history.add(Message(body, DateTime.now(), person));
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      largeIcon: personBitmap, // Shows the circular avatar prominently
      groupKey: groupKey,
      styleInformation: MessagingStyleInformation(
        person,
        messages: history,
        groupConversation: false,
      ),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      id ?? DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
