//
//  PTCharacterCounter.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 31/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTCharacterCounter.h"
#import "PTPreferenceManager.h"


@implementation PTCharacterCounter

- (void)controlTextDidChange:(NSNotification *)aNotification {
	// update the character counter
	[self setIntValue:140 - [[fPostTextField stringValue] length]];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
	if (![[PTPreferenceManager sharedInstance] postWithModifier]) {
		return NO;
	}
	if (command == @selector(insertNewline:)) {
		return YES;
	} else if (command == @selector(insertLineBreak:)) {
		[[control target] performSelector:[control action]];
		return YES;
	} else {
		return NO;
	}
}

@end
