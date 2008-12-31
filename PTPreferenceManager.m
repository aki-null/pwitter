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
			[instance setupPrefs];
		}
		return instance;
	}
	return nil;
}

- (void)setupPrefs {
	prefData = [NSUserDefaults standardUserDefaults];
	if ([prefData integerForKey:@"time_interval"] == 0)
		[prefData setInteger:2 forKey:@"time_interval"];;
}

- (NSString *) getUserName {
	return [prefData stringForKey:@"user_name"];
}

- (void)setUserName:(NSString *)userName {
	[prefData setObject:userName forKey:@"user_name"];
}

- (void)savePassword:(NSString *)aPassword {
	EMGenericKeychainItem *tempItem = 
		[[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"Pwitter" 
														withUsername:[prefData stringForKey:@"user_name"]];
	if (!tempItem) {
		[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"Pwitter" 
														   withUsername:[prefData stringForKey:@"user_name"] 
															   password:aPassword];
	} else {
		[tempItem setPassword:aPassword];
	}
}

- (NSString *)getPassword {
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

@end
