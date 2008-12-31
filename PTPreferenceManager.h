//
//  PTPreferenceManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PTStatusBox.h>

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
- (void)savePassword:(NSString *)password;
- (NSString *)getPassword;
- (void)setAlwaysOnTop:(BOOL)flag;
- (BOOL)alwaysOnTop;
- (void)setTimeInterval:(int)interval;
- (int)timeInterval;

@end
