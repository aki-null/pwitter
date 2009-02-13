//
//  PTClickableIcon.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 13/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTClickableIcon.h"
#import "PTMainActionHandler.h"


@implementation PTClickableIcon

- (void)mouseDown:(NSEvent *)aEvent {
	[fMainActionHandler replyToSelected:self];
}

@end
