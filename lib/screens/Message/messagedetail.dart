// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, deprecated_member_use, must_be_immutable, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/chatmessagemodel.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/screens/HomeScreens/storyplayvideo.dart';
import 'package:pinkGossip/screens/Message/sharestoryview.dart';
import 'package:pinkGossip/screens/sharepostview.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:pinkGossip/components/pg_app_bar.dart';
import 'package:pinkGossip/components/pg_back_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class MessageDetail extends StatefulWidget {
  String oppId = "";
  String firebaseUId = "";
  String name = "";
  String userImg = "";
  String type = "";
  MessageDetail({
    super.key,
    required this.oppId,
    required this.firebaseUId,
    required this.name,
    required this.userImg,
    required this.type,
  });

  @override
  State<MessageDetail> createState() => _MessageDetailState();
}

class _MessageDetailState extends State<MessageDetail> {
  List<ChatMessage> chatMessages = [];
  int prevDate = 0;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DatabaseReference? _chatmessagesRef;

  String firebaseId = "";
  String channelId = "";
  bool isLoading = false;

  VideoPlayerController? _videoController;
  getIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      firebaseId = prefs.getString('FirebaseId') ?? "";
    });
    print("channelId ======= $channelId");

    setState(() {
      firebaseId = prefs.getString('FirebaseId') ?? "";
      isLoading = true;
    });
    print("function call getchannellist");
    print("firebaseId  = ${firebaseId}");

    DatabaseReference ref = FirebaseDatabase.instance.ref('message');

    ref.once().then((event) {
      print("ref.once() callleddd");
      var temp = event.snapshot.value;

      Map<dynamic, dynamic> allChanels = temp as Map<dynamic, dynamic>;
      // print("allChanels = ${allChanels}");

      allChanels.forEach((key, value) async {
        List<String> parts = key.split('--');
        if (parts.contains(firebaseId.replaceFirst('-', ''))) {
          print("parts == ${parts}");
          print("key == ${key}");
          int idpossition = parts.indexOf(firebaseId.replaceFirst('-', ''));

          print("idpossition = ${idpossition}");
          print("widget.oppId = ${widget.oppId}");
          if (idpossition == 1) {
            if (parts[2] == widget.oppId.replaceFirst("-", "")) {
              channelId = key;
              _chatmessagesRef = FirebaseDatabase.instance
                  .ref()
                  .child('message')
                  .child(channelId);
              print("iff _chatmessagesRef == ${_chatmessagesRef!.key}");
              _chatmessagesRef!.once().then((valuechatisSeen) {
                var tempisSeen = valuechatisSeen.snapshot.value;

                Map<dynamic, dynamic> allChanelsisSeen =
                    tempisSeen as Map<dynamic, dynamic>;

                allChanelsisSeen.forEach((key, value) {
                  Map message = value as Map;

                  print("value == ${value['isSeen']}");
                  // print("key == ${key}");
                  if (message['idTo'] == firebaseId &&
                      message['isSeen'] == false) {
                    DatabaseReference messageRef = _chatmessagesRef!.child(key);
                    print("messageRef = ${messageRef.key}");
                    messageRef.update({'isSeen': true});
                  }
                });
                // print("allChanelsisSeen == ${allChanelsisSeen}");
              });
              setState(() {
                isLoading = false;
              });
            }
          } else if (idpossition == 2) {
            if (parts[1] == widget.oppId.replaceAll("-", "")) {
              channelId = key;
              _chatmessagesRef = FirebaseDatabase.instance
                  .ref()
                  .child('message')
                  .child(channelId);
              print("else _chatmessagesRef == ${_chatmessagesRef!.key}");
              _chatmessagesRef!.once().then((valuechatisSeen) {
                var tempisSeen = valuechatisSeen.snapshot.value;

                Map<dynamic, dynamic> allChanelsisSeen =
                    tempisSeen as Map<dynamic, dynamic>;

                allChanelsisSeen.forEach((key, value) {
                  Map message = value as Map;

                  print("value == ${value['isSeen']}");
                  // print("key == ${key}");
                  if (message['idTo'] == firebaseId &&
                      message['isSeen'] == false) {
                    DatabaseReference messageRef = _chatmessagesRef!.child(key);
                    print("messageRef = ${messageRef.key}");
                    messageRef.update({'isSeen': true});
                  }
                });

                // print("allChanelsisSeen == ${allChanelsisSeen}");
              });
              setState(() {
                isLoading = false;
              });
            }
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getIds();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  String? previousDate;

  @override
  void dispose() {
    _scrollController.dispose();
    _chatmessagesRef = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: PgAppBar(
        onBack: () {
          if (widget.type == "fromdetail") {
            Navigator.pop(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavBar(index: 3),
              ),
            );
          }
        },
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PgBackButton(
                onBack: () {
                  if (widget.type == "fromdetail") {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBar(index: 3),
                      ),
                    );
                  }
                },
              ),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: widget.userImg != ""
                      ? Image.network(
                          "${API.baseUrl}/api/${widget.userImg}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(PhosphorIconsRegular.user, size: 18, color: AppColors.textSecondary),
                        )
                      : const Icon(PhosphorIconsRegular.user, size: 18, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.name, style: AppTypography.heading3),
            ],
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _chatmessagesRef == null
                      ? Expanded(child: Container())
                      : Expanded(
                        child: FirebaseAnimatedList(
                          sort:
                              (DataSnapshot a, DataSnapshot b) =>
                                  b.key!.compareTo(a.key!),
                          query: _chatmessagesRef!,
                          reverse: true,
                          controller: _scrollController,
                          itemBuilder: (context, snapshot, animation, index) {
                            Map message = snapshot.value as Map;
                            // print(
                            //     "date = ${DateFormat('dd MMM').format(DateTime.fromMillisecondsSinceEpoch(message['timestamp']))} time  = ${DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(message['timestamp']))}");

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.all(10.0),
                                //   child: Text(
                                //     DateFormat('dd MMM').format(
                                //         DateTime.fromMillisecondsSinceEpoch(
                                //             message['timestamp'])),
                                //     style: const TextStyle(
                                //       color: AppColors.textPrimary,
                                //       fontFamily: "Geist",
                                //       fontWeight: FontWeight.w600,
                                //       fontSize: 14,
                                //     ),
                                //   ),
                                // ),
                                message['type'] == 0
                                    ? GestureDetector(
                                      onLongPress: () {
                                        if (message['idFrom'] == firebaseId) {
                                          unsendMessageAlert(
                                            message['timestamp'].toString(),
                                          );
                                          print(
                                            'message[timestamp] == ${message['timestamp']}',
                                          );
                                        }
                                      },
                                      child: BubbleSpecialOne(
                                        text:
                                            "${message['content']} ${DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(message['timestamp']))}",
                                        isSender:
                                            message['idFrom'] == firebaseId
                                                ? true
                                                : false,
                                        color:
                                            message['idFrom'] == firebaseId
                                                ? AppColors.chatSenderColor
                                                : AppColors.chatReceiverColor,
                                      ),
                                    )
                                    : message['type'] == 2
                                    ? Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      child: Align(
                                        alignment:
                                            message['idFrom'] == firebaseId
                                                ? Alignment.topRight
                                                : Alignment.topLeft,
                                        child: Container(
                                          // color: Colors.amber,
                                          padding:
                                              message['idFrom'] == firebaseId
                                                  ? const EdgeInsets.only(
                                                    right: 20,
                                                  )
                                                  : const EdgeInsets.only(
                                                    left: 20,
                                                  ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message['idFrom'] == firebaseId
                                                    ? Languages.of(
                                                      context,
                                                    )!.yourepliedtotheirstoryText
                                                    : Languages.of(
                                                      context,
                                                    )!.repliedtoyourstoryText,
                                                style:
                                                    AppTypography.captionMedium.copyWith(color: AppColors.textPrimary),
                                              ),
                                              const SizedBox(height: 5),
                                              _buildReplyContent(
                                                message['content'],
                                                message['idFrom'] == firebaseId
                                                    ? AppColors.chatSenderColor
                                                    : AppColors
                                                        .chatReceiverColor,
                                                message['idFrom'] == firebaseId
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    : getPostShareWidget(
                                      message,
                                      message['type'],
                                    ),
                              ],
                            );
                          },
                        ),
                      ),
                  MessageBar(
                    messageBarColor: Colors.white,
                    onSend: (txt) {
                      _sendMessage(txt);
                    },
                  ),
                  const SizedBox(height: 22),
                ],
              ),
    );
  }

  Widget _buildReplyContent(
    String content,
    Color? color,
    CrossAxisAlignment crossAxisAlignment,
  ) {
    print("Received content: $content");

    List<String> parts = content.split('|');

    if (parts.length != 2) {
      return const Text("Invalid content format");
    }

    String currentStory =
        parts[0].replaceFirst('currentstory:', '').replaceAll('"', '').trim();
    String replyText =
        parts[1].replaceFirst('replytext:', '').replaceAll('"', '').trim();

    print("currentStory == $currentStory");
    print("replyText == $replyText");

    if (currentStory.isEmpty) {
      return const Text("Current story is empty");
    }

    String mediaUrl = Uri.encodeFull(currentStory);
    print("Constructed media URL: $mediaUrl");

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        _buildMedia(mediaUrl),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            replyText,
            style: AppTypography.heading3.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildMedia(String mediaUrl) {
    bool isImage =
        mediaUrl.endsWith('.jpg') ||
        mediaUrl.endsWith('.png') ||
        mediaUrl.endsWith('.jpeg');
    bool isVideo = mediaUrl.endsWith('.mp4') || mediaUrl.endsWith('.mov');

    print("mediaUrl = ${mediaUrl}");

    _videoController = VideoPlayerController.network(
      "${API.baseUrl}/api/${mediaUrl}",
    );
    _videoController!.initialize();

    if (isImage) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ShareStoryView(
                    storyUrl: "${API.baseUrl}/api/${mediaUrl}",
                    isVideo: false,
                    userimage: widget.userImg,
                    username: widget.name,
                  ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.actionPrimary,
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
            "${API.baseUrl}/api/${mediaUrl}",
            width: 150, // Set your desired width
            height: 200, // Set your desired height
            fit: BoxFit.cover, // Adjust to your layout needs
          ),
        ),
      );
    } else if (isVideo) {
      return FutureBuilder(
        future: _videoController!.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ShareStoryView(
                          storyUrl: "${API.baseUrl}/api/${mediaUrl}",
                          isVideo: false,
                          userimage: widget.userImg,
                          username: widget.name,
                        ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 150, // Set your desired width
                  height: 200, // Set your desired height
                  child: VideoPlayer(_videoController!),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return Container();
    }
  }

  void _sendMessage(String content) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
      'message',
    );

    print("channelId == ${channelId}");

    if (channelId != "") {
      print("channelId == ${channelId}");

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
        'message',
      );

      var channelKey =
          'chat--${firebaseId.replaceFirst("-", "")}-${widget.oppId}';
      var channel2Key =
          'chat-${widget.oppId}--${firebaseId.replaceFirst("-", "")}';

      DatabaseEvent channelSnapshot = await userRef.child(channelKey).once();

      DatabaseEvent channel2Snapshot = await userRef.child(channel2Key).once();

      if (channelSnapshot.snapshot.exists) {
        print("ifff channelKey existst === ${channelKey.toString()}");
        DatabaseReference chatRef = FirebaseDatabase.instance
            .ref()
            .child('message')
            .child(channelId);

        print("chatRef == ${chatRef.root}");
        print("chatRef path == ${chatRef.ref}");

        if (content.isNotEmpty) {
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          Map<String, dynamic> message = {
            'content': content,
            'idFrom': firebaseId,
            'idTo': widget.oppId,
            'timestamp': timestamp,
            'type': 0,
            'isSeen': false,
          };

          chatRef.child(timestamp.toString()).set(message);
          _messageController.clear();
        }
      } else if (channel2Snapshot.snapshot.exists) {
        print("elseiifff channel2Key existst === ${channel2Key.toString()}");

        DatabaseReference chatRef = FirebaseDatabase.instance
            .ref()
            .child('message')
            .child(channelId);

        print("chatRef == ${chatRef.root}");
        print("chatRef path == ${chatRef.ref}");

        if (content.isNotEmpty) {
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          Map<String, dynamic> message = {
            'content': content,
            'idFrom': firebaseId,
            'idTo': widget.oppId,
            'timestamp': timestamp,
            'type': 0,
            'isSeen': false,
          };

          chatRef.child(timestamp.toString()).set(message);
          _messageController.clear();
        }
      } else {
        print("no channel exists");
        print("channelKey  ${channelKey.toString()}");
        print("channel2Key ${channel2Key.toString()}");
      }
    } else {
      print("elseeeee  new channel created");
      var channelKey =
          'chat--${firebaseId.replaceFirst('-', "")}-${widget.oppId}';
      print("channelKey = ${channelKey}");
      var timestamp = DateTime.timestamp();

      DatabaseReference messagesRef = userRef
          .child(channelKey)
          .child(timestamp.millisecondsSinceEpoch.toString());

      await messagesRef.set({
        'idFrom': firebaseId,
        'idTo': widget.oppId,
        'isSeen': false,
        'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'type': 0,
      });

      getIds();
    }
  }

  getPostShareWidget(Map message, int type) {
    Post? shareData;

    shareData = Post.fromJson(json.decode(message['content']));

    print("message['content'] == ${message['content']}");
    print("message['idFrom'] == ${message['idFrom']}");
    print("firebaseId == ${firebaseId}");
    return Align(
      alignment:
          message['idFrom'] == firebaseId
              ? Alignment.topRight
              : Alignment.topLeft,
      child: Padding(
        padding:
            message['idFrom'] == firebaseId
                ? const EdgeInsets.only(right: 20)
                : const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onLongPress: () {
            if (message['idFrom'] == firebaseId) {
              print('message[timestamp] == ${message['timestamp']}');
              unsendMessageAlert(message['timestamp'].toString());
            }
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SharePostView(
                      sharepostData: shareData,
                      usertype: shareData!.afterImage! != "" ? "1" : "2",
                    ),
              ),
            );
          },
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color:
                      message['idFrom'] == firebaseId
                          ? AppColors.chatSenderColor
                          : AppColors.chatReceiverColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: MediaQuery.of(context).size.width / 1.8,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            // height: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  shareData.profileImage!.isEmpty
                                      ? Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            17.5,
                                          ),
                                        ),
                                        child: const Icon(Icons.person),
                                      )
                                      : Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            17.5,
                                          ),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              "${API.baseUrl}/api/${shareData.profileImage!}",
                                            ),
                                          ),
                                        ),
                                      ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "${shareData.firstName!}${shareData.lastName!}",
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.only(left: 1, right: 1),
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  shareData.review!.isNotEmpty ? 0 : 12,
                                ),
                                bottomRight: Radius.circular(
                                  shareData.review!.isNotEmpty ? 0 : 12,
                                ),
                              ),
                              child: Image.network(
                                type == 1
                                    ? "${API.baseUrl}/api/${shareData.beforeImage}"
                                    : "${API.baseUrl}/api/${shareData.otherMultiPost![0].otherData}",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        shareData.review!.isNotEmpty
                            ? Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  bottom: 5,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${shareData.firstName!} ${shareData.lastName!}",
                                              style:
                                                  AppTypography.navLabel.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                            ),
                                            TextSpan(
                                              text: " ",
                                              style:
                                                  AppTypography.captionMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                            ),
                                            TextSpan(
                                              text: shareData.review,
                                              style:
                                                  AppTypography.navLabel.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : Container(),
                      ],
                    ),
                    Positioned(
                      right: 8,
                      bottom: 5,
                      child: Text(
                        DateFormat('h:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            message['timestamp'],
                          ),
                        ),
                        style: AppTypography.navLabel.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  unsendMessageAlert(String removekey) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                height: 35,
                width: MediaQuery.of(context).size.width / 2.5,
                // padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    FirebaseDatabase.instance
                        .ref()
                        .child('message')
                        .child(channelId)
                        .child(removekey)
                        .remove();
                    Navigator.pop(context);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset("lib/assets/images/delete.png", height: 20),
                      Text(
                        "Unsend Message",
                        style: AppTypography.bodySemiBold.copyWith(fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // unsendMessageAlert(String removekey) {
  //   return showGeneralDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //     barrierColor: Colors.transparent,
  //     transitionDuration: const Duration(milliseconds: 200),
  //     pageBuilder: (BuildContext buildContext, Animation<double> animation,
  //         Animation<double> secondaryAnimation) {
  //       return Dialog(
  //           alignment: Alignment.center,
  //           insetPadding: EdgeInsets.only(
  //             left: 120,
  //             right: 120,
  //           ),
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 height: 35,
  //                 padding: const EdgeInsets.all(6),
  //                 decoration: BoxDecoration(
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.grey.withOpacity(0.5),
  //                         spreadRadius: 2,
  //                         blurRadius: 2,
  //                         offset: const Offset(0, 3),
  //                       ),
  //                     ],
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(8)),
  //                 child: Expanded(
  //                   child: InkWell(
  //                     onTap: () async {
  //                       FirebaseDatabase.instance
  //                           .ref()
  //                           .child('message')
  //                           .child(channelId)
  //                           .child(removekey)
  //                           .remove();
  //                       Navigator.pop(context);
  //                     },
  //                     child: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                       children: [
  //                         Image.asset("lib/assets/images/delete.png",
  //                             height: 20),
  //                         Text(
  //                           "Unsend Message",
  //                           style: AppTypography.bodySemiBold.copyWith(fontSize: 15),
  //                         ),
  //                         const SizedBox(width: 8),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ));
  //     },
  //   );
  // }
}
