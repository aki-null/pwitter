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
	[[PTPreferenceManager getInstance] alwaysOnTop] ? [fAlwaysOnTop setState:NSOnState] : [fAlwaysOnTop setState:NSOffState];
	[fTimeInterval selectItemAtIndex:[[PTPreferenceManager getInstance] timeInterval] - 1];
	[fMessageUpdateInterval selectItemAtIndex:[[PTPreferenceManager getInstance] messageInterval] - 1];
	[fPassword setStringValue:@""];
	[fMainWindow setFloatingPanel:[[PTPreferenceManager getInstance] alwaysOnTop]];
	[[PTPreferenceManager getInstance] autoLogin] ? [fAutoLogin setState:NSOnState] : [fAutoLogin setState:NSOffState];
	[[PTPreferenceManager getInstance] receiveFromNonFollowers] ? [fReceiveFromNonFollowers setState:NSOnState] : [fReceiveFromNonFollowers setState:NSOffState];
}

- (IBAction)pressOK:(id)sender {
	BOOL fShouldReset = NO;
	[[PTPreferenceManager getInstance] setAlwaysOnTop:[fAlwaysOnTop state] == NSOnState];
	BOOL lNonFollower = [fReceiveFromNonFollowers state] == NSOnState;
	if ([[PTPreferenceManager getInstance] receiveFromNonFollowers] != lNonFollower) {
		[[PTPreferenceManager getInstance] setReceiveFromNonFollowers:lNonFollower];
		fShouldReset = YES;
	}
	[[PTPreferenceManager getInstance] setAutoLogin:[fAutoLogin state] == NSOnState];
	if ([[PTPreferenceManager getInstance] timeInterval] != [fTimeInterval indexOfSelectedItem] + 1) {
		[[PTPreferenceManager getInstance] setTimeInterval:[fTimeInterval indexOfSelectedItem] + 1];
		[fMainController setupUpdateTimer];
	}
	if ([[PTPreferenceManager getInstance] messageInterval] != [fMessageUpdateInterval indexOfSelectedItem] + 1) {
		[[PTPreferenceManager getInstance] setMessageInterval:[fMessageUpdateInterval indexOfSelectedItem] + 1];
		[fMainController setupMessageUpdateTimer];
	}
	if ([[fPassword stringValue] length] != 0) {
		[[PTPreferenceManager getInstance] setUserName:[fUserName stringValue] 
											  password:[fPassword stringValue]];
		fShouldReset = YES;
	}
	if (fShouldReset) [fMainController changeAccount:self];
	[fMainWindow setFloatingPanel:[[PTPreferenceManager getInstance] alwaysOnTop]];
	[NSApp endSheet:self];
}

- (IBAction)pressCancel:(id)sender {
    [self loadPreferences];
	[NSApp endSheet:self];
}

@end
