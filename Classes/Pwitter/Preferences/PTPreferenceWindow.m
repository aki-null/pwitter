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
#import <Growl/GrowlApplicationBridge.h>


@implementation PTPreferenceWindow

- (void)loadPreferences {
	NSString *lTempUserName = [[PTPreferenceManager sharedInstance] userName];
	if (lTempUserName == nil) lTempUserName = @"";
	[fUserName setStringValue:lTempUserName];
	[[PTPreferenceManager sharedInstance] alwaysOnTop] ? [fAlwaysOnTop setState:NSOnState] : [fAlwaysOnTop setState:NSOffState];
	[fTimeInterval selectItemAtIndex:[[PTPreferenceManager sharedInstance] timeInterval] - 1];
	[fMessageUpdateInterval selectItemAtIndex:[[PTPreferenceManager sharedInstance] messageInterval] - 1];
	[fBehaviorAfterUpdate selectItemAtIndex:[[PTPreferenceManager sharedInstance] statusUpdateBehavior] - 1];
	if ([[PTPreferenceManager sharedInstance] statusUpdateBehavior] == 1) {
		[fStatusController setSelectsInsertedObjects:YES];
	} else {
		[fStatusController setSelectsInsertedObjects:NO];
	}
	[fPassword setStringValue:@""];
	[fMainWindow setFloatingPanel:[[PTPreferenceManager sharedInstance] alwaysOnTop]];
	[[PTPreferenceManager sharedInstance] hideDockIcon] ? [fHideDockIcon setState:NSOnState] : [fHideDockIcon setState:NSOffState];
	[[PTPreferenceManager sharedInstance] autoLogin] ? [fAutoLogin setState:NSOnState] : [fAutoLogin setState:NSOffState];
	[[PTPreferenceManager sharedInstance] receiveFromNonFollowers] ? [fReceiveFromNonFollowers setState:NSOnState] : [fReceiveFromNonFollowers setState:NSOffState];
	[[PTPreferenceManager sharedInstance] useMiniView] ? [fUseMiniView setState:NSOnState] : [fUseMiniView setState:NSOffState];
	[[PTPreferenceManager sharedInstance] quickPost] ? [fActivateGlobalKey setState:NSOnState] : [fActivateGlobalKey setState:NSOffState];
	[[PTPreferenceManager sharedInstance] quickRead] ? [fActivateQuickReadKey setState:NSOnState] : [fActivateQuickReadKey setState:NSOffState];
	[[PTPreferenceManager sharedInstance] ignoreErrors] ? [fIgnoreErrors setState:NSOnState] : [fIgnoreErrors setState:NSOffState];
	[[PTPreferenceManager sharedInstance] swapMenuItemBehavior] ? [fSwapMenuItem setState:NSOnState] : [fSwapMenuItem setState:NSOffState];
	[[PTPreferenceManager sharedInstance] useTwelveHour] ? [fUseTwelveHour setState:NSOnState] : [fUseTwelveHour setState:NSOffState];
	[[PTPreferenceManager sharedInstance] disableTopView] ? [fHideTopView setState:NSOnState] : [fHideTopView setState:NSOffState];
	[[PTPreferenceManager sharedInstance] usePOSTMethod] ? [fUsePOSTMethod setState:NSOnState] : [fUsePOSTMethod setState:NSOffState];
	// Notification preferences
	[[PTPreferenceManager sharedInstance] disableGrowl] ? [fDisableGrowl setState:NSOnState] : [fDisableGrowl setState:NSOffState];
	[[PTPreferenceManager sharedInstance] disableMessageNotification] ? [fDisableMessageNotification setState:NSOnState] : [fDisableMessageNotification setState:NSOffState];
	[[PTPreferenceManager sharedInstance] disableReplyNotification] ? [fDisableReplyNotification setState:NSOnState] : [fDisableReplyNotification setState:NSOffState];
	[[PTPreferenceManager sharedInstance] disableStatusNotification] ? [fDisableStatusNotification setState:NSOnState] : [fDisableStatusNotification setState:NSOffState];
	[[PTPreferenceManager sharedInstance] disableErrorNotification] ? [fDisableErrorNotification setState:NSOnState] : [fDisableErrorNotification setState:NSOffState];
	[[PTPreferenceManager sharedInstance] disableSoundNotification] ? [fDisableSoundNotification setState:NSOnState] : [fDisableSoundNotification setState:NSOffState];
	if ([[PTPreferenceManager sharedInstance] disableGrowl]) {
		[fDisableMessageNotification setEnabled:NO];
		[fDisableStatusNotification setEnabled:NO];
		[fDisableReplyNotification setEnabled:NO];
		[fDisableErrorNotification setEnabled:NO];
	}
	if (![GrowlApplicationBridge isGrowlRunning]) {
		[fDisableGrowl setEnabled:NO];
		[fDisableMessageNotification setEnabled:NO];
		[fDisableStatusNotification setEnabled:NO];
		[fDisableReplyNotification setEnabled:NO];
		[fDisableErrorNotification setEnabled:NO];
	}
	[[fMainController fMenuItem] setSwapped:[[PTPreferenceManager sharedInstance] swapMenuItemBehavior]];
	// load key combination
	[self loadKeyCombo];
	[self turnOffHotKey];
	[fShortcutRecorder setEnabled:NO];
	[fQuickReadShortcutRecorder setEnabled:NO];
	if ([[PTPreferenceManager sharedInstance] quickPost]) {
		[fShortcutRecorder setEnabled:YES];
		[self turnOnHotKey];
	}
	if ([[PTPreferenceManager sharedInstance] quickRead]) {
		[fQuickReadShortcutRecorder setEnabled:YES];
		[self turnOnReadHotKey];
	}
}

- (IBAction)pressOK:(id)sender {
	BOOL fShouldReset = NO;
	[[PTPreferenceManager sharedInstance] setAlwaysOnTop:[fAlwaysOnTop state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setHideDockIcon:[fHideDockIcon state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setUseMiniView:[fUseMiniView state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setQuickPost:[fActivateGlobalKey state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setQuickRead:[fActivateGlobalKey state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setIgnoreErrors:[fIgnoreErrors state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setSwapMenuItemBehavior:[fSwapMenuItem state] == NSOnState];
	fShouldReset = [[PTPreferenceManager sharedInstance] useTwelveHour] == ([fUseTwelveHour state] != NSOnState);
	[[PTPreferenceManager sharedInstance] setUseTwelveHour:[fUseTwelveHour state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setUsePOSTMethod:[fUsePOSTMethod state] == NSOnState];
	if ([[PTPreferenceManager sharedInstance] disableTopView] == ([fHideTopView state] != NSOnState))
	{
		if ([[PTPreferenceManager sharedInstance] disableTopView])
			[fMainActionHandler enableTopView];
		else
			[fMainActionHandler disableTopView];
	}
	[[PTPreferenceManager sharedInstance] setDisableTopView:[fHideTopView state] == NSOnState];
	// Notification preferences
	[[PTPreferenceManager sharedInstance] setDisableGrowl:[fDisableGrowl state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setDisableMessageNotification:[fDisableMessageNotification state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setDisableReplyNotification:[fDisableReplyNotification state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setDisableStatusNotification:[fDisableStatusNotification state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setDisableErrorNotification:[fDisableErrorNotification state] == NSOnState];
	[[PTPreferenceManager sharedInstance] setDisableSoundNotification:[fDisableSoundNotification state] == NSOnState];
	if ([fIgnoreErrors state] == NSOnState)
		[fMainActionHandler clearErrors:sender];
	BOOL lNonFollower = [fReceiveFromNonFollowers state] == NSOnState;
	if ([[PTPreferenceManager sharedInstance] receiveFromNonFollowers] != lNonFollower) {
		[[PTPreferenceManager sharedInstance] setReceiveFromNonFollowers:lNonFollower];
		fShouldReset = YES;
	}
	[[PTPreferenceManager sharedInstance] setAutoLogin:[fAutoLogin state] == NSOnState];
	if ([[PTPreferenceManager sharedInstance] timeInterval] != [fTimeInterval indexOfSelectedItem] + 1) {
		[[PTPreferenceManager sharedInstance] setTimeInterval:[fTimeInterval indexOfSelectedItem] + 1];
		[fMainController setupUpdateTimer];
	}
	if ([[PTPreferenceManager sharedInstance] messageInterval] != [fMessageUpdateInterval indexOfSelectedItem] + 1) {
		[[PTPreferenceManager sharedInstance] setMessageInterval:[fMessageUpdateInterval indexOfSelectedItem] + 1];
		[fMainController setupMessageUpdateTimer];
	}
	if ([[PTPreferenceManager sharedInstance] statusUpdateBehavior] != [fBehaviorAfterUpdate indexOfSelectedItem] + 1) {
		[[PTPreferenceManager sharedInstance] setStatusUpdateBehavior:[fBehaviorAfterUpdate indexOfSelectedItem] + 1];
	}
	if ([[fPassword stringValue] length] != 0) {
		[[PTPreferenceManager sharedInstance] setUserName:[fUserName stringValue] 
											  password:[fPassword stringValue]];
		fShouldReset = YES;
	}
	if ([[PTPreferenceManager sharedInstance] statusUpdateBehavior] == 1) {
		[fStatusController setSelectsInsertedObjects:YES];
	} else {
		[fStatusController setSelectsInsertedObjects:NO];
	}
	[fMainWindow setFloatingPanel:[[PTPreferenceManager sharedInstance] alwaysOnTop]];
	[[fMainController fMenuItem] setSwapped:[[PTPreferenceManager sharedInstance] swapMenuItemBehavior]];
	[self saveKeyCombo];
	[self turnOffHotKey];
	if ([fActivateGlobalKey state] == NSOnState)
		[self turnOnHotKey];
	if ([fActivateQuickReadKey state] == NSOnState)
		[self turnOnReadHotKey];
	[NSApp endSheet:self];
	if (fShouldReset) [fMainController changeAccount:self];
}

- (IBAction)pressCancel:(id)sender {
    [self loadPreferences];
	[NSApp endSheet:self];
}

- (void)turnOffHotKey {
	[fShortcutRecorder setCanCaptureGlobalHotKeys:NO];
	[fQuickReadShortcutRecorder setCanCaptureGlobalHotKeys:NO];
	if (fHotKey != nil) {
		[[PTHotKeyCenter sharedCenter] unregisterHotKey: fHotKey];
		[fHotKey release];
		fHotKey = nil;
	}
	if (fHotKeyRead != nil) {
		[[PTHotKeyCenter sharedCenter] unregisterHotKey: fHotKeyRead];
		[fHotKeyRead release];
		fHotKeyRead = nil;
	}
}

- (void)turnOnHotKey {
	[fShortcutRecorder setCanCaptureGlobalHotKeys:YES];
	fHotKey = [[PTHotKey alloc] initWithIdentifier:@"ActivateQuickPost" 
										  keyCombo:[PTKeyCombo keyComboWithKeyCode:[(SRRecorderControl *)fShortcutRecorder keyCombo].code 
																		 modifiers:[(SRRecorderControl *)fShortcutRecorder cocoaToCarbonFlags:[(SRRecorderControl *)fShortcutRecorder keyCombo].flags]]];
	[fHotKey setTarget: self];
	[fHotKey setAction: @selector(hitKey:)];
	[[PTHotKeyCenter sharedCenter] registerHotKey: fHotKey];
}

- (void)turnOnReadHotKey {
	[fQuickReadShortcutRecorder setCanCaptureGlobalHotKeys:YES];
	fHotKeyRead = [[PTHotKey alloc] initWithIdentifier:@"ActivateQuickRead" 
										  keyCombo:[PTKeyCombo keyComboWithKeyCode:[(SRRecorderControl *)fQuickReadShortcutRecorder keyCombo].code 
																		 modifiers:[(SRRecorderControl *)fQuickReadShortcutRecorder cocoaToCarbonFlags:[(SRRecorderControl *)fQuickReadShortcutRecorder keyCombo].flags]]];
	[fHotKeyRead setTarget: self];
	[fHotKeyRead setAction: @selector(hitReadKey:)];
	[[PTHotKeyCenter sharedCenter] registerHotKey: fHotKeyRead];
}

- (void)saveKeyCombo {
	KeyCombo lTempKeyCode = [(SRRecorderControl*)fShortcutRecorder keyCombo];
	id lValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
	NSDictionary *lDefValue = [NSDictionary dictionaryWithObjectsAndKeys: 
							   [NSNumber numberWithShort:lTempKeyCode.code], @"keyCode", 
							   [NSNumber numberWithUnsignedInt:lTempKeyCode.flags], @"modifierFlags", 
							   nil];
	[lValues setValue:lDefValue forKey:@"quick_post_activation_key"];
	lTempKeyCode = [(SRRecorderControl*)fQuickReadShortcutRecorder keyCombo];
	lDefValue = [NSDictionary dictionaryWithObjectsAndKeys: 
				  [NSNumber numberWithShort:lTempKeyCode.code], @"keyCode", 
				  [NSNumber numberWithUnsignedInt:lTempKeyCode.flags], @"modifierFlags", 
				  nil];
	[lValues setValue:lDefValue forKey:@"quick_read_activation_key"];
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
	lSavedCombo = [lValued valueForKey:@"quick_read_activation_key"];
	lKeyCode = [[lSavedCombo valueForKey:@"keyCode"] shortValue];
	lFlags = [[lSavedCombo valueForKey:@"modifierFlags"] unsignedIntValue];
	if (lKeyCode == 0 && lFlags == 0) return;
	keyCombo.code = lKeyCode;
	keyCombo.flags = lFlags;
	[(SRRecorderControl *)fQuickReadShortcutRecorder setKeyCombo:keyCombo];
}

- (void)hitKey:(PTHotKey *)aHotKey {
	[NSApp activateIgnoringOtherApps:YES];
	[fMainWindow makeKeyAndOrderFront:self];
	[fPostTextField selectText:self];
}

- (void)hitReadKey:(PTHotKey *)aHotKey {
	[NSApp activateIgnoringOtherApps:YES];
	[fMainWindow makeKeyAndOrderFront:self];
	[fMainWindow makeFirstResponder:fStatusCollectionView];
}

- (IBAction)quickPostChanged:(id)sender {
	[fShortcutRecorder setEnabled:[sender state] == NSOnState];
}

- (IBAction)growlDisabled:(id)sender {
    if ([fDisableGrowl state] == NSOnState) {
		[fDisableMessageNotification setEnabled:NO];
		[fDisableStatusNotification setEnabled:NO];
		[fDisableReplyNotification setEnabled:NO];
	} else {
		[fDisableMessageNotification setEnabled:YES];
		[fDisableStatusNotification setEnabled:YES];
		[fDisableReplyNotification setEnabled:YES];
	}
}

-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	int lTargetHeight;
	switch ([[tabViewItem identifier] intValue]) {
		case 1:
			lTargetHeight = 313;
			break;
		case 2:
			lTargetHeight = 261;
			break;
		case 3:
			lTargetHeight = 294;
			break;
		case 4:
			lTargetHeight = 268;
			break;
		default:
			lTargetHeight = 313;
			break;
	}
	NSRect lNewFrame = [self frame];
	lNewFrame.origin.y += lNewFrame.size.height - lTargetHeight;
	lNewFrame.size.height = lTargetHeight;
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext]setDuration: 0.2];
	[[self animator] setFrame:lNewFrame display:YES];
	[NSAnimationContext endGrouping];
}

- (IBAction)quickReadChanged:(id)sender {
    [fQuickReadShortcutRecorder setEnabled:[sender state] == NSOnState];
}


@end
