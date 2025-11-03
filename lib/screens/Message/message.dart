// ignore_for_file: unused_field, unnecessary_brace_in_string_interps, deprecated_member_use, unnecessary_null_comparison, avoid_print
import 'dart:async';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/Message/messagedetail.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/screens/HomeScreens/notifications.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String firebaseId = "";
  List<Map> usersList = [];
  List<Map> tmpsearchusersList = [];
  List<String> userschat = [];
  List<String> tmpsearchchat = [];
  Map<dynamic, dynamic>? lastMessage;
  List<Map> lastMessageContentList = [];
  List<int> lastMessageTimeList = [];
  List<Map> userunreadCountlist = [];

  DatabaseReference? _chatMessagesRef;

  bool isLoading = true;

  List<Map> filteredUsersList = [];

  getchannellist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firebaseId = prefs.getString('FirebaseId') ?? "";
      isLoading = true;
    });

    DatabaseReference ref = FirebaseDatabase.instance.ref('message');

    ref.once().then((event) {
      var temp = event.snapshot.value;

      Map<dynamic, dynamic> allChanels = temp as Map<dynamic, dynamic>;
      Map<dynamic, dynamic> tmpallChanels = temp as Map<dynamic, dynamic>;
      List<Map>? shortedchannels = [];
      print("tmpallChanels = ${tmpallChanels}");

      tmpallChanels.forEach((key, value) {
        Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic>? tmplastMessage;
        List<String> parts = key.split('--');
        // print("parts == ${parts}");
        if (parts.contains(firebaseId.replaceFirst('-', ''))) {
          int maxTimestamp = 0;
          int unreadCount = 0;
          messages.forEach((messageKey, messageData) {
            unreadCount =
                messages.values
                    .where(
                      (message) =>
                          firebaseId.contains(message['idTo']) &&
                          !(message['isSeen'] ?? false),
                    )
                    .length;

            int timestamp = messageData['timestamp'];
            if (timestamp > maxTimestamp) {
              maxTimestamp = timestamp;
              tmplastMessage = messageData;
            }
          });
          // print(
          //     "tmplastMessage == ${key} ${tmplastMessage!['timestamp']} ${tmplastMessage!['content']}");

          shortedchannels.add({
            'key': key ?? "",
            'lastmessagetime': tmplastMessage!['timestamp'] ?? "",
            'content': tmplastMessage!['content'] ?? "",
            'type': tmplastMessage!['type'],
            'unreadCount': unreadCount,
          });
        }
      });

      shortedchannels.sort(
        (a, b) => (b['lastmessagetime'] as int).compareTo(
          a['lastmessagetime'] as int,
        ),
      );

      shortedchannels.forEach((element) async {
        List<String> parts = element['key'].split('--');
        print("element == ${element['unreadCount']}");

        int idpossition = parts.indexOf(firebaseId.replaceFirst('-', ''));
        if (idpossition == 1) {
          String extractedString = parts.length > 2 ? parts[1] : '';
          print(
            "iff extractedString == ${extractedString} ${element['key'].split('--')[2]}",
          );
          DatabaseReference userListRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child('-${element['key'].split('--')[2]}');

          await userListRef.once().then((snapshot) {
            Map<dynamic, dynamic> userData =
                snapshot.snapshot.value as Map<dynamic, dynamic>;
            // 'lastmessagetime': tmplastMessage!['timestamp'] ?? "",
            //         'content': tmplastMessage!['content'] ?? ""
            userData['lastmessagetime'] = element['lastmessagetime'] ?? "";
            userData['content'] = element['content'] ?? "";
            userData['type'] = element['type'];
            usersList.add(userData);
            filteredUsersList = usersList;
            setState(() {});

            userunreadCountlist.add({
              'userid': userData['id'],
              'unreadCount': element['unreadCount'],
            });
          });
        } else {
          String extractedString = parts.length > 2 ? parts[2] : '';
          print(
            "else  extractedString ==  ${element['key'].split('--')[1]} ${extractedString}",
          );
          DatabaseReference userListRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child('-${element['key'].split('--')[1]}');

          await userListRef.once().then((snapshot) {
            Map<dynamic, dynamic> userData =
                snapshot.snapshot.value as Map<dynamic, dynamic>;

            userData['lastmessagetime'] = element['lastmessagetime'] ?? "";
            userData['content'] = element['content'] ?? "";
            userData['type'] = element['type'];

            usersList.add(userData);
            filteredUsersList = usersList;
            setState(() {});
            userunreadCountlist.add({
              'userid': userData['id'],
              'unreadCount': element['unreadCount'],
            });
          });
        }
        print("userData == ${usersList.length}");
      });

      // allChanels.forEach((key, value) async {
      //   List<String> parts = key.split('--');
      //   // print("parts == ${parts}");
      //   if (parts.contains(firebaseId.replaceFirst('-', ''))) {
      //     int idpossition = parts.indexOf(firebaseId.replaceFirst('-', ''));
      //     if (idpossition == 1) {
      //       String extractedString = parts.length > 2 ? parts[1] : '';
      //       int unreadCount = 0;
      //       if (extractedString == firebaseId.replaceFirst('-', '')) {
      //         DatabaseReference userListRef = FirebaseDatabase.instance
      //             .ref()
      //             .child('users')
      //             .child('-${key.split('--')[2]}');

      //         await userListRef.once().then((snapshot) {
      //           Map<dynamic, dynamic> userData =
      //               snapshot.snapshot.value as Map<dynamic, dynamic>;

      //           Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;

      //           if (messages != null) {
      //             /////
      //             /// FOR LAST MESSAGE SHOW
      //             ///
      //             int maxTimestamp = 0;
      //             messages.forEach((messageKey, messageData) {
      //               int timestamp = messageData['timestamp'];
      //               if (timestamp > maxTimestamp) {
      //                 maxTimestamp = timestamp;
      //                 lastMessage = messageData;
      //               }
      //             });
      //             String? lastMessageContent = lastMessage!['content'];
      //             int? lastMessageTime = lastMessage!['timestamp'];
      //             if (lastMessageContent != null) {
      //               // print("Last Message: $lastMessageContentList");
      //               // print("lastMessageTime: $lastMessageTime");
      //               lastMessageContentList.add({
      //                 'content': lastMessageContent,
      //                 'type': lastMessage!['type']
      //               });
      //               lastMessageTimeList.add(lastMessageTime!);
      //             }
      //             /////
      //             /// FOR LAST MESSAGE SHOW
      //             /////
      //             unreadCount = messages.values
      //                 .where((message) =>
      //                     firebaseId.contains(message['idTo']) &&
      //                     !(message['isSeen'] ?? false))
      //                 .length;
      //           }

      //           userData['unreadCount'] = unreadCount;

      //           usersList.add(userData);
      //           tmpsearchusersList.add(userData);

      //           setState(() {
      //             isLoading = false;
      //           });
      //         });
      //       }
      //     } else {
      //       String extractedString = parts.length > 2 ? parts[2] : '';
      //       int unreadCount = 0;
      //       if (extractedString == firebaseId.replaceFirst('-', '')) {
      //         DatabaseReference userListRef = FirebaseDatabase.instance
      //             .ref()
      //             .child('users')
      //             .child('-${key.split('--')[1]}');

      //         await userListRef.once().then((snapshot) {
      //           Map<dynamic, dynamic> userData =
      //               snapshot.snapshot.value as Map<dynamic, dynamic>;

      //           Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;

      //           if (messages != null) {
      //             /////
      //             /// FOR LAST MESSAGE SHOW
      //             /////
      //             int maxTimestamp = 0;
      //             messages.forEach((messageKey, messageData) {
      //               int timestamp = messageData['timestamp'];
      //               if (timestamp > maxTimestamp) {
      //                 maxTimestamp = timestamp;
      //                 lastMessage = messageData;
      //               }
      //             });
      //             String? lastMessageContent = lastMessage!['content'];
      //             int? lastMessageTime = lastMessage!['timestamp'];
      //             if (lastMessageContent != null) {
      //               // print("Last Message: $lastMessageContentList");
      //               // print("lastMessageTime: $lastMessageTime");
      //               lastMessageContentList.add({
      //                 'content': lastMessageContent,
      //                 'type': lastMessage!['type']
      //               });
      //               lastMessageTimeList.add(lastMessageTime!);
      //             }
      //             /////
      //             /// FOR LAST MESSAGE SHOW
      //             /////
      //             unreadCount = messages.values
      //                 .where((message) =>
      //                     firebaseId.contains(message['idTo']) &&
      //                     !(message['isSeen'] ?? false))
      //                 .length;
      //           }
      //           userData['unreadCount'] = unreadCount;

      //           usersList.add(userData);
      //           tmpsearchusersList.add(userData);

      //           setState(() {
      //             isLoading = false;
      //           });
      //         });
      //       }
      //     }
      //   }
      // });
    });
    ref.onValue.listen((DatabaseEvent event) {
      // print("ref.onValue.listen callledd");
      var temp = event.snapshot.value;
      Map<dynamic, dynamic> allChanels = temp as Map<dynamic, dynamic>;
      // print("allChanels = ${allChanels}");
      userunreadCountlist.clear();

      // allChanels.forEach((key, value) async {
      //   List<String> parts = key.split('--');
      //   // print("parts == ${parts}");
      //   if (parts.contains(firebaseId.replaceFirst('-', ''))) {}
      //   print("key = ${key}");

      //   int idpossition = parts.indexOf(firebaseId.replaceFirst('-', ''));
      //   if (idpossition == 1) {
      //     DatabaseReference userListRef = FirebaseDatabase.instance
      //         .ref()
      //         .child('users')
      //         .child('-${key.split('--')[2]}');

      //     Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;
      //     int unreadCount = messages.values
      //         .where((message) =>
      //             firebaseId.contains(message['idTo']) &&
      //             !(message['isSeen'] ?? false))
      //         .length;

      //     await userListRef.once().then((snapshot) {
      //       Map<dynamic, dynamic> userData =
      //           snapshot.snapshot.value as Map<dynamic, dynamic>;

      //       userunreadCountlist
      //           .add({'userid': userData['id'], 'unreadCount': unreadCount});
      //     });
      //   } else {
      //     DatabaseReference userListRef = FirebaseDatabase.instance
      //         .ref()
      //         .child('users')
      //         .child('-${key.split('--')[1]}');

      //     Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;
      //     int unreadCount = messages.values
      //         .where((message) =>
      //             firebaseId.contains(message['idTo']) &&
      //             !(message['isSeen'] ?? false))
      //         .length;

      //     await userListRef.once().then((snapshot) {
      //       Map<dynamic, dynamic> userData =
      //           snapshot.snapshot.value as Map<dynamic, dynamic>;

      //       userunreadCountlist
      //           .add({'userid': userData['id'], 'unreadCount': unreadCount});
      //     });
      //   }
      // });

      // allChanels.forEach((key, value) async {
      //   List<String> parts = key.split('--');
      //   String extractedString = parts.length > 2 ? parts[1] : '';
      //   // print("extractedSt
      //   //ring = ${extractedString}");

      //   if (extractedString == firebaseId.replaceFirst('-', '')) {
      //     DatabaseReference userListRef = FirebaseDatabase.instance
      //         .ref()
      //         .child('users')
      //         .child('-${key.split('--')[1]}');
      //     await userListRef.once().then((snapshot) {
      //       Map<dynamic, dynamic> userData =
      //           snapshot.snapshot.value as Map<dynamic, dynamic>;
      //       Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;
      //       if (messages != null) {
      //         ///
      //         /// FOR LAST MESSAGE SHOW
      //         ///
      //         int maxTimestamp = 0;
      //         messages.forEach((messageKey, messageData) {
      //           int timestamp = messageData['timestamp'];
      //           if (timestamp > maxTimestamp) {
      //             maxTimestamp = timestamp;
      //             lastMessage = messageData;
      //           }
      //         });
      //         String? lastMessageContent = lastMessage!['content'];
      //         int? lastMessageTime = lastMessage!['timestamp'];
      //         if (lastMessageContent != null) {
      //           // print("Last Message: $lastMessageContentList");
      //           // print("lastMessageTime: $lastMessageTime");
      //           lastMessageContentList.add({
      //             'content': lastMessageContent,
      //             'type': lastMessage!['type']
      //           });
      //           lastMessageTimeList.add(lastMessageTime!);
      //         }
      //         ///
      //         /// FOR LAST MESSAGE SHOW
      //         ///
      //         int unreadCount = messages.values
      //             .where((message) =>
      //                 firebaseId.contains(message['idTo']) &&
      //                 !(message['isSeen'] ?? false))
      //             .length;
      //         userunreadCountlist
      //             .add({'userid': userData['id'], 'unreadCount': unreadCount});
      //       }
      //       setState(() {});
      //     });
      //   }
      // });
    });
  }

  // List<Map<dynamic, dynamic>> filterUsersList(String query) {
  //   if (query.length == 1) {
  //     return tmpsearchusersList;
  //   }
  //   return usersList
  //       .where((user) =>
  //           user['nickname'].toLowerCase().contains(query.toLowerCase()))
  //       .toList();
  // }

  void filterUsersList(String query) {
    if (query.isNotEmpty) {
      List<Map> tempList = [];
      for (var user in usersList) {
        print("user === $user &&& query == $query");
        if (user['nickname'].toLowerCase().contains(query.toLowerCase())) {
          tempList.add(user);
        }
      }
      setState(() {
        filteredUsersList = tempList;
      });
    } else {
      setState(() {
        filteredUsersList = usersList;
      });
    }
  }

  TextEditingController searchcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (isLoading == true) {
        setState(() {
          isLoading = false;
        });
      }
    });
    getchannellist();
    searchcontroller.clear();
  }

  @override
  void dispose() {
    _chatMessagesRef = null;
    super.dispose();
  }

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 50, child: Image.asset(ImageUtils.appbarlogo)),
            Row(
              children: [
                // InkWell(
                //   overlayColor:
                //       const MaterialStatePropertyAll(AppColors.kWhiteColor),
                //   borderRadius: BorderRadius.circular(20),
                //   onTap: () {},
                //   child: SizedBox(
                //     height: 25,
                //     width: 25,
                //     child: Image.asset(ImageUtils.searchimg),
                //   ),
                // ),
                const SizedBox(width: 5),
                InkWell(
                  overlayColor: const MaterialStatePropertyAll(
                    AppColors.kWhiteColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: Image.asset(ImageUtils.notificationimg),
                      ),
                      // Positioned(
                      //   left: 13,
                      //   top: 0,
                      //   child: Container(
                      //     height: 10,
                      //     width: 10,
                      //     decoration: BoxDecoration(
                      //       color: AppColors.kPinkColor,
                      //       borderRadius: BorderRadius.circular(5),
                      //     ),
                      //     // child: const Center(
                      //     //   child: Text(
                      //     //     "1",
                      //     //     style: TextStyle(color: Colors.white),
                      //     //   ),
                      //     // ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 80,
              width: kSize.width,
              color: AppColors.kWhiteColor,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: 12,
                ),
                child: Center(
                  child: TextFormField(
                    controller: searchcontroller,
                    autocorrect: true,
                    onChanged: (query) {
                      filterUsersList(query);
                    },
                    maxLines: 1,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.search,
                    cursorColor: AppColors.kTextColor,
                    decoration: InputDecoration(
                      fillColor: AppColors.kWhiteColor,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 14,
                      ),
                      hintText: Languages.of(context)!.searchText,
                      hintStyle: Pallete.textFieldTextStyle,
                      suffixIcon: const Icon(Icons.search, size: 30),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.kTextFieldBorderColor,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.kPinkColor,
                        ),
                      ),
                      focusColor: AppColors.kPinkColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            isLoading
                ? Container(
                  height: kSize.height,
                  width: kSize.width,
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
                : filteredUsersList.isEmpty
                ? SizedBox(
                  height: kSize.height / 1.5,
                  child: Center(
                    child: Text(Languages.of(context)!.NochathereText),
                  ),
                )
                : SingleChildScrollView(
                  child: SafeArea(
                    // child: ListView.builder(
                    //     itemCount: usersList.length,
                    //     shrinkWrap: true,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     itemBuilder: (context, index) {
                    //       return Container(
                    //         child: Column(
                    //           children: [
                    //             Text(usersList[index]['nickname']),
                    //             Text(usersList[index]['lastmessagetime']
                    //                 .toString()),
                    //             Text(usersList[index]['content']),
                    //           ],
                    //         ),
                    //       );
                    //     }),
                    child: ListView.builder(
                      itemCount: filteredUsersList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        DateTime currentDate = DateTime.now();
                        DateTime yesterdayDate = currentDate.subtract(
                          const Duration(days: 1),
                        );
                        String formattedYesterdayDate = DateFormat(
                          'dd-MM-yyyy',
                        ).format(yesterdayDate);
                        // print(
                        //     "filteredUsersList = ${filteredUsersList[index]['nickname']}  ${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastMessageTimeList[index]))}");

                        // print(
                        //     'Yesterday\'s date: $formattedYesterdayDate');

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: const BorderSide(color: Colors.black12),
                              top:
                                  index == 0
                                      ? const BorderSide(color: Colors.black12)
                                      : const BorderSide(
                                        color: Colors.transparent,
                                      ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                              left: 15,
                              right: 15,
                            ),
                            child: InkWell(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MessageDetail(
                                          oppId: filteredUsersList[index]['id'],
                                          firebaseUId: firebaseId,
                                          name:
                                              filteredUsersList[index]['nickname'],
                                          userImg:
                                              filteredUsersList[index]["photoUrl"],
                                          type: "frommessage",
                                        ),
                                  ),
                                ).then((value) {
                                  filteredUsersList.clear();
                                  searchcontroller.clear();
                                  getchannellist();
                                });
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        filteredUsersList[index]['photoUrl'] !=
                                                ""
                                            ? Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    "${API.baseUrl}/api/${filteredUsersList[index]['photoUrl']}",
                                                  ),
                                                ),
                                                color:
                                                    AppColors.chatReceiverColor,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            )
                                            : Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                color:
                                                    AppColors.chatSenderColor,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: const Icon(Icons.person),
                                            ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    filteredUsersList[index]['nickname'],
                                                    style:
                                                        Pallete
                                                            .Quicksand16drkBlackbold,
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                              'dd-MM-yyyy',
                                                            ).format(
                                                              DateTime.now(),
                                                            ) ==
                                                            DateFormat(
                                                              'dd-MM-yyyy',
                                                            ).format(
                                                              DateTime.fromMillisecondsSinceEpoch(
                                                                filteredUsersList[index]['lastmessagetime'],
                                                              ),
                                                            )
                                                        ? " ${DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(filteredUsersList[index]['lastmessagetime']))}"
                                                        : DateFormat(
                                                              'dd-MM-yyyy',
                                                            ).format(
                                                              DateTime.fromMillisecondsSinceEpoch(
                                                                filteredUsersList[index]['lastmessagetime'],
                                                              ),
                                                            ) ==
                                                            formattedYesterdayDate
                                                        ? "Yesterday"
                                                        : " ${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(filteredUsersList[index]['lastmessagetime']))}",
                                                    // DateFormat('dd-MM-yyyy')
                                                    //             .format(DateTime
                                                    //                 .now()) ==
                                                    //         DateFormat(
                                                    //                 'dd-MM-yyyy')
                                                    //             .format(DateTime.fromMillisecondsSinceEpoch(
                                                    //                 lastMessageTimeList[
                                                    //                     index]))
                                                    //     ? " ${DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(lastMessageTimeList[index]))}"
                                                    //     : DateFormat('dd-MM-yyyy')
                                                    //                 .format(
                                                    //                     DateTime.fromMillisecondsSinceEpoch(lastMessageTimeList[index])) ==
                                                    //             formattedYesterdayDate
                                                    //         ? "Yesterday"
                                                    //         : " ${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastMessageTimeList[index]))}",
                                                    style:
                                                        Pallete
                                                            .Quicksand10Blackkwe600,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    filteredUsersList[index]['type'] ==
                                                            0
                                                        ? filteredUsersList[index]['content']
                                                        : filteredUsersList[index]['type'] ==
                                                            2
                                                        ? Languages.of(
                                                          context,
                                                        )!.storyreplyText
                                                        : Languages.of(
                                                          context,
                                                        )!.sharedapostText,
                                                    // lastMessageContentList[
                                                    //                 index]
                                                    //             [
                                                    //             'type'] ==
                                                    //         0
                                                    //     ? lastMessageContentList[
                                                    //             index]
                                                    //         ['content']
                                                    //     : "Shared a post",
                                                    maxLines: 1,
                                                    style:
                                                        Pallete
                                                            .Quicksand15grey600,
                                                  ),
                                                  userunreadCountlist[index]['unreadCount'] >
                                                          0
                                                      ? Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          color: Colors.green,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            userunreadCountlist[index]['unreadCount']
                                                                .toString(),
                                                            style:
                                                                Pallete
                                                                    .Quicksand10Whiitewe600,
                                                          ),
                                                        ),
                                                      )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Column(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.end,
                                  //   children: [
                                  //     Text(
                                  //       DateFormat('dd-MM-yyyy').format(
                                  //                   DateTime.now()) ==
                                  //               DateFormat('dd-MM-yyyy')
                                  //                   .format(DateTime
                                  //                       .fromMillisecondsSinceEpoch(
                                  //                           lastMessageTimeList[
                                  //                               index]))
                                  //           ? " ${DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(lastMessageTimeList[index]))}"
                                  //           : DateFormat('dd-MM-yyyy').format(
                                  //                       DateTime.fromMillisecondsSinceEpoch(
                                  //                           lastMessageTimeList[
                                  //                               index])) ==
                                  //                   formattedYesterdayDate
                                  //               ? "Yesterday"
                                  //               : " ${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastMessageTimeList[index]))}",
                                  //       style: Pallete
                                  //           .Quicksand10Blackkwe600,
                                  //     ),
                                  //     const SizedBox(height: 10),
                                  //     filteredUsersList[index]['unreadCount'] != 0
                                  //         ? Container(
                                  //             height: 20,
                                  //             width: 20,
                                  //             decoration: BoxDecoration(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(
                                  //                       10),
                                  //               color: Colors.green,
                                  //             ),
                                  //             child: Center(
                                  //               child: Text(
                                  //                 filteredUsersList[index]
                                  //                         ['unreadCount']
                                  //                     .toString(),
                                  //                 style: Pallete
                                  //                     .Quicksand10Whiitewe600,
                                  //               ),
                                  //             ),
                                  //           )
                                  //         : Container(),
                                  //   ],
                                  // ),
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
      ),
    );
  }
}
