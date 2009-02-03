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
