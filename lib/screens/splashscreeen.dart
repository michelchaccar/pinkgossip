// ignore_for_file: avoid_print

import 'dart:async';

import 'package:pinkGossip/utils/color_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'Auth/loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogin = false;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove("picandvideostype2");
    // prefs.remove("photoVideoPrefs");
    setState(() {
      isLogin = prefs.getBool("isLogin") ?? false;
    });
  }

  getToken() async {
    String? getfcmtoken = await FirebaseMessaging.instance.getToken();
    print("fcmtoken MAIN FILE ========= $getfcmtoken");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmtoken', getfcmtoken!);
  }

  Future moveToNewScreen() async {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  isLogin == false
                      ? const LoginScreen()
                      : BottomNavBar(index: 0),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    print("getToken Fun Called in Splash Screen");
    getToken();
    checkLogin();
    moveToNewScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Image.asset("lib/assets/images/logo@3x.png"),
        ),
      ),
    );
  }
}
