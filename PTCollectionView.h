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
    IBOutlet id fMainWindow;
}

- (void)sendReplyForStatus:(PTStatusBox *)aBox;
- (void)sendMessageForStatus:(PTStatusBox *)aBox;
- (void)markAsFav:(PTStatusBox *)aBox;
- (void)disableAnimation;
- (void)fixFocus;

@end
