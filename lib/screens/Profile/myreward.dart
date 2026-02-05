import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/salondetailsviewmodel.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRewardPage extends StatefulWidget {
  const MyRewardPage({super.key});

  @override
  State<MyRewardPage> createState() => _MyRewardPageState();
}

class _MyRewardPageState extends State<MyRewardPage> {
  SharedPreferences? prefs;
  String userid = "";
  bool isLoading = false;

  List<Post> salonProfilePostArray = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAndCallApi();
    });
  }

  Future<void> _loadUserAndCallApi() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid') ?? "";
    if (userid.isNotEmpty) {
      myredeemRewardPost(userid);
    }
  }

  Future<void> myredeemRewardPost(String id) async {
    setState(() => isLoading = true);

    bool isConnected = await isInternetAvailable();
    if (!isConnected) {
      setState(() => isLoading = false);
      kToast(Languages.of(context)!.noInternetText);
      return;
    }

    final viewModel = Provider.of<SalonDetailsViewModel>(
      context,
      listen: false,
    );

    await viewModel.myredeemRewardPost(id);

    if (viewModel.isSuccess &&
        viewModel.salondetailsresponse.response != null) {
      final SalonDetailModel model =
          viewModel.salondetailsresponse.response as SalonDetailModel;

      setState(() {
        salonProfilePostArray = model.posts ?? [];
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.kAppBArBGColor,
        title: Text("My Rewards", style: Pallete.Quicksand16drkBlackBold),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : salonProfilePostArray.isEmpty
              ? const Center(child: Text("No rewards found"))
              : ListView.builder(
                itemCount: salonProfilePostArray.length,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero, // remove default ListView padding
                itemBuilder: (context, index) {
                  final post = salonProfilePostArray[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: NetworkImage(
                                    "${API.baseUrl}/api/${post.profileImage}",
                                  ),
                                ),

                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${post.firstName ?? ""}${post.lastName ?? ""}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      post.salonName ?? "",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          post.averageRating!.toStringAsFixed(
                                            1,
                                          ),
                                          style: Pallete.Quicksand12Greywe400,
                                        ),
                                        const SizedBox(width: 4),
                                        RatingBarIndicator(
                                          rating: double.parse(
                                            post.averageRating!.toString(),
                                          ),
                                          itemCount: 5,
                                          itemSize: 18.0,
                                          unratedColor:
                                              AppColors.klightGreyColor,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemBuilder:
                                              (context, _) => const Icon(
                                                Icons.star,
                                                color: AppColors.kPinkColor,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "(${post.ratingCount.toString()})",
                                          style: Pallete.Quicksand12Greywe400,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // IMAGE
                          post.otherMultiPost != null &&
                                  post.otherMultiPost!.isNotEmpty &&
                                  post.otherMultiPost![0].otherData != null &&
                                  post.otherMultiPost![0].otherData!.isNotEmpty
                              ? Image.network(
                                "${API.baseUrl}/api/${post.otherMultiPost![0].otherData}",
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                "lib/assets/images/profile2.png",
                                fit: BoxFit.cover,
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
