import 'dart:convert';

import 'package:pinkGossip/localization/language/language_en.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class OtherStoryViewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> myStories;
  final int initialIndex;
  final String myFireabseiD;

  const OtherStoryViewScreen({
    Key? key,
    required this.myStories,
    required this.initialIndex,
    required this.myFireabseiD,
  }) : super(key: key);

  @override
  State<OtherStoryViewScreen> createState() => _OtherStoryViewScreenState();
}

class _OtherStoryViewScreenState extends State<OtherStoryViewScreen> {
  final StoryController storyController = StoryController();
  late PageController pageController;
  late Map<String, dynamic> currentUserData;
  late List<List<StoryItem>> allStoryItems;

  FocusNode replyFocusNode = FocusNode();

  TextEditingController replyController = TextEditingController();
  String currentStory = "";

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialIndex);
    currentUserData = widget.myStories[widget.initialIndex];

    // Preload all story items
    allStoryItems = _buildAllStoryItems();

    replyFocusNode.addListener(_handleFocusChange);

    pageController.addListener(() {
      final currentPage = pageController.page?.round() ?? 0;
      if (currentPage != widget.initialIndex) {
        setState(() {
          currentUserData = widget.myStories[currentPage];
        });
      }
    });
  }

  void _handleFocusChange() {
    if (replyFocusNode.hasFocus) {
      storyController.pause();
    } else {
      storyController.play();
    }
  }

  @override
  void dispose() {
    storyController.dispose();
    pageController.dispose();
    replyFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileImage =
        currentUserData['profile_image'] ?? 'default_image_url.png';
    final firstName = currentUserData['first_name'] ?? 'Unknown';
    final lastName = currentUserData['last_name'] ?? 'User';
    final salonName = currentUserData['salon_name'] ?? 'Salon';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // bottomNavigationBar: Container(
        //   height: 100,
        //   color: const Color(0xff0c0f14),
        //   child: _buildReplySection(),
        // ),
        body: PageView.builder(
          controller: pageController,
          itemCount: widget.myStories.length,
          itemBuilder: (context, userIndex) {
            // Update the currentUserData for each page
            currentUserData = widget.myStories[userIndex];

            final storyItems = allStoryItems[userIndex];
            final profileImage =
                currentUserData['profile_image'] ?? 'default_image_url.png';
            final firstName = currentUserData['first_name'] ?? 'Unknown';
            final lastName = currentUserData['last_name'] ?? 'User';
            final salonName = currentUserData['salon_name'] ?? 'Salon';
            final oppfirebaseID = currentUserData['firebaseid'] ?? 'null';

            return Stack(
              alignment: Alignment.topCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: StoryView(
                    indicatorHeight: IndicatorHeight.small,
                    controller: storyController,
                    storyItems: storyItems,
                    onStoryShow: (storyItem, index) {
                      // Get the current user's stories
                      List<dynamic> stories = currentUserData['stories'] ?? [];

                      // Check the count of stories
                      print("Stories count: ${stories.length}");

                      // Ensure the index is valid before accessing the story
                      if (index < stories.length) {
                        // Access the current story based on the provided index
                        currentStory = stories[index]['url'] ?? '';
                        print("currentStory == $currentStory");
                      } else {
                        print("Index out of bounds: $index");
                      }

                      // Log each story for debugging
                      for (var story in stories) {
                        print("Story: $story");
                      }
                    },
                    onComplete: () {
                      if (userIndex < widget.myStories.length - 1) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    onVerticalSwipeComplete: (direction) {
                      if (direction == Direction.down) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: _buildHeader(
                    profileImage,
                    firstName,
                    lastName,
                    salonName,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    color: Colors.black26,
                    // color: const Color(0xff0c0f14),
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
                              if (replyText.isNotEmpty) {
                                final content = {
                                  'mediaUrl': currentStory ?? '',
                                  'text': replyText,
                                };

                                print("content == ${content}");

                                storyReply(
                                  oppfirebaseID,
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
                ),
              ],
            );
          },
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
                backgroundImage: NetworkImage(
                  "${API.baseUrl}/api/$profileImage",
                ),
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

  List<List<StoryItem>> _buildAllStoryItems() {
    List<List<StoryItem>> allStoryItems = [];

    for (var user in widget.myStories) {
      List<StoryItem> storyItems = [];

      for (var story in user['stories'] as List<Map<String, String?>>) {
        final url =
            story['url'] != null && story['url']!.isNotEmpty
                ? "${API.baseUrl}/api/${story['url']!.trim()}"
                : '';

        // Check if the URL is a valid video
        if (url.isEmpty) {
          storyItems.add(
            StoryItem.text(
              title: 'Error: Media not available',
              backgroundColor: Colors.red,
            ),
          );
        } else if (url.endsWith(".mp4")) {
          storyItems.add(
            StoryItem.pageVideo(
              url,
              duration: const Duration(seconds: 12),
              controller: storyController,
              imageFit: BoxFit.cover,
              shown: true,
            ),
          );
        } else {
          storyItems.add(
            StoryItem.pageImage(
              url: url,
              duration: const Duration(seconds: 10),
              controller: storyController,
              imageFit: BoxFit.cover,
            ),
          );
        }
      }

      allStoryItems.add(storyItems);
    }

    return allStoryItems;
  }
}
