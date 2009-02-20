//
//  PTMessageButton.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 18/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTMessageButton.h"
#import "PTStatusEntityView.h"


@implementation PTMessageButton

- (void)mouseDown:(NSEvent *)aEvent {
	[(PTStatusEntityView *)[self superview] forceSelect:YES];
	// send a message to the owner of the status view to select this entity
	[(PTStatusEntityView *)[self superview] sendMessage:self];
}

@end
