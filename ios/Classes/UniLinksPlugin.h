#import <Flutter/Flutter.h>

@interface UniLinksPlugin : NSObject<FlutterPlugin>
+ (instancetype)sharedInstance;
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler;
@end
