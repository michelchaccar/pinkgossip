// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, deprecated_member_use

import 'dart:io';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/checkuserexistmodel.dart';
import 'package:pinkGossip/models/updatefirebasemodel.dart';
import 'package:pinkGossip/services/tooltip_service.dart';
import 'package:pinkGossip/viewModels/checkaccountexistviewmodel.dart';
import 'package:pinkGossip/viewModels/updatefirebaseviewmodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/models/loginmodel.dart';
import 'package:pinkGossip/screens/Auth/forgotpassword.dart';
import 'package:pinkGossip/screens/Auth/signupscreen.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/loginviewmodel.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../bottomnavi.dart';
import '../../utils/color_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passTextController = TextEditingController();

  bool ischeckUser = false;
  bool isLoading = false;

  String fcmToken = "";

  gefcmToken() async {
    print("gefcmToken");
    fcmToken = await FirebaseMessaging.instance.getToken() ?? "no fcm";
    print("token ========= $fcmToken");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmtoken', fcmToken);
  }

  String userid = "";
  getuserid() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs = await SharedPreferences.getInstance();
    userid = _prefs.getString('userid') ?? "";
    print("USER IDDD +++++++ $userid");
  }

  bool _obscureText = true;

  @override
  void initState() {
    getuserid();
    gefcmToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
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
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            width: 2,
                            color: AppColors.kBorderColor,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
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
                  const SizedBox(height: 30),
                  Container(
                    height: 55,
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    decoration: Pallete.getButtonDecoration(),
                    child: ElevatedButton(
                      onPressed: () {
                        if (emailTextController.text.isEmpty) {
                          kToast(Languages.of(context)!.pleaseenteremailText);
                        } else if (ValidationChecks.validateEmail(
                              emailTextController.text,
                            ) ==
                            false) {
                          kToast(Languages.of(context)!.entervalidemailText);
                        } else if (passTextController.text.isEmpty) {
                          kToast(
                            Languages.of(context)!.pleaseenterpasswordText,
                          );
                        } else if (passTextController.text.length < 6) {
                          kToast(
                            Languages.of(
                              context,
                            )!.Thepasswordmustbeatleast6charactersText,
                          );
                        } else {
                          dologin(
                            "login",
                            emailTextController.text,
                            passTextController.text,
                            first_name: "",
                            last_name: "",
                            social_id: "",
                            user_type: "",
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: const MaterialStatePropertyAll(
                          AppColors.kPinkColor,
                        ),
                        elevation: const MaterialStatePropertyAll(0),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          Languages.of(context)!.loginText,
                          style: Pallete.buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(left: 32),
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: Text(
                        textAlign: TextAlign.start,
                        Languages.of(context)!.fpText,
                        style: Pallete.textFieldTextStyle,
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
                        backgroundColor: const MaterialStatePropertyAll(
                          AppColors.kWhiteColor,
                        ),
                        elevation: const MaterialStatePropertyAll(0),
                        overlayColor: const MaterialStatePropertyAll(
                          AppColors.kAppBArBGColor,
                        ),
                        shape: MaterialStatePropertyAll(
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
                        backgroundColor: const MaterialStatePropertyAll(
                          AppColors.kWhiteColor,
                        ),
                        elevation: const MaterialStatePropertyAll(0),
                        overlayColor: const MaterialStatePropertyAll(
                          AppColors.kAppBArBGColor,
                        ),
                        shape: MaterialStatePropertyAll(
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
                            builder:
                                (context) => SignUpScreen(
                                  firstname: "",
                                  lastname: "",
                                  email: "",
                                  socialid: "",
                                  type: "login",
                                ),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          Languages.of(context)!.createAccountText,
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

  void signInWithApple() async {
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      var socialid = result.userIdentifier;

      await getCheckAccountExist(socialid!, appleAccount: result, "apple");
    } catch (error) {
      print('Error signing in with Apple: $error');
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  void _handleGoogleSignIn() async {
    try {
      await _googleSignIn
          .signIn()
          .then((GoogleSignInAccount? account) {
            if (account != null) {
              var email = account.email;
              var socialid = account.id;
              var fullname = account.displayName!.split(" ");
              print("email =${email}");
              print("account =${account}");
              if (fullname.length > 1) {
                print("fullname[0] = ${fullname[0]}");
                print("fullname[1] = ${fullname[1]}");
              } else {
                print("fullname[0] = ${fullname[0]}");
              }
              print("ischeckUser =${ischeckUser}");

              getCheckAccountExist(socialid, account: account, "google");
            }
          })
          .catchError((e) {
            print("e ===== $e");
          });
    } catch (e) {
      print("EEEEEEEEEEEEEE ======= $e");
    }
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

            print(
              "model.response!.id.toString()  ${model.response!.id.toString()}",
            );

            await prefs.setString('userid', model.response!.id.toString());
            await prefs.setString(
              'profileimg',
              model.response!.profileImage.toString(),
            );
            await prefs.setString(
              'FirebaseId',
              model.response!.firebaseId.toString(),
            );
            await prefs.setString(
              'userType',
              model.response!.userType.toString(),
            );
            if (model.response!.userType == 2) {
              await prefs.setString('salonid', model.response!.id.toString());
            }

            kToast(model.message!);
            if (model.success == true) {
              print("fcmToken = ${fcmToken}");
              if (model.response!.firebaseId != null) {
                await updateFirebaseId(model.response!.firebaseId!, fcmToken);
              }
              prefs.setBool("isLogin", true);
              prefs.setBool(
                "onboarding_completed_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_search_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_notification_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_addStory_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_home_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_storeLocator_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_post_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_message_${model.response!.id.toString()}",
                true,
              );
              prefs.setBool(
                "tooltip_seen_profile_${model.response!.id.toString()}",
                true,
              );
              for (final type in TooltipType.values) {
                prefs.setBool(
                  _getTooltipKey(model.response!.id.toString(), type),
                  true,
                );
              }
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

  String _getTooltipKey(String userId, TooltipType type) {
    String typeStr = type.toString().split('.').last.toLowerCase();
    return 'tooltip_seen_${typeStr}_$userId';
  }

  updateFirebaseId(String firebase_id, String fcm_token) async {
    print("updateDevicetoken function call");
    setState(() {});
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<UpdateDeviceTokenViewModel>(
          context,
          listen: false,
        ).updateFirebaseId(userid, firebase_id, fcm_token);
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

  List<String>? googlefullname;

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

            print("account model success = ${account}");

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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SignUpScreen(
                          firstname: appleAccount!.givenName ?? "",
                          lastname: appleAccount.familyName ?? "",
                          email: appleAccount.email ?? "",
                          socialid: appleAccount.userIdentifier ?? "",
                          type: "apple",
                        ),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SignUpScreen(
                          firstname: fName,
                          lastname: lName,
                          email: account!.email,
                          socialid: account.id,
                          type: "google",
                        ),
                  ),
                );
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
}
