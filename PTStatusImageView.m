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
	[super mouseDown:theEvent];
	[(PTStatusEntityView *)[self superview] forceSelect:YES];
}

@end
