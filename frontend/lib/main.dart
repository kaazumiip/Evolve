import 'package:app_links/app_links.dart';
import 'dart:convert';
import 'screens/community/chat_detail_screen.dart';
import 'screens/community/user_profile_screen.dart';
import 'screens/community/post_detail_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'splash/splash_screen.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'screens/interest_picker_screen.dart';
import 'screens/home_screen.dart';

import 'services/push_notification_service.dart';
import 'services/api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n/app_localizations.dart';
import 'state/language_provider.dart';
import 'state/emoticon_provider.dart';

final themeManager = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const storage = FlutterSecureStorage();
  final darkModeStr = await storage.read(key: 'is_dark_mode');
  ApiService.isDarkMode = darkModeStr == 'true';
  themeManager.value = ApiService.isDarkMode;
  
  try {
    await Firebase.initializeApp();
    await PushNotificationService.initialize();
  } catch (e) {
    print("Firebase initialization failed: $e. Make sure you have added google-services.json/GoogleService-Info.plist");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => EmoticonProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    
    // Handle Push Notifications
    PushNotificationService.onNotificationClick = (data) {
      _handleNotificationClick(data);
    };
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    print("Handling notification click: $data");
    
    Map<String, dynamic> finalData = data;
    if (data.containsKey('payload')) {
      try {
        finalData = jsonDecode(data['payload']);
      } catch (e) {
        print("Error decoding notification payload: $e");
      }
    }

    if (finalData['type'] == 'chat' && finalData['conversationId'] != null) {
      final int convId = int.tryParse(finalData['conversationId'].toString()) ?? 0;
      final int senderId = int.tryParse(finalData['senderId']?.toString() ?? '') ?? 0;
      final String senderName = finalData['senderName'] ?? 'Chat';
      final String imageUrl = finalData['imageUrl'] ?? '';

      if (convId != 0 && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversationId: convId,
              otherUserId: senderId,
              otherUserName: senderName,
              otherUserImage: imageUrl,
            ),
          ),
        );
      }
    } else if ((finalData['type'] == 'comment' || finalData['type'] == 'reply' || finalData['type'] == 'like' || finalData['type'] == 'like_comment') && finalData['postId'] != null) {
      final int postId = int.tryParse(finalData['postId'].toString()) ?? 0;
      if (postId != 0 && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postData: {'id': postId}),
          ),
        );
      }
    } else if (finalData['type'] == 'friend_request' && (finalData['requesterId'] != null || finalData['senderId'] != null)) {
      final int userId = int.tryParse((finalData['requesterId'] ?? finalData['senderId']).toString()) ?? 0;
      final String userName = finalData['senderName'] ?? 'User';
      final String userImage = finalData['imageUrl'] ?? '';
      if (userId != 0 && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              userId: userId,
              userName: userName,
              userImage: userImage,
            ),
          ),
        );
      }
    } else if (finalData['type'] == 'friend_accepted' && (finalData['accepterId'] != null || finalData['senderId'] != null)) {
       final int userId = int.tryParse((finalData['accepterId'] ?? finalData['senderId']).toString()) ?? 0;
       final String userName = finalData['senderName'] ?? 'User';
       final String userImage = finalData['imageUrl'] ?? '';
       if (userId != 0 && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              userId: userId,
              userName: userName,
              userImage: userImage,
            ),
          ),
        );
      }
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was started with a link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      // Ignore
    }

    // Listen for new links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) async {
    // Check if it's our auth callback: evolve://auth_callback
    if (uri.scheme == 'evolve' && uri.host == 'auth_callback') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        try {
          // Save token using AuthService
          final authService = AuthService();
          await authService.setToken(token);
          
          // Navigate to home
          // Navigate based on interests
          final user = await authService.getUser();
          final interests = user['interests'];
          
          if (_navigatorKey.currentState != null) {
            if (interests == null || (interests is List && interests.isEmpty)) {
              _navigatorKey.currentState!.pushNamedAndRemoveUntil('/interest-picker', (route) => false);
            } else {
              _navigatorKey.currentState!.pushNamedAndRemoveUntil('/home', (route) => false);
            }
          }
        } catch (e) {
          print('Error handling deep link: $e');
        }
      }
    }
  }

  // We need a navigator key to navigate from here
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    // Update ApiService language whenever it changes
    ApiService.currentLanguage = langProvider.locale?.languageCode ?? 'en';

    return ValueListenableBuilder<bool>(
      valueListenable: themeManager,
      builder: (context, isDark, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Evolve App',
          debugShowCheckedModeBanner: false,
          locale: langProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomePage(),
            '/interest-picker': (context) => const InterestPickerScreen(),
          },
        );
      },
    );
  }
}


