import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_links/uni_links.dart';
import 'package:uni_links_platform_interface/in_memory_uni_links.dart';
import 'package:uni_links_platform_interface/uni_links_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const mChannel = MethodChannel('uni_links/messages');
  const eChannel = MethodChannel('uni_links/events');
  final log = <MethodCall>[];
  mChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
  });

  eChannel.setMockMethodCallHandler((MethodCall methodCall) async {});

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

  group('Links with stream', () {
    final events = <String>[];
    StreamSubscription<String> _subscription;
    StreamController<String> _links;

    setUp(() {
      _links = StreamController<String>(sync: true);
      UniLinksPlatform.instance = InMemoryUniLinks(streamController: _links);

      events.clear();
      _subscription = getLinksStream().listen((event) {
        events.add(event);
      });
    });

    tearDown(() {
      _subscription?.cancel();
      _subscription = null;
    });

    test('Stream receives single link', () async {
      const testLink = 'some-test-url';
      _links.add(testLink);
      expect(events, [testLink]);
    });

    test('Stream receives all links', () async {
      const links = ['lnk1', 'lnk2', 'lnk3'];
      for (final link in links) {
        _links.add(link);
      }

      expect(events, links);
    });
  });
}
