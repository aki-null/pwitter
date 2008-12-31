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
	BOOL _isSelected;
	PTStatusCollectionItem *colItem;
}
- (void)setSelected:(BOOL)flag;
- (BOOL)selected;
- (void)forceSelect:(BOOL)flag;
- (void)setColItem:(PTStatusCollectionItem *)parentCol;

@end