// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:async';

import 'package:pinkGossip/localization/locale_constants.dart';
import 'package:pinkGossip/localization/localizations_delegate.dart';

import 'package:pinkGossip/viewModels/addstoryviewmodel.dart';
import 'package:pinkGossip/viewModels/allfollowersorfollowviewmodel.dart';
import 'package:pinkGossip/viewModels/blockuserviewmodel.dart';
import 'package:pinkGossip/viewModels/checkaccountexistviewmodel.dart';
import 'package:pinkGossip/viewModels/checkusernameexistviewmodel.dart';
import 'package:pinkGossip/viewModels/getqrcodeviewmodel.dart';
import 'package:pinkGossip/viewModels/getstoryviewmodel.dart';
import 'package:pinkGossip/viewModels/notificationviewmode.dart';
import 'package:pinkGossip/viewModels/postdeleteviewmodel.dart';
import 'package:pinkGossip/viewModels/removestorycroneviewmodel.dart';
import 'package:pinkGossip/viewModels/updatefirebaseviewmodel.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:provider/provider.dart';
import 'package:pinkGossip/screens/splashscreeen.dart';
import 'package:pinkGossip/viewModels/commentpostviewmodel.dart';
import 'package:pinkGossip/viewModels/createpostviewmodel.dart';
import 'package:pinkGossip/viewModels/followingviewmodel.dart';
import 'package:pinkGossip/viewModels/forgotpasswordviewmodel.dart';
import 'package:pinkGossip/viewModels/homepagepostviewmodel.dart';
import 'package:pinkGossip/viewModels/loginviewmodel.dart';
import 'package:pinkGossip/viewModels/postlikeviewmodel.dart';
import 'package:pinkGossip/viewModels/salondetailsviewmodel.dart';
import 'package:pinkGossip/viewModels/salonlistviewmodel.dart';
import 'package:pinkGossip/viewModels/searchuserlistviewmodel.dart';
import 'package:pinkGossip/viewModels/signupviewmodel.dart';
import 'package:pinkGossip/viewModels/unfollwviewmodel.dart';
import 'package:pinkGossip/viewModels/updateprofileviewmdoel.dart';
import 'package:pinkGossip/viewModels/updateprofileviewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  // HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  String isLanguage = "en";
  getLocalLang() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      isLanguage = _prefs.getString("SelectedLanguageCode") ?? "en";
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    getLocalLang();
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    '270699',
    'Pink Gossip',
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    print("initState main");
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignUpViewModel()),
        ChangeNotifierProvider(create: (context) => LoginViewModel()),
        ChangeNotifierProvider(create: (context) => ForgotPassViewModel()),
        ChangeNotifierProvider(create: (context) => SalonListViewModel()),
        ChangeNotifierProvider(create: (context) => SalonDetailsViewModel()),
        ChangeNotifierProvider(create: (context) => CreatePostViewModel()),
        ChangeNotifierProvider(create: (context) => HomePagePostViewModel()),
        ChangeNotifierProvider(create: (context) => PostLikeViewModel()),
        ChangeNotifierProvider(create: (context) => CommentPostViewModel()),
        ChangeNotifierProvider(create: (context) => FollowingViewModel()),
        ChangeNotifierProvider(create: (context) => UnfollowViewModel()),
        ChangeNotifierProvider(create: (context) => UpdateProfileViewModel()),
        ChangeNotifierProvider(
          create: (context) => UpdatePofilePhotoViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchUserListViewModelViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => CheckUserExistViewModel()),
        ChangeNotifierProvider(
          create: (context) => UpdateDeviceTokenViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AllFollowerorFollowViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => GetQRCodeViewModel()),
        ChangeNotifierProvider(create: (context) => PostDeleteViewModel()),
        ChangeNotifierProvider(
          create: (context) => NotificationListViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => AddStoryViewModel()),
        ChangeNotifierProvider(create: (context) => GetStoryViewModel()),
        ChangeNotifierProvider(
          create: (context) => RemoveStoryCroneViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => CheckUserNameExistViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => BlockUserViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // important for deep linking
        locale: _locale,
        supportedLocales: const [Locale('en', ''), Locale('fr', '')],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
