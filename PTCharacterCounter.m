#import "PTCharacterCounter.h"

@implementation PTCharacterCounter

- (void)controlTextDidChange:(NSNotification *)aNotification {
	[self setIntValue:140 - [[postTextField stringValue] length]];
}

@end
