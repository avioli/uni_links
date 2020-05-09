// Copyright 2018 Evo Stamatov. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _mChannel = MethodChannel('uni_links/messages');
const EventChannel _eChannel = EventChannel('uni_links/events');
Stream<String> _stream;

/// Returns a [Future], which completes to one of the following:
///
///   * the initially stored link (possibly null), on successful invocation;
///   * a [PlatformException], if the invocation failed in the platform plugin.
Future<String> getInitialLink() async {
  final initialLink = await _mChannel.invokeMethod<String>('getInitialLink');
  return initialLink;
}

/// A convenience method that returns the initially stored link
/// as a new [Uri] object.
///
/// If the link is not valid as a URI or URI reference,
/// a [FormatException] is thrown.
Future<Uri> getInitialUri() async {
  final link = await getInitialLink();
  if (link == null) return null;
  return Uri.parse(link);
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
Stream<String> getLinksStream() =>
    _stream ??= _eChannel.receiveBroadcastStream().cast<String>();

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
