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
#import "PTReadManager.h"
#import "PTStatusTextField.h"
#import "AMCollectionView.h"


@implementation PTMainActionHandler

- (void)awakeFromNib {
	fShouldExit = NO;
	NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	[fStatusController setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
	[sortDesc release];
	[fPreferenceWindow loadPreferences];
	[self setCollectionViewPrototype:[[PTPreferenceManager sharedSingleton] useMiniView] 
						  useClassic:[[PTPreferenceManager sharedSingleton] useClassicView]];
	[fMainWindow makeFirstResponder:fStatusCollectionView];
}

- (void)setCollectionViewPrototype:(BOOL)aIsMini useClassic:(BOOL)aIsClassic {
	if (aIsMini) {
		if (aIsClassic) {
			if ([fStatusCollectionView itemPrototype] != fMiniClassicItemPrototype) {
				[fStatusCollectionView setItemPrototype:fMiniClassicItemPrototype];
			}
		} else if ([fStatusCollectionView itemPrototype] != fMiniItemPrototype) {
			[fStatusCollectionView setItemPrototype:fMiniItemPrototype];
		}
	} else if (aIsClassic) {
		if ([fStatusCollectionView itemPrototype] != fNormalClassicItemPrototype) {
			[fStatusCollectionView setItemPrototype:fNormalClassicItemPrototype];
		}
	} else if ([fStatusCollectionView itemPrototype] != fNormalItemPrototype) {
		[fStatusCollectionView setItemPrototype:fNormalItemPrototype];
	}
	[fStatusCollectionView deselectAll:self];
}
- (void)updateCollection {
	[fStatusCollectionView setContent:[fStatusController arrangedObjects]];
}

- (void)startAuthentication {
	if ([[PTPreferenceManager sharedSingleton] autoLogin]) {
		[fMainController setUpTwitterEngine];
		return;
	}
	[NSApp beginSheet:fAuthPanel
	   modalForWindow:fMainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
	NSString *lTempName = [[PTPreferenceManager sharedSingleton] userName];
	NSString *lTempPass = [[PTPreferenceManager sharedSingleton] password];
	if (lTempName)
		[fAuthUserName setStringValue:lTempName];
	if (lTempPass)
		[fAuthPassword setStringValue:lTempPass];
}

- (void)didEndSheet:(NSWindow *)aSheet returnCode:(int)aReturnCode contextInfo:(void *)aContextInfo
{
	[aSheet orderOut:self];
	[self setCollectionViewPrototype:[[PTPreferenceManager sharedSingleton] useMiniView] 
						  useClassic:[[PTPreferenceManager sharedSingleton] useClassicView]];
	if (fShouldExit) [NSApp terminate:self];
	if (aSheet == fAuthPanel) [fMainController setUpTwitterEngine];
}

- (IBAction)closeAuthSheet:(id)sender
{
	[[PTPreferenceManager sharedSingleton] setUserName:[fAuthUserName stringValue] 
										  password:[fAuthPassword stringValue]];
    [NSApp endSheet:fAuthPanel];
}

- (IBAction)quitApp:(id)sender {
	fShouldExit = YES;
	[NSApp endSheet:fAuthPanel];
}

- (void)messageToStatus:(PTStatusBox *)aBox {
	NSString *lMessageTarget = [NSString stringWithFormat:@"D %@ %@", aBox.userId, [fStatusUpdateField stringValue]];
	[fMainWindow makeFirstResponder:fStatusUpdateField];
	[fStatusUpdateField setStringValue:lMessageTarget];
	[(NSText *)[fMainWindow firstResponder] setSelectedRange:NSMakeRange([[fStatusUpdateField stringValue] length], 0)];
	[fCharacterCounter setIntValue:140 - [[fStatusUpdateField stringValue] length]];
}

- (IBAction)messageToSelected:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	if (lCurrentSelection.sType != ErrorMessage) {
		[self messageToStatus:lCurrentSelection];
	}
}

- (IBAction)openHome:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://twitter.com/home"]];
}

- (IBAction)openWebSelected:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	[[NSWorkspace sharedWorkspace] openURL:lCurrentSelection.userHome];
}

- (void)openReplyView {
	if (!fReplyViewIsOpen) {
		fReplyViewIsOpen = YES;
		NSRect lReplyFrame = [fPostView frame];
		NSRect lBottomFrame = [fBottomView frame];
		NSRect lInfoFrame = [fReplyInfoView frame];
		[fReplyInfoView setHidden:NO];
		[fPostView setFrame:NSMakeRect(lReplyFrame.origin.x, lReplyFrame.origin.y, lReplyFrame.size.width, lReplyFrame.size.height + 23)];
		NSRect lPostFrame = [fStatusUpdateField frame];
		[fBottomView setFrame:NSMakeRect(0, lBottomFrame.origin.y + 23, lBottomFrame.size.width, lBottomFrame.size.height - 23)];
		[fReplyInfoView setFrame:NSMakeRect(0, lPostFrame.size.height + 3, lInfoFrame.size.width, 23)];
		[fStatusCollectionView doLayout];
	}
}

- (void)closeReplyView {
	if (fReplyViewIsOpen) {
		[fMainController setReplyID:0];
		fReplyViewIsOpen = NO;
		NSRect lReplyFrame = [fPostView frame];
		NSRect lBottomFrame = [fBottomView frame];
		[fReplyInfoView setHidden:YES];
		[fPostView setFrame:NSMakeRect(lReplyFrame.origin.x, lReplyFrame.origin.y, lReplyFrame.size.width, lReplyFrame.size.height - 23)];
		[fBottomView setFrame:NSMakeRect(0, lBottomFrame.origin.y - 23, lBottomFrame.size.width, lBottomFrame.size.height + 23)];
		[fStatusUpdateField setStringValue:@""];
		[fCharacterCounter setIntValue:140 - [[fStatusUpdateField stringValue] length]];
		[fStatusCollectionView doLayout];
	}
}

- (void)replyToStatus:(PTStatusBox *)aBox {
	NSString *replyTarget = [NSString stringWithFormat:@"@%@ %@", aBox.userId, [fStatusUpdateField stringValue]];
	[fMainWindow makeFirstResponder:fStatusUpdateField];
	[fStatusUpdateField setStringValue:replyTarget];
	[(NSText *)[fMainWindow firstResponder] setSelectedRange:NSMakeRange([[fStatusUpdateField stringValue] length], 0)];
	[fCharacterCounter setIntValue:140 - [[fStatusUpdateField stringValue] length]];
	[fMainController setReplyID:aBox.updateId];
	[fReplyToBox setStringValue:[@"@" stringByAppendingString:aBox.userId]];
	[self openReplyView];
}

- (IBAction)replyToSelected:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	if (!lCurrentSelection) return;
	if (lCurrentSelection.sType == NormalMessage || lCurrentSelection.sType == ReplyMessage || lCurrentSelection.sType == DirectMessage) {
		[self replyToStatus:lCurrentSelection];
	}
}

- (IBAction)openPref:(id)sender {
	[fMainController activateApp:sender];
	[fPreferenceWindow loadPreferences];
	[NSApp beginSheet:fPreferenceWindow
	   modalForWindow:fMainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (IBAction)openSearchBox:(id)sender {
	if (!fSearchBoxIsOpen) {
		[fSearchBox setHidden:NO];
		[fSearchBox setEnabled:YES];
		fSearchBoxIsOpen = YES;
		NSRect lTempRect = [fSearchView frame];
		[[fSearchView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y - 21, lTempRect.size.width, 22)];
		lTempRect = [fStatusScrollView frame];
		[[fStatusScrollView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y, lTempRect.size.width, lTempRect.size.height - 21)];
	}
	[fMainWindow makeFirstResponder:fSearchBox];
}

- (IBAction)closeSearchBox:(id)sender {
	if (fSearchBoxIsOpen) {
		[fSearchBox setHidden:YES];
		[fSearchBox setEnabled:NO];
		fSearchBoxIsOpen = NO;
		NSRect lTempRect = [fSearchView frame];
		[[fSearchView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y + 21, lTempRect.size.width, 1)];
		lTempRect = [fStatusScrollView frame];
		[[fStatusScrollView animator] setFrame:NSMakeRect(lTempRect.origin.x, lTempRect.origin.y, lTempRect.size.width, lTempRect.size.height + 21)];
		[fStatusController setFilterPredicate:nil];
		[self updateCollection];
	}
	[fMainWindow makeFirstResponder:fStatusCollectionView];
}

- (IBAction)clearErrors:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 3", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
	NSArray *lErrorBoxes = [fStatusController arrangedObjects];
	[fStatusController removeObjects:lErrorBoxes];
	[fStatusController setFilterPredicate:nil];
	[self updateCollection];
}

+ (BOOL)hasFocus:(id)aField {
	return [[[aField window] firstResponder] isKindOfClass:[NSTextView class]] && 
	[[aField window] fieldEditor:NO forObject:nil] != nil && 
	((id)[[aField window] firstResponder] == aField || 
	 [(id)[[aField window] firstResponder] delegate] == aField);
}

- (void)updateSelectedMessage:(PTStatusBox *)aBox {
	if (!aBox) {
		[fWebButton setEnabled:NO];
		[fReplyButton setEnabled:NO];
		[fMessageButton setEnabled:NO];
		[fFavButton setEnabled:NO];
		return;
	}
	aBox.readFlag = YES;
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
	[fFavButton setEnabled:aBox.sType == NormalMessage || aBox.sType == ReplyMessage];
	if (![PTMainActionHandler hasFocus:fStatusUpdateField] && 
		![PTMainActionHandler hasFocus:fSearchBox])
		[fMainWindow makeFirstResponder:fStatusCollectionView];
}

- (IBAction)closeReplyViewFromButton:(id)sender {
	[self closeReplyView];
}

- (IBAction)favSelected:(id)sender {
	[fMainController favStatus:[[fStatusCollectionView selectedObjects] lastObject]];
}

- (void)retweetStatus:(PTStatusBox *)aBox {
	if (aBox.sType == ErrorMessage) return;
	NSString *lMessageTarget = [NSString stringWithFormat:@"RT @%@ %@", aBox.userId, [aBox.statusMessage string]];
	[fMainWindow makeFirstResponder:fStatusUpdateField];
	[fStatusUpdateField setStringValue:lMessageTarget];
	[(NSText *)[fMainWindow firstResponder] setSelectedRange:NSMakeRange([[fStatusUpdateField stringValue] length], 0)];
	[fCharacterCounter setIntValue:140 - [[fStatusUpdateField stringValue] length]];
}

- (IBAction)retweetSelection:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	if (lCurrentSelection)
		[self retweetStatus:lCurrentSelection];
}

- (IBAction)markAllAsRead:(id)sender {
	PTStatusBox *lCurrentBox;
	for (lCurrentBox in [fStatusController arrangedObjects]) {
		lCurrentBox.readFlag = YES;
	}
	[[PTReadManager getInstance] setUnreadDict:nil];
}

- (IBAction)openSelectedLink:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	if (lCurrentSelection.statusLink) {
		[[NSWorkspace sharedWorkspace] openURL:lCurrentSelection.statusLink];
	}
}

- (IBAction)openSelectedUser:(id)sender {
    PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	if (lCurrentSelection)
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[@"http://twitter.com/" stringByAppendingString:lCurrentSelection.userId]]];
}

- (IBAction)openPwitterHome:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://wiki.github.com/koroshiya1/pwitter"]];
}

- (IBAction)endSearch:(id)sender {
    [self updateCollection];
}

- (IBAction)openTweet:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	if (lCurrentSelection) {
		if (lCurrentSelection.sType == NormalMessage || lCurrentSelection.sType == ReplyMessage) {
			NSString *lUrlString = [NSString stringWithFormat:@"http://twitter.com/%@/status/%qu", lCurrentSelection.userId, lCurrentSelection.updateId];
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lUrlString]];
		}
	}
}

- (IBAction)openReplyInBrowser:(id)sender {
	PTStatusBox *lCurrentSelection = [[fStatusCollectionView selectedObjects] lastObject];
	if (lCurrentSelection) {
		if (lCurrentSelection.replyId != 0) {
			NSString *lUrlString = [NSString stringWithFormat:@"http://twitter.com/%@/status/%qu", lCurrentSelection.replyUserId, lCurrentSelection.replyId];
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lUrlString]];
		}
	}
}

- (IBAction)deleteSelectedTweet:(id)sender {
    [fMainController deleteTweet:[[fStatusCollectionView selectedObjects] lastObject]];
}

@end
