// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const mChannel = MethodChannel('uni_links/messages');
  final log = <MethodCall>[];
  mChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
  });

  tearDown(() {
    log.clear();
  });

  test('getInitialLink', () async {
    await getInitialLink();
    expect(
      log,
      <Matcher>[isMethodCall('getInitialLink', arguments: null)],
    );
  });

  test('getInitialUri', () async {
    await getInitialUri();
    expect(
      log,
      <Matcher>[isMethodCall('getInitialLink', arguments: null)],
    );
  });

  test('getLinksStream', () async {
    final stream = getLinksStream();
    expect(stream, isInstanceOf<Stream<String>>());
  });

  test('getUriLinksStream', () async {
    final stream = getUriLinksStream();
    expect(stream, isInstanceOf<Stream<Uri>>());
  });
}
