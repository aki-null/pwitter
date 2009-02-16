//
//  PTCollectionView.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 13/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTStatusBox.h"


@interface PTCollectionView : NSCollectionView {
    IBOutlet id fMainActionHandler;
    IBOutlet id fMainController;
}

- (void)sendReplyForStatus:(PTStatusBox *)aBox;
- (void)sendMessageForStatus:(PTStatusBox *)aBox;
- (void)disableAnimation;

@end
