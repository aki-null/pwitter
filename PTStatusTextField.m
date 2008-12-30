//
//  PTStatusTextField.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTStatusTextField.h"


@implementation PTStatusTextField

- (void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	[(PTStatusEntityView *)[self superview] forceSelect:YES];
}

@end
