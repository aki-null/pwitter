//
//  PTStatusEntityView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusEntityView.h"

@implementation PTStatusEntityView

- (void)setSelected:(BOOL)aFlag {
	fIsSelected = aFlag;
}

- (BOOL)selected {
	return fIsSelected;
}

- (void)forceSelect:(BOOL)aFlag {
	[fColItem setSelected:aFlag];
}

- (void)setColItem:(PTStatusCollectionItem *)aParentCol {
	fColItem = aParentCol;
}

@end
