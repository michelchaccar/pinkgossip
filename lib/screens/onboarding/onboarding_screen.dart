import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/localization/language/languages.dart';

class OnboardingScreen extends StatefulWidget {
  final String userType; // "1" for User, "2" for Salon (Consistent with LoginModel logic)
  final String userId;

  const OnboardingScreen({
    Key? key,
    required this.userType,
    required this.userId,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed_${widget.userId}', true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _cancelOnboarding() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder content based on user type
    // Assuming userType "2" is Salon based on LoginViewModel logic seen earlier (if (model.response!.userType == 2) ...)
    final isSalon = widget.userType == "2";
    final title = isSalon ? "Welcome Salon Partner!" : "Welcome to Pink Gossip!";
    final description = isSalon 
        ? "Manage your salon, connect with clients, and grow your business."
        : "Discover the best salons, share your experiences, and connect with others.";

    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Placeholder for Image
              Container(
                height: 200,
                width: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kBlackColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.kTextColor,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPinkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _cancelOnboarding,
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.kTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
