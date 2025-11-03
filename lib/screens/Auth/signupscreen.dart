// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, must_be_immutable, void_checks

import 'dart:io';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/checkuserexistmodel.dart';
import 'package:pinkGossip/models/checkusernameexistmodel.dart';
import 'package:pinkGossip/models/loginmodel.dart';
import 'package:pinkGossip/screens/Auth/loginscreen.dart';
import 'package:pinkGossip/viewModels/checkaccountexistviewmodel.dart';
import 'package:pinkGossip/viewModels/checkusernameexistviewmodel.dart';
import 'package:pinkGossip/viewModels/loginviewmodel.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/models/signupmodel.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/signupviewmodel.dart';

import '../../models/updatefirebasemodel.dart';
import '../../utils/color_utils.dart';
import '../../viewModels/updatefirebaseviewmodel.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignUpScreen extends StatefulWidget {
  String firstname, lastname, email, socialid, type;
  SignUpScreen({
    super.key,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.socialid,
    required this.type,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController firstNameTextController = TextEditingController();
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passTextController = TextEditingController();
  TextEditingController confirmpassTextController = TextEditingController();

  bool isLoading = false;
  String userid = "";
  getuserid() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs = await SharedPreferences.getInstance();
    userid = _prefs.getString('userid')!;

    print("USER IDDD +++++++ $userid");
  }

  String? accounttypedropdownvalue;
  String? categorydropdownvalue;
  String loginType = "";
  bool _obscureText = true;
  bool _confirmobscureText = true;

  String fcmToken = "";

  gefcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fcmToken = await FirebaseMessaging.instance.getToken() ?? "no fcm";
    print("token ========= $fcmToken");
    await prefs.setString('fcmtoken', fcmToken);
    print("loginType ========= $loginType");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    gefcmToken();
    firstNameTextController.text = widget.firstname;
    lastNameTextController.text = widget.lastname;
    emailTextController.text = widget.email;
    loginType = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    var droparray = [
      Languages.of(context)!.gossiperText,
      Languages.of(context)!.beautybusinessText,
    ];
    var categorydroparray = [
      Languages.of(context)!.hairsalonText,
      Languages.of(context)!.estheticsText,
      Languages.of(context)!.medicoestheticText,
      Languages.of(context)!.nailsspaText,
      Languages.of(context)!.tatooText,
      Languages.of(context)!.barbershopText,
      Languages.of(context)!.spafacilityText,
      Languages.of(context)!.messagesText,
      Languages.of(context)!.plasticsurgeryText,
      Languages.of(context)!.lashesandbrowsText,
      Languages.of(context)!.othersText,
    ];
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: 160,
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    color: AppColors.kWhiteColor,
                    alignment: Alignment.topCenter,
                    child: Image.asset("lib/assets/images/logo@3x.png"),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      maxLines: 1,
                      autocorrect: true,
                      style: Pallete.textFieldTextStyle,
                      onChanged: (value) {
                        getcheckUsernameExist(value);
                      },
                      scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      controller: usernameTextController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      cursorColor: AppColors.kTextColor,
                      decoration: Pallete.getTextfieldDecoration(
                        Languages.of(context)!.usernameText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      maxLines: 1,
                      autocorrect: true,
                      style: Pallete.textFieldTextStyle,
                      scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      controller: firstNameTextController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      cursorColor: AppColors.kTextColor,
                      decoration: Pallete.getTextfieldDecoration(
                        Languages.of(context)!.firstNameText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      maxLines: 1,
                      autocorrect: true,
                      style: Pallete.textFieldTextStyle,
                      scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      controller: lastNameTextController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      cursorColor: AppColors.kTextColor,
                      decoration: Pallete.getTextfieldDecoration(
                        Languages.of(context)!.lastNameText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      maxLines: 1,
                      autocorrect: true,
                      style: Pallete.textFieldTextStyle,
                      scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      controller: emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      cursorColor: AppColors.kTextColor,
                      decoration: Pallete.getTextfieldDecoration(
                        Languages.of(context)!.emailText,
                      ),
                    ),
                  ),
                  loginType != "login"
                      ? Container()
                      : Container(
                        margin: const EdgeInsets.only(
                          left: 30,
                          right: 30,
                          top: 15,
                        ),
                        child: TextFormField(
                          autocorrect: true,
                          maxLines: 1,
                          style: Pallete.textFieldTextStyle,
                          scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          controller: passTextController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscureText,
                          cursorColor: AppColors.kTextColor,
                          decoration: InputDecoration(
                            fillColor: AppColors.kWhiteColor,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            hintText: Languages.of(context)!.passwordText,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.kTextColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                  loginType != "login"
                      ? Container()
                      : Container(
                        margin: const EdgeInsets.only(
                          left: 30,
                          right: 30,
                          top: 15,
                        ),
                        child: TextFormField(
                          autocorrect: true,
                          maxLines: 1,
                          style: Pallete.textFieldTextStyle,
                          scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          controller: confirmpassTextController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          obscureText: _confirmobscureText,
                          cursorColor: AppColors.kTextColor,
                          decoration: InputDecoration(
                            fillColor: AppColors.kWhiteColor,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            hintText:
                                Languages.of(context)!.confirmpasswordText,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _confirmobscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.kTextColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmobscureText = !_confirmobscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30, top: 15),
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 2,
                        color: AppColors.kBorderColor,
                      ),
                    ),
                    width: kSize.width,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Row(
                          children: [
                            Expanded(
                              child: Text(
                                Languages.of(context)!.selectaccounttypeText,
                                style: Pallete.textFieldTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items:
                            droparray
                                .map(
                                  (String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: Pallete.textFieldTextStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        value: accounttypedropdownvalue,
                        onChanged: (String? value) {
                          setState(() {
                            accounttypedropdownvalue = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  accounttypedropdownvalue ==
                          Languages.of(context)!.beautybusinessText
                      ? Container(
                        margin: const EdgeInsets.only(left: 30, right: 30),
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 2,
                            color: AppColors.kBorderColor,
                          ),
                        ),
                        width: kSize.width,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    Languages.of(context)!.categoriesText,
                                    style: Pallete.textFieldTextStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            items:
                                categorydroparray
                                    .map(
                                      (String item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: Pallete.textFieldTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            value: categorydropdownvalue,
                            onChanged: (String? value) {
                              setState(() {
                                categorydropdownvalue = value;
                              });
                            },
                          ),
                        ),
                      )
                      : Container(),
                  const SizedBox(height: 30),
                  Container(
                    height: 55,
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    decoration: Pallete.getButtonDecoration(),
                    child: InkWell(
                      child: ElevatedButton(
                        onPressed: () async {
                          _validateAndSubmit();
                          // if (usernameTextController.text.isEmpty) {
                          //   kToast(
                          //       Languages.of(context)!.pleaseenterusernameText);
                          // } else if (firstNameTextController.text.isEmpty) {
                          //   kToast(Languages.of(context)!
                          //       .pleaseenterfirstnameText);
                          // } else if (lastNameTextController.text.isEmpty) {
                          //   kToast(
                          //       Languages.of(context)!.pleaseenterlastnameText);
                          // } else if (emailTextController.text.isEmpty) {
                          //   kToast(Languages.of(context)!.pleaseenteremailText);
                          // } else if (!ValidationChecks.validateEmail(
                          //     emailTextController.text)) {
                          //   kToast(Languages.of(context)!.entervalidemailText);
                          // } else if (loginType == "login") {
                          //   if (passTextController.text.isEmpty) {
                          //     kToast(Languages.of(context)!
                          //         .pleaseenterpasswordText);
                          //   } else if (confirmpassTextController.text.isEmpty) {
                          //     kToast(Languages.of(context)!
                          //         .pleaseenterconfirmpasswordText);
                          //   } else if (passTextController.text.length < 6 ||
                          //       confirmpassTextController.text.length < 6) {
                          //     kToast(Languages.of(context)!
                          //         .Thepasswordmustbeatleast6charactersText);
                          //   } else if (passTextController.text !=
                          //       confirmpassTextController.text) {
                          //     kToast(Languages.of(context)!
                          //         .confirmpasswordnotmatchedText);
                          //   } else if (accounttypedropdownvalue == null) {
                          //     kToast(Languages.of(context)!
                          //         .PleaseselectdropdownvalueText);
                          //   }
                          //   // Check if beauty business category is selected
                          //   else if (accounttypedropdownvalue ==
                          //       Languages.of(context)!.beautybusinessText) {
                          //     if (categorydropdownvalue == null) {
                          //       kToast(Languages.of(context)!
                          //           .pleaseselectcategoryText);
                          //     } else {
                          //       _handleSocialLoginOrSignup();
                          //     }
                          //   } else {
                          //     _handleSocialLoginOrSignup();
                          //   }
                          // }
                          // // Check if account type dropdown is selected
                          // else if (accounttypedropdownvalue == null) {
                          //   kToast(Languages.of(context)!
                          //       .PleaseselectdropdownvalueText);
                          // }
                          // // Check if beauty business category is selected
                          // else if (accounttypedropdownvalue ==
                          //     Languages.of(context)!.beautybusinessText) {
                          //   if (categorydropdownvalue == null) {
                          //     kToast(Languages.of(context)!
                          //         .pleaseselectcategoryText);
                          //   } else {
                          //     _handleSocialLoginOrSignup();
                          //   }
                          // } else {
                          //   _handleSocialLoginOrSignup();
                          // }
                        },
                        style: ButtonStyle(
                          backgroundColor: const WidgetStatePropertyAll(
                            AppColors.kPinkColor,
                          ),
                          elevation: const WidgetStatePropertyAll(0),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            Languages.of(context)!.createAccountText,
                            style: Pallete.buttonTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: kSize.width,
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: Text(
                      Languages.of(context)!.orText,
                      style: Pallete.Quicksand16drktxtGreywe500,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Container(
                  //   height: 60,
                  //   width: kSize.width,
                  //   margin: const EdgeInsets.only(left: 30, right: 30),
                  //   decoration: Pallete.getBorderButtonDecoration(),
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     style: ButtonStyle(
                  //         backgroundColor: const MaterialStatePropertyAll(
                  //             AppColors.kWhiteColor),
                  //         elevation: const MaterialStatePropertyAll(0),
                  //         overlayColor: const MaterialStatePropertyAll(
                  //             AppColors.kAppBArBGColor),
                  //         shape: MaterialStatePropertyAll(
                  //             RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(10),
                  //                 side: const BorderSide(
                  //                     color: AppColors.kBorderColor,
                  //                     width: 1)))),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const Icon(Icons.g_mobiledata,
                  //             color: Colors.transparent, size: 35),
                  //         Text(
                  //           Pallete.loginwithemailText,
                  //           style: Pallete.Quicksand15blackwe600,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  Container(
                    height: 60,
                    width: kSize.width,
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    decoration: Pallete.getBorderButtonDecoration(),
                    child: ElevatedButton(
                      onPressed: () {
                        _handleGoogleSignIn();
                      },
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          AppColors.kWhiteColor,
                        ),
                        elevation: const WidgetStatePropertyAll(0),
                        overlayColor: const WidgetStatePropertyAll(
                          AppColors.kAppBArBGColor,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: AppColors.kBorderColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.g_mobiledata,
                            color: Colors.black,
                            size: 35,
                          ),
                          Text(
                            Languages.of(context)!.loginwithgoogleText,
                            style: Pallete.Quicksand15blackwe600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Platform.isIOS
                      ? Container(
                        height: 55,
                        width: kSize.width,
                        margin: const EdgeInsets.only(left: 30, right: 30),
                        decoration: Pallete.getBorderButtonDecoration(),
                        child: ElevatedButton(
                          onPressed: () {
                            signInWithApple();
                          },
                          style: ButtonStyle(
                            backgroundColor: const WidgetStatePropertyAll(
                              AppColors.kWhiteColor,
                            ),
                            elevation: const WidgetStatePropertyAll(0),
                            overlayColor: const WidgetStatePropertyAll(
                              AppColors.kAppBArBGColor,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: AppColors.kBorderColor,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.apple,
                                size: 28,
                                color: AppColors.kBlackColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                Languages.of(context)!.loginwithappleText,
                                style: Pallete.Quicksand15blackwe600,
                              ),
                            ],
                          ),
                        ),
                      )
                      : Container(),
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    width: kSize.width,
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    decoration: Pallete.getBorderButtonDecoration(),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          AppColors.kWhiteColor,
                        ),
                        elevation: const WidgetStatePropertyAll(0),
                        overlayColor: const WidgetStatePropertyAll(
                          AppColors.kAppBArBGColor,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: AppColors.kBorderColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          Languages.of(context)!.loginwithemailText,
                          style: Pallete.Quicksand15blackwe600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          isLoading
              ? Container(
                height: kSize.height,
                width: kSize.width,
                color: Colors.transparent,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              )
              : Container(),
        ],
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    final lang = Languages.of(context)!;

    if (usernameTextController.text.isEmpty) {
      return kToast(lang.pleaseenterusernameText);
    }
    if (firstNameTextController.text.isEmpty) {
      return kToast(lang.pleaseenterfirstnameText);
    }
    if (lastNameTextController.text.isEmpty) {
      return kToast(lang.pleaseenterlastnameText);
    }
    if (emailTextController.text.isEmpty) {
      return kToast(lang.pleaseenteremailText);
    }
    if (!ValidationChecks.validateEmail(emailTextController.text)) {
      return kToast(lang.entervalidemailText);
    }

    if (loginType == "login") {
      if (passTextController.text.isEmpty) {
        return kToast(lang.pleaseenterpasswordText);
      }
      if (confirmpassTextController.text.isEmpty) {
        return kToast(lang.pleaseenterconfirmpasswordText);
      }
      if (passTextController.text.length < 6 ||
          confirmpassTextController.text.length < 6) {
        return kToast(lang.Thepasswordmustbeatleast6charactersText);
      }
      if (passTextController.text != confirmpassTextController.text) {
        return kToast(lang.confirmpasswordnotmatchedText);
      }
    }

    if (accounttypedropdownvalue == null) {
      return kToast(lang.PleaseselectdropdownvalueText);
    }

    if (accounttypedropdownvalue == lang.beautybusinessText &&
        categorydropdownvalue == null) {
      return kToast(lang.pleaseselectcategoryText);
    }

    _handleSocialLoginOrSignup();
  }

  Future<void> _handleSocialLoginOrSignup() async {
    String userType =
        accounttypedropdownvalue == Languages.of(context)!.gossiperText
            ? "1"
            : "2";

    if (loginType == "google" || loginType == "apple") {
      dologin(
        loginType,
        emailTextController.text,
        passTextController.text,
        first_name: firstNameTextController.text,
        last_name: lastNameTextController.text,
        social_id: widget.socialid,
        user_type: userType,
      );
    } else {
      if (accounttypedropdownvalue == Languages.of(context)!.gossiperText) {
        await doSignup(
          firstNameTextController.text,
          lastNameTextController.text,
          emailTextController.text,
          passTextController.text,
          userType,
          usernameTextController.text,
          '',
        );
      } else {
        await doSignup(
          firstNameTextController.text,
          lastNameTextController.text,
          emailTextController.text,
          passTextController.text,
          "2",
          usernameTextController.text,
          categorydropdownvalue!,
        );
      }
    }
  }

  void signInWithApple() async {
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print("result == $result");
      await getCheckAccountExist(
        result.userIdentifier ?? "",
        "apple",
        appleAccount: result,
      );

      // print('Successfully signed in with Apple!');
      // print('User ID: ${result.userIdentifier}');
      // print('Email: ${result.email}');
      // print('givenName: ${result.givenName}');
      // print('familyName: ${result.familyName}');

      //  getCheckAccountExist(result.userIdentifier??"", account);
      // dologin("apple", result.email ?? "", "",
      //     social_id: result.userIdentifier ?? "",
      //     first_name: result.givenName ?? "",
      //     last_name: result.familyName ?? "");
    } catch (error) {
      print('Error signing in with Apple: $error');
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  void _handleGoogleSignIn() async {
    _googleSignIn
        .signIn()
        .then((GoogleSignInAccount? account) {
          if (account != null) {
            var socialid = account.id;
            account.displayName!.split(" ");

            getCheckAccountExist(socialid, "google", account: account);
          }
        })
        .catchError((e) {
          print(e);
        });
  }

  getcheckUsernameExist(String user_name) async {
    print("get getcheckUsernameExist function call");
    setState(() {
      // isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<CheckUserNameExistViewModel>(
          context,
          listen: false,
        ).getcheckUsernameExist(user_name);
        if (Provider.of<CheckUserNameExistViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<CheckUserNameExistViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              // isLoading = false;
              print("Success");
              CheckUsernameExistModel model =
                  Provider.of<CheckUserNameExistViewModel>(
                        context,
                        listen: false,
                      ).checkusernameexistresponse.response
                      as CheckUsernameExistModel;

              if (model.success == true) {
                kToast(Languages.of(context)!.usernamenotavailableText);
              }
            });
          } else {
            setState(() {
              // isLoading = false;
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

  getCheckAccountExist(
    String social_id,
    String type, {
    AuthorizationCredentialAppleID? appleAccount,
    GoogleSignInAccount? account,
  }) async {
    print("getCheckAccountExist function call");
    setState(() {});
    String fName = "";
    String lName = "";
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<CheckUserExistViewModel>(
          context,
          listen: false,
        ).getCheckAccountExist(social_id);
        if (Provider.of<CheckUserExistViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<CheckUserExistViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            print("Success");

            CheckUserExistModel model =
                Provider.of<CheckUserExistViewModel>(
                      context,
                      listen: false,
                    ).checkuserexistresponse.response
                    as CheckUserExistModel;
            print("model success = ${model.success}");
            if (account != null) {}

            if (type != "apple") {
              var fullname = account!.displayName!.split(" ");

              if (fullname.length > 1) {
                fName = fullname[0];
                lName = fullname[1];
              } else {
                fName = fullname[0];
              }
            }
            if (model.success == false) {
              if (type == "apple") {
                print("appleAccount == $appleAccount");
                firstNameTextController.text = appleAccount!.givenName ?? "";
                lastNameTextController.text = appleAccount.familyName ?? "";
                emailTextController.text = appleAccount.email ?? "";
                loginType = "apple";
                widget.socialid = appleAccount.userIdentifier ?? "";
                setState(() {});
              } else {
                var fullname = account!.displayName!.split(" ");
                if (fullname.length > 1) {
                  fName = fullname[0];
                  lName = fullname[1];
                } else {
                  fName = fullname[0];
                }
                firstNameTextController.text = fName;
                lastNameTextController.text = lName;
                emailTextController.text = account.email;
                loginType = "google";
                widget.socialid = account.id;
                setState(() {});
              }
            } else {
              if (type == "apple") {
                dologin(
                  "apple",
                  appleAccount!.email ?? "",
                  "",
                  first_name: appleAccount.givenName ?? "",
                  last_name: appleAccount.familyName ?? "",
                  social_id: appleAccount.userIdentifier!,
                  user_type: "",
                );
              } else {
                var fullname = account!.displayName!.split(" ");
                if (fullname.length > 1) {
                  fName = fullname[0];
                  lName = fullname[1];
                } else {
                  fName = fullname[0];
                }
                dologin(
                  "google",
                  account.email,
                  "",
                  first_name: fName,
                  last_name: lName,
                  social_id: account.id,
                  user_type: "",
                );
              }
            }
          } else {
            setState(() {});
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

  dologin(
    String social_type,
    String email,
    String password, {
    first_name,
    last_name,
    social_id,
    user_type,
  }) async {
    print("get function call");
    setState(() {
      isLoading = true;
    });

    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<LoginViewModel>(context, listen: false).doLogin(
          social_type,
          email,
          password,
          first_name: first_name,
          last_name: last_name,
          social_id: social_id,
          user_type: user_type,
        );
        if (Provider.of<LoginViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<LoginViewModel>(context, listen: false).isSuccess ==
              true) {
            isLoading = false;
            print("Success");
            LoginModel model =
                Provider.of<LoginViewModel>(
                      context,
                      listen: false,
                    ).loginresponse.response
                    as LoginModel;

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();

            await prefs.setString('userid', model.response!.id.toString());
            await prefs.setString(
              'firebaseid',
              model.response!.firebaseId.toString(),
            );

            await prefs.setString(
              'profileimg',
              model.response!.profileImage.toString(),
            );

            await prefs.setString(
              'userType',
              model.response!.userType.toString(),
            );

            if (accounttypedropdownvalue ==
                Languages.of(context)!.gossiperText) {
              await prefs.setString('userType', "1");
            } else {
              await prefs.setString('userType', "2");
            }
            if (model.response!.userType == 2) {
              await prefs.setString('salonid', model.response!.id.toString());
            }

            kToast(model.message!);

            if (model.success == true) {
              if (social_type == "google" || social_type == "apple") {
                DatabaseReference userRef = FirebaseDatabase.instance
                    .ref()
                    .child('users');

                String userId = model.response!.id.toString();

                DatabaseEvent event = await userRef.child(userId).once();
                DataSnapshot snapshot = event.snapshot;

                if (model.response!.firebaseId != null) {
                  print('User already exists');
                  await updateFirebaseId(model.response!.firebaseId!, fcmToken);
                } else {
                  print("in eelsse");
                  SharedPreferences preffs =
                      await SharedPreferences.getInstance();

                  DatabaseReference userRef = FirebaseDatabase.instance
                      .ref()
                      .child('users');
                  DatabaseReference databaseReference = userRef.push();
                  // Replace the following values with actual user data
                  preffs.setString(
                    "FirebaseId",
                    databaseReference.key.toString(),
                  );
                  await userRef.child(databaseReference.key.toString()).set({
                    "id": databaseReference.key,
                    "loginuserid": model.response!.id.toString(),
                    "nickname":
                        "${model.response!.firstName!}${model.response!.lastName!}",
                    "photoUrl": "",
                    "status": "online",
                    "fcmToken": fcmToken,
                  });
                  await updateFirebaseId(databaseReference.key!, fcmToken);

                  // DatabaseReference databaseReference = userRef.child(userId);
                  // print("databaseReference == ${databaseReference}");

                  // prefs.setString("FirebaseId", userId);
                  // await databaseReference.set(
                  //   {
                  //     "id": databaseReference.key,
                  //     "loginuserid": model.response!.id.toString(),
                  //     "nickname":
                  //         "${model.response!.firstName!}${model.response!.lastName!}",
                  //     "photoUrl": "",
                  //     "status": "online",
                  //     "fcmToken": fcmToken,
                  //   },
                  // );
                }
              }
            }

            if (model.success == true) {
              prefs.setBool("isLogin", true);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavBar(index: 0)),
              );
            } else {
              print("model.success == false");
            }
          } else {
            setState(() {
              isLoading = false;
              // print("Error");
              // kToast("user not found");
            });
            kToast(
              Provider.of<LoginViewModel>(
                context,
                listen: false,
              ).loginresponse.msg.toString(),
            );
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

  doSignup(
    String first_name,
    String last_name,
    String email,
    String password,
    String user_type,
    String user_name,
    String category,
  ) async {
    print("get function call");
    setState(() {
      isLoading = true;
    });

    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SignUpViewModel>(context, listen: false).doSignup(
          first_name,
          last_name,
          email,
          password,
          user_type,
          user_name,
          category,
        );
        if (Provider.of<SignUpViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<SignUpViewModel>(context, listen: false).isSuccess ==
              true) {
            print("Success");
            SignUpModel model =
                Provider.of<SignUpViewModel>(
                      context,
                      listen: false,
                    ).signupresponse.response
                    as SignUpModel;
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();

            await prefs.setString('userid', model.response!.id.toString());

            if (accounttypedropdownvalue ==
                Languages.of(context)!.gossiperText) {
              await prefs.setString('userType', "1");
            } else {
              await prefs.setString('userType', "2");
            }

            kToast(model.message!);
            SharedPreferences preffs = await SharedPreferences.getInstance();

            print("modell ==== ${model.response!.toJson()}");
            if (model.success == true) {
              DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
                'users',
              );
              DatabaseReference databaseReference = userRef.push();
              // Replace the following values with actual user data
              preffs.setString("FirebaseId", databaseReference.key.toString());
              print("databaseReference.key == ${databaseReference.key}");
              print("Key: ${databaseReference.key}");
              print("Ref: ${userRef.path}");
              // await userRef.child(databaseReference.key.toString()).set(
              //   {
              //     "id": databaseReference.key,
              //     "loginuserid": model.response!.id.toString(),
              //     "nickname":
              //         "${model.response!.firstName!}${model.response!.lastName!}",
              //     "photoUrl": "",
              //     "status": "online",
              //     "fcmToken": fcmToken,
              //   },
              // );

              try {
                await userRef.child(databaseReference.key.toString()).set({
                  "id": databaseReference.key,
                  "loginuserid": model.response!.id.toString(),
                  "nickname":
                      "${model.response!.firstName!}${model.response!.lastName!}",
                  "photoUrl": "",
                  "status": "online",
                  "fcmToken": fcmToken,
                });

                // ✅ Success
                print("Data added successfully!");
              } catch (e) {
                // ❌ Failure
                print("Failed to add data: $e");
              }

              await updateFirebaseId(
                databaseReference.key.toString(),
                fcmToken,
              );

              prefs.setBool("isLogin", true);
              // isLoading = false;
              // setState(() {});
              // print("Goint to home page......");

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => BottomNavBar(index: 0),
                ),
                ModalRoute.withName('/'),
              );
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => BottomNavBar(
              //               index: 0,
              //             )));
            } else {
              print("model.success == false");

              kToast(model.message!);
            }
          } else {
            setState(() {
              isLoading = false;
              // print("Error");
              // kToast("user not found");
            });
            kToast(
              Provider.of<SignUpViewModel>(
                context,
                listen: false,
              ).signupresponse.msg.toString(),
            );
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

  updateFirebaseId(String firebaseId, String fcm_token) async {
    print("updateDevicetoken function call");
    setState(() {});
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<UpdateDeviceTokenViewModel>(
          context,
          listen: false,
        ).updateFirebaseId(userid, firebaseId, fcm_token);
        if (Provider.of<UpdateDeviceTokenViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<UpdateDeviceTokenViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              DeviceTokenUpdateModel model =
                  Provider.of<UpdateDeviceTokenViewModel>(
                        context,
                        listen: false,
                      ).updatedevicetokenresponse.response
                      as DeviceTokenUpdateModel;

              print("model message == ${model.message}");
              // kToast(model.message!);
            });
          }
        } else {
          setState(() {});
          kToast(Languages.of(context)!.noInternetText);
        }
      }
    });
  }
}
