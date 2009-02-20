//
//  PTStatusCollectionItem.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusCollectionItem.h"
#import "PTStatusEntityView.h"
#import "PTStatusBox.h"
#import "PTStatusTextField.h"


@implementation PTStatusCollectionItem

- (void)setSelected:(BOOL)aFlag {
	[super setSelected:aFlag];
	PTStatusEntityView* theView = (PTStatusEntityView* )[self view];
	if([theView isKindOfClass:[PTStatusEntityView class]]) {
		[theView setSelected:aFlag];
		[theView setNeedsDisplay:YES];
	}
}

- (void)setView:(NSView *)aView {
	[(PTStatusEntityView *)aView setColItem:self];
	[super setView:aView];
}

@end
