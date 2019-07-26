#import "UniLinksPlugin.h"

static NSString *const kMessagesChannel = @"uni_links/messages";
static NSString *const kEventsChannel = @"uni_links/events";

@interface UniLinksPlugin () <FlutterStreamHandler>
@property(nonatomic, copy) NSString *initialLink;
@property(nonatomic, copy) NSString *latestLink;
@end

@implementation UniLinksPlugin {
  FlutterEventSink _eventSink;
  API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(macos, watchos, tvos) NFCCallbacks* _nfcCallbacks;
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
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  self.latestLink = [url absoluteString];
  return YES;
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler {
  if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
    self.latestLink = [userActivity.webpageURL absoluteString];
    if (!_eventSink) {
      self.initialLink = self.latestLink;
    }
    return YES;
  }
  return NO;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"getInitialLink" isEqualToString:call.method]) {
    result(self.initialLink);
    // } else if ([@"getLatestLink" isEqualToString:call.method]) {
    //     result(self.latestLink);
  } else if ([@"startNFCSession" isEqualToString:call.method]) {
      if (@available(iOS 11, *)){
          NSLog(@"Starting nfc session");
          if(_nfcCallbacks == nil) {
              _nfcCallbacks = [[NFCCallbacks alloc] init];
              _nfcCallbacks.delegate = self;
              if([call.arguments isKindOfClass:[NSString class]]){
                  _nfcCallbacks.dialogMessage = call.arguments;
              }
          }
          [_nfcCallbacks start];
      }
  } else if ([@"stopNFCSession" isEqualToString:call.method]) {
      if (@available(iOS 11, *)){
          NSLog(@"Stopping nfc session");
          if(_nfcCallbacks != nil){
              [_nfcCallbacks stop];
          }
          _nfcCallbacks = nil;
      }
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (void) foundUri: (NSString* _Nullable) uri {
    if(uri != nil){
        NSLog(@"Found uri");
        self.latestLink = uri;
        if (!_eventSink) {
            self.initialLink = self.latestLink;
        }
    }
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)eventSink {
  _eventSink = eventSink;
  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

@end

@implementation NFCCallbacks

- (void) readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages {
    NSLog(@"readerSession, detected ndef messages.");
    if (@available(iOS 11, *)) {
        if(session == _nfcReaderSession){
            for(NFCNDEFMessage* message in messages) {
                if(message == nil){
                    continue;
                }
                for(NFCNDEFPayload* payload in message.records){
                    if(payload == nil){
                        continue;
                    }
                    if(payload.typeNameFormat == NFCTypeNameFormatAbsoluteURI){
                        if (payload.type == nil){
                            continue;
                        }
                        if([payload.type length] > 0){
                            NSString* dataStr = [NSString stringWithUTF8String:[payload.type bytes]];
                            if(dataStr != nil){
                                NSLog(@"URI ok, send to delegate.");
                                if ([self.delegate respondsToSelector:@selector(foundUri:)]) {
                                    [self.delegate foundUri:dataStr];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error {
    if(session == _nfcReaderSession){
        _nfcReaderSession = nil;
    }
    if(error != nil){
        NSLog(@"readerSession error: %@", error);
    }
}

- (void) start {
    if (@available(iOS 11, *)) {
        if(NFCNDEFReaderSession.readingAvailable){
            if (_nfcReaderSession == nil ){
                _nfcReaderSession = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
                _nfcReaderSession.alertMessage = _dialogMessage;
            }
            [_nfcReaderSession beginSession];
        } else {
            NSLog(@"NFCReaderSession is not available");
        }
    }
}

- (void) stop {
    if (_nfcReaderSession != nil) {
        [_nfcReaderSession invalidateSession];
        _nfcReaderSession = nil;
    }
}

@end
