import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/localization/locale_constants.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:pinkGossip/components/pg_app_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      backgroundColor: AppColors.bgPrimary,
      appBar: PgAppBar(
        title: Languages.of(context)!.changelanguageText,
        actions: [
          PgAppBarAction(
            icon: LucideIcons.check,
            onTap: () async {
              if (isEnglishSelected == true) {
                changeLanguage(context, "en");
              } else {
                changeLanguage(context, "fr");
              }
              await getLocale();
              Navigator.pop(context);
            },
          ),
        ],
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
                      color: AppColors.bgPrimary,
                      border:
                          isEnglishSelected
                              ? Border.all(
                                color: AppColors.actionPrimary,
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
                      color: AppColors.bgPrimary,
                      border:
                          isFrenchSelected
                              ? Border.all(
                                color: AppColors.actionPrimary,
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
