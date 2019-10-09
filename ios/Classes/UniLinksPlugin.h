#import <Flutter/Flutter.h>
#import <CoreNFC/CoreNFC.h>

@protocol UriDelegate <NSObject>
- (void) foundUri:(NSString* _Nullable) uri;
@end

@interface UniLinksPlugin : NSObject <FlutterPlugin, UriDelegate>
+ (_Nullable instancetype)sharedInstance;
- (BOOL)application:(UIApplication * _Nullable)application
    continueUserActivity:(NSUserActivity * _Nullable)userActivity
      restorationHandler:(void (^_Nullable)(NSArray *_Nullable))restorationHandler;
@end

API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(macos, watchos, tvos)
@interface NFCCallbacks : NSObject <NFCNDEFReaderSessionDelegate>
@property(nonatomic, weak) _Nullable id <UriDelegate> delegate;
@property(nonatomic, copy) NSString* _Nullable dialogMessage;
@property(nonatomic, strong) NFCNDEFReaderSession * _Nullable nfcReaderSession;
- (void) start;
- (void) stop;
@end
