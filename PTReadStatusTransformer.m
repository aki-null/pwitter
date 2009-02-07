//
//  PTReadStatusTransformer.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 6/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTReadStatusTransformer.h"


@implementation PTReadStatusTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)aValue {
	if ([aValue boolValue])
		return nil;
	else
		return [NSImage imageNamed:@"unread_orb"];
}

@end
