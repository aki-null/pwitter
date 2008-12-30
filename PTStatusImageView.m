//
//  PTStatusImageView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTStatusImageView.h"


@implementation PTStatusImageView

- (void)mouseDown:(NSEvent *)theEvent {
	[[self superview] mouseDown:theEvent];
	[super performClick:self];
}

@end
