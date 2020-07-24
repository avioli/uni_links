import 'dart:async';

import 'uni_links_platform_interface.dart';

/// Stores links in memory.
/// Useful in tests.
class InMemoryUniLinks extends UniLinksPlatform {
  InMemoryUniLinks({StreamController streamController})
      : this.withData(
            Future.value(), streamController ?? StreamController<String>());

  InMemoryUniLinks.withData(this.initialLink, this.controller);

  Future<String> initialLink;
  final StreamController<String> controller;

  @override
  Future<String> getInitialLink() => initialLink;

  @override
  Stream<String> getLinksStream() {
    return controller.stream;
  }

  void addLinkToStream(String link) {
    controller.add(link);
  }
}
