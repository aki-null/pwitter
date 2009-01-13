//
//  PTMain.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 24/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTMain.h"
#import "PTStatusBoxGenerator.h"
#import "PTGrowlNotificationManager.h"


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
			lIntervalTime = 300;
			break;
		case 2:
			lIntervalTime = 180;
			break;
		case 3:
			lIntervalTime = 120;
			break;
	}
	// create new timer
	fUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:lIntervalTime 
													 target:self 
												   selector:@selector(runUpdateFromTimer:) 
												   userInfo:nil 
													repeats:YES] retain];
}

- (void)setupMessageUpdateTimer {
	// stop the old timer
	if (fMessageUpdateTimer) {
		[fMessageUpdateTimer invalidate];
		[fMessageUpdateTimer release];
	}
	// determine the timer delay
	int lIntervalTime;
	switch ([[PTPreferenceManager getInstance] timeInterval]) {
		case 1:
			lIntervalTime = 900;
			break;
		case 2:
			lIntervalTime = 600;
			break;
		case 3:
			lIntervalTime = 300;
			break;
	}
	// create new timer
	fMessageUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:lIntervalTime 
															target:self 
														  selector:@selector(runMessageUpdateFromTimer:) 
														  userInfo:nil 
														   repeats:YES] retain];
}

- (void)updateIndicatorAnimation {
	if ([fRequestDetails count] == 0) {
		if ([fProgressBar isHidden]) {
			[fProgressBar startAnimation:self];
			[fProgressBar setHidden:NO];
			[fUpdateButton setEnabled:NO];
		} else {
			[fProgressBar stopAnimation:self];
			[fProgressBar setHidden:YES];
			[fUpdateButton setEnabled:YES];
		}
	}
}

- (void)runMessageUpdateFromTimer:(NSTimer *)aTimer {
	[self updateIndicatorAnimation];
	[fRequestDetails setObject:@"MESSAGE_UPDATE" 
						forKey:[fTwitterEngine getDirectMessagesSinceID:fLastMessageID 
														 startingAtPage:0]];
}

- (void)runUpdateFromTimer:(NSTimer *)aTimer {
	[self updateTimeline:self];
}

- (void)runInitialUpdates {
	[self updateIndicatorAnimation];
	[fRequestDetails setObject:@"INIT_MESSAGE_UPDATE" 
						forKey:[fTwitterEngine getDirectMessagesSince:nil
													   startingAtPage:0]];
	[fRequestDetails setObject:@"INIT_UPDATE" 
						forKey:[fTwitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] userName] 
																since:nil startingAtPage:0 count:50]];
	if ([[PTPreferenceManager getInstance] receiveFromNonFollowers]) {
		[fRequestDetails setObject:@"INIT_REPLY_UPDATE" 
							forKey:[fTwitterEngine getRepliesStartingAtPage:0]];
	}
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
	[self setupMessageUpdateTimer];
}

- (IBAction)changeAccount:(id)sender {
	fLastReplyID = 0;
	if (fLastUpdateID) {
		[fLastUpdateID release];
		fLastUpdateID = nil;
	}
	if (fLastMessageID) {
		[fLastMessageID release];
		fLastMessageID = nil;
	}
	[[fStatusController content] removeAllObjects];
	[fStatusController rearrangeObjects];
	[fTwitterEngine setUsername:[[PTPreferenceManager getInstance] userName] 
					   password:[[PTPreferenceManager getInstance] password]];
	[self runInitialUpdates];
	[self setupUpdateTimer];
	[self setupMessageUpdateTimer];
}

- (void)awakeFromNib
{
	fUpdateTimer = nil;
	fRequestDetails = [[NSMutableDictionary alloc] init];
	fImageLocationForReq = [[NSMutableDictionary alloc] init];
	fImageReqForLocation = [[NSMutableDictionary alloc] init];
	fStatusBoxesForReq = [[NSMutableDictionary alloc] init];
	fUserImageCache = [[NSMutableDictionary alloc] init];
	fIgnoreUpdate = [[NSMutableDictionary alloc] init];
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
	if (fIgnoreUpdate) [fIgnoreUpdate release];
	if (fUpdateTimer) {
		[fUpdateTimer invalidate];
		[fUpdateTimer release];
	}
	if (fMessageUpdateTimer) {
		[fMessageUpdateTimer invalidate];
		[fMessageUpdateTimer release];
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
		[fStatusController addObject:lErrorBox];
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
	long long int lLastReplyID = 0;
	for (lCurrentStatus in aStatuses) {
		if ([fIgnoreUpdate objectForKey:[lCurrentStatus objectForKey:@"id"]] != @"IGNORE") {
			int lDecision = 0;
			NSString *lUpdateType = [fRequestDetails objectForKey:aIdentifier];
			if ([[lCurrentStatus objectForKey:@"in_reply_to_screen_name"] isEqualToString:[fTwitterEngine username]]) {
				if (lUpdateType == @"REPLY_UPDATE" || 
					lUpdateType == @"INIT_REPLY_UPDATE" || 
					lUpdateType == @"POST") {
					long long int lCurrentUpdateID = [[lCurrentStatus objectForKey:@"id"] longLongValue];
					if (fLastReplyID != 0 && lCurrentUpdateID > fLastReplyID || fLastReplyID == 0) {
						lDecision = 1;
						if (lLastReplyID < lCurrentUpdateID) lLastReplyID = lCurrentUpdateID;
					}
				} else if (![[PTPreferenceManager getInstance] receiveFromNonFollowers])
					lDecision = 1;
			} else lDecision = 2;
			if (lDecision != 0) {
				PTStatusBox *lBoxToAdd = nil;
				lBoxToAdd = [fStatusBoxGenerator constructStatusBox:lCurrentStatus 
															isReply:lDecision == 1];
				if (lDecision == 1 && lUpdateType != @"INIT_REPLY_UPDATE")
					[fNotificationMan postReplyNotification:lBoxToAdd];
				[lTempBoxes addObject:lBoxToAdd];
				[lBoxToAdd release];
			}
		} else {
			[fIgnoreUpdate removeObjectForKey:[lCurrentStatus objectForKey:@"id"]];
		}
		if (!lLastStatus) lLastStatus = lCurrentStatus;
	}
	if (lLastReplyID != 0) fLastReplyID = lLastReplyID;
	[fStatusController addObjects:lTempBoxes];
	[lTempBoxes release];
	if ([fRequestDetails objectForKey:aIdentifier] == @"POST") {
		[fIgnoreUpdate setObject:@"IGNORE" forKey:[[aStatuses lastObject] objectForKey:@"id"]];
		[fStatusUpdateField setEnabled:YES];
		[fStatusUpdateField setStringValue:@""];
		[fTextLevelIndicator setIntValue:140];
	} else {
		if (fLastUpdateID) {
			if ([fLastUpdateID longLongValue] < [[lLastStatus objectForKey:@"id"] longLongValue]) {
				[fLastUpdateID release];
				fLastUpdateID = [[NSString alloc] initWithString:[lLastStatus objectForKey:@"id"]];
			}
		} else fLastUpdateID = [[NSString alloc] initWithString:[lLastStatus objectForKey:@"id"]];
	}
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self updateIndicatorAnimation];
}

- (void)directMessagesReceived:(NSArray *)aMessages forRequest:(NSString *)aIdentifier
{
	if ([aMessages count] == 0) {
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self updateIndicatorAnimation];
		return;
	}
	if ([[[aMessages objectAtIndex:0] objectForKey:@"id"] isEqual:@""]) {
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self updateIndicatorAnimation];
		return;
	}
	NSDictionary *lCurrentDic;
	NSDictionary *lLastDic = nil;
	NSMutableArray *lTempArray = [[NSMutableArray alloc] init];
	for (lCurrentDic in aMessages) {
		PTStatusBox *lBoxToAdd = [fStatusBoxGenerator constructMessageBox:lCurrentDic];
		if ([fRequestDetails objectForKey:aIdentifier] != @"INIT_MESSAGE_UPDATE")
			[fNotificationMan postMessageNotification:lBoxToAdd];
		[lTempArray addObject:lBoxToAdd];
		[lBoxToAdd release];
		if (!lLastDic) lLastDic = lCurrentDic;
	}
	[fStatusController addObjects:lTempArray];
	[lTempArray release];
	if (fLastMessageID) [fLastMessageID release];
	fLastMessageID = [[NSString alloc] initWithString:[lLastDic objectForKey:@"id"]];
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self updateIndicatorAnimation];
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
	// sender is self when this method is provoked by the timer
	if (sender != self) {
		[self setupUpdateTimer];
		[self setupMessageUpdateTimer];
	}
	if (!fLastUpdateID) {
		[self runInitialUpdates];
	} else {
		[self updateIndicatorAnimation];
		[fRequestDetails setObject:@"UPDATE" 
							forKey:[fTwitterEngine getFollowedTimelineFor:[fTwitterEngine username] 
																  sinceID:fLastUpdateID startingAtPage:0 count:100]];
		if ([[PTPreferenceManager getInstance] receiveFromNonFollowers])
			[fRequestDetails setObject:@"REPLY_UPDATE" 
								forKey:[fTwitterEngine getRepliesStartingAtPage:0]];
		if (sender != self)
			[fRequestDetails setObject:@"MESSAGE_UPDATE" 
								forKey:[fTwitterEngine getDirectMessagesSinceID:fLastMessageID 
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

@end
