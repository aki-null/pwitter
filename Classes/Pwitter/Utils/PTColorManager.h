//
//  PTColorManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/03/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTColorManager : NSObject {
	NSColor *fTweetColor;
	NSColor *fReplyColor;
	NSColor *fMessageColor;
	NSColor *fFavoriteColor;
	NSColor *fErrorColor;
}

+ (PTColorManager *)sharedSingleton;
- (NSColor *)tweetColor;
- (NSColor *)replyColor;
- (NSColor *)messageColor;
- (NSColor *)favoriteColor;
- (NSColor *)errorColor;

@end
