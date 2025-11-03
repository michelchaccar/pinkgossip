// import 'dart:async';
// import 'package:pinkGossip/screens/HomeScreens/storyplayvideo.dart';
// import 'package:pinkGossip/utils/color_utils.dart';
// import 'package:pinkGossip/utils/custom.dart';
// import 'package:pinkGossip/utils/pallete.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:pinkGossip/models/getstorylistmodel.dart';

// class MyStoryView extends StatefulWidget {
//   final String img, firstname, lastname, salonanme;
//   final List<Stories>? myStorysArray;

//   const MyStoryView({
//     super.key,
//     required this.myStorysArray,
//     required this.firstname,
//     required this.img,
//     required this.lastname,
//     required this.salonanme,
//   });

//   @override
//   State<MyStoryView> createState() => _MyStoryViewState();
// }

// class _MyStoryViewState extends State<MyStoryView> {
//   VideoPlayerController? _videoController;
//   int _currentStoryIndex = 0;
//   Timer? _storyTimer;
//   double _progress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _playCurrentStory();
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _storyTimer?.cancel();
//     super.dispose();
//   }

//   void _playCurrentStory() {
//     if (_currentStoryIndex < widget.myStorysArray!.length) {
//       final story = widget.myStorysArray![_currentStoryIndex];
//       final isVideo = story.storyData!.endsWith('.mp4');

//       // Dispose the previous video controller if any
//       _videoController?.dispose();

//       if (isVideo) {
//         _videoController = VideoPlayerController.network(
//           "${API.baseUrl}/api/${story.storyData!}",
//         )..initialize().then((_) {
//             setState(() {
//               _videoController!.play();
//               _videoController!.setLooping(false);
//               _progress = 0.0;

//               // Listen for the video end and move to the next story
//               _videoController!.addListener(() {
//                 if (_videoController!.value.position >=
//                     _videoController!.value.duration) {
//                   _nextStory();
//                 }
//               });
//             });
//           });
//       } else {
//         // For image, use a fixed duration of 10 seconds
//         _videoController = null;
//         _progress = 0.0;
//         _storyTimer?.cancel();
//         _storyTimer =
//             Timer.periodic(const Duration(milliseconds: 100), (timer) {
//           setState(() {
//             _progress += 0.01;
//             if (_progress >= 1.0) {
//               _nextStory();
//               timer.cancel();
//             }
//           });
//         });
//       }
//     } else {
//       Navigator.of(context).pop();
//     }
//   }

//   void _nextStory() {
//     if (_currentStoryIndex < widget.myStorysArray!.length - 1) {
//       setState(() {
//         _currentStoryIndex++;
//         _progress = 0.0;
//         _playCurrentStory();
//       });
//     } else {
//       Navigator.of(context).pop();
//     }
//   }

//   void _previousStory() {
//     if (_currentStoryIndex > 0) {
//       setState(() {
//         _currentStoryIndex--;
//         _progress = 0.0;
//         _playCurrentStory();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final story = widget.myStorysArray![_currentStoryIndex];
//     final isVideo = story.storyData!.endsWith('.mp4');
//     String vUrl = "${API.baseUrl}/api/${story.storyData!}";

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey.shade900,
//         body: GestureDetector(
//           onTapUp: (details) {
//             var screenWidth = MediaQuery.of(context).size.width;
//             if (details.globalPosition.dx < screenWidth / 2) {
//               _previousStory();
//             } else {
//               _nextStory();
//             }
//           },
//           child: SizedBox(
//             height: double.infinity,
//             width: double.infinity,
//             child: Stack(
//               children: [
//                 Center(
//                   child: isVideo
//                       ? StoryVideoPlayer(videoUrl: vUrl)
//                       : Image.network(
//                           "${API.baseUrl}/api/${story.storyData!}",
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: double.infinity,
//                         ),
//                 ),
//                 Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     Row(
//                       children:
//                           List.generate(widget.myStorysArray!.length, (index) {
//                         return Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 2),
//                             height: 3,
//                             decoration: BoxDecoration(
//                               color: index == _currentStoryIndex
//                                   ? AppColors.kWhiteColor
//                                   : Colors.grey,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.only(top: 10, left: 10),
//                               height: 45,
//                               width: 45,
//                               decoration: BoxDecoration(
//                                 color: AppColors.kWhiteColor,
//                                 borderRadius: BorderRadius.circular(22.5),
//                                 image: DecorationImage(
//                                   fit: BoxFit.cover,
//                                   image: NetworkImage(
//                                     "${API.baseUrl}/api/${widget.img}",
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             SizedBox(
//                               height: 52,
//                               child: Center(
//                                 child: Text(
//                                   widget.firstname.isNotEmpty ||
//                                           widget.lastname.isNotEmpty
//                                       ? "${widget.firstname} ${widget.lastname}"
//                                       : widget.salonanme,
//                                   style: Pallete.Quicksand17Whiitewe600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(right: 15),
//                           child: InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Align(
//                               alignment: Alignment.topRight,
//                               child: Icon(
//                                 Icons.close,
//                                 color: Colors.white,
//                                 size: 25,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';

class MyStoryView extends StatefulWidget {
  final String img, firstname, lastname, salonanme;
  final List<Stories>? myStorysArray;

  const MyStoryView({
    super.key,
    required this.myStorysArray,
    required this.firstname,
    required this.img,
    required this.lastname,
    required this.salonanme,
  });

  @override
  State<MyStoryView> createState() => _MyStoryViewState();
}

class _MyStoryViewState extends State<MyStoryView> {
  final StoryController storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build story items using the _buildStoryItems() function
    List<StoryItem> storyItems = _buildStoryItems();

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
                controller: storyController,
                storyItems: storyItems,
                onComplete: () {
                  Navigator.of(context).pop();
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
                widget.img,
                widget.firstname,
                widget.lastname,
                widget.salonanme,
              ),
            ),
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

  List<StoryItem> _buildStoryItems() {
    List<StoryItem> storyItems = [];

    // Iterate over the user's stories and add them as StoryItems
    for (var story in widget.myStorysArray!) {
      final url = story.storyData; // Assuming story model has a 'url' field

      if (url == null || url.isEmpty) {
        storyItems.add(
          StoryItem.text(
            title: 'Error: Media not available',
            backgroundColor: Colors.red,
          ),
        );
      } else if (url.endsWith(".mp4")) {
        storyItems.add(
          StoryItem.pageVideo(
            imageFit: BoxFit.cover,
            "${API.baseUrl}/api/$url",
            duration: const Duration(seconds: 12),
            controller: storyController,
          ),
        );
      } else {
        storyItems.add(
          StoryItem.pageImage(
            imageFit: BoxFit.cover,
            url: "${API.baseUrl}/api/$url",
            duration: const Duration(seconds: 10),
            controller: storyController,
          ),
        );
      }
    }

    return storyItems;
  }
}
