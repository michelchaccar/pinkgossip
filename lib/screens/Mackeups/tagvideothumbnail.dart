import 'dart:async';

import 'package:pinkGossip/utils/color_utils.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Tagvideothumbnail extends StatefulWidget {
  final String videoUrl;

  const Tagvideothumbnail({super.key, required this.videoUrl});

  @override
  _TagvideothumbnailState createState() => _TagvideothumbnailState();
}

class _TagvideothumbnailState extends State<Tagvideothumbnail> {
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
    // _videoPlayerController = VideoPlayerController.network(widget.videoUrl);

    // _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child:
                _chewieController.videoPlayerController.value.isInitialized
                    ?
                    //  AspectRatio(
                    //     aspectRatio: _chewieController.,
                    // 1 / 1,
                    // child:
                    VideoPlayer(_videoPlayerController)
                    // )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
