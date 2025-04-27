import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'myjl_plugin_method_channel.dart';

abstract class MyjlPluginPlatform extends PlatformInterface {
  /// Constructs a MyjlPluginPlatform.
  MyjlPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MyjlPluginPlatform _instance = MethodChannelMyjlPlugin();

  /// The default instance of [MyjlPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelMyjlPlugin].
  static MyjlPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MyjlPluginPlatform] when
  /// they register themselves.
  static set instance(MyjlPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
