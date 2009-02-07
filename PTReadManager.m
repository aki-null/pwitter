//
//  PTReadManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 7/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTReadManager.h"


@implementation PTReadManager

+ (PTReadManager *)getInstance
{
	static PTReadManager *instance;
	
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [[PTReadManager alloc] init];
		}
		return instance;
	}
	return nil;
}

- (void)setUnreadDict:(NSDictionary *)aDict {
	if (fUnreads) [fUnreads release];
	if (aDict)
		fUnreads = [aDict copy];
	else
		aDict = [[NSDictionary alloc] init];
}

- (BOOL)isUpdateRead:(int)aId {
	NSNumber *lRead = [fUnreads objectForKey:[NSNumber numberWithInt:aId]];
	if (!lRead)
		return NO;
	else
		return [lRead boolValue];
}

@end
