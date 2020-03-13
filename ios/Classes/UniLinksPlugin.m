#import "UniLinksPlugin.h"

static NSString *const kMessagesChannel = @"uni_links/messages";
static NSString *const kEventsChannel = @"uni_links/events";

@interface UniLinksPlugin () <FlutterStreamHandler>
@property(nonatomic, copy) NSString *initialLink;
@property(nonatomic, copy) NSString *latestLink;
@end

@implementation UniLinksPlugin {
  FlutterEventSink _eventSink;
}

static id _instance;

+ (UniLinksPlugin *)sharedInstance {
  if (_instance == nil) {
    _instance = [[UniLinksPlugin alloc] init];
  }
  return _instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  UniLinksPlugin *instance = [UniLinksPlugin sharedInstance];

  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kMessagesChannel
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];

  FlutterEventChannel *chargingChannel =
      [FlutterEventChannel eventChannelWithName:kEventsChannel
                                binaryMessenger:[registrar messenger]];
  [chargingChannel setStreamHandler:instance];

  [registrar addApplicationDelegate:instance];
}

- (void)setLatestLink:(NSString *)latestLink {
  static NSString *key = @"latestLink";

  [self willChangeValueForKey:key];
  _latestLink = [latestLink copy];
  [self didChangeValueForKey:key];

  if (_eventSink) _eventSink(_latestLink);
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSURL *url = (NSURL *)launchOptions[UIApplicationLaunchOptionsURLKey];
  self.initialLink = [url absoluteString];
  self.latestLink = self.initialLink;
    NSLog(@"didFinishLaunchingWithOptionsを呼んだ:%@", url);
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  self.latestLink = [url absoluteString];
    NSLog(@"openURLを読んだ self.latestLink: %@", self.latestLink);
  return YES;
}

- (void)scene:(UIScene *)scene openURLContexts:(nonnull NSSet<UIOpenURLContext *> *)URLContexts
API_AVAILABLE(ios(13.0)){
    NSURL *url = [[URLContexts allObjects] firstObject].URL;
 NSLog(@"scene:(UIScene *)scene openURLContextsを呼んだ url: %@", url);
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler {
  if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
    self.latestLink = [userActivity.webpageURL absoluteString];
    if (!_eventSink) {
      self.initialLink = self.latestLink;
    }
      NSLog(@"continueUserActivityを呼んだ initialLink: %@", self.initialLink);
    return YES;
  }
  return NO;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"handleMethodCall call.method:%@",call.method);
  if ([@"getInitialLink" isEqualToString:call.method]) {
    result(self.initialLink);
    // } else if ([@"getLatestLink" isEqualToString:call.method]) {
    //     result(self.latestLink);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)eventSink {
  _eventSink = eventSink;
    NSLog(@"onListenWithArguments");
  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
    NSLog(@"onCancelWithArguments");
  return nil;
}

@end
