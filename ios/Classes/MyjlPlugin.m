#import "MyjlPlugin.h"
#import "BTManager.h"

@implementation MyjlPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"myjl_plugin"
                                  binaryMessenger:[registrar messenger]];
  MyjlPlugin *instance = [[MyjlPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS "
        stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"startScan" isEqualToString:call.method]) {
    [[BTManager sharedInstance] startScan];
    // result([@"iOS " stringByAppendingString:[[UIDevice currentDevice]
    // systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
