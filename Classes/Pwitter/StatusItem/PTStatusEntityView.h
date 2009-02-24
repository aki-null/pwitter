//
//  PTStatusEntityView.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTStatusCollectionItem.h"


@interface PTStatusEntityView : NSBox {
	BOOL fIsSelected;
	PTStatusCollectionItem *fColItem;
}
- (void)setSelected:(BOOL)aFlag;
- (BOOL)selected;
- (void)setColItem:(PTStatusCollectionItem *)aParentCol;
- (void)openInBrowser:(id)sender;
- (void)openUserPage:(id)sender;
- (void)openUserWeb:(id)sender;
- (void)openReply:(id)sender;
- (void)openLink:(id)sender;
- (void)sendReply:(id)sender;
- (void)sendMessage:(id)sender;
- (void)openContextMenu:(NSEvent *)aEvent;

@end