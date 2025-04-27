#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint myjl_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'myjl_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.vendored_frameworks = [
    'Frameworks/JL_AdvParse.framework',
    'Frameworks/JL_BLEKit.framework',
    'Frameworks/JL_HashPair.framework',
    'Frameworks/OTALib.framework',
  ] # 引用框架
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-ObjC' 
  }

  s.info_plist = {
    'NSBluetoothAlwaysUsageDescription' => 'This app uses Bluetooth to connect to devices.',
    'NSBluetoothPeripheralUsageDescription' => 'This app uses Bluetooth to connect to devices.',
  }

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'myjl_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
