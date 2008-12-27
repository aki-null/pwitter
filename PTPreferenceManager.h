//
//  PTPreferenceManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PTPreferenceManager : NSObject {
	NSUserDefaults *prefData;
	NSString *_userName;
}

+ (PTPreferenceManager *)getInstance;
- (void)setupPrefs;
- (NSString *) getUserName;
- (void)setUserName:(NSString *)userName;
- (void)savePassword:(NSString *)password;
- (NSString *)getPassword;

@end
