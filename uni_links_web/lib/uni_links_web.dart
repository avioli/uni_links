import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:uni_links_platform_interface/uni_links_platform_interface.dart';

class UniLinksPlugin extends UniLinksPlatform {
  static void registerWith(Registrar registrar) {
    UniLinksPlatform.instance = UniLinksPlugin();
  }

  /// The Web URL is stored here on startup, as it's prone to changing
  /// throughout the app's lifetime.
  final _initialLink = window.location.href;

  @override
  Future<String?> getInitialLink() async => _initialLink;

  @override
  Stream<String?> get linkStream => throw UnsupportedError(
      'As the Web URL cannot be changed without restarting the application, link streams are unimplemented on this platform.');
}
