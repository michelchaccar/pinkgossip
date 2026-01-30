// ignore_for_file: unused_local_variable

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/Shops/productdetails.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  TextEditingController searchtexteditingcontroller = TextEditingController();

  bool isselcted1 = false;
  bool isselcted2 = false;
  bool isselcted3 = false;
  bool isselcted4 = false;
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
            SizedBox(height: 50, child: Image.asset(ImageUtils.appbarlogo)),
            Row(
              children: [
                InkWell(
                  overlayColor: const WidgetStatePropertyAll(
                    AppColors.kWhiteColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: Image.asset(ImageUtils.heartimg),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  overlayColor: const WidgetStatePropertyAll(
                    AppColors.kWhiteColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 30,
                        child: Image.asset("lib/assets/images/shopping.png"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        maxLines: 1,
                        autocorrect: true,
                        controller: searchtexteditingcontroller,
                        scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.search,
                        cursorColor: AppColors.kTextColor,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          fillColor: AppColors.kWhiteColor,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                          hintText: Languages.of(context)!.searchText,
                          hintStyle: Pallete.textFieldTextStyle,
                          suffixIcon: const Icon(Icons.search, size: 30),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            borderSide: BorderSide(
                              width: 1,
                              color: AppColors.kTextFieldBorderColor,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            borderSide: BorderSide(
                              width: 1,
                              color: AppColors.kPinkColor,
                            ),
                          ),
                          focusColor: AppColors.kPinkColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: Image.asset("lib/assets/images/filter.png"),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  Languages.of(context)!.categoriesText,
                  style: Pallete.Quicksand18drkBlackbold,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        color: AppColors.chatSenderColor,
                        border: Border.all(
                          color:
                              isselcted1
                                  ? Colors.black
                                  : const Color(0xffdfdfdf),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isselcted1 = !isselcted1;
                            isselcted2 = false;
                            isselcted3 = false;
                            isselcted4 = false;
                          });
                        },
                        child: Center(
                          child: Text(Languages.of(context)!.eyesText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isselcted2
                                  ? Colors.black
                                  : const Color(0xffdfdfdf),
                        ),
                        color: AppColors.chatSenderColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isselcted2 = !isselcted2;
                            isselcted1 = false;
                            isselcted3 = false;
                            isselcted4 = false;
                          });
                        },
                        child: Center(
                          child: Text(Languages.of(context)!.faceText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isselcted3
                                  ? Colors.black
                                  : const Color(0xffdfdfdf),
                        ),
                        color: AppColors.chatSenderColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isselcted3 = !isselcted3;
                            isselcted1 = false;
                            isselcted2 = false;
                            isselcted4 = false;
                          });
                        },
                        child: Center(
                          child: Text(Languages.of(context)!.lipsText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isselcted4
                                  ? Colors.black
                                  : const Color(0xffdfdfdf),
                        ),
                        color: AppColors.chatSenderColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isselcted4 = !isselcted4;
                            isselcted1 = false;
                            isselcted2 = false;
                            isselcted3 = false;
                          });
                        },
                        child: Center(
                          child: Text(Languages.of(context)!.handsText),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                GridView.builder(
                  itemCount: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 18,
                  ),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductDetails(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: AppColors.kTextFieldBorderColor,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    "lib/assets/images/productimg.png",
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "ST Lundon",
                              style: Pallete.Quicksand15blackwe600,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "ST London - Dual Wet & Dry Compact Powder",
                              maxLines: 2,
                              style: Pallete.Quicksand15blackwe300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "\$39.99",
                              style: Pallete.Quicksand15blackwe600,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.kPinkColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    AppColors.kPinkColor,
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  elevation: WidgetStateProperty.all(0),
                                ),
                                child: Center(
                                  child: Text(
                                    Languages.of(context)!.addtocartText,
                                    style: const TextStyle(
                                      color: AppColors.kWhiteColor,
                                      fontFamily: "Quicksand",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
