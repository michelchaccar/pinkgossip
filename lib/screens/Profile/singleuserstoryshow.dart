import 'dart:convert';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/allfollowersorfollowingmodel.dart';
import 'package:pinkGossip/models/homepagepostmodel.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class SingleUserStoryView extends StatefulWidget {
  String myFireabseiD, profileimage, firstname, lastname, salonname, type;
  final List<StoryDatumUserList>? storyData;
  final List<StoryUserDetails>? storyUserDetailsData;
  final List<Story>? storyOtherHomeData;
  final List<StoryDatum>? storyFollowFollowingData;

  SingleUserStoryView({
    Key? key,
    this.storyData,
    required this.myFireabseiD,
    required this.profileimage,
    required this.firstname,
    required this.lastname,
    required this.salonname,
    required this.type,
    this.storyUserDetailsData,
    this.storyOtherHomeData,
    this.storyFollowFollowingData,
  }) : super(key: key);

  @override
  State<SingleUserStoryView> createState() => _SingleUserStoryViewState();
}

class _SingleUserStoryViewState extends State<SingleUserStoryView> {
  final StoryController storyController = StoryController();
  late List<StoryItem> storyItems;

  FocusNode replyFocusNode = FocusNode();

  TextEditingController replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    replyFocusNode.addListener(_handleFocusChange);

    if (widget.type == "UserList") {
      storyItems =
          widget.storyData != null
              ? widget.storyData!.map((story) {
                String? mediaUrl = "${API.baseUrl}/api/${story.storyData}";
                if (mediaUrl != null) {
                  // Check if the media is an image (jpg or JPG)
                  if (mediaUrl.endsWith('.jpg') || mediaUrl.endsWith('.JPG')) {
                    return StoryItem.pageImage(
                      url: mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                  // Check if the media is a video (mp4 or MP4)
                  else if (mediaUrl.endsWith('.mp4') ||
                      mediaUrl.endsWith('.MP4') ||
                      mediaUrl.endsWith('.mov')) {
                    return StoryItem.pageVideo(
                      mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                }
                // Default to a text story if media type is unknown
                return StoryItem.text(
                  title: "Unknown Story",
                  backgroundColor: Colors.blueGrey,
                );
              }).toList()
              : [];
    } else if (widget.type == "Details") {
      storyItems =
          widget.storyUserDetailsData != null
              ? widget.storyUserDetailsData!.map((story) {
                String? mediaUrl = "${API.baseUrl}/api/${story.storyData}";
                if (mediaUrl != null) {
                  // Check if the media is an image (jpg or JPG)
                  if (mediaUrl.endsWith('.jpg') || mediaUrl.endsWith('.JPG')) {
                    return StoryItem.pageImage(
                      url: mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                  // Check if the media is a video (mp4 or MP4)
                  else if (mediaUrl.endsWith('.mp4') ||
                      mediaUrl.endsWith('.MP4') ||
                      mediaUrl.endsWith('.mov')) {
                    return StoryItem.pageVideo(
                      mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                }
                // Default to a text story if media type is unknown
                return StoryItem.text(
                  title: "Unknown Story",
                  backgroundColor: Colors.blueGrey,
                );
              }).toList()
              : [];
    } else if (widget.type == "Home") {
      storyItems =
          widget.storyOtherHomeData != null
              ? widget.storyOtherHomeData!.map((story) {
                String? mediaUrl = "${API.baseUrl}/api/${story.storyData}";
                if (mediaUrl != null) {
                  // Check if the media is an image (jpg or JPG)
                  if (mediaUrl.endsWith('.jpg') || mediaUrl.endsWith('.JPG')) {
                    return StoryItem.pageImage(
                      url: mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                  // Check if the media is a video (mp4 or MP4)
                  else if (mediaUrl.endsWith('.mp4') ||
                      mediaUrl.endsWith('.MP4') ||
                      mediaUrl.endsWith('.mov')) {
                    return StoryItem.pageVideo(
                      mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                }
                // Default to a text story if media type is unknown
                return StoryItem.text(
                  title: "Unknown Story",
                  backgroundColor: Colors.blueGrey,
                );
              }).toList()
              : [];
    } else if (widget.type == "Followers") {
      storyItems =
          widget.storyFollowFollowingData != null
              ? widget.storyFollowFollowingData!.map((story) {
                String? mediaUrl = "${API.baseUrl}/api/${story.storyData}";
                if (mediaUrl != null) {
                  // Check if the media is an image (jpg or JPG)
                  if (mediaUrl.endsWith('.jpg') || mediaUrl.endsWith('.JPG')) {
                    return StoryItem.pageImage(
                      url: mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                  // Check if the media is a video (mp4 or MP4)
                  else if (mediaUrl.endsWith('.mp4') ||
                      mediaUrl.endsWith('.MP4') ||
                      mediaUrl.endsWith('.mov')) {
                    return StoryItem.pageVideo(
                      mediaUrl,
                      controller: storyController,
                      imageFit: BoxFit.cover,
                    );
                  }
                }
                // Default to a text story if media type is unknown
                return StoryItem.text(
                  title: "Unknown Story",
                  backgroundColor: Colors.blueGrey,
                );
              }).toList()
              : [];
    }
  }

  @override
  void dispose() {
    storyController.dispose();
    replyFocusNode.dispose();
    storyController.dispose();

    super.dispose();
  }

  void _handleFocusChange() {
    if (replyFocusNode.hasFocus) {
      storyController.pause();
    } else {
      storyController.play();
    }
  }

  String currentStory = "";
  String oppFirebaseID = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: StoryView(
                indicatorHeight: IndicatorHeight.small,
                storyItems: storyItems,
                controller: storyController,
                onStoryShow: (storyItem, index) {
                  // print("current url ${widget.storyData![index].storyData}");
                  if (widget.type == "UserList") {
                    currentStory = widget.storyData![index].storyData!;
                    oppFirebaseID = widget.storyData![index].firebaseId!;
                  } else if (widget.type == "Details") {
                    currentStory =
                        widget.storyUserDetailsData![index].storyData!;
                    oppFirebaseID =
                        widget.storyUserDetailsData![index].firebaseId!;
                  } else if (widget.type == "Home") {
                    currentStory = widget.storyOtherHomeData![index].storyData!;
                    oppFirebaseID =
                        widget.storyOtherHomeData![index].firebaseId!;
                  } else if (widget.type == "Followers") {
                    currentStory =
                        widget.storyFollowFollowingData![index].storyData!;
                    oppFirebaseID =
                        widget.storyFollowFollowingData![index].firebaseId!;
                  }
                  print("widget.myFireabseiD == ${widget.myFireabseiD}");
                  print("oppFirebaseID == ${oppFirebaseID}");
                },
                onComplete: () {
                  Navigator.pop(context);
                },
                progressPosition: ProgressPosition.top,
                repeat: false,
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: _buildHeader(
                widget.profileimage,
                widget.firstname,
                widget.lastname,
                widget.salonname,
              ),
            ),
            widget.myFireabseiD != oppFirebaseID
                ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    color: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: replyFocusNode,
                              style: Pallete.Quicksand14Whiitewe600,
                              controller: replyController,
                              onEditingComplete: () {
                                replyController.clear();
                                FocusScope.of(context).unfocus();
                              },
                              decoration: InputDecoration(
                                hintText:
                                    Languages.of(context)!.sendamessageText,
                                hintStyle: Pallete.Quicksand14Whiitewe600,
                                fillColor: Colors.grey.shade900,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.kWhiteColor,
                                    width: 2.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.kWhiteColor,
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.kWhiteColor,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.kWhiteColor,
                            ),
                            onPressed: () {
                              final replyText = replyController.text;

                              print("object");
                              if (replyText.isNotEmpty) {
                                final content = {
                                  'mediaUrl': currentStory ?? '',
                                  'text': replyText,
                                };

                                print("content == ${content}");

                                storyReply(
                                  oppFirebaseID,
                                  "currentstory:$currentStory|replytext:$replyText",
                                  2,
                                );
                                replyController.clear();
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String profileImage,
    String firstName,
    String lastName,
    String salonName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(profileImage),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 35,
                child: Center(
                  child: Text(
                    firstName.isNotEmpty || lastName.isNotEmpty
                        ? "$firstName $lastName"
                        : salonName,
                    style: Pallete.Quicksand16Whiitewe600,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.close,
                  color: AppColors.kWhiteColor,
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void storyReply(String oppId, String content, int userType) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
      'message',
    );

    DatabaseReference userRef1 = FirebaseDatabase.instance.ref().child(
      'message',
    );

    var channelKey =
        'chat--${widget.myFireabseiD.replaceFirst("-", "")}-${oppId}';
    var channel2Key =
        'chat-${oppId}--${widget.myFireabseiD.replaceFirst("-", "")}';

    DatabaseEvent channelSnapshot = await userRef.child(channelKey).once();

    DatabaseEvent channel2Snapshot = await userRef.child(channel2Key).once();

    DatabaseReference? chatRef;

    if (channelSnapshot.snapshot.exists) {
      print("ifff channelKey existst === ${channelKey.toString()}");

      DatabaseReference chatRef = FirebaseDatabase.instance
          .ref()
          .child('message')
          .child(channelKey);

      print("chatRef == ${chatRef.root}");
      print("chatRef path == ${chatRef.ref}");

      if (content.isNotEmpty) {
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        Map<String, dynamic> message = {
          'content': jsonEncode(content),
          'idFrom': widget.myFireabseiD,
          'idTo': oppId,
          'timestamp': timestamp,
          'type': userType,
          'isSeen': false,
        };

        chatRef.child(timestamp.toString()).set(message);
      }
    } else if (channel2Snapshot.snapshot.exists) {
      print("elseiifff channel2Key existst === ${channel2Key.toString()}");

      DatabaseReference chatRef = FirebaseDatabase.instance
          .ref()
          .child('message')
          .child(channel2Key);

      print("chatRef == ${chatRef.root}");
      print("chatRef path == ${chatRef.ref}");

      if (content.isNotEmpty) {
        int timestamp = DateTime.now().millisecondsSinceEpoch;

        Map<String, dynamic> message = {
          'content': jsonEncode(content),
          'idFrom': widget.myFireabseiD,
          'idTo': oppId,
          'timestamp': timestamp,
          'type': userType,
          'isSeen': false,
        };

        chatRef.child(timestamp.toString()).set(message);
      }
    } else {
      print("no channel exists");
      // print("channelKey  ${channelKey.toString()}");
      // print("channel2Key ${channel2Key.toString()}");

      var channelKey =
          'chat--${widget.myFireabseiD.replaceFirst('-', "")}-${oppId}';
      print("channelKey = ${channelKey}");
      var timestamp = DateTime.timestamp();

      DatabaseReference messagesRef = userRef
          .child(channelKey)
          .child(timestamp.millisecondsSinceEpoch.toString());

      await messagesRef.set({
        'idFrom': widget.myFireabseiD,
        'idTo': oppId,
        'isSeen': false,
        'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'type': userType,
      });
    }
  }
}
