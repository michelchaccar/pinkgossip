// ignore_for_file: non_constant_identifier_names

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/viewModels/notificationviewmode.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/getnotificationmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Color> ColorArr = [
    AppColors.kAppBArBGColor,
    AppColors.kAppBArBGColor,
    AppColors.lightPink,
    AppColors.lightPink,
    AppColors.kAppBArBGColor,
    AppColors.kAppBArBGColor,
    AppColors.kAppBArBGColor,
    AppColors.kAppBArBGColor,
    AppColors.lightPink,
    AppColors.kAppBArBGColor,
    AppColors.lightPink,
    AppColors.lightPink,
    AppColors.lightPink,
    AppColors.kAppBArBGColor,
    AppColors.lightPink,
  ];

  List<GetNotification>? notificationList;

  bool isLoading = false;
  SharedPreferences? prefs;

  String userid = "";
  int tmppageKey = 1;
  String userTyppe = "";
  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;

    print("userid   ${userid}");
  }

  @override
  void initState() {
    super.initState();
    getuserid();
    getNotificationList();
  }

  String getpostTime(DateTime loadedTime) {
    print("loadedTime === ${loadedTime}");
    final now = DateTime.now();
    final difference = now.difference(loadedTime);

    if (difference.inDays > 365) {
      // If it's been more than a year
      int years = (difference.inDays / 365).floor();
      return years == 1
          ? '$years ${Languages.of(context)!.yearagoText}'
          : '$years ${Languages.of(context)!.yearsagoText}';
    } else if (difference.inDays > 30) {
      // If it's been more than a month
      int months = (difference.inDays / 30).floor();
      return months == 1
          ? '$months ${Languages.of(context)!.monthagoText}'
          : '$months ${Languages.of(context)!.monthsagoText}';
    } else if (difference.inDays > 0) {
      // If it's been more than a day
      return difference.inDays == 1
          ? '${difference.inDays} ${Languages.of(context)!.dayagoText}'
          : '${difference.inDays} ${Languages.of(context)!.daysagoText}';
    } else if (difference.inHours > 0) {
      // If it's been more than an hour
      return difference.inHours == 1
          ? '${difference.inHours} ${Languages.of(context)!.houragoText}'
          : '${difference.inHours} ${Languages.of(context)!.hoursagoText}';
    } else if (difference.inMinutes > 0) {
      // If it's been more than a minute
      return difference.inMinutes == 1
          ? '${difference.inMinutes} ${Languages.of(context)!.minuteeagoText}'
          : '${difference.inMinutes} ${Languages.of(context)!.minutesagoText}';
    } else {
      // If it's been less than a minute
      return Languages.of(context)!.justnowText;
    }
  }
  // String getpostTime(DateTime loadedTime) {
  //   print("loadedTime === ${loadedTime}");
  //   final now = DateTime.now();
  //   final difference = now.difference(loadedTime);
  //   DateTime postTime = now.subtract(difference);

  //   String timeAgo = timeago.format(postTime, locale: 'en');

  //   print("postDateTime === ${timeAgo}");
  //   return timeAgo;
  // }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.kAppBArBGColor,
        automaticallyImplyLeading: false,
        elevation: 2.0,
        title: Row(
          children: [
            InkWell(
              overlayColor: const WidgetStatePropertyAll(AppColors.kWhiteColor),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(ImageUtils.leftarrow),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              Languages.of(context)!.notificationsText,
              style: Pallete.Quicksand16drkBlackBold,
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? Container(
                height: kSize.height,
                width: kSize.width,
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.kPinkColor),
                ),
              )
              : notificationList!.isNotEmpty
              ? RefreshIndicator(
                color: AppColors.kPinkColor,
                onRefresh: () async {
                  notificationList!.clear();
                  getNotificationList();
                },
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notificationList!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 2,
                              color: AppColors.kBorderColor,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(27.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(27.5),
                                  child: Image.network(
                                    "${API.baseUrl}/api/${notificationList![index].profileImage!}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          color: AppColors.chatSenderColor,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: const Icon(Icons.person),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${notificationList![index].firstName!}${notificationList![index].lastName!}",
                                          style: Pallete
                                              .Quicksand12whiteBold.copyWith(
                                            color: AppColors.kBlackColor,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            notificationList![index].text!,
                                            style:
                                                Pallete.Quicksand12blackwe600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      getpostTime(
                                        notificationList![index].createdAt!,
                                      ),
                                      style: Pallete.Quicksand12blackwe500,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              : Center(
                child: Text(
                  Languages.of(context)!.nodatafoundText,
                  style: Pallete.Quicksand16drkBlackBold,
                ),
              ),
    );
  }

  getNotificationList() async {
    print("getProfile get function call");
    setState(() {
      isLoading = true;
    });
    await getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        print("in isConnected ${isConnected}");
        await Provider.of<NotificationListViewModel>(
          context,
          listen: false,
        ).getNotificationList(userid);
        if (Provider.of<NotificationListViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          print("in isLoading == false");

          if (Provider.of<NotificationListViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            print("in isSuccess == true");

            setState(() {
              isLoading = false;
              GetNotificationModel model =
                  Provider.of<NotificationListViewModel>(
                        context,
                        listen: false,
                      ).notificationresponse.response
                      as GetNotificationModel;

              print("model.notifications! =${model.notifications!.length}");
              if (model.success == false) {
                setState(() {
                  isLoading = false;
                });
              }
              notificationList = model.notifications!.reversed.toList();
            });
          } else {
            setState(() {
              notificationList = [];
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }
}
