//
//  PTContextButton.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 18/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTContextButton.h"
#import "PTStatusEntityView.h"


@implementation PTContextButton

- (void)mouseDown:(NSEvent *)aEvent {
	[[self superview] mouseDown:aEvent];
	// send a message to the owner of the status view to select this entity
	[(PTStatusEntityView *)[self superview] openContextMenu:aEvent];
}

@end
