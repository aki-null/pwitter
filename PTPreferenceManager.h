//
//  PTPreferenceManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTStatusBox.h"


@interface PTPreferenceManager : NSObject {
	NSUserDefaults *fPrefData;
}

+ (PTPreferenceManager *)getInstance;
- (void)setupPreferences;
- (void)setUserName:(NSString *)aUserName password:(NSString *)aPassword;
- (NSString *)userName;
- (NSString *)password;
- (void)setAlwaysOnTop:(BOOL)aFlag;
- (BOOL)alwaysOnTop;
- (void)setReceiveFromNonFollowers:(BOOL)aFlag;
- (BOOL)receiveFromNonFollowers;
- (void)setTimeInterval:(int)aInterval;
- (int)timeInterval;
- (void)setMessageInterval:(int)aInterval;
- (int)messageInterval;
- (void)setUseMiniView:(BOOL)aFlag;
- (BOOL)useMiniView;
- (void)setAutoLogin:(BOOL)aFlag;
- (BOOL)autoLogin;
- (void)setQuickPost:(BOOL)aFlag;
- (BOOL)quickPost;
- (void)setIgnoreErrors:(BOOL)aFlag;
- (BOOL)ignoreErrors;
- (void)setDisableGrowl:(BOOL)aFlag;
- (BOOL)disableGrowl;
- (void)setDisableMessageNotification:(BOOL)aFlag;
- (BOOL)disableMessageNotification;
- (void)setDisableReplyNotification:(BOOL)aFlag;
- (BOOL)disableReplyNotification;
- (void)setDisableStatusNotification:(BOOL)aFlag;
- (BOOL)disableStatusNotification;
- (void)setDisableErrorNotification:(BOOL)aFlag;
- (BOOL)disableErrorNotification;
- (void)setDisableSoundNotification:(BOOL)aFlag;
- (BOOL)disableSoundNotification;
- (void)setStatusUpdateBehavior:(int)aBehavior;
- (int)statusUpdateBehavior;
- (void)setSwapMenuItemBehavior:(BOOL)aFlag;
- (BOOL)swapMenuItemBehavior;
- (void)setUseTwelveHour:(BOOL)aFlag;
- (BOOL)useTwelveHour;
- (void)setHideDockIcon:(BOOL)aFlag;
- (BOOL)hideDockIcon;

@end
