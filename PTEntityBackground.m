//
//  PTEntityBackground.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTEntityBackground.h"
#import "PTStatusEntityView.h"
#import "PTStatusBox.h"


@implementation PTEntityBackground

- (void)drawRect:(NSRect)aRect {
	[[self textColor] set];
	NSBezierPath *lPath = [NSBezierPath bezierPath];
	[lPath appendBezierPathWithRoundedRect:NSInsetRect([self bounds], 10.0, 2.0) 
								   xRadius:12.0 
								   yRadius:12.0];
	[lPath fill];
	// render the selection border
	if([(PTStatusEntityView *)[self superview] selected]) {
		[[NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1.0] set];
		[lPath setLineWidth:2.5];
		[lPath stroke];
	}
	[super drawRect:aRect];
}

- (void)mouseDown:(NSEvent *)aEvent {
	// pass the event to the super class as usual
	[super mouseDown:aEvent];
	// send a message to the owner of the status view to select this entity
	[(PTStatusEntityView *)[self superview] forceSelect:YES];
}

- (void)rightMouseDown:(NSEvent *)aEvent {
	[super rightMouseDown:aEvent];
	[(PTStatusEntityView *)[self superview] forceSelect:YES];
	[(PTStatusEntityView *)[self superview] openContextMenu:aEvent];
}

@end
