import 'dart:async';

import 'package:flutter/services.dart';

import 'uni_links_platform_interface.dart';

class MethodChannelUniLinks extends UniLinksPlatform {
  final _mChannel = MethodChannel('uni_links/messages');
  final _eChannel = EventChannel('uni_links/events');
  Stream<String> _stream;

  @override
  Future<String> getInitialLink() {
    return _mChannel.invokeMethod<String>('getInitialLink');
  }

  @override
  Stream<String> getLinksStream() {
    return _stream ??= _eChannel.receiveBroadcastStream().cast<String>();
  }
}
