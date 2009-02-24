//
//  PTStatusTextField.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusTextField.h"
#import "PTStatusBox.h"


@implementation PTStatusTextField

- (void)mouseDown:(NSEvent *)aEvent {
	if ([(PTStatusEntityView *)[self superview] selected]) {
		[super mouseDown:aEvent];
	} else {
		// send a message to the owner of the status view to select this entity
		[[self superview] mouseDown:aEvent];
	}
}

- (void)rightMouseDown:(NSEvent *)aEvent {
	[[self superview] mouseDown:aEvent];
	[(PTStatusEntityView *)[self superview] openContextMenu:aEvent];
}

- (NSSize)minSizeForContent { 
	NSRect lFrame = [self frame];
	NSRect lNewF = lFrame;
	NSTextView* lEditor = nil;
	if ((lEditor = (NSTextView*)[self currentEditor])) {
		lNewF = [[lEditor layoutManager] usedRectForTextContainer:[lEditor textContainer]];
		lNewF.size.height += lFrame.size.height-[[self cell] drawingRectForBounds:lFrame].size.height;
	} else {
		lNewF.size.height = HUGE_VALF;
		lNewF.size = [[self cell] cellSizeForBounds:lNewF];
	}
	lFrame.size.height = lNewF.size.height;
	return lFrame.size;
}


@end
