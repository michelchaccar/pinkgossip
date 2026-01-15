import 'package:flutter/material.dart';

/// Responsive configuration for onboarding with linear interpolation
/// Adapted for all screens from iPhone SE to iPhone Pro Max
class OnboardingResponsiveConfig {
  final Size screenSize;

  OnboardingResponsiveConfig(this.screenSize);

  // ============================================================
  // GLOBAL CONSTANTS
  // ============================================================

  // --- Screen Breakpoints ---
  static const double minScreenHeight = 667;  // iPhone SE
  static const double maxScreenHeight = 926;  // iPhone 17 Pro Max
  static const double verySmallThreshold = 667;

  // --- Global Font Sizes ---
  static const double minTitleFontSize = 32;
  static const double maxTitleFontSize = 46;
  static const double minBodyFontSize = 13;
  static const double maxBodyFontSize = 18;
  static const double minCardTitleFontSize = 14;
  static const double maxCardTitleFontSize = 19;

  // --- Global Image Sizes ---
  static const double minQrCodeSize = 180;
  static const double maxQrCodeSize = 280;
  static const double minQrCodeScale = 1.0;
  static const double maxQrCodeScale = 1.2;
  static const double minButterflySize = 70;
  static const double maxButterflySize = 95;

  // --- Global Spacing ---
  static const double minVerticalSpacing = 12;
  static const double maxVerticalSpacing = 24;
  static const double minCardPadding = 12;
  static const double maxCardPadding = 24;
  static const double minTopPadding = 60;
  static const double maxTopPadding = 80;
  static const double minBottomSpacing = 100;
  static const double maxBottomSpacing = 160;

  // --- Global Card Insets ---
  static const double minCardInsetsHorizontal = 12;
  static const double maxCardInsetsHorizontal = 28;
  static const double minCardInsetsVertical = 8;
  static const double maxCardInsetsVertical = 14;

  // ============================================================
  // SALON SCREEN 1 - WELCOME
  // ============================================================

  // --- Title Section ---
  static const double minScreen1TitleTop = 90;
  static const double maxScreen1TitleTop = 130;

  // --- Card Section ---
  static const double minScreen1CardWidth = 260;
  static const double maxScreen1CardWidth = 300;
  static const double minScreen1CardPadding = 20;
  static const double maxScreen1CardPadding = 28;
  static const double minScreen1CardTextSize = 20;
  static const double maxScreen1CardTextSize = 26;

  // --- Butterfly Section ---
  static const double minScreen1ButterflySize = 350;
  static const double maxScreen1ButterflySize = 450;

  // --- Button Section ---
  static const double minScreen1ButtonBottom = 25;
  static const double maxScreen1ButtonBottom = 35;

  // ============================================================
  // SALON SCREEN 2 - WHAT IS PINK GOSSIP
  // ============================================================

  // --- Title Section ---
  static const double minScreen2TitleTop = 90;
  static const double maxScreen2TitleTop = 130;

  // --- Phone Mockup Section ---
  static const double minScreen2PhoneBottomPadding = 80;
  static const double maxScreen2PhoneBottomPadding = 120;
  static const double minScreen2PhoneHeightRatio = 0.60;
  static const double maxScreen2PhoneHeightRatio = 0.68;

  // --- Card Section ---
  static const double minScreen2CardBottom = 90;
  static const double maxScreen2CardBottom = 120;
  static const double minScreen2CardPadding = 20;
  static const double maxScreen2CardPadding = 28;
  static const double minScreen2CardTextSize = 16;
  static const double maxScreen2CardTextSize = 20;

  // --- Button Section ---
  static const double minScreen2ButtonBottom = 25;
  static const double maxScreen2ButtonBottom = 35;

  // ============================================================
  // SALON SCREEN 3 - QR CODE SCAN
  // ============================================================

  // --- Title Section ---
  static const double minScreen3TopPadding = 25;
  static const double maxScreen3TopPadding = 25;
  static const double minScreen3TitlePaddingV = 10;
  static const double maxScreen3TitlePaddingV = 14;

  // --- QR Code Section ---
  static const double minScreen3QrCodeSize = 180;
  static const double maxScreen3QrCodeSize = 220;
  static const double screen3QrCodeScale = 1.0;

  // ============================================================
  // SALON SCREEN 4 - BOOM ANIMATION
  // ============================================================

  // --- Title Section ---
  static const double minScreen4TitleFontSize = 28;
  static const double maxScreen4TitleFontSize = 40;

  // --- Card Section ---
  static const double minScreen4CardSpacing = 12;
  static const double maxScreen4CardSpacing = 16;
  static const double minScreen4CardTextFontSize = 14;
  static const double maxScreen4CardTextFontSize = 17;
  static const double minScreen4CardButterflySize = 80;
  static const double maxScreen4CardButterflySize = 100;

  // --- Boom Section ---
  static const double minScreen4BoomTitleFontSize = 15;
  static const double maxScreen4BoomTitleFontSize = 18;
  static const double minScreen4BoomDescFontSize = 12;
  static const double maxScreen4BoomDescFontSize = 14;
  static const double minScreen4BoomPadding = 12;
  static const double maxScreen4BoomPadding = 20;
  static const double minScreen4BoomTitleSpacing = 6;
  static const double maxScreen4BoomTitleSpacing = 10;

  // ============================================================
  // SALON SCREEN 5 - MESSAGE BUBBLES
  // ============================================================

  // --- Title Section ---
  static const double minScreen5TitleFontSize = 26;
  static const double maxScreen5TitleFontSize = 36;
  static const double minScreen5TitleTop = 60;
  static const double maxScreen5TitleTop = 90;

  // --- Phone Mockup Section ---
  static const double minScreen5PhoneHeightRatio = 0.50;
  static const double maxScreen5PhoneHeightRatio = 0.65;
  static const double minScreen5PhoneBottomPadding = 30;
  static const double maxScreen5PhoneBottomPadding = 50;

  // --- Message Bubbles Section ---
  static const double minScreen5BubbleSpacing = 8;
  static const double maxScreen5BubbleSpacing = 12;
  static const double minScreen5BubblePaddingH = 16;
  static const double maxScreen5BubblePaddingH = 20;
  static const double minScreen5BubblePaddingV = 10;
  static const double maxScreen5BubblePaddingV = 12;
  static const double minScreen5BubbleTitleFontSize = 12;
  static const double maxScreen5BubbleTitleFontSize = 14;
  static const double minScreen5BubbleSubtitleFontSize = 10;
  static const double maxScreen5BubbleSubtitleFontSize = 12;
  static const double minScreen5BubblesBottom = 100;
  static const double maxScreen5BubblesBottom = 120;
  static const double minScreen5BubbleInnerSpacing = 3;
  static const double maxScreen5BubbleInnerSpacing = 5;

  // ============================================================
  // SALON SCREEN 6 - FINAL SCREEN
  // ============================================================

  // --- Title Section ---
  static const double minScreen6TitleFontSize = 32;
  static const double maxScreen6TitleFontSize = 42;
  static const double minScreen6TitleTop = 20;
  static const double maxScreen6TitleTop = 40;
  static const double minScreen6TitleToBoxSpacing = 30;
  static const double maxScreen6TitleToBoxSpacing = 60;

  // --- Butterfly & Text Box Section ---
  static const double minScreen6ButterflyBoxHeight = 160;
  static const double maxScreen6ButterflyBoxHeight = 200;
  static const double minScreen6ButterflyBoxTextSize = 16;
  static const double maxScreen6ButterflyBoxTextSize = 20;
  static const double minScreen6ButterflyImageSize = 240;
  static const double maxScreen6ButterflyImageSize = 300;
  static const double minScreen6ButterflyBoxPadding = 8;
  static const double maxScreen6ButterflyBoxPadding = 12;

  // --- Phone & QR Code Section ---
  static const double minScreen6PhoneScale = 1.10;
  static const double maxScreen6PhoneScale = 1.30;
  static const double minScreen6QrCodeScale = 1.0;
  static const double maxScreen6QrCodeScale = 1.2;
  static const double minScreen6QrCodeSize = 160;
  static const double maxScreen6QrCodeSize = 200;

  // --- Spacing Section ---
  static const double minScreen6BottomSpacing = 10;
  static const double maxScreen6BottomSpacing = 20;

  // Linear interpolation between min and max values based on screen height
  double _interpolate(double minHeight, double maxHeight, double minValue, double maxValue) {
    final height = screenSize.height;
    if (height <= minHeight) return minValue;
    if (height >= maxHeight) return maxValue;

    // Calculate ratio and interpolate
    final ratio = (height - minHeight) / (maxHeight - minHeight);
    return minValue + (maxValue - minValue) * ratio;
  }

  // Helper: Check if screen is very small (for special cases like scroll)
  bool get isVerySmall => screenSize.height < verySmallThreshold;

  // Font sizes - smoothly adapt from iPhone SE to Pro Max
  double get titleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minTitleFontSize, maxTitleFontSize);
  double get bodyFontSize => _interpolate(minScreenHeight, maxScreenHeight, minBodyFontSize, maxBodyFontSize);
  double get cardTitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minCardTitleFontSize, maxCardTitleFontSize);

  // Image sizes - smoothly adapt
  double get qrCodeSize => _interpolate(minScreenHeight, maxScreenHeight, minQrCodeSize, maxQrCodeSize);
  double get qrCodeScale => _interpolate(minScreenHeight, maxScreenHeight, minQrCodeScale, maxQrCodeScale);
  double get butterflySize => _interpolate(minScreenHeight, maxScreenHeight, minButterflySize, maxButterflySize);

  // Spacing - smoothly adapt
  double get verticalSpacing => _interpolate(minScreenHeight, maxScreenHeight, minVerticalSpacing, maxVerticalSpacing);
  double get cardPadding => _interpolate(minScreenHeight, maxScreenHeight, minCardPadding, maxCardPadding);
  double get topPadding => _interpolate(minScreenHeight, maxScreenHeight, minTopPadding, maxTopPadding);
  double get bottomSpacing => _interpolate(minScreenHeight, maxScreenHeight, minBottomSpacing, maxBottomSpacing);

  // Screen 1 specific - Getters
  double get screen1TitleTop => _interpolate(minScreenHeight, maxScreenHeight, minScreen1TitleTop, maxScreen1TitleTop);
  double get screen1CardWidth => _interpolate(minScreenHeight, maxScreenHeight, minScreen1CardWidth, maxScreen1CardWidth);
  double get screen1CardPadding => _interpolate(minScreenHeight, maxScreenHeight, minScreen1CardPadding, maxScreen1CardPadding);
  double get screen1CardTextSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen1CardTextSize, maxScreen1CardTextSize);
  double get screen1ButterflySize => _interpolate(minScreenHeight, maxScreenHeight, minScreen1ButterflySize, maxScreen1ButterflySize);
  double get screen1ButtonBottom => _interpolate(minScreenHeight, maxScreenHeight, minScreen1ButtonBottom, maxScreen1ButtonBottom);

  // Helper getter for butterfly offset (proportional to butterfly size)
  double get screen1ButterflyOffset => screen1ButterflySize / 2;

  // Screen 2 specific - Getters
  double get screen2TitleTop => _interpolate(minScreenHeight, maxScreenHeight, minScreen2TitleTop, maxScreen2TitleTop);
  double get screen2PhoneBottomPadding => _interpolate(minScreenHeight, maxScreenHeight, minScreen2PhoneBottomPadding, maxScreen2PhoneBottomPadding);
  double get screen2PhoneHeightRatio => _interpolate(minScreenHeight, maxScreenHeight, minScreen2PhoneHeightRatio, maxScreen2PhoneHeightRatio);
  double get screen2CardBottom => _interpolate(minScreenHeight, maxScreenHeight, minScreen2CardBottom, maxScreen2CardBottom);
  double get screen2CardPadding => _interpolate(minScreenHeight, maxScreenHeight, minScreen2CardPadding, maxScreen2CardPadding);
  double get screen2CardTextSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen2CardTextSize, maxScreen2CardTextSize);
  double get screen2ButtonBottom => _interpolate(minScreenHeight, maxScreenHeight, minScreen2ButtonBottom, maxScreen2ButtonBottom);

  // Screen 3 specific - Getters
  double get screen3TopPadding => _interpolate(minScreenHeight, maxScreenHeight, minScreen3TopPadding, maxScreen3TopPadding);
  double get screen3QrCodeSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen3QrCodeSize, maxScreen3QrCodeSize);
  double get screen3TitlePaddingV => _interpolate(minScreenHeight, maxScreenHeight, minScreen3TitlePaddingV, maxScreen3TitlePaddingV);

  EdgeInsets get cardInsets {
    final horizontal = _interpolate(minScreenHeight, maxScreenHeight, minCardInsetsHorizontal, maxCardInsetsHorizontal);
    final vertical = _interpolate(minScreenHeight, maxScreenHeight, minCardInsetsVertical, maxCardInsetsVertical);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  // Screen 4 specific - Getters
  double get screen4TitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen4TitleFontSize, maxScreen4TitleFontSize);
  double get screen4CardSpacing => _interpolate(minScreenHeight, maxScreenHeight, minScreen4CardSpacing, maxScreen4CardSpacing);
  double get screen4CardTextFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen4CardTextFontSize, maxScreen4CardTextFontSize);
  double get screen4CardButterflySize => _interpolate(minScreenHeight, maxScreenHeight, minScreen4CardButterflySize, maxScreen4CardButterflySize);
  double get screen4BoomTitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen4BoomTitleFontSize, maxScreen4BoomTitleFontSize);
  double get screen4BoomDescFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen4BoomDescFontSize, maxScreen4BoomDescFontSize);
  double get screen4BoomPadding => _interpolate(minScreenHeight, maxScreenHeight, minScreen4BoomPadding, maxScreen4BoomPadding);
  double get screen4BoomTitleSpacing => _interpolate(minScreenHeight, maxScreenHeight, minScreen4BoomTitleSpacing, maxScreen4BoomTitleSpacing);

  // Screen 5 specific - Getters
  double get screen5TitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen5TitleFontSize, maxScreen5TitleFontSize);
  double get screen5TitleTop => _interpolate(minScreenHeight, maxScreenHeight, minScreen5TitleTop, maxScreen5TitleTop);
  double get screen5PhoneHeightRatio => _interpolate(minScreenHeight, maxScreenHeight, minScreen5PhoneHeightRatio, maxScreen5PhoneHeightRatio);
  double get screen5PhoneBottomPadding => _interpolate(minScreenHeight, maxScreenHeight, minScreen5PhoneBottomPadding, maxScreen5PhoneBottomPadding);
  double get screen5BubbleSpacing => _interpolate(minScreenHeight, maxScreenHeight, minScreen5BubbleSpacing, maxScreen5BubbleSpacing);
  double get screen5BubbleTitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen5BubbleTitleFontSize, maxScreen5BubbleTitleFontSize);
  double get screen5BubbleSubtitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen5BubbleSubtitleFontSize, maxScreen5BubbleSubtitleFontSize);
  double get screen5BubblesBottom => _interpolate(minScreenHeight, maxScreenHeight, minScreen5BubblesBottom, maxScreen5BubblesBottom);
  double get screen5BubbleInnerSpacing => _interpolate(minScreenHeight, maxScreenHeight, minScreen5BubbleInnerSpacing, maxScreen5BubbleInnerSpacing);

  EdgeInsets get screen5BubblePadding {
    final h = _interpolate(minScreenHeight, maxScreenHeight, minScreen5BubblePaddingH, maxScreen5BubblePaddingH);
    final v = _interpolate(minScreenHeight, maxScreenHeight, minScreen5BubblePaddingV, maxScreen5BubblePaddingV);
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  // Screen 6 specific - Getters
  double get screen6TitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen6TitleFontSize, maxScreen6TitleFontSize);
  double get screen6TitleTop => _interpolate(minScreenHeight, maxScreenHeight, minScreen6TitleTop, maxScreen6TitleTop);
  double get screen6TitleToBoxSpacing => _interpolate(minScreenHeight, maxScreenHeight, minScreen6TitleToBoxSpacing, maxScreen6TitleToBoxSpacing);
  double get screen6ButterflyBoxHeight => _interpolate(minScreenHeight, maxScreenHeight, minScreen6ButterflyBoxHeight, maxScreen6ButterflyBoxHeight);
  double get screen6ButterflyBoxTextSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen6ButterflyBoxTextSize, maxScreen6ButterflyBoxTextSize);
  double get screen6ButterflyImageSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen6ButterflyImageSize, maxScreen6ButterflyImageSize);
  double get screen6ButterflyBoxPadding => _interpolate(minScreenHeight, maxScreenHeight, minScreen6ButterflyBoxPadding, maxScreen6ButterflyBoxPadding);
  double get screen6PhoneScale => _interpolate(minScreenHeight, maxScreenHeight, minScreen6PhoneScale, maxScreen6PhoneScale);
  double get screen6QrCodeScale => _interpolate(minScreenHeight, maxScreenHeight, minScreen6QrCodeScale, maxScreen6QrCodeScale);
  double get screen6QrCodeSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen6QrCodeSize, maxScreen6QrCodeSize);
  double get screen6BottomSpacing => _interpolate(minScreenHeight, maxScreenHeight, minScreen6BottomSpacing, maxScreen6BottomSpacing);
}
