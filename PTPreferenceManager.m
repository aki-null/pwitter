//
//  PTPreferenceManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTPreferenceManager.h"
#import "EMKeychainProxy.h"


@implementation PTPreferenceManager

+ (PTPreferenceManager *)getInstance
{
	static PTPreferenceManager *instance;
	
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [[PTPreferenceManager alloc] init];
			[instance setupPreferences];
		}
		return instance;
	}
	return nil;
}

- (void)setupPreferences {
	fPrefData = [NSUserDefaults standardUserDefaults];
	if ([fPrefData integerForKey:@"time_interval"] == 0)
		[fPrefData setInteger:2 forKey:@"time_interval"];
	if ([fPrefData integerForKey:@"message_interval"] == 0)
		[fPrefData setInteger:3 forKey:@"message_interval"];
}

- (void)setUserName:(NSString *)aUserName password:(NSString *)aPassword {
	[fPrefData setObject:aUserName forKey:@"user_name"];
	EMGenericKeychainItem *tempItem = 
	[[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"Pwitter" 
													withUsername:aUserName];
	if (!tempItem) {
		[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"Pwitter" 
														   withUsername:aUserName 
															   password:aPassword];
	} else {
		[tempItem setPassword:aPassword];
	}
}

- (NSString *)userName {
	return [fPrefData stringForKey:@"user_name"];
}

- (NSString *)password {
	EMGenericKeychainItem *lTempItem = 
	[[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"Pwitter" 
													withUsername:[fPrefData stringForKey:@"user_name"]];
	if (!lTempItem) {
		return nil;
	} else {
		return [lTempItem password];
	}
}

- (void)setAlwaysOnTop:(BOOL)aFlag {
	[fPrefData setBool:aFlag forKey:@"always_on_top"];
}

- (BOOL)alwaysOnTop {
	return [fPrefData boolForKey:@"always_on_top"];
}

- (void)setReceiveFromNonFollowers:(BOOL)aFlag {
	[fPrefData setBool:aFlag forKey:@"receive_updates_from_non_followers"];
}

- (BOOL)receiveFromNonFollowers {
	return [fPrefData boolForKey:@"receive_updates_from_non_followers"];
}

- (void)setTimeInterval:(int)aInterval {
	[fPrefData setInteger:aInterval forKey:@"time_interval"];
}

- (int)timeInterval {
	return [fPrefData integerForKey:@"time_interval"];
}

- (void)setMessageInterval:(int)aInterval {
	[fPrefData setInteger:aInterval forKey:@"message_interval"];
}

- (int)messageInterval {
	return [fPrefData integerForKey:@"message_interval"];
}

- (void)setUseMiniView:(BOOL)aFlag {
	[fPrefData setBool:aFlag forKey:@"enable_mini_view"];
}

- (BOOL)useMiniView {
	return [fPrefData boolForKey:@"enable_mini_view"];
}

- (void)setAutoLogin:(BOOL)aFlag {
	[fPrefData setBool:aFlag forKey:@"auto_login"];
}

- (BOOL)autoLogin {
	return [fPrefData boolForKey:@"auto_login"];
}

- (void)setQuickPost:(BOOL)aFlag {
	[fPrefData setBool:aFlag forKey:@"use_quick_post"];
}

- (BOOL)quickPost {
	return [fPrefData boolForKey:@"use_quick_post"];
}

- (void)setIgnoreErrors:(BOOL)aFlag {
	[fPrefData setBool:aFlag forKey:@"ignore_errors"];
}

- (BOOL)ignoreErrors {
	return [fPrefData boolForKey:@"ignore_errors"];
}

@end
