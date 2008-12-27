//
//  PTPreferenceManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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
	_userName = [prefData stringForKey:@"user_name"];
}

- (NSString *) getUserName {
	return _userName;
}

- (void)setUserName:(NSString *)userName {
	[prefData setObject:userName forKey:@"user_name"];
	_userName = userName;
}

- (void)savePassword:(NSString *)password {
	EMGenericKeychainItem *tempItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"Pwitter" withUsername:_userName];
	if (!tempItem) {
		[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"Pwitter" withUsername:_userName password:password];
	} else {
		[tempItem setPassword:password];
	}
}

- (NSString *)getPassword {
	EMGenericKeychainItem *tempItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"Pwitter" withUsername:_userName];
	if (!tempItem) {
		return nil;
	} else {
		return [tempItem password];
	}
}

@end
