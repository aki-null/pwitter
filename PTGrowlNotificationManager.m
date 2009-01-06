//
//  PTGrowlNotificationManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 6/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTGrowlNotificationManager.h"
#import <Growl/GrowlApplicationBridge.h>


@implementation PTGrowlNotificationManager

- (void)awakeFromNib {
	[GrowlApplicationBridge setGrowlDelegate:@""];
}

- (void)postReplyNotification:(PTStatusBox *)aReplyInfo {
	[GrowlApplicationBridge
	 notifyWithTitle:[NSString stringWithFormat:@"Reply from %@", aReplyInfo.userID] 
	 description:[aReplyInfo.statusMessage string] 
	 notificationName:@"PTReplyReceived" 
	 iconData:[aReplyInfo.userImage TIFFRepresentation] 
	 priority:0 
	 isSticky:NO 
	 clickContext:nil];
}

- (void)postMessageNotification:(PTStatusBox *)aReplyInfo {
	[GrowlApplicationBridge
	 notifyWithTitle:[NSString stringWithFormat:@"Message from %@", aReplyInfo.userID] 
	 description:[aReplyInfo.statusMessage string] 
	 notificationName:@"PTMessageReceived" 
	 iconData:[aReplyInfo.userImage TIFFRepresentation] 
	 priority:1 
	 isSticky:NO 
	 clickContext:nil];
}

@end
