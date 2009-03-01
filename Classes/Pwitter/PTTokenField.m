//
//  PTTokenField.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 28/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTTokenField.h"


@implementation PTTokenField

- (void)awakeFromNib {
	NSTextView *lField = (NSTextView*)[[self window] fieldEditor:TRUE forObject:self];
	[lField setInsertionPointColor:[NSColor whiteColor]];
}

@end
