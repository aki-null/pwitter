//
//  PTSelectedUserNameTextField.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 2/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTSelectedUserNameTextField.h"
#import "PTMain.h"


@implementation PTSelectedUserNameTextField

- (void)mouseDown:(NSEvent *)aEvent {
	// pass the event to the super class as usual
	[super mouseDown:aEvent];
	[fMainController openTwitterWeb];
}

@end
