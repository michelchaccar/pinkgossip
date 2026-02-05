import 'dart:io';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/createpostmodel.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/screens/AddPost/mentionTextifield.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/localfilevideoplay.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/createpostviewmodel.dart';
import 'package:pinkGossip/viewModels/searchuserlistviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AddPostScreen extends StatefulWidget {
  final Function(bool)? imagetype1Selected;
  const AddPostScreen({super.key, this.imagetype1Selected});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  _unselectselectImage() {
    if (widget.imagetype1Selected != null) {
      widget.imagetype1Selected!(false);
    }
  }

  _selectImage() {
    if (widget.imagetype1Selected != null) {
      widget.imagetype1Selected!(true);
    }
  }

  bool isLoading = false;

  TextEditingController captionController = TextEditingController();

  final List<Widget> _mediaList = [];
  final List<File> path = [];
  List<int> selectedIndexes = [];
  bool isMultiSelectMode = false;
  int currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  bool isImageSelected = false;

  final PageController _pageController = PageController();

  List<File> selectedMedia = [];
  String userid = "";
  String captionData = "";
  SharedPreferences? prefs;

  bool istaguserShow = false;

  getUserID() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
    captionData = prefs!.getString('caption') ?? "";
    print("captionData == ${captionData}");
    captionController.text = captionData;
    print("userTyppe = ${userid}");
    setState(() {});
  }

  @override
  _fetchNewMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> album = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      List<AssetEntity> media = await album[0].getAssetListPaged(
        page: currentPage,
        size: 60,
      );

      for (var asset in media) {
        if (asset.type == AssetType.image || asset.type == AssetType.video) {
          final file = await asset.file;
          if (file != null) {
            path.add(File(file.path));
          }
        }
      }

      List<Widget> temp = [];
      for (var asset in media) {
        temp.add(
          FutureBuilder(
            future: asset.thumbnailDataWithSize(
              const ThumbnailSize(1024, 1024),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                    ),
                    if (asset.type == AssetType.video)
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white.withOpacity(0.8),
                          size: 30,
                        ),
                      ),
                  ],
                );
              }
              return Container();
            },
          ),
        );
      }

      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserID();
    getTagUserList("1");
    _fetchNewMedia();
  }

  TextEditingController addcommentcontroller = TextEditingController();

  List<UserList> tagUserList = [];
  List<String> taggedUserIds = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  int salonselectindex = 1;
  bool salonstep1 = true;
  bool salonstep2 = false;
  bool salonstep3 = false;
  bool salonstep4 = false;
  List<File> allOtherdata = [];

  Future<void> pickAllOtherVideoORImage() async {
    try {
      final List<XFile> result = await ImagePicker().pickMultipleMedia();
      allOtherdata.clear();
      List<String> picandvideostype2Pref = [];
      SharedPreferences postReviewPref = await SharedPreferences.getInstance();

      if (result.isNotEmpty) {
        await postReviewPref.remove('picandvideostype1');

        for (var file in result) {
          allOtherdata.add(File(file.path));
          picandvideostype2Pref.add(file.path);
        }
        print("allOtherdata = ${allOtherdata}");

        setState(() {});

        await postReviewPref.setStringList(
          'picandvideostype1',
          picandvideostype2Pref,
        );

        List<String>? savedList = postReviewPref.getStringList(
          'picandvideostype1',
        );
        print('Retrieved list after saving: $savedList');
      }
    } on PlatformException catch (error) {
      print('Failed to pick media: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;

    return isImageSelected
        ? Scaffold(
          backgroundColor: AppColors.kWhiteColor,

          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _unselectselectImage();
                      isImageSelected = false;
                      prefs!.setString('caption', captionController.text);
                    });
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
                Text(
                  Languages.of(context)!.postsText,
                  style: Pallete.Quicksand18drkBlackbold,
                ),
                GestureDetector(
                  onTap: () {
                    Pallete.closeKeyboard(context);
                    print("captionController.text ${captionController.text}");
                    print("taggedUserIds ${taggedUserIds}");
                    print("selectedMedia == ${selectedMedia}");

                    Pallete.closeKeyboard(context);

                    // return;

                    CreatePost(
                      userid,
                      userid,
                      File(""),
                      File(""),
                      selectedMedia,
                      "",
                      0,
                      "",
                      "",
                      captionController.text,
                      taggedUserIds,
                      "NormalPost",
                    );
                  },
                  child: Text(
                    Languages.of(context)!.postCapitalText,
                    style: Pallete.Quicksand18drkBlackbold.copyWith(
                      color: AppColors.kblueColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.black12),
                  height: 500,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            currentPage = page;
                          });
                        },
                        itemCount: selectedMedia.length,
                        itemBuilder: (context, index) {
                          File mediaFile = selectedMedia[index];
                          if (mediaFile.path.endsWith('.mp4') ||
                              mediaFile.path.endsWith('.MP4') ||
                              mediaFile.path.endsWith('.mov')) {
                            return VideoDisplay(selectedAsset: mediaFile);
                          } else {
                            return Image.file(mediaFile);
                          }
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: selectedMedia.length,
                            effect: const WormEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              activeDotColor: AppColors.kPinkColor,
                              dotColor: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                MentionTextField(
                  userList: tagUserList,
                  type: "NormalPost",
                  storedata: captionController.text,
                  onChanged: (txt) {
                    print("txt = ${txt}");
                    setState(() {
                      captionController.text = txt;
                    });
                  },
                  onTaggedUserIdsChanged: (List<String> ids) {
                    if (ids.isNotEmpty) {
                      setState(() {
                        taggedUserIds = ids;
                      });
                      print(
                        "Currently Tagged User IDs: ${taggedUserIds.join(', ')}",
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        )
        : Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              Languages.of(context)!.newpostText,
              style: Pallete.Quicksand18Whiitewe600.copyWith(
                color: AppColors.kBlackColor,
              ),
            ),
            centerTitle: false,
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () async {
                      if (selectedIndexes.isNotEmpty) {
                        selectedMedia =
                            selectedIndexes
                                .map((index) => path[index])
                                .toList();

                        setState(() {
                          isImageSelected = true;
                          _selectImage();
                        });
                      } else {
                        kToast(Languages.of(context)!.pleaseselectmediaText);
                      }
                    },
                    child: Text(
                      Languages.of(context)!.nextText,
                      style: Pallete.Quicksand15blackwe600.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body:
              isLoading
                  ? Container(
                    height: kSize.height,
                    width: kSize.width,
                    color: AppColors.kWhiteColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.kBlackColor,
                      ),
                    ),
                  )
                  : SafeArea(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.white,
                            height: 375,
                            child: GridView.builder(
                              controller: _scrollController,
                              itemCount: 1,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing: 1,
                                    crossAxisSpacing: 1,
                                  ),
                              itemBuilder: (context, index) {
                                if (selectedIndexes.isNotEmpty) {
                                  int selectedIndex = selectedIndexes.first;
                                  var selectedAsset = path[selectedIndex];

                                  print("selectedAsset = ${selectedAsset}");

                                  if (_mediaList.isNotEmpty &&
                                      selectedAsset != null) {
                                    // Check if it's a video and play it
                                    if (selectedAsset.path.endsWith('.mp4') ||
                                        selectedAsset.path.endsWith('.MP4') ||
                                        selectedAsset.path.endsWith('.mov')) {
                                      return VideoDisplay(
                                        selectedAsset: selectedAsset,
                                      );
                                    } else {
                                      return _mediaList[selectedIndex];
                                    }
                                  }
                                } else if (_mediaList.isNotEmpty) {
                                  return _mediaList.first;
                                } else {
                                  return Container();
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 40,
                            color: Colors.white,
                            child: const Row(
                              children: [
                                SizedBox(width: 10),
                                Text(
                                  'Recent',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemCount: _mediaList.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 1,
                                  crossAxisSpacing: 2,
                                ),
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              bool isSelected = selectedIndexes.contains(index);
                              return GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    isMultiSelectMode = true;
                                    if (!selectedIndexes.contains(index)) {
                                      selectedIndexes.add(index);
                                      _scrollController.jumpTo(0);
                                    }
                                    _scrollToTop();
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    if (isMultiSelectMode) {
                                      if (selectedIndexes.contains(index)) {
                                        selectedIndexes.remove(index);
                                        if (selectedIndexes.isEmpty) {
                                          isMultiSelectMode = false;
                                        }
                                      } else {
                                        selectedIndexes.add(index);
                                        _scrollController.jumpTo(0);
                                      }
                                    } else {
                                      selectedIndexes.clear();
                                      selectedIndexes.add(index);
                                    }
                                    _scrollToTop();
                                  });
                                },
                                child: Stack(
                                  children: [
                                    _mediaList[index],
                                    if (isSelected)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.5),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
        );
  }

  CreatePost(
    String salon_id,
    String user_id,
    File before_image,
    File after_image,
    List<File> other,
    String fileExtension,
    double rating,
    String reward_type,
    String reward_image,
    String review,
    List<String> tag_users,
    String post_type, {
    String rewardpoint = "0",
  }) async {
    print("get CreatePost function call === $other");
    setState(() {
      isLoading = true;
    });
    print("mainfunc == ${rating}");

    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<CreatePostViewModel>(
          context,
          listen: false,
        ).CreatePost(
          salon_id,
          user_id,
          before_image,
          after_image,
          other,
          fileExtension,
          rating,
          reward_type,
          reward_image,
          review,
          tag_users,
          post_type,
          rewardpoint,
        );
        if (Provider.of<CreatePostViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<CreatePostViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;

              CreatePostModel model =
                  Provider.of<CreatePostViewModel>(
                        context,
                        listen: false,
                      ).createpostresponse.response
                      as CreatePostModel;

              kToast(model.message!);

              print("model message = ${model.message}");

              if (model.success == true) {
                prefs!.remove('caption');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavBar(index: 0),
                  ),
                );
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

  getTagUserList(String type) async {
    print("get getTagUserList function call");
    setState(() {
      isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SearchUserListViewModelViewModel>(
          context,
          listen: false,
        ).getsearchUserList(type, userid);
        if (Provider.of<SearchUserListViewModelViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<SearchUserListViewModelViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              print("Success");
              SalonSearchListModel model =
                  Provider.of<SearchUserListViewModelViewModel>(
                        context,
                        listen: false,
                      ).searchuserlistresponse.response
                      as SalonSearchListModel;

              tagUserList = model.userList!;
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
}
