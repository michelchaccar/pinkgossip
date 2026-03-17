import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/AddPost/addpost.dart';
import 'package:pinkGossip/screens/HomeScreens/addstory.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
          backgroundColor: AppColors.bgPrimary,
          appBar:
              ispostSelected == false && isstorySelected == false
                  ? AppBar(
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: AppColors.bgPrimary,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    title: Row(
                      children: [
                        Text(
                          Languages.of(context)!.submitnewpostText,
                          style: AppTypography.heading3,
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
                            ? AppColors.textPrimary
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
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        _buildOptionCard(
                          icon: PhosphorIconsRegular.image,
                          title: Languages.of(context)!.sharepostText,
                          subtitle: Languages.of(context)!.sharepostdescText,
                          onTap: () {
                            setState(() {
                              isselectedPostOrStory = false;
                              ispostSelected = true;
                              isstorySelected = false;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildOptionCard(
                          icon: PhosphorIconsRegular.clockCounterClockwise,
                          title: Languages.of(context)!.sharestoryText,
                          subtitle: Languages.of(context)!.sharestorydescText,
                          onTap: () {
                            setState(() {
                              isselectedPostOrStory = false;
                              ispostSelected = false;
                              isstorySelected = true;
                            });
                          },
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
                    backgroundColor: AppColors.bgPrimary,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    title: Row(
                      children: [
                        Text(
                          Languages.of(context)!.submitnewpostText,
                          style: AppTypography.heading3,
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
                            ? AppColors.textPrimary
                            : issalonreviewSelected
                            ? AppColors.kAppBArBGColor
                            : AppColors.bgPrimary,
                  ),
          backgroundColor: AppColors.bgPrimary,
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
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        _buildOptionCard(
                          icon: PhosphorIconsRegular.image,
                          title: Languages.of(context)!.sharepostText,
                          subtitle: Languages.of(context)!.sharepostdescText,
                          onTap: () {
                            setState(() {
                              istype1Select = false;
                              isposttype1Selected = true;
                              isstorytype1Selected = false;
                              issalonreviewSelected = false;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildOptionCard(
                          icon: PhosphorIconsRegular.clockCounterClockwise,
                          title: Languages.of(context)!.sharestoryText,
                          subtitle: Languages.of(context)!.sharestorydescText,
                          onTap: () {
                            setState(() {
                              istype1Select = false;
                              isposttype1Selected = false;
                              isstorytype1Selected = true;
                              issalonreviewSelected = false;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildOptionCard(
                          icon: PhosphorIconsRegular.star,
                          title: Languages.of(context)!.sharesalonreviewText,
                          subtitle: Languages.of(context)!.sharesalonreviewdescText,
                          onTap: () {
                            setState(() {
                              istype1Select = false;
                              isposttype1Selected = false;
                              isstorytype1Selected = false;
                              issalonreviewSelected = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
        );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.actionPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.heading3),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
