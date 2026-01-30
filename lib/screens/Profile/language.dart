import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/localization/locale_constants.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLang = "";
  bool isEnglishSelected = false;
  bool isFrenchSelected = false;

  getLocale() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLang = _prefs.getString("SelectedLanguageCode") ?? "en";
      if (selectedLang == "en") {
        setState(() {
          isEnglishSelected = true;
        });
      } else {
        isFrenchSelected = true;
      }
      print("selectedLanguage = $selectedLang");
    });
  }

  @override
  void initState() {
    getLocale();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  overlayColor: const WidgetStatePropertyAll(
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
                  Languages.of(context)!.changelanguageText,
                  style: Pallete.Quicksand16drkBlackBold,
                ),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(17.5),
              onTap: () async {
                if (isEnglishSelected == true) {
                  changeLanguage(context, "en");
                } else {
                  changeLanguage(context, "fr");
                }
                await getLocale();
                Navigator.pop(context);
              },
              child: const SizedBox(
                height: 35,
                width: 35,
                child: Icon(Icons.done),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedLang = "en";
                      isEnglishSelected = true;
                      isFrenchSelected = false;
                    });
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.kWhiteColor,
                      border:
                          isEnglishSelected
                              ? Border.all(
                                color: AppColors.kPinkColor,
                                width: 2,
                              )
                              : Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text("ENGLISH")),
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedLang = "fr";
                      isFrenchSelected = true;
                      isEnglishSelected = false;
                    });
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.kWhiteColor,
                      border:
                          isFrenchSelected
                              ? Border.all(
                                color: AppColors.kPinkColor,
                                width: 2,
                              )
                              : Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text("FRENCH")),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
