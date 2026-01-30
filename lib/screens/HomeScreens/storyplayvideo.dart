import 'dart:async';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const StoryVideoPlayer({super.key, required this.videoUrl});

  @override
  _StoryVideoPlayerState createState() => _StoryVideoPlayerState();
}

class _StoryVideoPlayerState extends State<StoryVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isPaused = true;
  late ValueNotifier<Duration> _videoPositionNotifier;
  late ValueNotifier<Duration> _videoDurationNotifier;
  Timer? _hidePlayIconTimer;

  @override
  void initState() {
    super.initState();

    print("videoUrl ======= ${widget.videoUrl}");

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    // Initialize the video controller and then set the ChewieController
    _videoPlayerController
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoPlayerController,
                autoPlay: true,
                looping: false,
                showControls: false,
              );

              _videoPositionNotifier = ValueNotifier(Duration.zero);
              _videoDurationNotifier = ValueNotifier(Duration.zero);

              // Add listener after initialization
              _videoPlayerController.addListener(() {
                if (_videoPlayerController.value.isInitialized) {
                  _videoPositionNotifier.value =
                      _videoPlayerController.value.position;
                  _videoDurationNotifier.value =
                      _videoPlayerController.value.duration;

                  setState(() {
                    _isPaused = !_videoPlayerController.value.isPlaying;
                  });
                }
              });
            });
          }
        })
        .catchError((error) {
          // Handle errors if initialization fails
          print("Error initializing video player: $error");
        });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _videoPositionNotifier.dispose();
    _videoDurationNotifier.dispose();
    _hidePlayIconTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerController.value.isInitialized
        ? Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController),
              ),
            ),
          ),
        )
        : const Center(child: CircularProgressIndicator());
  }
}
