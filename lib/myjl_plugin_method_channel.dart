import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'myjl_plugin_platform_interface.dart';

/// An implementation of [MyjlPluginPlatform] that uses method channels.
class MethodChannelMyjlPlugin extends MyjlPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('myjl_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> startScan() async {
    await methodChannel.invokeMethod('startScan');
  }
}
