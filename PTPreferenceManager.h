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
	NSString *_userName;
	BOOL alwaysOnTop;
	int timeInterval;
}

+ (PTPreferenceManager *)getInstance;
- (void)setupPrefs;
- (NSString *) getUserName;
- (void)setUserName:(NSString *)userName;
- (void)savePassword:(NSString *)aPassword;
- (NSString *)getPassword;
- (void)setAlwaysOnTop:(BOOL)aFlag;
- (BOOL)alwaysOnTop;
- (void)setTimeInterval:(int)aInterval;
- (int)timeInterval;

@end
