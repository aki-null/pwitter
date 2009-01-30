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
@synthesize userID;
@synthesize entityColor;
@synthesize time;
@synthesize strTime;
@synthesize searchString;
@synthesize sType;

- (void)dealloc {
	if (userImage) [userImage release];
	if (userName) [userName release];
	if (statusMessage) [statusMessage release];
	if (userHome) [userHome release];
	if (userID) [userID release];
	if (entityColor) [entityColor release];
	if (time) [time release];
	if (strTime) [strTime release];
	if (searchString) [searchString release];
	[super dealloc];
}

@end
