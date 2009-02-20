//
//  PTPostField.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 7/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTPostField.h"
#import "PTMain.h"


@implementation PTPostField

- (void) awakeFromNib {
	[(NSTextView*)[[self window] fieldEditor:TRUE forObject:self] setInsertionPointColor:[NSColor whiteColor]];
	[(NSTextView*)[[self window] fieldEditor:TRUE forObject:self] toggleContinuousSpellChecking:self];
	fEditing = NO;
}

- (void)drawRect:(NSRect)aRect {
	[super drawRect:aRect];
	NSBezierPath *lPath = [NSBezierPath bezierPath];
	[lPath appendBezierPathWithRoundedRect:[self bounds] 
								   xRadius:4.0 
								   yRadius:4.0];
	[[NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:0.8] set];
	[lPath setLineWidth:2];
	[lPath stroke];
}


@end
