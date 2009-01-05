//
//  PTMain.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 24/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTMain.h"
#import "PTStatusBoxGenerator.h"


@implementation PTMain

- (void)setupUpdateTimer {
	// stop the old timer
	if (fUpdateTimer) {
		[fUpdateTimer invalidate];
		[fUpdateTimer release];
	}
	// determine the timer delay
	int lIntervalTime;
	switch ([[PTPreferenceManager getInstance] timeInterval]) {
		case 1:
			lIntervalTime = 180;
			break;
		case 2:
			lIntervalTime = 120;
			break;
		case 3:
			lIntervalTime = 90;
			break;
	}
	// create new timer
	fUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:lIntervalTime 
													 target:self 
												   selector:@selector(runUpdateFromTimer:) 
												   userInfo:nil 
													repeats:YES] retain];
}

- (void)runUpdateFromTimer:(NSTimer *)aTimer {
	[self updateTimeline:aTimer];
}

- (void)updateIndicatorAnimation {
	if ([fRequestDetails count] == 0) {
		if ([fProgressBar isHidden]) {
			[fProgressBar startAnimation:self];
			[fProgressBar setHidden:NO];
		} else {
			[fProgressBar stopAnimation:self];
			[fProgressBar setHidden:YES];
		}
	}
}

- (void)runInitialUpdates {
	[self updateIndicatorAnimation];
	[fRequestDetails setObject:@"MESSAGE_UPDATE" 
						forKey: [fTwitterEngine getDirectMessagesSince:nil
														startingAtPage:0]];
	[fRequestDetails setObject:@"INIT_UPDATE" 
						forKey:[fTwitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] userName] 
																since:nil startingAtPage:0 count:50]];
	[fRequestDetails setObject:@"REPLY_UPDATE" 
						forKey:[fTwitterEngine getRepliesStartingAtPage:0]];
}

- (void)setUpTwitterEngine {
	fTwitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[fTwitterEngine setClientName:@"Pwitter" 
						  version:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
							  URL:@"http://github.com/koroshiya1/pwitter/wikis/home" 
							token:@"pwitter"];
	[fTwitterEngine setUsername:[[PTPreferenceManager getInstance] userName] 
					   password:[[PTPreferenceManager getInstance] password]];
	[self runInitialUpdates];
	[self setupUpdateTimer];
}

- (IBAction)changeAccount:(id)sender {
	if (fLastUpdateID) {
		[fLastUpdateID release];
		fLastUpdateID = nil;
	}
	if (fLastMessageID) {
		[fLastMessageID release];
		fLastMessageID = nil;
	}
	[[fStatusController content] removeAllObjects];
	[fTwitterEngine setUsername:[[PTPreferenceManager getInstance] userName] 
					   password:[[PTPreferenceManager getInstance] password]];
	[self runInitialUpdates];
	[self setupUpdateTimer];
}

- (void)awakeFromNib
{
	fUpdateTimer = nil;
	fRequestDetails = [[NSMutableDictionary alloc] init];
	fImageLocationForReq = [[NSMutableDictionary alloc] init];
	fImageReqForLocation = [[NSMutableDictionary alloc] init];
	fStatusBoxesForReq = [[NSMutableDictionary alloc] init];
	fUserImageCache = [[NSMutableDictionary alloc] init];
	fDefaultImage = [NSImage imageNamed:@"default.png"];
}

- (void)dealloc
{
	if (fRequestDetails) [fRequestDetails release];
	if (fImageLocationForReq) [fImageLocationForReq release];
	if (fImageReqForLocation) [fImageReqForLocation release];
	if (fStatusBoxesForReq) [fStatusBoxesForReq release];
	if (fUserImageCache) [fUserImageCache release];
	if (fTwitterEngine) [fTwitterEngine release];
	if (fLastUpdateID) [fLastUpdateID release];
	if (fLastMessageID) [fLastMessageID release];
	if (fUpdateTimer) {
		[fUpdateTimer invalidate];
		[fUpdateTimer release];
	}
	[super dealloc];
}

- (void)requestSucceeded:(NSString *)requestIdentifier
{
	if ([fRequestDetails objectForKey:requestIdentifier] == @"MESSAGE") {
		[fStatusUpdateField setEnabled:YES];
		[fStatusUpdateField setStringValue:@""];
		[fMessageButton setState:NSOffState];
		[fTextLevelIndicator setIntValue:140];
	}
}

- (void)requestFailed:(NSString *)aRequestIdentifier withError:(NSError *)aError
{
	BOOL lIgnoreError = NO;
	NSString *lRequestType = [fRequestDetails objectForKey:aRequestIdentifier];
	if (lRequestType == @"POST" || lRequestType == @"MESSAGE") {
		[fStatusUpdateField setEnabled:YES];
	} else if (lRequestType == @"IMAGE") {
		[fStatusBoxesForReq removeObjectForKey:aRequestIdentifier];
		[fImageReqForLocation removeObjectForKey:[fImageLocationForReq objectForKey:aRequestIdentifier]];
		[fImageLocationForReq removeObjectForKey:aRequestIdentifier];
		lIgnoreError = YES;
	}
	[fRequestDetails removeObjectForKey:aRequestIdentifier];
	[self updateIndicatorAnimation];
	if (!lIgnoreError) {
		PTStatusBox *lErrorBox = [fStatusBoxGenerator constructErrorBox:aError];
		NSLog(@"here");
		[fStatusController addObject:lErrorBox];
		NSLog(@"here2");
		[lErrorBox release];
	}
}

- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox {
	NSImage *lImageData = [fUserImageCache objectForKey:aImageLocation];
	if (!lImageData) {
		if (![fImageReqForLocation objectForKey:aImageLocation]) {
			[self updateIndicatorAnimation];
			NSString *lImageReq = [fTwitterEngine getImageAtURL:aImageLocation];
			[fRequestDetails setObject:@"IMAGE" forKey:lImageReq];
			[fImageReqForLocation setObject:lImageReq forKey:aImageLocation];
			[fImageLocationForReq setObject:aImageLocation forKey:lImageReq];
			[fStatusBoxesForReq setObject:[[[NSMutableArray alloc] init] autorelease] forKey:lImageReq];
		}
		NSMutableArray *lRequestedBoxes = [fStatusBoxesForReq objectForKey:[fImageReqForLocation objectForKey:aImageLocation]];
		[lRequestedBoxes addObject:aNewBox];
		return fDefaultImage;
	} else {
		return lImageData;
	}
}

- (void)statusesReceived:(NSArray *)aStatuses forRequest:(NSString *)aIdentifier
{
	if ([aStatuses count] == 0) {
		if (!fLastUpdateID) fLastUpdateID = [[NSString alloc] initWithString:@"0"];
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self updateIndicatorAnimation];
		return;
	}
	NSDictionary *lCurrentStatus;
	NSDictionary *lLastStatus = nil;
	NSMutableArray *lTempBoxes = [[NSMutableArray alloc] init];
	for (lCurrentStatus in aStatuses) {
		PTStatusBox *lBoxToAdd = nil;
		if ([[lCurrentStatus objectForKey:@"in_reply_to_screen_name"] isEqualToString:[fTwitterEngine username]]) {
			if ([fRequestDetails objectForKey:aIdentifier] != @"INIT_UPDATE")
				lBoxToAdd = [fStatusBoxGenerator constructStatusBox:lCurrentStatus isReply:YES];
		} else lBoxToAdd = [fStatusBoxGenerator constructStatusBox:lCurrentStatus isReply:NO];
		if (lBoxToAdd) {
			[lTempBoxes addObject:lBoxToAdd];
			[lBoxToAdd release];
		}
		if (!lLastStatus) lLastStatus = lCurrentStatus;
	}
	[fStatusController addObjects:lTempBoxes];
	[lTempBoxes release];
	if (fLastUpdateID) {
		if ([fLastUpdateID longLongValue] < [[lLastStatus objectForKey:@"id"] longLongValue]) {
			[fLastUpdateID release];
			fLastUpdateID = [[NSString alloc] initWithString:[lLastStatus objectForKey:@"id"]];
		}
	} else fLastUpdateID = [[NSString alloc] initWithString:[lLastStatus objectForKey:@"id"]];
	if ([fRequestDetails objectForKey:aIdentifier] == @"POST") {
		[fStatusUpdateField setEnabled:YES];
		[fStatusUpdateField setStringValue:@""];
		[fTextLevelIndicator setIntValue:140];
	}
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self updateIndicatorAnimation];
}

- (void)directMessagesReceived:(NSArray *)aMessages forRequest:(NSString *)aIdentifier
{
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self updateIndicatorAnimation];
	if ([aMessages count] == 0) return;
	if ([[[aMessages objectAtIndex:0] objectForKey:@"id"] isEqual: @""]) return;
	NSDictionary *lCurrentDic;
	NSDictionary *lLastDic = nil;
	NSMutableArray *lTempArray = [[NSMutableArray alloc] init];
	for (lCurrentDic in aMessages) {
		PTStatusBox *lBoxToAdd = [fStatusBoxGenerator constructMessageBox:lCurrentDic];
		[lTempArray addObject:lBoxToAdd];
		[lBoxToAdd release];
		if (!lLastDic) lLastDic = lCurrentDic;
	}
	[fStatusController addObjects:lTempArray];
	[lTempArray release];
	if (fLastMessageID) [fLastMessageID release];
	fLastMessageID = [[NSString alloc] initWithString:[lLastDic objectForKey:@"id"]];
}

- (void)userInfoReceived:(NSArray *)aUserInfo forRequest:(NSString *)aIdentifier
{
	// not implemented
}

- (void)miscInfoReceived:(NSArray *)aMiscInfo forRequest:(NSString *)aIdentifier
{
	// not implemented
}

- (void)imageReceived:(NSImage *)aImage forRequest:(NSString *)aIdentifier
{
	PTStatusBox *lCurrentBox;
	for (lCurrentBox in [fStatusBoxesForReq objectForKey:aIdentifier]) {
		lCurrentBox.userImage = aImage;
	}
	NSString *lImageLocation = [fImageLocationForReq objectForKey:aIdentifier];
	[fUserImageCache setObject:aImage forKey:lImageLocation];
	[fStatusBoxesForReq removeObjectForKey:aIdentifier];
	[fImageReqForLocation removeObjectForKey:lImageLocation];
	[fImageLocationForReq removeObjectForKey:aIdentifier];
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self updateIndicatorAnimation];
}

- (IBAction)updateTimeline:(id)sender {
	if (!fLastUpdateID) {
		[self runInitialUpdates];
	} else {
		[self updateIndicatorAnimation];
		[fRequestDetails setObject:@"UPDATE" 
							forKey: [fTwitterEngine getFollowedTimelineFor:[fTwitterEngine username] 
																   sinceID:fLastUpdateID startingAtPage:0 count:100]];
		[fRequestDetails setObject:@"MESSAGE_UPDATE" 
							forKey: [fTwitterEngine getDirectMessagesSinceID:fLastMessageID
															  startingAtPage:0]];
	}
}

- (IBAction)postStatus:(id)sender {
	[self updateIndicatorAnimation];
	NSArray *lSeparated = [[fStatusUpdateField stringValue] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([lSeparated count] >= 2 && [[lSeparated objectAtIndex:0] isEqual:@"d"]) {
		NSString *lMessageTarget;
		NSString *lMessageToSend;
		lMessageTarget = [lSeparated objectAtIndex:1];
		if ([lSeparated count] == 2) {
			lMessageToSend = @"";
		} else {
			if ([lSeparated count] == 3 && [[lSeparated objectAtIndex:2] length] == 0) {
				lMessageToSend = @"";
			} else {
				lMessageToSend = [[fStatusUpdateField stringValue] substringFromIndex:3 + [lMessageTarget length]];
			}
		}
		[fRequestDetails setObject:@"MESSAGE" 
							forKey:[fTwitterEngine sendDirectMessage:lMessageToSend
																  to:lMessageTarget]];
	} else {
		[fRequestDetails setObject:@"POST" 
							forKey:[fTwitterEngine sendUpdate:[fStatusUpdateField stringValue]]];
	}
	[fStatusUpdateField setEnabled:NO];
}

- (void)openTwitterWeb {
	PTStatusBox *lCurrentSelection = [[fStatusController selectedObjects] lastObject];
	if (lCurrentSelection && lCurrentSelection.sType != ErrorMessage)
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", lCurrentSelection.userID]]];
}

- (void)selectStatusBox:(PTStatusBox *)aSelection {
	if (!aSelection) {
		[fWebButton setEnabled:NO];
		[fReplyButton setEnabled:NO];
		[fMessageButton setEnabled:NO];
		return;
	}
	[fReplyButton setState:NSOffState];
	[fMessageButton setState:NSOffState];
	!aSelection.userHome ? [fWebButton setEnabled:NO] : [fWebButton setEnabled:YES];
	if (aSelection.sType == ErrorMessage) {
		[fReplyButton setEnabled:NO];
		[fMessageButton setEnabled:NO];
	} else {
		[fReplyButton setEnabled:YES];
		[fMessageButton setEnabled:YES];
	}
}

@end
