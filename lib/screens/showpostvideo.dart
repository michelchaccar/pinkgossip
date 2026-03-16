// ignore_for_file: must_be_immutable, deprecated_member_use, avoid_print
import 'dart:async';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/videoplayer.dart';
import 'package:chewie/chewie.dart';
// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:pinkGossip/components/pg_app_bar.dart';
import 'package:video_player/video_player.dart';

class ShowPostVideo extends StatefulWidget {
  final List<String> getvideoList;
  int selectedLessonIndex = 0;

  ShowPostVideo({
    super.key,
    required this.getvideoList,
    required this.selectedLessonIndex,
  });

  @override
  State<ShowPostVideo> createState() => _ShowPostVideoState();
}

class _ShowPostVideoState extends State<ShowPostVideo> {
  // String videoUrl =  "http://52.201.213.202:8000/api/pink-gossip-image_picker_83FD2D2 -1703044080482.mp4";

  // late FlickManager flickManager;

  PageController? _controller;

  _scrollListener() {}

  @override
  void initState() {
    super.initState();

    _controller = PageController();

    _controller!.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller!.hasClients) {
        _controller!.animateTo(
          (widget.selectedLessonIndex *
              MediaQuery.of(context).size.height /
              1.2),
          duration: const Duration(milliseconds: 1),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    // flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kAppBArBGColor,
      appBar: PgAppBar(
        title: Languages.of(context)!.videoText,
      ),
      body: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.getvideoList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Container(
                height: kSize.height / 1.2,
                width: kSize.width,
                color: AppColors.bgPrimary,
                child: MyVideoPlayer(videoUrl: widget.getvideoList[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
