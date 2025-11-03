import 'dart:convert';

import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/utils/apiservice.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  bool isFromDeeplink = false;
  final GlobalKey<NavigatorState> navigatorKey;
  DeepLinkHandler({required this.navigatorKey});

  Future<void> initDeepLinks() async {
    // Handle deep link when app is started
    // final appLink = await _appLinks.getInitialAppLink();
    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      _handleDeepLink(appLink);
    }
    // Handle deep link when app is already running
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Parse the URI
    print("_handleDeepLink - uri $uri");
    List<String> segments = uri.pathSegments;
    // Handle profile deep links
    if (segments.length >= 2 && segments[0] == 'profile') {
      String username = segments[1];
      _navigateToProfile(username);
    }
    // Handle other deep links if needed
  }

  void _navigateToProfile(String username) {
    // Navigate to profile page
    // navigatorKey.currentState?.pushNamed(
    //   '/profile',
    //   arguments: {'username': username},
    // );
    getUserIdFromUserName(username);
  }

  getUserIdFromUserName(String username) async {
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        var response = await APIService.getUserID_and_Type(username);
        if (response is Success) {
          Success result = response;
          if (result.success == true) {
            //
            Map responce = json.decode(result.response.toString());

            String passedId = responce['user_profile']['id'].toString();
            String userType = responce['user_profile']['user_type'].toString();
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder:
                    (_) => SalonDetailScreen(id: passedId, userType: userType),
              ),
            );
          } else {
            //
          }
        }
      }
    });
  }
}
