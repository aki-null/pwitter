//
//  PTStatusCollectionItem.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCollectionViewItem.h"


@interface PTStatusCollectionItem : AMCollectionViewItem {
    IBOutlet id fEntityColor;
    IBOutlet id fIconView;
    IBOutlet id fStatusMessage;
    IBOutlet id fTime;
    IBOutlet id fUnreadStatus;
    IBOutlet id fUserId;
	float fOldWidth;
	NSSize fCachedSize;
	// for mini-view
	BOOL fIsOpen;
}
- (void)setSelected:(BOOL)aFlag;

@end
