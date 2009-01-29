//
//  PTGrowlNotificationManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 6/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTGrowlNotificationManager.h"
#import "PTPreferenceManager.h"
#import <Growl/GrowlApplicationBridge.h>


@implementation PTGrowlNotificationManager

- (void)awakeFromNib {
	[GrowlApplicationBridge setGrowlDelegate:@""];
}

- (void)postReplyNotification:(PTStatusBox *)aReplyInfo {
	[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"Reply from %@", aReplyInfo.userID] 
								description:[aReplyInfo.statusMessage string] 
						   notificationName:@"PTReplyReceived" 
								   iconData:[aReplyInfo.userImage TIFFRepresentation] 
								   priority:1 
								   isSticky:NO 
							   clickContext:nil];
}

- (void)postMessageNotification:(PTStatusBox *)aReplyInfo {
	[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"Message from %@", aReplyInfo.userID] 
								description:[aReplyInfo.statusMessage string] 
						   notificationName:@"PTMessageReceived" 
								   iconData:[aReplyInfo.userImage TIFFRepresentation] 
								   priority:1 
								   isSticky:NO 
							   clickContext:nil];
}

- (void)postNormalNotification:(PTStatusBox *)aStatusInfo {
	[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"%@", aStatusInfo.userID] 
								description:[aStatusInfo.statusMessage string] 
						   notificationName:@"PTStatusReceived" 
								   iconData:[aStatusInfo.userImage TIFFRepresentation] 
								   priority:0
								   isSticky:NO 
							   clickContext:nil];
}

- (void)postGeneralNotification:(NSString *)aTitle 
						message:(NSString *)aMessage 
					  userImage:(NSImage *)aImage {
	[GrowlApplicationBridge notifyWithTitle:aTitle 
								description:aMessage 
						   notificationName:@"PTMiscReceived" 
								   iconData:[aImage TIFFRepresentation] 
								   priority:0
								   isSticky:NO 
							   clickContext:nil];
}

- (NSArray *)filterNotifications:(NSArray *)aBoxes {
	if ([[PTPreferenceManager getInstance] disableGrowl])
		return nil;
	PTStatusBox *lCurrentBox;
	NSMutableArray *lFilteredBoxes = [[NSMutableArray alloc] init];
	for (lCurrentBox in aBoxes) {
		switch (lCurrentBox.sType) {
			case DirectMessage:
				if (![[PTPreferenceManager getInstance] disableMessageNotification])
					[lFilteredBoxes addObject:lCurrentBox];
				break;
			case ReplyMessage:
				if (![[PTPreferenceManager getInstance] disableReplyNotification])
					[lFilteredBoxes addObject:lCurrentBox];
				break;
			case NormalMessage:
				if (![[PTPreferenceManager getInstance] disableStatusNotification])
					[lFilteredBoxes addObject:lCurrentBox];
				break;
			case ErrorMessage:
				if (![[PTPreferenceManager getInstance] disableErrorNotification])
					[lFilteredBoxes addObject:lCurrentBox];
				break;
			default:
				break;
		}
	}
	return [lFilteredBoxes autorelease];
}

- (void)postNotifications:(NSArray *)aBoxes defaultImage:(NSImage *)aImage {
	NSArray *lFilteredBoxes = [self filterNotifications:aBoxes];
	if (!lFilteredBoxes) return;
	PTStatusBox *lCurrentBox;
	int i = 0;
	NSMutableArray *lSenderList = [NSMutableArray array];
	BOOL lOverLimit = NO;
	for (lCurrentBox in lFilteredBoxes) {
		i++;
		if (i > 10) {
			lOverLimit = YES;
			if (![lSenderList containsObject:lCurrentBox.userID])
				[lSenderList addObject:lCurrentBox.userID];
		} else {
			switch (lCurrentBox.sType) {
				case DirectMessage:
					[self postMessageNotification:lCurrentBox];
					break;
				case ReplyMessage:
					[self postReplyNotification:lCurrentBox];
					break;
				case NormalMessage:
					[self postNormalNotification:lCurrentBox];
					break;
				case ErrorMessage:
					[self postNormalNotification:lCurrentBox];
					break;
				default:
					break;
			}
		}
	}
	NSMutableString *lFromList = [NSMutableString string];
	NSString *lCurrentString;
	for (lCurrentString in lSenderList) {
		if (lCurrentString != [lSenderList lastObject])
			[lFromList appendString:[NSString stringWithFormat:@"%@, ", lCurrentString]];
		else
			[lFromList appendString:[NSString stringWithFormat:@"%@", lCurrentString]];
	}
	if (lOverLimit) {
		[self postGeneralNotification:[NSString stringWithFormat:@"%d more tweets from", [lFilteredBoxes count] - 10] 
							  message:lFromList 
							userImage:aImage];
	}
}

@end
