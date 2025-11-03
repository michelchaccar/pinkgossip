import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    if (_counter > 1) {
      setState(() {
        _counter--;
      });
    }
  }

  bool isselcted1 = true;
  bool isselcted2 = false;
  bool isselcted3 = false;
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
            Expanded(
              child: Text(
                "ST London - Dual Wet & Dry Compact Powder",
                style: Pallete.Quicksand16drkBlackBold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 300,
                  width: kSize.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset(
                      "lib/assets/images/productimg.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "ST London - Dual Wet & Dry Compact Powder",
                  style: Pallete.Quicksand16drkBlackBold,
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "${Languages.of(context)!.BrandText}: ",
                        style: Pallete.Quicksand12blackwe600,
                      ),
                      TextSpan(
                        text: "ST Lundon",
                        style: Pallete.Quicksand12darkGreykwe400,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "${Languages.of(context)!.ProductTypeText}: ",
                        style: Pallete.Quicksand12blackwe600,
                      ),
                      TextSpan(
                        text: "Powder",
                        style: Pallete.Quicksand12darkGreykwe400,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "${Languages.of(context)!.CategoryText}: ",
                        style: Pallete.Quicksand12blackwe600,
                      ),
                      TextSpan(
                        text: "Face",
                        style: Pallete.Quicksand12darkGreykwe400,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text("\$39.99", style: Pallete.Quicksand15blackwe600),
                const SizedBox(height: 25),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isselcted1 = true;
                          isselcted2 = false;
                          isselcted3 = false;
                        });
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isselcted1 ? Colors.pink : Colors.transparent,
                            width: isselcted1 ? 2 : 0,
                          ),
                          color: const Color(0xfffce8b3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isselcted2 = true;
                          isselcted1 = false;
                          isselcted3 = false;
                        });
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isselcted2 ? Colors.pink : Colors.transparent,
                            width: isselcted2 ? 2 : 0,
                          ),
                          color: const Color(0xffe6c689),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isselcted3 = true;
                          isselcted2 = false;
                          isselcted1 = false;
                        });
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isselcted3 ? Colors.pink : Colors.transparent,
                            width: isselcted3 ? 2 : 0,
                          ),
                          color: const Color(0xfffeeddf),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                        color:
                            _counter > 1 ? Colors.white : Colors.grey.shade200,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: InkWell(
                        onTap: _decrementCounter,
                        child: Icon(
                          Icons.remove,
                          color: _counter > 1 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Center(
                        child: Text(
                          '$_counter',
                          style: Pallete.Quicksand18drkBlackbold,
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                      ),
                      child: InkWell(
                        onTap: _incrementCounter,
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.kPinkColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.pop(context);
                          },
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
                    ),
                    const SizedBox(width: 15),
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
                        const SizedBox(width: 10),
                        InkWell(
                          overlayColor: const WidgetStatePropertyAll(
                            AppColors.kWhiteColor,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {},
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: Image.asset(ImageUtils.shareIcon),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
