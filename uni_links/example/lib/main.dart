import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum UniLinksType { string, uri }

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  String? _initialLink;
  Uri? _initialUri;
  String? _latestLink = 'Unknown';
  Uri? _latestUri;

  StreamSubscription? _sub;

  late final TabController _tabController;
  UniLinksType _type = UniLinksType.string;

  final List<String>? _cmds = getCmds();
  final TextStyle _cmdStyle = const TextStyle(
      fontFamily: 'Courier', fontSize: 12.0, fontWeight: FontWeight.w700);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2)
      ..addListener(_handleTabChange);
    initPlatformState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (_type == UniLinksType.string) {
      await initPlatformStateForStringUniLinks();
    } else {
      await initPlatformStateForUriUniLinks();
    }
  }

  /// An implementation using a [String] link
  Future<void> initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    if (!kIsWeb)
      _sub = linkStream.listen((String? link) {
        if (!mounted) return;
        setState(() {
          _latestLink = link ?? 'Unknown';
          _latestUri = null;
          try {
            if (link != null) _latestUri = Uri.parse(link);
          } on FormatException {}
        });
      }, onError: (Object err) {
        if (!mounted) return;
        setState(() {
          _latestLink = 'Failed to get latest link: $err.';
          _latestUri = null;
        });
      });

    // Attach a second listener to the stream
    if (!kIsWeb)
      linkStream.listen((String? link) {
        print('got link: $link');
      }, onError: (Object err) {
        print('got err: $err');
      });

    // Get the latest link
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _initialLink = await getInitialLink();
      print('initial link: $_initialLink');
      if (_initialLink != null) _initialUri = Uri.parse(_initialLink!);
    } on PlatformException {
      _initialLink = 'Failed to get initial link.';
      _initialUri = null;
    } on FormatException {
      _initialLink = 'Failed to parse the initial link as Uri.';
      _initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = _initialLink;
      _latestUri = _initialUri;
    });
  }

  /// An implementation using the [Uri] convenience helpers
  Future<void> initPlatformStateForUriUniLinks() async {
    // Attach a listener to the Uri links stream
    if (!kIsWeb)
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        setState(() {
          _latestUri = uri;
          _latestLink = uri?.toString() ?? 'Unknown';
        });
      }, onError: (Object err) {
        if (!mounted) return;
        setState(() {
          _latestUri = null;
          _latestLink = 'Failed to get latest link: $err.';
        });
      });

    // Attach a second listener to the stream
    if (!kIsWeb)
      uriLinkStream.listen((Uri? uri) {
        print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
      }, onError: (Object err) {
        print('got err: $err');
      });

    // Get the latest Uri
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _initialUri = await getInitialUri();
      print('initial uri: ${_initialUri?.path}'
          ' ${_initialUri?.queryParametersAll}');
      _initialLink = _initialUri?.toString();
    } on PlatformException {
      _initialUri = null;
      _initialLink = 'Failed to get initial uri.';
    } on FormatException {
      _initialUri = null;
      _initialLink = 'Bad parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestUri = _initialUri;
      _latestLink = _initialLink;
    });
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = _latestUri?.queryParametersAll.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'STRING LINK'),
            Tab(text: 'URI'),
          ],
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        children: [
          ListTile(
            title: const Text('Initial Link'),
            subtitle: Text('$_initialLink'),
          ),
          if (!kIsWeb)
            ListTile(
              title: const Text('Link'),
              subtitle: Text('$_latestLink'),
            ),
          ListTile(
            title: const Text('Uri Path'),
            subtitle: Text('${_latestUri?.path}'),
          ),
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text('Query params'),
            children: queryParams == null
                ? const [
                    ListTile(
                      dense: true,
                      title: const Text('null'),
                    ),
                  ]
                : [
                    for (final item in queryParams)
                      ListTile(
                        title: Text(item.key),
                        trailing: Text(
                          item.value.join(', '),
                        ),
                      ),
                  ],
          ),
          _cmdsCard(_cmds),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: const Text(
              'Force quit this example app',
              style: TextStyle(color: Colors.red),
            ),
          ),
          _cmdsCard(_cmds),
          const Divider(),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text(
                'Force quit this example app',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                if (kIsWeb) return;
                // WARNING: DO NOT USE this in production !!!
                //          Your app will (most probably) be rejected !!!
                if (Platform.isIOS) {
                  exit(0);
                } else {
                  SystemNavigator.pop();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _cmdsCard(List<String>? commands) {
    Widget platformCmds;

    if (commands == null) {
      platformCmds = const Center(child: Text('Unsupported platform'));
    } else {
      platformCmds = Column(
        children: [
          const [
            Text('To populate above fields open a terminal shell and run:\n'),
          ],
          intersperse(
              commands.map<Widget>((cmd) => InkWell(
                    onTap: () => _printAndCopy(cmd),
                    child: Text('\n$cmd\n', style: _cmdStyle),
                  )),
              const Text('or')),
          [
            Text(
              '(tap on any of the above commands to print it to'
              ' the console/logger and copy to the device clipboard.)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ]
        ].expand((el) => el).toList(),
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: platformCmds,
      ),
    );
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _type = UniLinksType.values[_tabController.index];
      });
      initPlatformState();
    }
  }

  Future<void> _printAndCopy(String cmd) async {
    print(cmd);

    await Clipboard.setData(ClipboardData(text: cmd));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to Clipboard')),
    );
  }
}

List<String>? getCmds() {
  late final String cmd;
  var cmdSuffix = '';

  if (kIsWeb) {
    cmd = 'Append something like the path in';
    cmdSuffix = ' to the Web app\'s URL';
  } else if (Platform.isIOS) {
    cmd = '/usr/bin/xcrun simctl openurl booted';
  } else if (Platform.isAndroid) {
    cmd = '\$ANDROID_HOME/platform-tools/adb shell \'am start'
        ' -a android.intent.action.VIEW'
        ' -c android.intent.category.BROWSABLE -d';
    cmdSuffix = "'";
  } else {
    return null;
  }

  // https://orchid-forgery.glitch.me/mobile/redirect/
  return [
    '$cmd "unilinks://host/path/subpath"$cmdSuffix',
    '$cmd "unilinks://example.com/path/portion/?uid=123&token=abc"$cmdSuffix',
    '$cmd "unilinks://example.com/?arr%5b%5d=123&arr%5b%5d=abc'
        '&addr=1%20Nowhere%20Rd&addr=Rand%20City%F0%9F%98%82"$cmdSuffix',
  ];
}

List<Widget> intersperse(Iterable<Widget> list, Widget item) {
  final initialValue = <Widget>[];
  return list.fold(initialValue, (all, el) {
    if (all.isNotEmpty) all.add(item);
    all.add(el);
    return all;
  });
}
