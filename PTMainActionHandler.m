//
//  PTMainActionHandler.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTMainActionHandler.h"
#import "PTPreferenceManager.h"
#import "PTPreferenceWindow.h"
#import "PTMain.h"


@implementation PTMainActionHandler

- (void)awakeFromNib {
	fShouldExit = NO;
	NSDictionary *lLinkFormat =
	[NSDictionary dictionaryWithObjectsAndKeys:
	 [NSColor cyanColor], @"NSColor",
	 [NSCursor pointingHandCursor], @"NSCursor",
	 [NSNumber numberWithInt:1], @"NSUnderline",
	 nil];
	[fSelectedTextView setLinkTextAttributes:lLinkFormat];
	lLinkFormat =
	[NSDictionary dictionaryWithObjectsAndKeys:
	 [NSColor whiteColor], @"NSColor",
	 [NSCursor pointingHandCursor], @"NSCursor",
	 [NSNumber numberWithInt:1], @"NSUnderline",
	 nil];
	[fUserNameBox setLinkTextAttributes:lLinkFormat];
	NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	[fStatusController setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
	[sortDesc release];
	[fPreferenceWindow loadPreferences];
}

- (void)startAuthentication {
	if ([[PTPreferenceManager getInstance] autoLogin]) {
		[fMainController setUpTwitterEngine];
		return;
	}
	[NSApp beginSheet:fAuthPanel
	   modalForWindow:fMainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
	NSString *lTempName = [[PTPreferenceManager getInstance] userName];
	NSString *lTempPass = [[PTPreferenceManager getInstance] password];
	if (lTempName)
		[fAuthUserName setStringValue:lTempName];
	if (lTempPass)
		[fAuthPassword setStringValue:lTempPass];
}

- (void)didEndSheet:(NSWindow *)aSheet returnCode:(int)aReturnCode contextInfo:(void *)aContextInfo
{
	[aSheet orderOut:self];
	if (fShouldExit) [NSApp terminate:self];
	if (aSheet == fAuthPanel) [fMainController setUpTwitterEngine];
}

- (IBAction)closeAuthSheet:(id)sender
{
	[[PTPreferenceManager getInstance] setUserName:[fAuthUserName stringValue] 
										  password:[fAuthPassword stringValue]];
    [NSApp endSheet:fAuthPanel];
}

- (IBAction)quitApp:(id)sender {
	fShouldExit = YES;
	[NSApp endSheet:fAuthPanel];
}

- (IBAction)messageToSelected:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusController selectedObjects] lastObject];
	NSString *lMessageTarget = [NSString stringWithFormat:@"d %@ %@", lCurrentSelection.userID, [fStatusUpdateField stringValue]];
	[fStatusUpdateField setStringValue:lMessageTarget];
	[fMainWindow makeFirstResponder:fStatusUpdateField];
	[(NSText *)[fMainWindow firstResponder] setSelectedRange:NSMakeRange([[fStatusUpdateField stringValue] length], 0)];
}

- (IBAction)openHome:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://twitter.com/home"]];
}

- (IBAction)openWebSelected:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusController selectedObjects] lastObject];
	[[NSWorkspace sharedWorkspace] openURL:lCurrentSelection.userHome];
}

- (IBAction)replyToSelected:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusController selectedObjects] lastObject];
	NSString *replyTarget = [NSString stringWithFormat:@"@%@ %@", lCurrentSelection.userID, [fStatusUpdateField stringValue]];
	[fStatusUpdateField setStringValue:replyTarget];
	[fMainWindow makeFirstResponder:fStatusUpdateField];
	[(NSText *)[fMainWindow firstResponder] setSelectedRange:NSMakeRange([[fStatusUpdateField stringValue] length], 0)];
}

- (IBAction)openPref:(id)sender {
	[fPreferenceWindow loadPreferences];
	[NSApp beginSheet:fPreferenceWindow
	   modalForWindow:fMainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (IBAction)openSearchBox:(id)sender {
	if (!fSearchBoxIsOpen) {
		fSearchBoxIsOpen = YES;
		NSRect lTempRect = [fSearchView frame];
		[[fSearchView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y - 21, lTempRect.size.width, 22)];
		lTempRect = [fStatusScrollView frame];
		[[fStatusScrollView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y, lTempRect.size.width, lTempRect.size.height - 21)];
	}
	[fSearchBox selectText:sender];
}

- (IBAction)closeSearchBox:(id)sender {
	if (fSearchBoxIsOpen) {
		fSearchBoxIsOpen = NO;
		NSRect lTempRect = [fSearchView frame];
		[[fSearchView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y + 21, lTempRect.size.width, 1)];
		lTempRect = [fStatusScrollView frame];
		[[fStatusScrollView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y, lTempRect.size.width, lTempRect.size.height + 21)];
		[fStatusController setFilterPredicate:nil];
	}
	[fMainWindow makeFirstResponder:fMainWindow];
}

- (IBAction)clearErrors:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 3", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
	NSArray *lErrorBoxes = [fStatusController arrangedObjects];
	[fStatusController removeObjects:lErrorBoxes];
	[fStatusController setFilterPredicate:nil];
}

- (void)updateViewSizes:(float)aHeightReq withAnim:(BOOL)aAnim {
	float lTopHeight = 79;
	if (aHeightReq > 51) lTopHeight += aHeightReq - 51;
	NSRect lTopFrame = [fTopView frame];
	float lTopDiff = lTopFrame.size.height - lTopHeight;
	if (aAnim) {
		[[fTopView animator] setFrame:NSMakeRect(0, lTopFrame.origin.y + lTopDiff, [fTopView frame].size.width, lTopHeight)];
		[[fBottomView animator] setFrame:NSMakeRect(0, 43, [fBottomView frame].size.width, [fBottomView frame].size.height + lTopDiff)];
	} else {
		[fTopView setFrame:NSMakeRect(0, lTopFrame.origin.y + lTopDiff, [fTopView frame].size.width, lTopHeight)];
		[fBottomView setFrame:NSMakeRect(0, 43, [fBottomView frame].size.width, [fBottomView frame].size.height + lTopDiff)];
	}
}

- (void)updateSelectedMessage:(PTStatusBox *)aBox {
	if (!aBox) {
		[self updateViewSizes:0 withAnim:YES];
		[fWebButton setEnabled:NO];
		[fReplyButton setEnabled:NO];
		[fMessageButton setEnabled:NO];
		return;
	}
	[fReplyButton setState:NSOffState];
	[fMessageButton setState:NSOffState];
	!aBox.userHome ? [fWebButton setEnabled:NO] : [fWebButton setEnabled:YES];
	if (aBox.sType == ErrorMessage) {
		[fReplyButton setEnabled:NO];
		[fMessageButton setEnabled:NO];
	} else {
		[fReplyButton setEnabled:YES];
		[fMessageButton setEnabled:YES];
	}
	
	NSRect lFrame = NSMakeRect(0, 0, [fSelectedTextView frame].size.width, MAXFLOAT);
	NSTextView *lTempTextView = [[NSTextView alloc] initWithFrame:lFrame];
	[[lTempTextView textStorage] setAttributedString:aBox.statusMessage];
	[lTempTextView setHorizontallyResizable:NO];
	[lTempTextView sizeToFit];
	float lHeightReq = [lTempTextView frame].size.height;
	[lTempTextView release];
	[self updateViewSizes:lHeightReq withAnim:YES];
}

@end
