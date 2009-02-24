//
//  PTStatusBox.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 25/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusBox.h"


@implementation PTStatusBox

@synthesize userName;
@synthesize statusMessage;
@synthesize userImage;
@synthesize userHome;
@synthesize statusLink;
@synthesize userId;
@synthesize entityColor;
@synthesize time;
@synthesize searchString;
@synthesize sType;
@synthesize updateId;
@synthesize replyId;
@synthesize replyUserId;
@synthesize readFlag;
@synthesize fav;

- (void)dealloc {
	if (userImage) [userImage release];
	if (userName) [userName release];
	if (statusMessage) [statusMessage release];
	if (userHome) [userHome release];
	if (statusLink) [statusLink release];
	if (userId) [userId release];
	if (entityColor) [entityColor release];
	if (time) [time release];
	if (searchString) [searchString release];
	if (replyUserId) [replyUserId release];
	[super dealloc];
}

@end
