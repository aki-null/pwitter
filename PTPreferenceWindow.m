//
//  PTPreferenceWindow.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTPreferenceWindow.h"
#import "PTPreferenceManager.h"
#import "PTHotKeyCenter.h"
#import "PTMain.h"
#import "PTMainActionHandler.h"


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
	[[PTPreferenceManager getInstance] useMiniView] ? [fUseMiniView setState:NSOnState] : [fUseMiniView setState:NSOffState];
	[[PTPreferenceManager getInstance] quickPost] ? [fActivateGlobalKey setState:NSOnState] : [fActivateGlobalKey setState:NSOffState];
	[[PTPreferenceManager getInstance] ignoreErrors] ? [fIgnoreErrors setState:NSOnState] : [fIgnoreErrors setState:NSOffState];
	[self loadKeyCombo];
	[self turnOffHotKey];
	[fShortcutRecorder setEnabled:NO];
	if ([[PTPreferenceManager getInstance] quickPost])
	{
		[fShortcutRecorder setEnabled:YES];
		[self turnOnHotKey];
	}
}

- (IBAction)pressOK:(id)sender {
	BOOL fShouldReset = NO;
	[[PTPreferenceManager getInstance] setAlwaysOnTop:[fAlwaysOnTop state] == NSOnState];
	[[PTPreferenceManager getInstance] setUseMiniView:[fUseMiniView state] == NSOnState];
	[[PTPreferenceManager getInstance] setQuickPost:[fActivateGlobalKey state] == NSOnState];
	[[PTPreferenceManager getInstance] setIgnoreErrors:[fIgnoreErrors state] == NSOnState];
	if ([fIgnoreErrors state] == NSOnState)
		[fMainActionHandler clearErrors:sender];
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
	[self saveKeyCombo];
	[self turnOffHotKey];
	if ([fActivateGlobalKey state] == NSOnState)
		[self turnOnHotKey];
	[NSApp endSheet:self];
}

- (IBAction)pressCancel:(id)sender {
    [self loadPreferences];
	[NSApp endSheet:self];
}

- (void)turnOffHotKey {
	[fShortcutRecorder setCanCaptureGlobalHotKeys:NO];
	if (fHotKey != nil)
	{
		[[PTHotKeyCenter sharedCenter] unregisterHotKey: fHotKey];
		[fHotKey release];
		fHotKey = nil;
	}
}

- (void)turnOnHotKey {
	[fShortcutRecorder setCanCaptureGlobalHotKeys:YES];
	fHotKey = [[PTHotKey alloc] initWithIdentifier:@"ActivateQuickPostWindow" 
										  keyCombo:[PTKeyCombo keyComboWithKeyCode:[(SRRecorderControl *)fShortcutRecorder keyCombo].code 
																		 modifiers:[(SRRecorderControl *)fShortcutRecorder cocoaToCarbonFlags:[(SRRecorderControl *)fShortcutRecorder keyCombo].flags]]];
	[fHotKey setTarget: self];
	[fHotKey setAction: @selector(hitKey:)];
	[[PTHotKeyCenter sharedCenter] registerHotKey: fHotKey];
}

- (void)saveKeyCombo {
	KeyCombo lTempKeyCode = [(SRRecorderControl*)fShortcutRecorder keyCombo];
	id lValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
	NSDictionary *lDefValue = [NSDictionary dictionaryWithObjectsAndKeys: 
							   [NSNumber numberWithShort:lTempKeyCode.code], @"keyCode", 
							   [NSNumber numberWithUnsignedInt:lTempKeyCode.flags], @"modifierFlags", 
							   nil];
	[lValues setValue:lDefValue forKey:@"quick_post_activation_key"];
}

- (void)loadKeyCombo
{
	id lValued = [[NSUserDefaultsController sharedUserDefaultsController] values];
	NSDictionary *lSavedCombo = [lValued valueForKey:@"quick_post_activation_key"];
	signed short lKeyCode = [[lSavedCombo valueForKey:@"keyCode"] shortValue];
	unsigned int lFlags = [[lSavedCombo valueForKey:@"modifierFlags"] unsignedIntValue];
	if (lKeyCode == 0 && lFlags == 0) return;
	KeyCombo keyCombo;
	keyCombo.code = lKeyCode;
	keyCombo.flags = lFlags;
	[(SRRecorderControl *)fShortcutRecorder setKeyCombo:keyCombo];
}

- (void)hitKey:(PTHotKey *)aHotKey {
	[NSApp activateIgnoringOtherApps:YES];
	[fMainWindow orderFront:self];
	[fMainWindow makeKeyWindow];
	[fPostTextField selectText:self];
}

- (IBAction)quickPostChanged:(id)sender {
	[fShortcutRecorder setEnabled:[sender state] == NSOnState];
}

@end
