import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class VideoDisplay extends StatefulWidget {
  final File selectedAsset;

  const VideoDisplay({Key? key, required this.selectedAsset}) : super(key: key);

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _playVideo(widget.selectedAsset);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _playVideo(File asset) async {
    final file = await asset.path;
    if (file != null) {
      _videoPlayerController = VideoPlayerController.file(File(file))
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController?.play();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerController != null &&
            _videoPlayerController!.value.isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoPlayerController!.value.isPlaying) {
                      _videoPlayerController!.pause();
                    } else {
                      _videoPlayerController!.play();
                    }
                  });
                },
                child: Container(
                  color: Colors.amber,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController!),
                  ),
                ),
              ),
              // _videoPlayerController!.value.isPlaying
              //     ? const Icon(Icons.pause)
              //     : const Icon(Icons.play_arrow)
            ],
          )
        : Container();
  }
}
