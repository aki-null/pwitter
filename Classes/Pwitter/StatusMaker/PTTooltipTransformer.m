//
//  PTTooltipTransformer.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 21/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTTooltipTransformer.h"


@implementation PTTooltipTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)aValue {
	return [aValue string];
}

@end
