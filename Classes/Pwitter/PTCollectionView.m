//
//  PTCollectionView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 13/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTCollectionView.h"
#import "PTMainActionHandler.h"
#import "PTMain.h"


@implementation PTCollectionView

- (void)sendReplyForStatus:(PTStatusBox *)aBox {
	[fMainActionHandler replyToStatus:aBox];
}

- (void)sendMessageForStatus:(PTStatusBox *)aBox {
	[fMainActionHandler messageToStatus:aBox];
}

- (void)markAsFav:(PTStatusBox *)aBox {
	[fMainController favStatus:aBox];
}

- (void)deleteStatus:(PTStatusBox *)aBox {
	[fMainController deleteTweet:aBox];
}

- (void)retweet:(PTStatusBox *)aBox {
	[fMainActionHandler retweetStatus:aBox];
}

- (void)fixFocus {
	[fMainWindow makeFirstResponder:self];
}

@end
