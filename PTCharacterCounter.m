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
	[self setIntValue:140 - [[postTextField stringValue] length]];
}

@end
