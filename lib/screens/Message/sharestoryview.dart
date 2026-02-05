import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class ShareStoryView extends StatefulWidget {
  final String storyUrl,
      userimage,
      username; // This will hold the URL of the story (image or video)
  final bool
  isVideo; // This will determine whether the story is an image or video

  const ShareStoryView({
    super.key,
    required this.storyUrl,
    required this.isVideo,
    required this.userimage,
    required this.username,
  });

  @override
  State<ShareStoryView> createState() => _ShareStoryViewState();
}

class _ShareStoryViewState extends State<ShareStoryView> {
  final StoryController storyController = StoryController();

  @override
  void dispose() {
    // Dispose the story controller when the widget is disposed
    storyController.dispose();
    super.dispose();
  }

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

                controller: storyController, // Pass the story controller
                storyItems: [
                  // Check if the story is a video or image, and build accordingly
                  widget.isVideo
                      ? StoryItem.pageVideo(
                        widget.storyUrl,
                        controller: storyController,
                        duration: const Duration(seconds: 10), // Video duration
                      )
                      : StoryItem.pageImage(
                        url: widget.storyUrl,
                        controller: storyController,
                        duration: const Duration(seconds: 5),
                      ),
                ],
                onComplete: () {
                  Navigator.of(context).pop();
                },
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.of(context).pop(); // Swipe down to close
                  }
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: _buildHeader(widget.userimage, widget.username),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String profileImage, String name) {
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
                  child: Text(name, style: Pallete.Quicksand16Whiitewe600),
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
                child: Icon(Icons.close, color: Colors.white, size: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
