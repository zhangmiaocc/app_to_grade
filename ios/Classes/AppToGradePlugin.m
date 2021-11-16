#import "AppToGradePlugin.h"
#import <StoreKit/StoreKit.h>

@interface AppToGradePlugin()
    
@property (nonatomic, assign) BOOL isAppStorePopup;

@end

@implementation AppToGradePlugin
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"app_to_grade"
            binaryMessenger:[registrar messenger]];
    AppToGradePlugin* instance = [[AppToGradePlugin alloc] init];
    instance.isAppStorePopup = NO;
  [registrar addMethodCallDelegate:instance channel:channel];
    // 监听window 改变
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(windowDidBecomeVisibleNotification:)
                                                 name:UIWindowDidBecomeVisibleNotification
                                               object:nil];
    
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
   if ([@"gradeAndFeedBack" isEqualToString:call.method]){
      NSString *AppleId = call.arguments[@"AppleId"];
      if (@available(iOS 10.3, *)){
          [self appGradeInSystemWayWithAppleId:AppleId];
      } else {
          [self jumpToAppStoreGradeWithAppleId:AppleId];
      }
      // 打分评价
  } else {
    result(FlutterMethodNotImplemented);
  }
}


/**
 * 只能评分，不能编写评论
 * 有次数限制，一年只能使用三次
 * 使用次数超限后，需要跳转appstore
 * 所以我们要在苹果不弹出的情况下跳转到app store 评论页
 */
- (void)appGradeInSystemWayWithAppleId:(NSString *)appleId {
    
    if (@available(iOS 10.3, *)){
        //Request StoreKit to ask the user for an app review. This may or may not show any UI.
        if([SKStoreReviewController respondsToSelector:@selector(requestReview)]) {// iOS 10.3 以上支持
            //防止键盘遮挡
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            
            /*
            当调用了requestReview，但是没有弹出评分弹弹框的处理方案
             方案一：https://stackoverflow.com/questions/42533520/skstorereviewcontroller-how-to-detect-that-user-has-turned-off-rate-this-app-rt
            
             方案二https://stackoverflow.com/questions/43745157/mechanism-to-detect-display-of-ios-10-3-app-rating-dialog
             经过测试，方案二是可以的。方案一有一定几率不对。
            
             */
            [SKStoreReviewController requestReview];
            
            // give the review controller some time to display the popup
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (self.isAppStorePopup)
                {
                    // assume review popup showed instead of some other system alert
                    // for example show "thank you"
                    self.isAppStorePopup = NO;
                }
                else
                {
                    [self jumpToAppStoreGradeWithAppleId:appleId];
                }
            });
        } else {
            [self jumpToAppStoreGradeWithAppleId:appleId];
        }
    }
    
}

// 跳转到App store 评分页面
- (void)jumpToAppStoreGradeWithAppleId:(NSString *)appleId {
    
    NSURL *appleGradeURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",appleId]];
    if ([[UIApplication sharedApplication] canOpenURL:appleGradeURL]) {
        if (@available(iOS 10.0, *)) {
            [UIApplication.sharedApplication openURL:appleGradeURL options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @(YES)} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [UIApplication.sharedApplication openURL:appleGradeURL];
        }
    }
    
}
#pragma mark - NSNotification
// 监听window 改变回调
- (void)windowDidBecomeVisibleNotification:(NSNotification *)notification {
    
    if([notification.object isKindOfClass:NSClassFromString(@"SKStoreReviewPresentationWindow")])
    {
        self.isAppStorePopup = YES;
    }
}


@end
