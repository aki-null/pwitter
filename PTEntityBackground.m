//
//  PTEntityBackground.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTEntityBackground.h"
#import "PTStatusEntityView.h"


@implementation PTEntityBackground

- (void)drawRect:(NSRect)rect {
	[[self textColor] set];
	NSBezierPath *thePath = [NSBezierPath bezierPath];
	[thePath appendBezierPathWithRoundedRect:NSInsetRect([self bounds], 10.0, 2.0) xRadius:12.0 yRadius:12.0];
	[thePath fill];
	if([(PTStatusEntityView *)[self superview] selected]) {
		[[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0] set];
		[thePath setLineWidth:3.0];
		[thePath stroke];
	}
	[super drawRect:rect];
}

@end
