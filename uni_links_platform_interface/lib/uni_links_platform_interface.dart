import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:uni_links_platform_interface/src/method_channel_uni_links.dart';

/// The interface that implementations of uni_links must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as uni_links does not consider newly added methods to be breaking changes.
/// Extending this class ensures that the subclass will get the default
/// implementation, while platform implementations that merely implement the
/// interface will be broken by newly added [UniLinksPlatform] functions.
abstract class UniLinksPlatform extends PlatformInterface {
  /// A token used for verification of subclasses to ensure they extend this
  /// class instead of implementing it.
  static const _token = Object();

  /// Constructs a [UniLinksPlatform].
  UniLinksPlatform() : super(token: _token);

  static UniLinksPlatform _instance = MethodChannelUniLinks();

  /// The default instance of [UniLinksPlatform] to use.
  ///
  /// Defaults to [MethodChannelUniLinks].
  static UniLinksPlatform get instance => _instance;

  /// Platform-specific plugins should set this to an instance of their own
  /// platform-specific class that extends [UniLinksPlatform] when they register
  /// themselves.
  static set instance(UniLinksPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns a [Future], which completes to the initially stored link, which
  /// may be null.
  ///
  /// NOTE: base code found in [MethodChannelUniLinks.getInitialLink]
  Future<String?> getInitialLink() => throw UnimplementedError(
      'getInitialLink() has not been implemented on the current platform.');

  /// A broadcast stream for receiving incoming link change events.
  ///
  /// The [Stream] emits opened links as [String]s.
  ///
  /// NOTE: base code found in [MethodChannelUniLinks.linkStream]
  Stream<String?> get linkStream => throw UnimplementedError(
      'getLinksStream has not been implemented on the current platform.');
}
