//
//  PTStatusEntityView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTStatusEntityView.h"

@implementation PTStatusEntityView

- (void)setSelected:(BOOL)flag {
	_isSelected = flag;
}

- (BOOL)selected {
	return _isSelected;
}

- (void)forceSelect:(BOOL)flag {
	[colItem setSelected:flag];
}

- (void)setColItem:(PTStatusCollectionItem *)parentCol {
	colItem = parentCol;
}

@end
