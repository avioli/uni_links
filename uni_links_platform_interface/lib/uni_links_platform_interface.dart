import 'dart:async';

import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_uni_links.dart';

abstract class UniLinksPlatform extends PlatformInterface {
  UniLinksPlatform() : super(token: _token);

  static UniLinksPlatform _instance = MethodChannelUniLinks();

  static final Object _token = Object();

  static UniLinksPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UniLinksStorePlatform] when they register themselves.
  static set instance(UniLinksPlatform value) {
    if (!value.isMock) {
      try {
        value._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = value;
  }

  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements` which is forbidden for anything
  /// other than mocks (see class docs). This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  /// Returns a [Future], which completes to one of the following:
  ///
  ///   * the initially stored link (possibly null), on successful invocation;
  ///   * a [PlatformException], if the invocation failed in the platform plugin.
  Future<String> getInitialLink();

  /// A convenience method that returns the initially stored link
  /// as a new [Uri] object.
  ///
  /// If the link is not valid as a URI or URI reference,
  /// a [FormatException] is thrown.
  Future<Uri> getInitialUri() async {
    final link = await getInitialLink();
    return link == null ? null : Uri.parse(link);
  }

  /// Sets up a broadcast stream for receiving incoming link change events.
  ///
  /// Returns a broadcast [Stream] which emits events to listeners as follows:
  ///
  ///   * a decoded data ([String]) event (possibly null) for each successful
  ///   event received from the platform plugin;
  ///   * an error event containing a [PlatformException] for each error event
  ///   received from the platform plugin.
  ///
  /// Errors occurring during stream activation or deactivation are reported
  /// through the `FlutterError` facility. Stream activation happens only when
  /// stream listener count changes from 0 to 1. Stream deactivation happens
  /// only when stream listener count changes from 1 to 0.
  ///
  /// If the app was stared by a link intent or user activity the stream will
  /// not emit that initial one - query either the `getInitialLink` instead.
  Stream<String> getLinksStream();

  /// A convenience transformation of the stream to a `Stream<Uri>`.
  ///
  /// If the link is not valid as a URI or URI reference,
  /// a [FormatException] is thrown.
  ///
  /// Refer to `getLinksStream` about error/exception details.
  ///
  /// If the app was stared by a link intent or user activity the stream will
  /// not emit that initial uri - query either the `getInitialUri` instead.
  Stream<Uri> getUriLinksStream() {
    return getLinksStream().transform<Uri>(
      StreamTransformer<String, Uri>.fromHandlers(
        handleData: (String link, EventSink<Uri> sink) {
          if (link == null) {
            sink.add(null);
          } else {
            sink.add(Uri.parse(link));
          }
        },
      ),
    );
  }

  // This method makes sure that UniLinksStorePlatform isn't implemented with `implements`.
  //
  // See class doc for more details on why implementing this class is forbidden.
  //
  // This private method is called by the instance setter, which fails if the class is
  // implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}
}
