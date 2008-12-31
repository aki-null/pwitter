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
	NSUserDefaults *prefData;
}

+ (PTPreferenceManager *)getInstance;
- (void)setupPreferences;
- (void)setUserName:(NSString *)aUserName password:(NSString *)aPassword;
- (NSString *)userName;
- (NSString *)password;
- (void)setAlwaysOnTop:(BOOL)aFlag;
- (BOOL)alwaysOnTop;
- (void)setTimeInterval:(int)aInterval;
- (int)timeInterval;
- (void)setAutoLogin:(BOOL)aFlag;
- (BOOL)autoLogin;

@end
