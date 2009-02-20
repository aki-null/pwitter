//
//  PTDateToStringTransformer.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTDateToStringTransformer.h"
#import "PTPreferenceManager.h"


@implementation PTDateToStringTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)aValue {
	if (![[PTPreferenceManager sharedInstance] useTwelveHour]) {
		return [aValue descriptionWithCalendarFormat:@"%H:%M:%S" 
											timeZone:[NSTimeZone systemTimeZone] 
											  locale:nil];
	} else {
		return [aValue descriptionWithCalendarFormat:@"%I:%M %p" 
											timeZone:[NSTimeZone systemTimeZone] 
											  locale:nil];
	}
}

@end
