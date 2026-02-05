// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/forgotpasswordviewmodel.dart';
import '../../models/forgotpasswordmodel.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  TextEditingController emailTextController = TextEditingController();
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
          children: [
            InkWell(
              overlayColor: const WidgetStatePropertyAll(AppColors.kWhiteColor),
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
              Languages.of(context)!.forgotpassText,
              style: Pallete.Quicksand16drkBlackBold,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  height: 160,
                  color: AppColors.kWhiteColor,
                  alignment: Alignment.topCenter,
                  child: Image.asset("lib/assets/images/logo@3x.png"),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30),
                  child: TextFormField(
                    autocorrect: true,
                    maxLines: 1,
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
                const SizedBox(height: 30),
                Container(
                  height: 60,
                  width: kSize.width,
                  margin: const EdgeInsets.only(left: 30, right: 30),
                  decoration: Pallete.getBorderButtonDecoration(),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: const WidgetStatePropertyAll(
                        AppColors.kPinkColor,
                      ),
                      elevation: const WidgetStatePropertyAll(0),
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
                    onPressed: () async {
                      if (emailTextController.text.isEmpty) {
                        kToast(Languages.of(context)!.pleaseenteremailText);
                      } else if (ValidationChecks.validateEmail(
                            emailTextController.text,
                          ) ==
                          false) {
                        kToast(Languages.of(context)!.entervalidemailText);
                      } else {
                        await callForgotPass(emailTextController.text);
                      }
                    },
                    child: Center(
                      child: Text(
                        Languages.of(context)!.sendlinktText,
                        style: Pallete.buttonTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
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

  callForgotPass(String email) async {
    print("get callForgotPass function call");
    setState(() {
      isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<ForgotPassViewModel>(
          context,
          listen: false,
        ).forgotPassword(email);
        if (Provider.of<ForgotPassViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<ForgotPassViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              print("Success");
              Forgotpasswordmodel model =
                  Provider.of<ForgotPassViewModel>(
                        context,
                        listen: false,
                      ).forgotpasswordresponse.response
                      as Forgotpasswordmodel;
              kToast(model.message!);
            });
          } else {
            setState(() {
              isLoading = false;
            });
            kToast(
              Provider.of<ForgotPassViewModel>(
                context,
                listen: false,
              ).forgotpasswordresponse.msg.toString(),
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
}
