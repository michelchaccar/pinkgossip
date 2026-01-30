import 'package:flutter/cupertino.dart';

class ImageUtils {
  static const String basePath = "lib/assets/images";

  static const String bgImage = "$basePath/bgImg.png",
          // appLogoImg = "$basePath/logo@3x.png",
          homeLogo =
          "$basePath/home@3x.png",
      makeupselectLogo = "$basePath/makeup-icon-filled@3x.png",
      makeupLogo = "$basePath/makeup-icon@3x.png",
      postLogo = "$basePath/post-icon@3x.png",
      postselectLogo = "$basePath/post-icon-filled.png",
      messgaeLogo = "$basePath/message-icon@3x.png",
      messgaselectLogo = "$basePath/message-icon-filled@3x.png",
      profileLogo = "$basePath/profile-icon@3x.png",
      profileLselectogo = "$basePath/profile-icon-filled@3x.png",
      appbarlogo = "$basePath/nav-logo@3x.png",
      leftarrow = "$basePath/leftarrow.png",
      searchimg = "$basePath/search@3x.png",
      notificationimg = "$basePath/bellicon@3x.png",
      emptystartimg = "$basePath/empty-start.png",
      starhalfimg = "$basePath/star-half@2x.png",
      startfullimg = "$basePath/start-full@2x.png",
      moreoptionimg = "$basePath/more-option-icon.png",
      heartimg = "$basePath/heart-icon@3x.png",
      lipimage = "$basePath/ilp-icon@3x.png",
      uploadimage = "$basePath/upload-icon.png",
      uploadvideo = "$basePath/upload.png",
      qrImge = "$basePath/qrcode.png",
      star3x = "$basePath/start-full@3x.png",
      sendimage = "$basePath/send -con@3x.png",
      listicon = "$basePath/list-icon@3x.png",
      gridicon = "$basePath/grid-icon-filled@3x.png",
      videoicon = "$basePath/video-icon-filled@3x.png",
      mapImage = "$basePath/map-icon@3x.png",
      daysImage = "$basePath/days-icon.png",
      timeImage = "$basePath/time-icon.png",
      phoneImage = "$basePath/phone-icon.png",
      websiteImage = "$basePath/website-icon.png",
      rewardImage = "$basePath/rewardicon.png",
      mapsmallImage = "$basePath/map-icon.png",
      homeselectLogo = "$basePath/home-filled@3x.png",
      shareIcon = "$basePath/share.png",
      profilebtmIcon = "$basePath/profile-icon-filled@3x.png";

  static Widget bgImg(BuildContext context) {
    return Image.asset(
      bgImage,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
    );
  }

  static Widget appLogo(BuildContext context) {
    return Image.asset(
      "lib/assets/images/logo@3x.png",
      height: MediaQuery.of(context).size.height * 0.075,
    );
  }
}
