import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/commentpostmodel.dart';
import 'package:pinkGossip/models/postlike.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/utils/videoplayer.dart';
import 'package:pinkGossip/viewModels/commentpostviewmodel.dart';
import 'package:pinkGossip/viewModels/postlikeviewmodel.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class TagPostViewScreen extends StatefulWidget {
  String usertype;
  final List<TagPost> postData;
  int selectedLessonIndex = 1;

  TagPostViewScreen({
    super.key,
    required this.postData,
    required this.selectedLessonIndex,
    required this.usertype,
  });

  @override
  State<TagPostViewScreen> createState() => _TagPostViewScreenState();
}

class _TagPostViewScreenState extends State<TagPostViewScreen> {
  int page = 1;

  int curentPagecount = 1;
  List<int> allcount = [];
  int mxline = 2;
  int selectindex = -1;
  bool more = true;
  bool less = false;
  SharedPreferences? prefs;
  String userid = "";

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
    // print("userid   ${userid}")
  }

  List<int> likeCount = [];
  TextEditingController commentcontroller = TextEditingController();

  bool unlike = true;
  bool like = false;

  bool isLoading = false;
  _scrollListener() {}

  final PageController _pageController = PageController(initialPage: 0);
  ScrollController? _controller;

  @override
  void initState() {
    super.initState();

    getuserid();
    print("widget.postData.length = ${widget.postData.length}");

    _controller = ScrollController();

    _controller!.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller!.hasClients) {
        _controller!.animateTo(
          (widget.selectedLessonIndex * 520),
          duration: const Duration(milliseconds: 1),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    // flickManager.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.kAppBArBGColor,
        automaticallyImplyLeading: false,
        elevation: 2.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                  Languages.of(context)!.taggedText,
                  style: Pallete.Quicksand16drkBlackBold,
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: widget.postData.length,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            // decoration: const BoxDecoration(
            //     border: Border(
            //         bottom:
            //             BorderSide(width: 2, color: AppColors.kBorderColor))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 8,
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child:
                                widget.postData[index].profileImage != ""
                                    ? Container(
                                      height: 40,
                                      width: 40,
                                      padding: const EdgeInsets.all(2.0),
                                      child: CircleAvatar(
                                        radius: 33.0,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: NetworkImage(
                                          "${API.baseUrl}/api/${widget.postData[index].profileImage!}",
                                        ),
                                      ),
                                    )
                                    : Container(
                                      height: 40,
                                      width: 40,
                                      padding: const EdgeInsets.all(2.0),
                                      child: CircleAvatar(
                                        radius: 25.0,
                                        backgroundColor: Colors.grey[300],
                                        child: const Icon(Icons.person),
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              widget.usertype == "1"
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          print("InkWell");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      SalonDetailScreen(
                                                        id:
                                                            widget
                                                                .postData[index]
                                                                .userId
                                                                .toString(),
                                                        userType:
                                                            widget.usertype
                                                                .toString(),
                                                      ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          widget
                                                  .postData[index]
                                                  .userName!
                                                  .isNotEmpty
                                              ? widget.postData[index].userName!
                                              : "${widget.postData[index].firstName!} ${widget.postData[index].lastName!}",
                                          style: Pallete.Quicksand12blackwe600,
                                        ),
                                      ),
                                      widget.postData[index].beforeImage != ""
                                          ? InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => SalonDetailScreen(
                                                        id:
                                                            widget
                                                                .postData[index]
                                                                .userSalonId
                                                                .toString(),
                                                        userType: "2",
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              widget.postData[index].salonName!,
                                              style:
                                                  Pallete
                                                      .Quicksand12Black54we600,
                                            ),
                                          )
                                          : Container(),
                                      widget.postData[index].beforeImage != ""
                                          ? Row(
                                            children: [
                                              Text(
                                                widget
                                                    .postData[index]
                                                    .averageRating!
                                                    .toStringAsFixed(1),
                                                style:
                                                    Pallete
                                                        .Quicksand12blackwe400,
                                              ),
                                              const SizedBox(width: 4),
                                              RatingBarIndicator(
                                                rating: double.parse(
                                                  widget
                                                      .postData[index]
                                                      .averageRating!
                                                      .toString(),
                                                ),
                                                itemCount: 5,
                                                itemSize: 18.0,
                                                unratedColor:
                                                    AppColors.klightGreyColor,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder:
                                                    (context, _) => const Icon(
                                                      Icons.star,
                                                      color:
                                                          AppColors.kPinkColor,
                                                    ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "(${widget.postData[index].ratingCount.toString()})",
                                                style:
                                                    Pallete
                                                        .Quicksand12Greywe400,
                                              ),
                                            ],
                                          )
                                          : Container(),
                                    ],
                                  )
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          print("InkWell");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      SalonDetailScreen(
                                                        id:
                                                            widget
                                                                .postData[index]
                                                                .userId
                                                                .toString(),
                                                        userType:
                                                            widget.usertype
                                                                .toString(),
                                                      ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          widget
                                                  .postData[index]
                                                  .userName!
                                                  .isNotEmpty
                                              ? widget.postData[index].userName!
                                              : "${widget.postData[index].firstName!} ${widget.postData[index].lastName!}",
                                          style: Pallete.Quicksand12blackwe600,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      SalonDetailScreen(
                                                        id:
                                                            widget
                                                                .postData[index]
                                                                .userSalonId
                                                                .toString(),
                                                        userType: "2",
                                                      ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          widget.postData[index].salonName!,
                                          style:
                                              Pallete.Quicksand12Black54we600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget
                                                .postData[index]
                                                .averageRating!
                                                .toStringAsFixed(1),
                                            style:
                                                Pallete.Quicksand12blackwe400,
                                          ),
                                          const SizedBox(width: 4),
                                          RatingBarIndicator(
                                            rating: double.parse(
                                              widget
                                                  .postData[index]
                                                  .averageRating!
                                                  .toString(),
                                            ),
                                            itemCount: 5,
                                            itemSize: 18.0,
                                            unratedColor:
                                                AppColors.klightGreyColor,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemBuilder:
                                                (context, _) => const Icon(
                                                  Icons.star,
                                                  color: AppColors.kPinkColor,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "(${widget.postData[index].ratingCount.toString()})",
                                            style: Pallete.Quicksand12Greywe400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              // Text(
                              //   widget.postData[index].userName!.isNotEmpty
                              //       ? widget.postData[index].userName!
                              //       : "${widget.postData[index].firstName!} ${widget.postData[index].lastName!}",
                              //   style: Pallete.Quicksand12blackwe600,
                              // ),
                              // widget.postData[index].beforeImage != ""
                              //     ? InkWell(
                              //         onTap: () {
                              //           print(
                              //               "id  = ${widget.postData[index].userSalonId}");
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     SalonDetailScreen(
                              //                   id: widget
                              //                       .postData[index].userSalonId
                              //                       .toString(),0
                              //                   userType: "2",
                              //                 ),
                              //               ));
                              //         },
                              //         child: Text(
                              //           widget.postData[index].salonName!,
                              //           style: Pallete.Quicksand12Black54we600,
                              //         ),
                              //       )
                              //     : Container(),
                            ],
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {},
                        child: SizedBox(
                          height: 30,
                          width: 15,
                          child: Image.asset(ImageUtils.moreoptionimg),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.postData[index].beforeImage != ""
                    ? ExpandablePageView.builder(
                      itemCount:
                          (widget.postData[index].otherMultiPost!.length) + 1,
                      onPageChanged: (int pageIndex) {
                        print("Current Page Index: $pageIndex");
                      },
                      itemBuilder: (context, pageviewindex) {
                        page = pageviewindex + 1;
                        return Stack(
                          children: [
                            pageviewindex == 0
                                ? Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.black12,
                                        height: kSize.height / 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Image.network(
                                            loadingBuilder: (
                                              BuildContext context,
                                              Widget child,
                                              ImageChunkEvent? loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        AppColors.kBlackColor,
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            "${API.baseUrl}/api/${widget.postData[index].beforeImage!}",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: kSize.height / 3,
                                        color: Colors.black12,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Image.network(
                                            loadingBuilder: (
                                              BuildContext context,
                                              Widget child,
                                              ImageChunkEvent? loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        AppColors.kBlackColor,
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            "${API.baseUrl}/api/${widget.postData[index].afterImage!}",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Container(
                                  child:
                                      widget
                                                  .postData[index]
                                                  .otherMultiPost![pageviewindex -
                                                      1]
                                                  .otherData!
                                                  .endsWith('.mp4') ||
                                              widget
                                                  .postData[index]
                                                  .otherMultiPost![pageviewindex -
                                                      1]
                                                  .otherData!
                                                  .endsWith('.mov')
                                          ? SizedBox(
                                            child: MyVideoPlayer(
                                              videoUrl:
                                                  "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex - 1].otherData}",
                                            ),
                                          )
                                          : Container(
                                            height:
                                                widget
                                                            .postData[index]
                                                            .postType ==
                                                        "NormalPost"
                                                    ? kSize.height / 2
                                                    : kSize.height / 3,
                                            width: kSize.width,
                                            child: Image.network(
                                              fit: BoxFit.cover,
                                              "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex - 1].otherData}",
                                              loadingBuilder: (
                                                BuildContext context,
                                                Widget child,
                                                ImageChunkEvent?
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: SizedBox(
                                                    height: 100,
                                                    width: 100,
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        color:
                                                            AppColors
                                                                .kBlackColor,
                                                        value:
                                                            loadingProgress
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    loadingProgress
                                                                        .expectedTotalBytes!
                                                                : null,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                ),
                            widget.postData[index].otherMultiPost!.isEmpty
                                ? Container()
                                : Positioned(
                                  top: 10.0,
                                  right: 10,
                                  child: Container(
                                    height: 20,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12.5),
                                    ),
                                    alignment: Alignment.topRight,
                                    child: Center(
                                      child: Text(
                                        "${pageviewindex + 1}/${widget.postData[index].otherMultiPost!.length + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      },
                    )
                    : ExpandablePageView.builder(
                      // controller: _pageController,
                      itemCount:
                          (widget.postData[index].otherMultiPost!.length),
                      onPageChanged: (int pageIndex) {
                        print("Current Page Index: $pageIndex");
                      },
                      itemBuilder: (context, pageviewindex) {
                        return Stack(
                          children: [
                            Container(
                              child:
                                  widget
                                              .postData[index]
                                              .otherMultiPost![pageviewindex]
                                              .otherData!
                                              .endsWith('.mp4') ||
                                          widget
                                              .postData[index]
                                              .otherMultiPost![pageviewindex]
                                              .otherData!
                                              .endsWith('.mov')
                                      ? SizedBox(
                                        child: MyVideoPlayer(
                                          videoUrl:
                                              "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex].otherData}",
                                        ),
                                      )
                                      : Container(
                                        height:
                                            widget.postData[index].postType ==
                                                    "NormalPost"
                                                ? kSize.height / 2
                                                : kSize.height / 3,
                                        width: kSize.width,
                                        child: Image.network(
                                          fit: BoxFit.cover,
                                          "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex].otherData}",
                                          loadingBuilder: (
                                            BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        AppColors.kBlackColor,
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                            ),
                            widget.postData[index].otherMultiPost!.length > 1
                                ? Positioned(
                                  top: 10.0,
                                  right: 10,
                                  child: Container(
                                    height: 20,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12.5),
                                    ),
                                    alignment: Alignment.topRight,
                                    child: Center(
                                      child: Text(
                                        "${pageviewindex + 1}/${widget.postData[index].otherMultiPost!.length}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                : Container(),
                          ],
                        );
                      },
                    ),

                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.postData[index].like == 1) {
                            widget.postData[index].like = 0;
                            widget.postData[index].likeCount =
                                widget.postData[index].likeCount! - 1;

                            setState(() {
                              widget.postData[index].like = 0;
                            });
                            doPostLike(
                              userid,
                              widget.postData[index].id!.toString(),
                              "0",
                              index,
                            );
                          } else {
                            widget.postData[index].like = 1;
                            widget.postData[index].likeCount =
                                widget.postData[index].likeCount! + 1;

                            setState(() {
                              widget.postData[index].like = 1;
                            });
                            doPostLike(
                              userid,
                              widget.postData[index].id!.toString(),
                              "1",
                              index,
                            );
                          }
                        },
                        child:
                            widget.postData[index].like == 1
                                ? Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.topLeft,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: AppColors.kPinkColor,
                                  ),
                                )
                                : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    Icons.favorite_outline,
                                    color: AppColors.kBlackColor,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 30,
                        width: 40,
                        child: InkWell(
                          onTap: () {
                            CommentBottomSheet(context, kSize, index);
                          },
                          child: Image.asset(ImageUtils.lipimage),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: InkWell(
                          child: Image.asset(ImageUtils.sendimage),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${widget.postData[index].likeCount} ${Languages.of(context)!.likesText}",
                    style: Pallete.Quicksand12blackwe600,
                  ),
                ),
                // const SizedBox(height: 8),
                widget.postData[index].review!.isNotEmpty
                    ? Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.topLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: RichText(
                              maxLines: selectindex == index ? mxline : 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${widget.postData[index].firstName!} ${widget.postData[index].lastName!}",
                                    style: Pallete.Quicksand12blackwe600,
                                  ),
                                  TextSpan(
                                    text: " ",
                                    style: Pallete.Quicksand12blackwe600,
                                  ),
                                  _buildReviewText(
                                    widget.postData[index].review!,
                                    widget.postData[index].userTags!,
                                  ),
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () {
                                        print(
                                          "length === ${widget.postData[index].review!.length}",
                                        );
                                        setState(() {
                                          mxline = 2;
                                          more = true;
                                          less = false;
                                          selectindex = -1;
                                        });
                                      },
                                      child: Visibility(
                                        visible: less,
                                        child: Text(
                                          " ${Languages.of(context)!.lessText}",
                                          style: Pallete.Quicksand12blackwe600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          widget.postData[index].review!.length > 100
                              ? InkWell(
                                onTap: () {
                                  setState(() {
                                    print(
                                      "lenght === ${widget.postData[index].review!.length}",
                                    );
                                    mxline = 15;
                                    more = false;
                                    less = true;
                                    selectindex = index;
                                  });
                                },
                                child: Visibility(
                                  visible: selectindex == index ? more : true,
                                  child: Text(
                                    "..${Languages.of(context)!.moreText}",
                                    style: Pallete.Quicksand12blackwe600,
                                  ),
                                ),
                              )
                              : Container(),
                        ],
                      ),
                    )
                    : Container(),

                const SizedBox(height: 2),
                widget.postData[index].commentCount != 0
                    ? Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () {
                          CommentBottomSheet(context, kSize, index);
                        },
                        child: Text(
                          "${Languages.of(context)!.viewallText} ${widget.postData[index].commentCount.toString()} ${Languages.of(context)!.commentsText}",
                          style: Pallete.Quicksand12drktxtGreywe500,
                        ),
                      ),
                    )
                    : Container(),
                Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    getpostTime(widget.postData[index].createdAt!),
                    style: Pallete.Quicksand12drktxtGreywe500,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openSalonDetails(BuildContext context, String tag) {
    if (tagToIdMap.containsKey(tag)) {
      int id = tagToIdMap[tag]!;
      print('Tapped on tag: $tag with ID: $id');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SalonDetailScreen(id: id.toString(), userType: "1"),
        ),
      );
    } else {
      print('Tag not found in map');
    }
  }

  Map<String, int> tagToIdMap = {};

  void _createTagToIdMap(String review, String userTags) {
    List<String> tags = review.split(' ');
    List<String> ids = userTags.split(',');

    int tagIndex = 0;
    for (String tag in tags) {
      if (tag.startsWith('@') && tagIndex < ids.length) {
        tagToIdMap[tag] = int.parse(ids[tagIndex]);
        tagIndex++;
      }
    }
  }

  TextSpan _buildReviewText(String review, String userTags) {
    if (userTags.isNotEmpty) {
      _createTagToIdMap(review, userTags);
    }

    List<TextSpan> textSpans = [];

    List<String> words = review.split(' ');

    for (String word in words) {
      if (word.startsWith('@')) {
        textSpans.add(
          TextSpan(
            text: '$word ',
            style: Pallete.Quicksand12blackwe600.copyWith(
              color: AppColors.kblueColor,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    print('Tapped on: $word');
                    _openSalonDetails(context, word);
                  },
          ),
        );
      } else {
        textSpans.add(
          TextSpan(text: '$word ', style: Pallete.Quicksand12darkGreykwe400),
        );
      }
    }

    return TextSpan(children: textSpans);
  }

  String getpostTime(DateTime loadedTime) {
    print("loadedTime === ${loadedTime}");
    final now = DateTime.now();
    final difference = now.difference(loadedTime);
    DateTime postTime = now.subtract(difference);

    String timeAgo = timeago.format(postTime, locale: 'en');

    print("postDateTime === ${timeAgo}");
    return timeAgo;
  }

  Future<void> CommentBottomSheet(BuildContext context, Size kSize, int index) {
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, BottomsetState) {
            return Container(
              height: (kSize.height * 85) / 100,
              width: kSize.width,
              decoration: const BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(border: Border()),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        child: const Icon(
                                          Icons.close,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        Languages.of(context)!.CommentsText,
                                        style: Pallete.Quicksand20drkBlackBold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                widget.postData[index].comments!.isNotEmpty
                                    ? SizedBox(
                                      height: kSize.height / 1.55,
                                      width: kSize.width,
                                      child: ListView.builder(
                                        itemCount:
                                            widget
                                                .postData[index]
                                                .comments!
                                                .length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, cindex) {
                                          return Container(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10,
                                            ),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                        "${API.baseUrl}/api/${widget.postData[index].comments![cindex].profileImage}",
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.5,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${widget.postData[index].comments![cindex].firstName.toString()} ${widget.postData[index].comments![cindex].lastName.toString()}",
                                                          style:
                                                              Pallete
                                                                  .Quicksand12blackwe600,
                                                        ),
                                                        const SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          getpostTime(
                                                            widget
                                                                .postData[index]
                                                                .comments![cindex]
                                                                .createdAt!,
                                                          ),
                                                          style:
                                                              Pallete
                                                                  .Quicksand12drktxtGreywe500,
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      widget
                                                          .postData[index]
                                                          .comments![cindex]
                                                          .comment
                                                          .toString(),
                                                      style:
                                                          Pallete
                                                              .Quicksand12Blackkwe400,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : SizedBox(
                                      height: ((kSize.height * 85) / 100) / 2,
                                      child: Center(
                                        child: Text(
                                          Languages.of(
                                            context,
                                          )!.NoCommentsavailableText,
                                          style:
                                              Pallete.Quicksand20drkBlackBold,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 50,
                          left: 15,
                          right: 15,
                        ),
                        child: TextField(
                          style: Pallete.textFieldTextStyle,
                          controller: commentcontroller,
                          maxLines: 1,
                          autocorrect: true,
                          keyboardType: TextInputType.text,
                          scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          textInputAction: TextInputAction.done,
                          cursorColor: AppColors.kTextColor,
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                              onTap: () {
                                if (commentcontroller.text.isEmpty) {
                                  kToast(
                                    Languages.of(
                                      context,
                                    )!.pleaseentercommentText,
                                  );
                                } else {
                                  doCommentPost(
                                    userid,
                                    widget.postData[index].id.toString(),
                                    commentcontroller.text,
                                  );
                                  commentcontroller.text = "";
                                }
                              },
                              child: const Icon(Icons.send),
                            ),
                            fillColor: AppColors.kWhiteColor,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            hintText: Languages.of(context)!.sendcommentText,
                            hintStyle: Pallete.textFieldTextStyle,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                width: 2,
                                color: AppColors.kBorderColor,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                width: 1,
                                color: AppColors.kPinkColor,
                              ),
                            ),
                            focusColor: AppColors.kPinkColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  doCommentPost(
    String app_user_id,
    String salon_post_id,
    String comment,
  ) async {
    print("get callForgotPass function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<CommentPostViewModel>(
          context,
          listen: false,
        ).doCommentPost(app_user_id, salon_post_id, comment);
        if (Provider.of<CommentPostViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<CommentPostViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              print("Success");
              CommentPostModel model =
                  Provider.of<CommentPostViewModel>(
                        context,
                        listen: false,
                      ).commentpostresponse.response
                      as CommentPostModel;

              kToast(model.message!);
              if (model.success == true) {
                Navigator.pop(context);
              }
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  doPostLike(String user_id, String post_id, String like, int index) async {
    print("get doPostLike function call");
    setState(() {
      // isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<PostLikeViewModel>(
          context,
          listen: false,
        ).doPostLike(user_id, post_id, like);
        if (Provider.of<PostLikeViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<PostLikeViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              // isLoading = false;
              print("Success");
              PostLikeModel model =
                  Provider.of<PostLikeViewModel>(
                        context,
                        listen: false,
                      ).postlikeresponse.response
                      as PostLikeModel;

              if (model.success == true) {
                likeCount.removeAt(index);
                likeCount.insert(index, model.likeCount!);
                print("likecount == ${likeCount}");
              }

              kToast(model.message!);
            });
          }
        }
      } else {
        setState(() {
          // isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }
}
