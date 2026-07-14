import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public store listing URLs so free builds can send users to buy Standard.
abstract final class StoreLinks {
  static const packageId = 'com.spencerbeaumier.sbnetpad';

  /// Numeric Apple App Store id (App Store Connect). Optional until published:
  /// `--dart-define=APPLE_APP_STORE_ID=1234567890`
  static const appleAppId = String.fromEnvironment('APPLE_APP_STORE_ID');

  static Uri get playStore => Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageId',
      );

  static Uri get appStore {
    if (appleAppId.isNotEmpty) {
      return Uri.parse('https://apps.apple.com/app/id$appleAppId');
    }
    return Uri.parse(
      'https://apps.apple.com/search?term=${Uri.encodeQueryComponent('SB Simple Netpad')}',
    );
  }

  static Uri get microsoftStore => Uri.parse(
        'https://apps.microsoft.com/search?query=${Uri.encodeQueryComponent('SB Simple Netpad')}',
      );

  /// Preferred listing for the current OS, if one exists.
  static Uri? get preferredListing {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return playStore;
    if (Platform.isIOS || Platform.isMacOS) return appStore;
    if (Platform.isWindows) return microsoftStore;
    return null;
  }

  /// True when there is no single preferred store for this OS (show all links).
  static bool get showAllStoreOptions => preferredListing == null;

  static Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
