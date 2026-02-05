// ignore_for_file: must_be_immutable, deprecated_member_use, avoid_print
import 'dart:async';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/videoplayer.dart';
import 'package:chewie/chewie.dart';
// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
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
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.kAppBArBGColor,
        automaticallyImplyLeading: false,
        elevation: 2.0,
        title: Row(
          children: [
            InkWell(
              overlayColor: const MaterialStatePropertyAll(
                AppColors.kWhiteColor,
              ),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(ImageUtils.leftarrow),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              Languages.of(context)!.videoText,
              style: Pallete.Quicksand16drkBlackBold,
            ),
          ],
        ),
      ),
      body: Scaffold(
        backgroundColor: AppColors.kWhiteColor,
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
                color: AppColors.kWhiteColor,
                child: MyVideoPlayer(videoUrl: widget.getvideoList[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
