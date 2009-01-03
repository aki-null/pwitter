//
//  PTMainWindowDelegate.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 2/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTMainWindowDelegate.h"
#import "PTMain.h"


@implementation PTMainWindowDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[fMainController startAuthentication];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)aApplication 
					hasVisibleWindows:(BOOL)aFlag
{
	if(!aFlag) [fMainWindow makeKeyAndOrderFront:self];
	return YES;
}

- (BOOL)windowShouldClose:(id)sender
{
	BOOL lResult = YES;
	if (sender == fMainWindow) {
		[fMainWindow orderOut:self];
		lResult = NO;
	}
	return lResult;
}

@end
