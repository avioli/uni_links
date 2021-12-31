import 'dart:async';

import 'package:uni_links_platform_interface/uni_links_platform_interface.dart';

/// Returns a [Future], which completes to the initially stored link, which
/// may be null.
Future<String?> getInitialLink() => UniLinksPlatform.instance.getInitialLink();

/// A convenience method that returns the initially stored link
/// as a new [Uri] object.
///
/// If the link is not valid as a URI or URI reference,
/// a [FormatException] is thrown.
Future<Uri?> getInitialUri() async {
  final link = await getInitialLink();
  if (link == null) return null;
  return Uri.parse(link);
}

/// A broadcast stream for receiving incoming link change events.
///
/// The [Stream] emits opened links as [String]s.
Stream<String?> get linkStream => UniLinksPlatform.instance.linkStream;

/// A convenience transformation of the [linkStream] to a `Stream<Uri>`.
///
/// If the link is not valid as a URI or URI reference,
/// a [FormatException] is thrown.
///
/// If the app was stared by a link intent or user activity the stream will
/// not emit that initial uri - query either the `getInitialUri` instead.
late final uriLinkStream = linkStream.transform<Uri?>(
  StreamTransformer<String?, Uri?>.fromHandlers(
    handleData: (String? link, EventSink<Uri?> sink) {
      if (link == null) {
        sink.add(null);
      } else {
        sink.add(Uri.parse(link));
      }
    },
  ),
);

/// A broadcast stream for receiving incoming link change events.
///
/// The [Stream] emits opened links as [String]s.
@Deprecated('Use [linkStream]')
Stream<String?> getLinksStream() => linkStream;

/// A convenience transformation of the [linkStream] to a `Stream<Uri>`.
///
/// If the link is not valid as a URI or URI reference,
/// a [FormatException] is thrown.
///
/// If the app was stared by a link intent or user activity the stream will
/// not emit that initial uri - query either the `getInitialUri` instead.
@Deprecated('Use [uriLinkStream]')
Stream<Uri?> getUriLinksStream() => uriLinkStream;
