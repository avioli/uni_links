# Uni Links

[![Travis' Continuous Integration build status](https://api.travis-ci.org/avioli/uni_links.svg?branch=master)](https://travis-ci.org/avioli/uni_links)

A Flutter plugin project to help with App/Deep Links (Android) and
Universal Links and Custom URL schemes (iOS).

These links are simply web-browser-like-links that activate your app and may
contain information that you can use to load specific section of the app or
continue certain user activity from a website (or another app).

App Links and Universal Links are regular https links, thus if the app is not
installed (or setup correctly) they'll load in the browser, allowing you to
present a web-page for further action, eg. install the app.

Make sure you read both the Installation and the Usage guides, thoroughly,
especiallly for App/Universal Links (the https scheme).


## Installation

To use the plugin, add `uni_links` as a
[dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


### Permission

Android and iOS require to declare links' permission in a configuration file.

Feel free to examine tha example app in the example directory for
Deep Links (Android) and Custom URL schemes (iOS).

The following steps are not Flutter specific, but platform specific. You might
be able to find more in-depth guides elsewhere online, by searching about App
Links or Deep Links on Android; Universal Links or Custom URL schemas on iOS.

#### For Android

Uni Links supports two types of Android links: "App Links" and "Deep Links".

  * App Links only work with `https` scheme and require a specified host, plus
  a hosted file - `assetlinks.json`. Check the Guide links below.
  * Deep Links can have any custom scheme and do not require a host, nor a
  hosted file. The downside is that any app can claim a scheme + host combo, so
  make sure yours are as unique as possible, eg. `HST0000001://host.com`.

You need to declare at least one of the two intent filters in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <!-- ... other tags -->
  <application ...>
    <activity ...>
      <!-- ... other tags -->

      <!-- Deep Links -->
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- Accepts URIs that begin with YOUR_SCHEME://YOUR_HOST -->
        <data
          android:scheme="[YOUR_SCHEME]"
          android:host="[YOUR_HOST]" />
      </intent-filter>

      <!-- App Links -->
      <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- Accepts URIs that begin with https://YOUR_HOST -->
        <data
          android:scheme="https"
          android:host="[YOUR_HOST]" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

The `android:host` attribute is optional for Deep Links.

To further the specificity you can add an `android:pathPrefix` attribute:

```xml
<!-- Accepts URIs that begin with YOUR_SCHEME://YOUR_HOST/NAME/NAME... -->
<!-- Accepts URIs that begin with       https://YOUR_HOST/NAME/NAME... -->
<!-- note that the leading "/" is required for pathPrefix -->
<data
  android:scheme="[YOUR_SCHEME_OR_HTTPS]"
  android:host="[YOUR_HOST]"
  android:pathPrefix="/[NAME][/NAME...]" />
```

For more info read
[The Ultimate Guide](https://simonmarquis.github.io/Android-App-Linking/).
Pay close attention to the
[App Links](https://simonmarquis.github.io/Android-App-Linking/#app-links)
section in the Guide regarding the required `/.well-known/assetlinks.json`
file.

The Android developer docs are also a great source of information for both
[Deep Links and App Links](https://developer.android.com/training/app-links/deep-linking).

#### For iOS

There are two kinds of links in iOS: "Universal Links" and "Custom URL schemes".

  * Universal Links only work with `https` scheme and require a specified host,
  entitlements and a hosted file - `apple-app-site-association`. Check the Guide
  links below.
  * Custom URL schemes can have... any custom scheme and there is no host
  specificity, nor entitlements or a hosted file. The downside is that any app
  can claim any scheme, so make sure yours is as unique as possible,
  eg. `hst0000001` or `myIncrediblyAwesomeScheme`.

You need to declare at least one of the two.

--

For **Universal Links** you need to add or create a
`com.apple.developer.associated-domains` entitlement - either through Xcode or
by editing (or creating and adding to Xcode) `ios/Runner/Runner.entitlements`
file.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- ... other keys -->
  <key>com.apple.developer.associated-domains</key>
  <array>
    <string>applinks:[YOUR_HOST]</string>
  </array>
  <!-- ... other keys -->
</dict>
</plist>
```

This allows for your app to be started from `https://YOUR_HOST` links.

For more information, read Apple's guide for
[Universal Links](https://developer.apple.com/library/content/documentation/General/Conceptual/AppSearch/UniversalLinks.html).

--

For **Custom URL schemes** you need to declare the scheme in
`ios/Runner/Info.plist` (or through Xcode's Target Info editor,
under URL Types):

```xml
<?xml ...>
<!-- ... other tags -->
<plist>
<dict>
  <!-- ... other tags -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLName</key>
      <string>[ANY_URL_NAME]</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>[YOUR_SCHEME]</string>
      </array>
    </dict>
  </array>
  <!-- ... other tags -->
</dict>
</plist>
```

This allows for your app to be started from `YOUR_SCHEME://ANYTHING` links.

For a little more information, read Apple's guide for
[Inter-App Communication](https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html).

I **strongly** recommend watching the [Apple WWDC 2015, session 509 - Seamless Linking to Your App](https://developer.apple.com/videos/play/wwdc2015/509/) to understand how the Universal Links work (and are setup).


## Usage

There are two ways your app will recieve a link - from cold start and brought
from the background. More on these after the example usage in
[More about app start from a link](#more-about-app-start-from-a-link).

### Initial Link (String)

Returns the link that the app was started with, if any.

```dart
import 'dart:async';
import 'dart:io';

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

// ...

  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

// ...
```


### Initial Link (Uri)

Same as the `getInitialLink`, but converted to a `Uri`.

```dart
    // Uri parsing may fail, so we use a try/catch FormatException.
    try {
      Uri initialUri = await getInitialUri();
      // Use the uri and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on FormatException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
    // ... other exception handling like PlatformException
```

One can achieve the same by using `Uri.parse(initialLink)`, which is what this
convenience method does.


### On change event (String)

Usually you would check the `getInitialLink` and also listen for changes.

```dart
import 'dart:async';
import 'dart:io';

import 'package:uni_links/uni_links.dart';

// ...

  StreamSubscription _sub;

  Future<Null> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) {
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

// ...
```


### On change event (Uri)

Same as the `stream`, but transformed to emit `Uri` objects.

Usually you would check the `getInitialUri` and also listen for changes.

```dart
import 'dart:async';
import 'dart:io';

import 'package:uni_links/uni_links.dart';

// ...

  StreamSubscription _sub;

  Future<Null> initUniLinks() async {
    // ... check initialUri

    // Attach a listener to the stream
    _sub = getUriLinksStream().listen((Uri uri) {
      // Use the uri and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

// ...
```

### More about app start from a link

If the app was terminated (or rather not running in the background) and the OS
must start it anew - that's a cold start. In that case, `getInitialLink` will
have the link that started your app and the Stream won't produce a link (at
that point in time).

Alternatively - if the app was running in the background and the OS must bring
it to the foreground the Stream will be the one to produce the link, while
`getInitialLink` will be either `null`, or the initial link, with which the
app was started.

Because of these two situations - you should always add a check for the
initial link (or URI) and also subscribe for a Stream of links (or URIs).


## Tools for invoking links

If you register a schema, say `unilink`, you could use these cli tools:

### Android

You could do below tasks within [Android Studio](https://developer.android.com/studio/write/app-link-indexing#testindent).

Assuming you've installed Android Studio (with the SDK platform tools):

```sh
adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "unilinks://host/path/subpath"'
adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "unilinks://example.com/path/portion/?uid=123&token=abc"'
adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "unilinks://example.com/?arr%5b%5d=123&arr%5b%5d=abc&addr=1%20Nowhere%20Rd&addr=Rand%20City%F0%9F%98%82"'
```

If you don't have [`adb`](https://developer.android.com/studio/command-line/adb)
in your path, but have `$ANDROID_HOME` env variable then use
`"$ANDROID_HOME"/platform-tools/adb ...`.

Note: Alternatively you could simply enter an `adb shell` and run the
[`am`](https://developer.android.com/studio/command-line/adb#am) commands in it.

Note: I use single quotes, because what follows the `shell` command is what will
run in the emulator (or device) and shell metacharacters, such as question marks
(`?`) and ampersands (`&`), usually mean something different to your own shell.

`adb shell` communicates with the only available device (or emulator), so if
you've got multiple devices you have to specify which one you want to run the
shell in via:

  * The _only_ USB connected device - `adb -d shell '...'`
  * The _only_ emulated device - `adb -e shell '...'`

You could use `adb devices` to list currently available devices (similarly
`flutter devices` does the same job).

### iOS

Assuming you've got Xcode already installed:

```sh
/usr/bin/xcrun simctl openurl booted "unilinks://host/path/subpath"
/usr/bin/xcrun simctl openurl booted "unilinks://example.com/path/portion/?uid=123&token=abc"
/usr/bin/xcrun simctl openurl booted "unilinks://example.com/?arr%5b%5d=123&arr%5b%5d=abc&addr=1%20Nowhere%20Rd&addr=Rand%20City%F0%9F%98%82"
```

If you've got `xcrun` (or `simctl`) in your path, you could invoke it directly.

The flag `booted` assumes an open simulator (you can start it via
`open -a Simulator`) with a booted device. You could target specific device by
specifying its UUID (found via `xcrun simctl list` or `flutter devices`),
replacing the `booted` flag.

### App Links or Universal Links

These types of links use `https` for schema, thus you can use above examples by
replacing `unilinks` with `https`.


## Contributing

For help on editing plugin code, view the
[documentation](https://flutter.io/platform-plugins/#edit-code).


## License

BSD 2-clause
