//
//  PTStatusEntityView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTStatusEntityView.h"

@implementation PTStatusEntityView

- (id)copyWithZone:(NSZone *)zone {
	PTStatusEntityView *theCopy = [[PTStatusEntityView allocWithZone:zone] initWithFrame:[self frame]];
	[theCopy setDelegate:[self delegate]];
	[theCopy setSelected:[self selected]];  
	return theCopy;
}

- (void)setSelected:(BOOL)flag {
	_isSelected = flag;
}

- (id)delegate {
	return _theDelegate;
}

- (void)setDelegate:(id)theDelegate {
	_theDelegate = theDelegate;
}

- (BOOL)selected {
	return _isSelected;
}

- (void)drawRect:(NSRect)rect {
	[[NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1.0] set];
	NSBezierPath *thePath = [NSBezierPath bezierPath];
	[thePath appendBezierPathWithRoundedRect:NSInsetRect([self bounds], 3.0, 2.0) xRadius:12.0 yRadius:12.0];
	[thePath fill];
	if([self selected]) {
		[[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0] set];
		[thePath setLineWidth:3.0];
		[thePath stroke];
	}
	[super drawRect:rect];
}

- (NSView *)hitTest:(NSPoint)aPoint {
	// don't allow any mouse clicks for subviews in this view
	if(NSPointInRect(aPoint,[self convertRect:[self bounds] toView:[self superview]])) {
		return self;
	} else {
		return nil;
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];

	// check for click count above one
	if([theEvent clickCount] > 1) {
		if([[self delegate] respondsToSelector:@selector(doubleClick:)]) {
			[[self delegate] doubleClick:self];
		}
	}
}

@end
