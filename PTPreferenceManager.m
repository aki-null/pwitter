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
	prefData = [NSUserDefaults standardUserDefaults];
	if ([prefData integerForKey:@"time_interval"] == 0)
		[prefData setInteger:2 forKey:@"time_interval"];;
}

- (NSString *)userName {
	return [prefData stringForKey:@"user_name"];
}

- (void)setUserName:(NSString *)aUserName password:(NSString *)aPassword {
	[prefData setObject:aUserName forKey:@"user_name"];
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

- (NSString *)password {
	EMGenericKeychainItem *lTempItem = 
		[[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"Pwitter" 
														withUsername:[prefData stringForKey:@"user_name"]];
	if (!lTempItem) {
		return nil;
	} else {
		return [lTempItem password];
	}
}

- (void)setAlwaysOnTop:(BOOL)aFlag {
	[prefData setBool:aFlag forKey:@"always_on_top"];
}

- (BOOL)alwaysOnTop {
	return [prefData boolForKey:@"always_on_top"];
}

- (void)setTimeInterval:(int)aInterval {
	[prefData setInteger:aInterval forKey:@"time_interval"];
}

- (int)timeInterval {
	return [prefData integerForKey:@"time_interval"];
}

- (void)setAutoLogin:(BOOL)aFlag {
	[prefData setBool:aFlag forKey:@"auto_login"];
}

- (BOOL)autoLogin {
	return [prefData boolForKey:@"auto_login"];
}

@end
