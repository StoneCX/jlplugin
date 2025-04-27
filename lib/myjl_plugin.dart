
import 'myjl_plugin_platform_interface.dart';

class MyjlPlugin {
  Future<String?> getPlatformVersion() {
    return MyjlPluginPlatform.instance.getPlatformVersion();
  }
}
