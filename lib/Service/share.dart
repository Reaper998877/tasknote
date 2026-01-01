import 'package:share_plus/share_plus.dart';

class ShareService {
  // Access the SharePlus instance via SharePlus.instance. Then, invoke the share() method anywhere in your Dart code.
  // The share() method requires the ShareParams object, which contains the content to share.

  // These are some of the accepted parameters of the ShareParams class:
  // text: text to share.
  // title: content or share-sheet title (if supported).
  // subject: email subject (if supported).

  static Future<ShareResult> shareText(String text) async {
    final result = await SharePlus.instance.share(ShareParams(text: text));
    return result;
  }

 
}
