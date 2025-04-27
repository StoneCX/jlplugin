import 'package:flutter_test/flutter_test.dart';
import 'package:myjl_plugin/myjl_plugin.dart';
import 'package:myjl_plugin/myjl_plugin_platform_interface.dart';
import 'package:myjl_plugin/myjl_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMyjlPluginPlatform
    with MockPlatformInterfaceMixin
    implements MyjlPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MyjlPluginPlatform initialPlatform = MyjlPluginPlatform.instance;

  test('$MethodChannelMyjlPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMyjlPlugin>());
  });

  test('getPlatformVersion', () async {
    MyjlPlugin myjlPlugin = MyjlPlugin();
    MockMyjlPluginPlatform fakePlatform = MockMyjlPluginPlatform();
    MyjlPluginPlatform.instance = fakePlatform;

    expect(await myjlPlugin.getPlatformVersion(), '42');
  });
}
