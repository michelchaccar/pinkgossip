import 'dart:async';

import 'package:pinkGossip/utils/color_utils.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MyVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const MyVideoPlayer({super.key, required this.videoUrl});

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isControlsVisible = true;
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

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      showControls: false,
    );

    _videoPositionNotifier = ValueNotifier(Duration.zero);
    _videoDurationNotifier = ValueNotifier(Duration.zero);

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isInitialized) {
        _videoPositionNotifier.value = _videoPlayerController.value.position;
        _videoDurationNotifier.value = _videoPlayerController.value.duration;

        setState(() {
          _isPaused = !_videoPlayerController.value.isPlaying;

          if (_isPaused) {
            _isControlsVisible = true;
            _hidePlayIconTimer?.cancel();
          }
        });
      }
    });

    _videoPlayerController.initialize().then((_) {
      setState(() {});
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

  void _togglePlayPause() {
    if (_chewieController.isPlaying) {
      _chewieController.pause();
      setState(() {
        _isPaused = true;
        _isControlsVisible = true;
      });
      _hidePlayIconTimer?.cancel();
    } else {
      _chewieController.play();
      setState(() {
        _isPaused = false;
        _isControlsVisible = true;

        _hidePlayIconTimer?.cancel();
        _hidePlayIconTimer = Timer(const Duration(seconds: 2), () {
          if (_chewieController.isPlaying) {
            setState(() {
              _isControlsVisible = false;
            });
          }
        });
      });
    }
  }

  void _handleVisibility(double visibleFraction) {
    final shouldPlay = visibleFraction > 0.6; // play if more than 60% visible
    if (shouldPlay && !_chewieController.isPlaying) {
      _chewieController.play();
    } else if (!shouldPlay && _chewieController.isPlaying) {
      _chewieController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoAspectRatio = _videoPlayerController.value.aspectRatio;
    final maxHeight =
        MediaQuery.of(context).size.height * 0.6; // 60% of screen height
    final maxWidth =
        MediaQuery.of(context).size.width * 0.9; // 90% of screen width

    double frameWidth = maxWidth;
    double frameHeight = frameWidth / videoAspectRatio;

    // Adjust for portrait videos exceeding maxHeight
    if (frameHeight > maxHeight) {
      frameHeight = maxHeight;
      frameWidth = frameHeight * videoAspectRatio;
    }
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (visibilityInfo) {
        _handleVisibility(visibilityInfo.visibleFraction);
      },
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: VideoPlayer(_videoPlayerController),
                ),
              ),
            ),
            if (_isControlsVisible)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.kPinkColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      _isPaused ? Icons.play_arrow_rounded : Icons.pause,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _videoPositionNotifier,
      builder: (context, position, child) {
        return ValueListenableBuilder<Duration>(
          valueListenable: _videoDurationNotifier,
          builder: (context, duration, child) {
            final double progress =
                duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0;
            return SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.kPinkColor,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
