//
//  PTStatusEntityView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusEntityView.h"
#import "PTStatusBox.h"
#import "PTCollectionView.h"
#import "PTPreferenceManager.h"

@implementation PTStatusEntityView

- (void)setSelected:(BOOL)aFlag {
	fIsSelected = aFlag;
}

- (BOOL)selected {
	return fIsSelected;
}

- (void)openInBrowser:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	if (lBox.updateId != 0) {
		NSString *lUrlString = [NSString stringWithFormat:@"http://twitter.com/%@/status/%u", lBox.userId, lBox.updateId];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lUrlString]];
	}
}

- (void)openUserPage:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	NSString *lUrlString = [NSString stringWithFormat:@"http://twitter.com/%@", lBox.userId];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lUrlString]];
}

- (void)openUserWeb:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	[[NSWorkspace sharedWorkspace] openURL:lBox.userHome];
}

- (void)openReply:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	NSString *lUrlString = [NSString stringWithFormat:@"http://twitter.com/%@/status/%u", lBox.replyUserId, lBox.replyId];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lUrlString]];
}

- (void)openLink:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	[[NSWorkspace sharedWorkspace] openURL:lBox.statusLink];
}

- (void)sendReply:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	if (lBox.sType != ErrorMessage)
		[(PTCollectionView *)[self superview] sendReplyForStatus:lBox];
}

- (void)sendMessage:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	if (lBox.sType != ErrorMessage)
		[(PTCollectionView *)[self superview] sendMessageForStatus:lBox];
}

- (void)addToFav:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	[(PTCollectionView *)[self superview] markAsFav:lBox];
}

- (void)retweetSelection:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	[(PTCollectionView *)[self superview] retweet:lBox];
}

- (void)deleteSelection:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	[(PTCollectionView *)[self superview] deleteStatus:lBox];
}

- (void)openContextMenu:(NSEvent *)aEvent {
	PTStatusBox *lBox = [fColItem representedObject];
	NSMenu *lMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
	[lMenu insertItemWithTitle:@"Send Reply to This Tweet" action:@selector(sendReply:) keyEquivalent:@"r" atIndex:0];
	[lMenu insertItemWithTitle:@"Send Direct Message to User" action:@selector(sendMessage:) keyEquivalent:@"d" atIndex:1];
	[lMenu insertItemWithTitle:@"Toggle Favorite" action:@selector(addToFav:) keyEquivalent:@"F" atIndex:2];
	[lMenu insertItemWithTitle:@"Retweet Selection" action:@selector(retweetSelection:) keyEquivalent:@"r" atIndex:3];
	[[lMenu itemAtIndex:3] setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
	[lMenu insertItemWithTitle:@"Delete Selection" action:@selector(deleteSelection:) keyEquivalent:@"⌦" atIndex:4];
	if (![lBox.userId isEqualToString:[[PTPreferenceManager sharedSingleton] userName]] && 
		lBox.sType != DirectMessage)
		[[lMenu itemAtIndex:4] setAction:nil];
	[lMenu insertItem:[NSMenuItem separatorItem] atIndex:5];
	[lMenu insertItemWithTitle:@"Open Tweet in Browser" action:@selector(openInBrowser:) keyEquivalent:@"T" atIndex:6];
	if (lBox.sType != NormalMessage && lBox.sType != ReplyMessage) {
		[[lMenu itemAtIndex:2] setAction:nil];
		[[lMenu itemAtIndex:6] setAction:nil];
	}
	[lMenu insertItemWithTitle:@"Open Reply in Browser" action:@selector(openReply:) keyEquivalent:@"p" atIndex:7];
	[[lMenu itemAtIndex:7] setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
	if (lBox.replyId == 0) [[lMenu itemAtIndex:7] setAction:nil];
	[lMenu insertItemWithTitle:@"Open Link in Selected Tweet" action:@selector(openLink:) keyEquivalent:@"l" atIndex:8];
	[[lMenu itemAtIndex:8] setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
	if (!lBox.statusLink) [[lMenu itemAtIndex:8] setAction:nil];
	[lMenu insertItem:[NSMenuItem separatorItem] atIndex:9];
	[lMenu insertItemWithTitle:@"Open User's Twitter Page" action:@selector(openUserPage:) keyEquivalent:@"O" atIndex:10];
	if (lBox.sType == ErrorMessage) {
		[[lMenu itemAtIndex:0] setAction:nil];
		[[lMenu itemAtIndex:1] setAction:nil];
		[[lMenu itemAtIndex:3] setAction:nil];
		[[lMenu itemAtIndex:10] setAction:nil];
	}
	[lMenu insertItemWithTitle:@"Open User's Web Page" action:@selector(openUserWeb:) keyEquivalent:@"K" atIndex:11];
	if (lBox.userHome == nil) [[lMenu itemAtIndex:11] setAction:nil];
	[NSMenu popUpContextMenu:lMenu withEvent:aEvent forView:self];
}

- (void)setColItem:(PTStatusCollectionItem *)aParentCol {
	fColItem = aParentCol;
}

@end
