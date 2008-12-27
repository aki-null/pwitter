//
//  PTLevelIndicator.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 27/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTLevelIndicator.h"


@implementation PTLevelIndicator

- (void)controlTextDidChange:(NSNotification *)aNotification {
	[self setIntValue:[[statusTextField stringValue] length] / 14];
}

@end
