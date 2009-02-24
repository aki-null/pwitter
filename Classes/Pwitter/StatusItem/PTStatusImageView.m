//
//  PTStatusImageView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusImageView.h"
#import "PTStatusBox.h"


@implementation PTStatusImageView

- (void)mouseDown:(NSEvent *)aEvent {
	// pass the event to the super class as usual
	[super mouseDown:aEvent];
	// send a message to the owner of the status view to select this entity
	[[self superview] mouseDown:aEvent];
	[(PTStatusEntityView *)[self superview] sendReply:self];
}

- (void)rightMouseDown:(NSEvent *)aEvent {
	[[self superview] mouseDown:aEvent];
	[(PTStatusEntityView *)[self superview] openContextMenu:aEvent];
}

@end
