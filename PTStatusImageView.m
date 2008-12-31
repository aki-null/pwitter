//
//  PTStatusImageView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusImageView.h"


@implementation PTStatusImageView

- (void)mouseDown:(NSEvent *)theEvent {
	// pass the event to the super class as usual
	[super mouseDown:theEvent];
	// send a message to the owner of the status view to select this entity
	[(PTStatusEntityView *)[self superview] forceSelect:YES];
}

@end
