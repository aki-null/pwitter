//
//  PTDateToStringTransformer.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTDateToStringTransformer.h"


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
	return [aValue descriptionWithCalendarFormat:@"%H:%M:%S" 
										timeZone:[NSTimeZone systemTimeZone] 
										  locale:nil];
}

@end
