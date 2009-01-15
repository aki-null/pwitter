//
//  PTQuickPostPanel.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 13/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTQuickPostPanel.h"
#import "PTMain.h"


@implementation PTQuickPostPanel
- (IBAction)cancelPost:(id)sender {
	[self close];
}

- (IBAction)post:(id)sender {
	[fMainController makePost:[fStatusUpdateField stringValue]];
}

- (void)orderFront:(id)sender {
	[self setAlphaValue:0.0];
	[super orderFront:sender];
	[self makeFirstResponder:fStatusUpdateField];
	[[self animator] setAlphaValue:1.0];
}

@end
