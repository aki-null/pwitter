//
//  PTTextField.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 28/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTTextField.h"


@implementation PTTextField

- (void)awakeFromNib {
	NSTextView *lField = (NSTextView*)[[self window] fieldEditor:TRUE forObject:self];
	[lField setInsertionPointColor:[NSColor whiteColor]];
}

@end
