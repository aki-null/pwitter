//
//  PTCharacterCounter.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 31/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTCharacterCounter.h"


@implementation PTCharacterCounter

- (void)controlTextDidChange:(NSNotification *)aNotification {
	// update the character counter
	[self setIntValue:140 - [[fPostTextField stringValue] length]];
}

@end
