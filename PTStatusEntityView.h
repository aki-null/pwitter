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
- (void)forceSelect:(BOOL)aFlag;
- (void)setColItem:(PTStatusCollectionItem *)aParentCol;

@end