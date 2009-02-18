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

@implementation PTStatusEntityView

- (void)setSelected:(BOOL)aFlag {
	fIsSelected = aFlag;
}

- (BOOL)selected {
	return fIsSelected;
}

- (void)forceSelect:(BOOL)aFlag {
	[fColItem setSelected:aFlag];
	[(PTCollectionView *)[self superview] fixFocus];
}

- (void)openInBrowser:(id)sender {
	PTStatusBox *lBox = [fColItem representedObject];
	if (lBox.updateId != 0) {
		NSString *lUrlString = [NSString stringWithFormat:@"http://twitter.com/%@/status/%d", lBox.userId, lBox.updateId];
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
	NSString *lUrlString = [NSString stringWithFormat:@"http://twitter.com/%@/status/%d", lBox.replyUserId, lBox.replyId];
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

- (void)openContextMenu:(NSEvent *)aEvent {
	[(PTCollectionView *)[self superview] disableAnimation];
	PTStatusBox *lBox = [fColItem representedObject];
	NSMenu *lMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
	[lMenu insertItemWithTitle:@"Send Reply" action:@selector(sendReply:) keyEquivalent:@"r" atIndex:0];
	[lMenu insertItemWithTitle:@"Send Message" action:@selector(sendMessage:) keyEquivalent:@"d" atIndex:1];
	[lMenu insertItemWithTitle:@"Add to Favorite" action:@selector(addToFav:) keyEquivalent:@"f" atIndex:2];
	[lMenu insertItem:[NSMenuItem separatorItem] atIndex:3];
	[lMenu insertItemWithTitle:@"Open Tweet in Browser" action:@selector(openInBrowser:) keyEquivalent:@"b" atIndex:4];
	if (lBox.sType != NormalMessage && lBox.sType != ReplyMessage)
	{
		[[lMenu itemAtIndex:2] setTarget:[self superview]];
		[[lMenu itemAtIndex:4] setTarget:[self superview]];
	}
	[lMenu insertItemWithTitle:@"Open Reply in Browser" action:@selector(openReply:) keyEquivalent:@"t" atIndex:5];
	if (lBox.replyId == 0) [[lMenu itemAtIndex:5] setTarget:[self superview]];
	[lMenu insertItemWithTitle:@"Open Link in Browser" action:@selector(openLink:) keyEquivalent:@"l" atIndex:6];
	if (!lBox.statusLink) [[lMenu itemAtIndex:6] setTarget:[self superview]];
	[lMenu insertItem:[NSMenuItem separatorItem] atIndex:7];
	[lMenu insertItemWithTitle:@"Open User's Twitter Home" action:@selector(openUserPage:) keyEquivalent:@"h" atIndex:8];
	if (lBox.sType == ErrorMessage) {
		[[lMenu itemAtIndex:0] setTarget:[self superview]];
		[[lMenu itemAtIndex:1] setTarget:[self superview]];
		[[lMenu itemAtIndex:8] setTarget:[self superview]];
	}
	[lMenu insertItemWithTitle:@"Open User's Website" action:@selector(openUserWeb:) keyEquivalent:@"w" atIndex:9];
	if (lBox.userHome == nil) [[lMenu itemAtIndex:9] setTarget:[self superview]];
	[NSMenu popUpContextMenu:lMenu withEvent:aEvent forView:self];
}

- (void)setColItem:(PTStatusCollectionItem *)aParentCol {
	fColItem = aParentCol;
}

@end
