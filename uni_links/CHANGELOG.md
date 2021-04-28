## [0.5.1] - 2021-04-28

* Add the `getLinksStream()` and `getUriLinksStream()` methods back (flagged as deprecated) since they were removed.

## [0.5.0+2] - 2021-04-28

* Update README to add steps to add associated-domains entitlement via Xcode. (Need a version change to publish to pub.dev)

## [0.5.0+1] - 2021-04-28

* Add `uni_links_web` to the list of platform definitions.
* Update example app and README to highlight handling of the initial link.

## [0.5.0] - 2021-04-28

**Breaking changes**  
  Due to the migration to null safety, some APIs have changed. These changes mainly involve functions changing into getters, and types becoming explicitly nullable.  

  The changes to the example package are a good example of how to upgrade to this version.

* Support null safety. (@hacker1024)
* Migrate to the federated plugin architecture, paving the way for Web support in the future. (@hacker1024)

## [0.4.0] - 2020-05-10

* Reduce iOS compiler warnings #42 (@ened)
* Fix UniLinks Plugin for Flutter 1.12.13 #55 (@markathomas)

## [0.2.1] - 2019-09-30

* Updated iOS example project project files.
* Added NS_NONNULL macro to iOS plugin header to reduce compiler warnings.

## [0.2.0] - 2019-03-10

**Breaking change**
  Migrate from the deprecated original Android Support Library to AndroidX. This shouldn't result in any functional changes, but it requires any Android apps using this plugin to [also migrate](https://developer.android.com/jetpack/androidx/migrate) if they're using the original support library.

* [Android] Update to AndroidX. (@bbedward)


## [0.1.4] - 2018-10-16

* [Android] Don't process links when launched in background. (@wkornewald)


## [0.1.3] - 2018-09-08

* No code changes.
* Added section in the README about Swift-enabled apps.
* Added section in the README about tooling for invoking links from the cli.


## [0.1.2] - 2018-07-30

* Fixed lost initialLink on iOS launch via Universal Link. (@wkornewald)


## [0.1.1] - 2018-05-31

* No code changes. Pushed to pub.dartlang.org with an untracked file that had to
  be manually removed.


## [0.1.0] - 2018-05-31

* Initial release.
