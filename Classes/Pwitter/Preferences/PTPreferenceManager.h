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

+ (PTPreferenceManager *)sharedInstance;
- (void)setupPreferences;
- (void)setUserName:(NSString *)aUserName password:(NSString *)aPassword;
- (NSString *)userName;
- (NSString *)password;
- (BOOL)alwaysOnTop;
- (BOOL)receiveFromNonFollowers;
- (void)setTimeInterval:(int)aInterval;
- (int)timeInterval;
- (void)setMessageInterval:(int)aInterval;
- (int)messageInterval;
- (BOOL)useMiniView;
- (BOOL)autoLogin;
- (BOOL)quickPost;
- (BOOL)quickRead;
- (BOOL)ignoreErrors;
- (BOOL)disableGrowl;
- (BOOL)disableMessageNotification;
- (BOOL)disableReplyNotification;
- (BOOL)disableStatusNotification;
- (BOOL)disableErrorNotification;
- (BOOL)disableSoundNotification;
- (void)setStatusUpdateBehavior:(int)aBehavior;
- (int)statusUpdateBehavior;
- (BOOL)swapMenuItemBehavior;
- (BOOL)useTwelveHour;
- (BOOL)usePOSTMethod;
- (BOOL)disableWindowShadow;
- (BOOL)hideWithQuickReadShortcut;
- (void)setHideDockIcon:(BOOL)aFlag;
- (BOOL)hideDockIcon;

@end
