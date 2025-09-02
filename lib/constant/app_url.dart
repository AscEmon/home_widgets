import 'package:home_widgets/utils/enum.dart';

enum AppUrl { base, baseImage, hadithApi, dailyHadith, hadithDetail }

extension AppUrlExtention on AppUrl {
  static String _baseUrl = "";
  static String _baseImageUrl = "";

  static void setUrl(UrlLink urlLink) {
    switch (urlLink) {
      case UrlLink.isLive:
        _baseUrl = "";
        _baseImageUrl = "";

        break;

      case UrlLink.isDev:
        _baseUrl = "";
        _baseImageUrl = "";

        break;
      case UrlLink.isLocalServer:
        // set up your local server ip address.
        _baseUrl = "";
        break;
    }
  }

  String get url {
    switch (this) {
      case AppUrl.base:
        return _baseUrl;
      case AppUrl.baseImage:
        return _baseImageUrl;
      case AppUrl.hadithApi:
        return 'https://api.sunnah.com/v1/collections/bukhari';
      case AppUrl.dailyHadith:
        // Using a specific hadith number instead of random endpoint
        return 'https://api.sunnah.com/v1/collections/bukhari/hadiths/1';
      case AppUrl.hadithDetail:
        return 'https://api.sunnah.com/v1/collections/bukhari/hadiths';
    }
  }
}
