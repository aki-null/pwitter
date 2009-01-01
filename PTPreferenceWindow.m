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
	NSString *tempUserName = [[PTPreferenceManager getInstance] userName];
	if (tempUserName == nil) tempUserName = @"";
	[userName setStringValue:tempUserName];
	if ([[PTPreferenceManager getInstance] alwaysOnTop]) {
		[alwaysOnTop setState:NSOnState];
	} else {
		[alwaysOnTop setState:NSOffState];
	}
	[timeInterval selectItemAtIndex:[[PTPreferenceManager getInstance] timeInterval] - 1];
	[password setStringValue:@""];
	[mainWindow setFloatingPanel:[[PTPreferenceManager getInstance] alwaysOnTop]];
	if ([[PTPreferenceManager getInstance] autoLogin]) {
		[autoLogin setState:NSOnState];
	} else {
		[autoLogin setState:NSOffState];
	}
}

- (IBAction)pressOK:(id)sender {
	[[PTPreferenceManager getInstance] setAlwaysOnTop:[alwaysOnTop state] == NSOnState];
	[[PTPreferenceManager getInstance] setAutoLogin:[autoLogin state] == NSOnState];
	if ([[PTPreferenceManager getInstance] timeInterval] != [timeInterval indexOfSelectedItem] + 1) {
		[[PTPreferenceManager getInstance] setTimeInterval:[timeInterval indexOfSelectedItem] + 1];
		[mainController setupUpdateTimer];
	}
	if ([[password stringValue] length] != 0) {
		[[PTPreferenceManager getInstance] setUserName:[userName stringValue] 
											  password:[password stringValue]];
		[mainController changeAccount];
	}
	[mainWindow setFloatingPanel:[[PTPreferenceManager getInstance] alwaysOnTop]];
	[NSApp endSheet:self];
}

- (IBAction)pressCancel:(id)sender {
    [self loadPreferences];
	[NSApp endSheet:self];
}

@end
