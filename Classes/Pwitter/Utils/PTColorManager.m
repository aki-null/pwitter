//
//  PTColorManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/03/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTColorManager.h"


@implementation PTColorManager

static PTColorManager *sharedSingleton;

+ (PTColorManager *)sharedSingleton
{
	@synchronized(self)
	{
		if (!sharedSingleton)
			[[PTColorManager alloc] init];
		return sharedSingleton;
	}
	return nil;
}

+(id)alloc
{
	@synchronized(self)
	{
		NSAssert(sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedSingleton = [super alloc];
		return sharedSingleton;
	}
	return nil;
}

- (NSColor *)tweetColor {
	return [NSColor colorWithCalibratedRed:0.20 green:0.20 blue:0.20 alpha:1.0];
}

- (NSColor *)replyColor {
	return [NSColor colorWithCalibratedRed:0.3 green:0.1 blue:0.1 alpha:1.0];
}

- (NSColor *)messageColor {
	return [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.3 alpha:1.0];
}

- (NSColor *)favoriteColor {
	return [NSColor colorWithCalibratedRed:0.4 green:0.2 blue:0.0 alpha:1.0];
}

- (NSColor *)errorColor {
	return [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1.0];
}

@end
