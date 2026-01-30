import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/AddPost/addpost.dart';
import 'package:pinkGossip/screens/HomeScreens/addstory.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_post_screen.dart';

class AddPostOptionScreen extends StatefulWidget {
  const AddPostOptionScreen({super.key});

  @override
  State<AddPostOptionScreen> createState() => _AddPostOptionScreenState();
}

class _AddPostOptionScreenState extends State<AddPostOptionScreen> {
  bool ispostSelected = false;
  bool isstorySelected = false;
  bool isselectedPostOrStory = true;

  bool isposttype1Selected = false;
  bool isstorytype1Selected = false;
  bool issalonreviewSelected = false;
  bool istype1Select = true;

  bool ishiden = false;
  bool ishidentype1 = false;
  String userTyppe = "";
  SharedPreferences? prefs;

  getuserType() async {
    prefs = await SharedPreferences.getInstance();
    userTyppe = prefs!.getString('userType')!;
    print("userTyppe = $userTyppe");
    setState(() {});
  }

  @override
  void initState() {
    getuserType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userTyppe == "2"
        ? Scaffold(
          backgroundColor: AppColors.kWhiteColor,
          appBar:
              ispostSelected == false && isstorySelected == false
                  ? AppBar(
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: AppColors.kAppBArBGColor,
                    automaticallyImplyLeading: false,
                    elevation: 2.0,
                    title: Row(
                      children: [
                        Text(
                          Languages.of(context)!.submitnewpostText,
                          style: Pallete.Quicksand16drkBlackBold,
                        ),
                      ],
                    ),
                  )
                  : AppBar(
                    toolbarHeight: 0,
                    backgroundColor:
                        ispostSelected
                            ? AppColors.kAppBArBGColor
                            : isstorySelected
                            ? AppColors.kBlackColor
                            : AppColors.kAppBArBGColor,
                  ),
          body:
              ispostSelected
                  ? AddPost(
                    type: "AddPost",
                    onImageSelected: (bool isSelected) {
                      if (isSelected) {
                        setState(() {
                          ishiden = true;
                        });
                        print("An image has been selected.");
                      } else {
                        print("No image is selected.");
                        setState(() {
                          ishiden = false;
                        });
                      }
                    },
                  )
                  : isstorySelected
                  ? AddStory(
                    type: "Post",
                    // onImageSelected: (bool isSelected) {
                    //   if (isSelected) {
                    //     setState(() {
                    //       ishiden = true;
                    //     });
                    //   } else {
                    //     setState(() {
                    //       ishiden = false;
                    //     });
                    //   }
                    // }
                  )
                  : Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(
                        //   width: 130,
                        //   child: Image.asset("lib/assets/images/post.png"),
                        // ),
                        const SizedBox(height: 20),
                        Container(
                          height: 30,
                          width: 180,
                          decoration: Pallete.getButtonDecoration(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isselectedPostOrStory = false;
                                ispostSelected = true;
                                isstorySelected = false;
                              });
                            },
                            child: Center(
                              child: Text(
                                Languages.of(context)!.sharepostText,
                                style: Pallete.buttonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        // SizedBox(
                        //   width: 130,
                        //   child: Image.asset("lib/assets/images/story.png"),
                        // ),
                        const SizedBox(height: 20),
                        Container(
                          height: 30,
                          width: 180,
                          decoration: Pallete.getButtonDecoration(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isselectedPostOrStory = false;
                                ispostSelected = false;
                                isstorySelected = true;
                              });
                            },
                            child: Center(
                              child: Text(
                                Languages.of(context)!.sharestoryText,
                                style: Pallete.buttonTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        )
        : Scaffold(
          appBar:
              isposttype1Selected == false &&
                      isstorytype1Selected == false &&
                      issalonreviewSelected == false
                  ? AppBar(
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: AppColors.kAppBArBGColor,
                    automaticallyImplyLeading: false,
                    elevation: 2.0,
                    title: Row(
                      children: [
                        Text(
                          Languages.of(context)!.submitnewpostText,
                          style: Pallete.Quicksand16drkBlackBold,
                        ),
                      ],
                    ),
                  )
                  : AppBar(
                    toolbarHeight: 0,
                    backgroundColor:
                        isposttype1Selected
                            ? AppColors.kAppBArBGColor
                            : isstorytype1Selected
                            ? AppColors.kBlackColor
                            : issalonreviewSelected
                            ? AppColors.kAppBArBGColor
                            : AppColors.kWhiteColor,
                  ),
          backgroundColor: AppColors.kWhiteColor,
          body:
              isposttype1Selected
                  ? AddPost(type: "1", usertype: "1")
                  //  AddPostScreen(imagetype1Selected: (bool isSelected) {
                  //     if (isSelected) {
                  //       setState(() {
                  //         ishidentype1 = true;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         ishidentype1 = false;
                  //       });
                  //     }
                  //   })
                  : isstorytype1Selected
                  ? AddStory(
                    type: "Post",
                    onImagetype1Selected: (bool isSelected) {
                      if (isSelected) {
                        setState(() {
                          ishidentype1 = true;
                        });
                      } else {
                        setState(() {
                          ishidentype1 = false;
                        });
                      }
                    },
                  )
                  : issalonreviewSelected
                  ? AddPost(
                    type: "2",
                    onImagetype1Selected: (bool isSelected) {
                      if (isSelected) {
                        setState(() {
                          ishidentype1 = true;
                        });
                      } else {
                        setState(() {
                          ishidentype1 = false;
                        });
                      }
                    },
                  )
                  : Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // const SizedBox(height: 10),
                        // SizedBox(
                        //   width: 130,
                        //   child: Image.asset(
                        //       "lib/assets/images/post.png"),
                        // ),
                        // const SizedBox(height: 10),
                        Container(
                          height: 30,
                          width: 180,
                          decoration: Pallete.getButtonDecoration(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                istype1Select = false;
                                isposttype1Selected = true;
                                isstorytype1Selected = false;
                                issalonreviewSelected = false;
                              });
                            },
                            child: Center(
                              child: Text(
                                Languages.of(context)!.sharepostText,
                                style: Pallete.buttonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        // SizedBox(
                        //   width: 130,
                        //   child: Image.asset(
                        //       "lib/assets/images/story.png"),
                        // ),
                        const SizedBox(height: 20),
                        Container(
                          height: 30,
                          width: 180,
                          decoration: Pallete.getButtonDecoration(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                istype1Select = false;
                                isposttype1Selected = false;
                                isstorytype1Selected = true;
                                issalonreviewSelected = false;
                              });
                            },
                            child: Center(
                              child: Text(
                                Languages.of(context)!.sharestoryText,
                                style: Pallete.buttonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        // SizedBox(
                        //   width: 130,
                        //   child: Image.asset(
                        //       "lib/assets/images/salonreview.png"),
                        // ),
                        const SizedBox(height: 20),
                        Container(
                          height: 30,
                          width: 180,
                          decoration: Pallete.getButtonDecoration(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                istype1Select = false;
                                isposttype1Selected = false;
                                isstorytype1Selected = false;
                                issalonreviewSelected = true;
                              });
                            },
                            child: Center(
                              child: Text(
                                Languages.of(context)!.sharesalonreviewText,
                                style: Pallete.buttonTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        );
  }
}
