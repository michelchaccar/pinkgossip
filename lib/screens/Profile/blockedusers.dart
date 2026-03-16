import 'dart:ui';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/blockedusermodel.dart';
import 'package:pinkGossip/models/deletepostmodel.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:pinkGossip/components/pg_app_bar.dart';
import 'package:pinkGossip/viewModels/blockuserviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockedusersScreen extends StatefulWidget {
  const BlockedusersScreen({super.key});

  @override
  State<BlockedusersScreen> createState() => _BlockedusersScreenState();
}

class _BlockedusersScreenState extends State<BlockedusersScreen> {
  bool isReqLoading = false;
  bool isLoading = false;
  String userid = "";
  List<BlockedUserDatum> blockedUsersDatum = [];
  getuserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString('userid')!;
    print("userid   ${userid}");
  }

  @override
  void initState() {
    super.initState();
    getBlockedUser();
  }

  getBlockedUser() async {
    print("get getBlockedUser function call");
    getuserid();
    setState(() {
      isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<BlockUserViewModel>(
          context,
          listen: false,
        ).getBlockedUser(userid);
        if (Provider.of<BlockUserViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<BlockUserViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              BlockedUserResponseModel model =
                  Provider.of<BlockUserViewModel>(
                        context,
                        listen: false,
                      ).allblockeduserresponse.response
                      as BlockedUserResponseModel;
              blockedUsersDatum = model.notifications ?? [];
              isLoading = false;
              print("Success");
            });
          } else {
            setState(() {
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

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: PgAppBar(
        title: Languages.of(context)!.blockedusersText,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              isLoading
                  ? Expanded(
                    child: Container(
                      width: kSize.width,
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.chatSenderColor,
                        ),
                      ),
                    ),
                  )
                  : blockedUsersDatum.isEmpty
                  ? Expanded(
                    child: Center(
                      child: Text(
                        Languages.of(context)!.nodatafoundText,
                        style: AppTypography.bodySemiBold.copyWith(fontSize: 15),
                      ),
                    ),
                  )
                  : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ListView.builder(
                        itemCount: blockedUsersDatum.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 10,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 0.6,
                                    color: AppColors.kTextFieldBorderColor,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25.0,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage:
                                                blockedUsersDatum[index]
                                                            .profileImage !=
                                                        null
                                                    ? NetworkImage(
                                                      "${API.baseUrl}/api/${blockedUsersDatum[index].profileImage}",
                                                    )
                                                    : const AssetImage(
                                                          "lib/assets/images/person.png",
                                                        )
                                                        as ImageProvider<
                                                          Object
                                                        >,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              "${blockedUsersDatum[index].firstName} ${blockedUsersDatum[index].lastName}",
                                              style:
                                                  AppTypography.bodySemiBold.copyWith(fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _showReportUserAlertDialog(
                                          blockedUsersDatum[index].blockUserId
                                              .toString(),
                                          index,
                                        );
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 135,
                                        decoration: BoxDecoration(
                                          color: AppColors.actionPrimary,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            Languages.of(context)!.unblockText,
                                            style:
                                                AppTypography.bodySemiBold.copyWith(color: AppColors.bgPrimary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            ],
          ),
          isReqLoading
              ? Container(
                width: kSize.width,
                color: Colors.transparent,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.actionPrimary),
                ),
              )
              : Container(),
        ],
      ),
    );
  }

  void _showReportUserAlertDialog(String frdId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: StatefulBuilder(
            builder: (context, setAState) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.start,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: Colors.white,
                alignment: Alignment.center,
                contentPadding: EdgeInsets.zero,
                insetPadding: const EdgeInsets.only(left: 10, right: 10),
                actions: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            Languages.of(context)!.unblockalertmsgText,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(fontSize: 17),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await unBlockUser(userid, frdId, index);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 40,
                                  // width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.actionPrimary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      Languages.of(context)!.unblockText,
                                      style: AppTypography.bodySemiBold.copyWith(color: AppColors.bgPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 40,
                                  // width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.actionPrimary,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      Languages.of(context)!.cancelText,
                                      style: AppTypography.bodySemiBold.copyWith(color: AppColors.actionPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  unBlockUser(String userId, String blockUserId, int index) async {
    print("get unBlockUser function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<BlockUserViewModel>(
          context,
          listen: false,
        ).unBlockUser(userId, blockUserId);
        if (Provider.of<BlockUserViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<BlockUserViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            print("Success");
            PostDeleteModel model =
                Provider.of<BlockUserViewModel>(
                      context,
                      listen: false,
                    ).unblockuserresponse.response
                    as PostDeleteModel;
            blockedUsersDatum.removeAt(index);
            kToast(model.message!);
            setState(() {
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
