//
//  PTPreferenceWindow.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTPreferenceWindow.h"
#import "PTPreferenceManager.h"
#import "PTMain.h"


@implementation PTPreferenceWindow

- (void)loadPreferences {
	NSString *lTempUserName = [[PTPreferenceManager getInstance] userName];
	if (lTempUserName == nil) lTempUserName = @"";
	[fUserName setStringValue:lTempUserName];
	if ([[PTPreferenceManager getInstance] alwaysOnTop]) {
		[fAlwaysOnTop setState:NSOnState];
	} else {
		[fAlwaysOnTop setState:NSOffState];
	}
	[fTimeInterval selectItemAtIndex:[[PTPreferenceManager getInstance] timeInterval] - 1];
	[fPassword setStringValue:@""];
	[fMainWindow setFloatingPanel:[[PTPreferenceManager getInstance] alwaysOnTop]];
	if ([[PTPreferenceManager getInstance] autoLogin]) {
		[fAutoLogin setState:NSOnState];
	} else {
		[fAutoLogin setState:NSOffState];
	}
}

- (IBAction)pressOK:(id)aSender {
	[[PTPreferenceManager getInstance] setAlwaysOnTop:[fAlwaysOnTop state] == NSOnState];
	[[PTPreferenceManager getInstance] setAutoLogin:[fAutoLogin state] == NSOnState];
	if ([[PTPreferenceManager getInstance] timeInterval] != [fTimeInterval indexOfSelectedItem] + 1) {
		[[PTPreferenceManager getInstance] setTimeInterval:[fTimeInterval indexOfSelectedItem] + 1];
		[fMainController setupUpdateTimer];
	}
	if ([[fPassword stringValue] length] != 0) {
		[[PTPreferenceManager getInstance] setUserName:[fUserName stringValue] 
											  password:[fPassword stringValue]];
		[fMainController changeAccount];
	}
	[fMainWindow setFloatingPanel:[[PTPreferenceManager getInstance] alwaysOnTop]];
	[NSApp endSheet:self];
}

- (IBAction)pressCancel:(id)aSender {
    [self loadPreferences];
	[NSApp endSheet:self];
}

@end
