//
//  PTReplyButton.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 18/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTReplyButton.h"
#import "PTStatusEntityView.h"


@implementation PTReplyButton

- (void)mouseDown:(NSEvent *)aEvent {
	[[self superview] mouseDown:aEvent];
	// send a message to the owner of the status view to select this entity
	[(PTStatusEntityView *)[self superview] sendReply:self];
}

@end
