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

#define STATUS_LIMIT 200
	

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
		case 4:
			lIntervalTime = 60;
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

- (void)playSoundEffect {
	switch (fCurrentSoundStatus) {
		case StatusReceived:
			[fStatusReceived play];
			break;
		case ReplyOrMessageReceived:
			[fReplyReceived play];
			break;
	}
	fCurrentSoundStatus = NoneReceived;
}

- (void)sortArray:(NSMutableArray *)aArray {
	NSSortDescriptor *lSortDesc = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	NSMutableArray *lTempDescArray = [NSMutableArray array];
	[lTempDescArray addObject:lSortDesc];
	[lSortDesc release];
	[aArray sortUsingDescriptors:lTempDescArray];
}

- (void)postGrowlNotifications {
	[self sortArray:fBoxesToNotify];
	[fNotificationMan postNotifications:fBoxesToNotify 
						   defaultImage:fDefaultImage];
	[fBoxesToNotify removeAllObjects];
}

- (void)addNewStatusBoxes {
	[self sortArray:fBoxesToAdd];
	[fStatusController addObjects:fBoxesToAdd];
	[fBoxesToAdd removeAllObjects];
}

- (void)updateSessionStatus {
	if ([fRequestDetails count] == 0) {
		if ([fProgressBar isHidden]) {
			[fProgressBar startAnimation:self];
			[fProgressBar setHidden:NO];
			[fUpdateButton setEnabled:NO];
		} else {
			[fProgressBar stopAnimation:self];
			[fProgressBar setHidden:YES];
			[fUpdateButton setEnabled:YES];
			[self addNewStatusBoxes];
			// limit the number of status boxes
			int lStatusCount = [[fStatusController content] count] + 1;
			if (lStatusCount > STATUS_LIMIT) {
				NSRange lDeletionRange = NSMakeRange(STATUS_LIMIT - 1, lStatusCount - STATUS_LIMIT);
				NSIndexSet *lToDelete = [NSIndexSet indexSetWithIndexesInRange:lDeletionRange];
				[fStatusController removeObjectsAtArrangedObjectIndexes:lToDelete];
			}
			[self postGrowlNotifications];
			[self playSoundEffect];
		}
	}
}

- (void)runMessageUpdateFromTimer:(NSTimer *)aTimer {
	[self updateSessionStatus];
	[fRequestDetails setObject:@"MESSAGE_UPDATE" 
						forKey:[fTwitterEngine getDirectMessagesSinceID:[fLastMessageID  stringValue] 
														 startingAtPage:0]];
}

- (void)runUpdateFromTimer:(NSTimer *)aTimer {
	[self updateTimeline:self];
}

- (void)runInitialUpdates {
	[self updateSessionStatus];
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

- (void)initTransaction {
	fRequestDetails = [[NSMutableDictionary alloc] init];
	fImageLocationForReq = [[NSMutableDictionary alloc] init];
	fImageReqForLocation = [[NSMutableDictionary alloc] init];
	fStatusBoxesForReq = [[NSMutableDictionary alloc] init];
	fUserImageCache = [[NSMutableDictionary alloc] init];
	fIgnoreUpdate = [[NSMutableDictionary alloc] init];
	fBoxesToNotify = [[NSMutableArray alloc] init];
	fBoxesToAdd = [[NSMutableArray alloc] init];
}

- (void)deallocTransaction {
	if (fRequestDetails) [fRequestDetails release];
	if (fImageLocationForReq) [fImageLocationForReq release];
	if (fImageReqForLocation) [fImageReqForLocation release];
	if (fStatusBoxesForReq) [fStatusBoxesForReq release];
	if (fUserImageCache) [fUserImageCache release];
	if (fIgnoreUpdate) [fIgnoreUpdate release];
	if (fBoxesToNotify) [fBoxesToNotify release];
	if (fBoxesToAdd) [fBoxesToAdd release];
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
	[self setupUpdateTimer];
	[self setupMessageUpdateTimer];
	[fTwitterEngine closeAllConnections];
	[self deallocTransaction];
	[self initTransaction];
	[fProgressBar stopAnimation:self];
	[fProgressBar setHidden:YES];
	[fUpdateButton setEnabled:YES];
	[self runInitialUpdates];
}

- (void)awakeFromNib
{
	[self initTransaction];
	fDefaultImage = [NSImage imageNamed:@"default.png"];
	fStatusReceived = [NSSound soundNamed:@"statusReceived"];
	fReplyReceived = [NSSound soundNamed:@"replyReceived"];
}

- (void)dealloc
{
	[self deallocTransaction];
	if (fTwitterEngine) [fTwitterEngine release];
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

- (void)postComplete {
	[fStatusUpdateField setEnabled:YES];
	[fStatusUpdateField setStringValue:@""];
	[fTextLevelIndicator setIntValue:140];
}

- (void)requestSucceeded:(NSString *)requestIdentifier
{
	if ([fRequestDetails objectForKey:requestIdentifier] == @"MESSAGE") {
		[self postComplete];
	}
}

- (void)requestFailed:(NSString *)aRequestIdentifier withError:(NSError *)aError
{
	BOOL lIgnoreError = [[PTPreferenceManager getInstance] ignoreErrors];
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
	[self updateSessionStatus];
	if (!lIgnoreError) {
		PTStatusBox *lErrorBox = [fStatusBoxGenerator constructErrorBox:aError];
		[fBoxesToAdd addObject:lErrorBox];
	}
}

- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox {
	NSImage *lImageData = [fUserImageCache objectForKey:aImageLocation];
	if (!lImageData) {
		if (![fImageReqForLocation objectForKey:aImageLocation]) {
			[self updateSessionStatus];
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

- (void)updateLastUpdateID:(NSNumber *)aLastUpdateID {
	if (fLastUpdateID) {
		if ([fLastUpdateID longLongValue] < [aLastUpdateID longLongValue]) {
			[fLastUpdateID release];
			fLastUpdateID = [aLastUpdateID copy];
		}
	} else fLastUpdateID = [aLastUpdateID copy];
}

- (void)updateLastReplyID:(NSString *)aLastReplyID {
	if (fLastReplyID) {
		if ([fLastReplyID longLongValue] < [aLastReplyID longLongValue]) {
			[fLastReplyID release];
			fLastReplyID = [aLastReplyID copy];
		}
	} else fLastReplyID = [aLastReplyID copy];
}

- (void)statusesReceived:(NSArray *)aStatuses forRequest:(NSString *)aIdentifier
{
	if ([aStatuses count] == 0) {
		if (!fLastUpdateID) fLastUpdateID = [[NSNumber alloc] initWithLongLong:0];
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self updateSessionStatus];
		return;
	}
	NSDictionary *lCurrentStatus;
	NSDictionary *lLastStatus = nil;
	NSMutableArray *lTempBoxes = [[NSMutableArray alloc] init];
	NSString *lUpdateType = [fRequestDetails objectForKey:aIdentifier];
	for (lCurrentStatus in aStatuses) {
		if ([fIgnoreUpdate objectForKey:[lCurrentStatus objectForKey:@"id"]] != @"IGNORE") {
			int lDecision = 0;
			if ([[lCurrentStatus objectForKey:@"in_reply_to_screen_name"] isEqualToString:[fTwitterEngine username]]) {
				if (lUpdateType == @"REPLY_UPDATE" || 
					lUpdateType == @"INIT_REPLY_UPDATE" || 
					lUpdateType == @"POST" || 
					![[PTPreferenceManager getInstance] receiveFromNonFollowers]) {
					lDecision = 1;
				}
			} else lDecision = 2;
			if (lDecision != 0) {
				PTStatusBox *lBoxToAdd = nil;
				lBoxToAdd = [fStatusBoxGenerator constructStatusBox:lCurrentStatus 
															isReply:lDecision == 1];
				if (lDecision == 1 && fCurrentSoundStatus != ErrorReceived)
					fCurrentSoundStatus = ReplyOrMessageReceived;
				[lTempBoxes addObject:lBoxToAdd];
			}
		}
		if (!lLastStatus) lLastStatus = lCurrentStatus;
	}
	if (fCurrentSoundStatus == NoneReceived && 
		[lTempBoxes count] != 0)
		fCurrentSoundStatus = StatusReceived;
	if (![NSApp isActive] && 
		(lUpdateType == @"UPDATE" || lUpdateType == @"REPLY_UPDATE")) {
		[fBoxesToNotify addObjectsFromArray:lTempBoxes];
	}
	[fBoxesToAdd addObjectsFromArray:lTempBoxes];
	[lTempBoxes release];
	if (lUpdateType == @"POST") {
		[fIgnoreUpdate setObject:@"IGNORE" forKey:[[aStatuses lastObject] objectForKey:@"id"]];
		[self postComplete];
	} else if (lUpdateType == @"REPLY_UPDATE" || lUpdateType == @"INIT_REPLY_UPDATE") {
		[self updateLastReplyID:[lLastStatus objectForKey:@"id"]];
	} else {
		[self updateLastUpdateID:[lLastStatus objectForKey:@"id"]];
	}
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self updateSessionStatus];
}

- (void)directMessagesReceived:(NSArray *)aMessages forRequest:(NSString *)aIdentifier
{
	if ([aMessages count] == 0) {
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self updateSessionStatus];
		return;
	}
	if ([[[aMessages objectAtIndex:0] objectForKey:@"id"] longLongValue] == 0) {
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self updateSessionStatus];
		return;
	}
	NSDictionary *lCurrentDic;
	NSDictionary *lLastDic = nil;
	NSMutableArray *lTempArray = [[NSMutableArray alloc] init];
	for (lCurrentDic in aMessages) {
		PTStatusBox *lBoxToAdd = [fStatusBoxGenerator constructMessageBox:lCurrentDic];
		[lTempArray addObject:lBoxToAdd];
		if (!lLastDic) lLastDic = lCurrentDic;
	}
	if ([fRequestDetails objectForKey:aIdentifier] != @"INIT_MESSAGE_UPDATE" &&
		![NSApp isActive]) {
		[fBoxesToNotify addObjectsFromArray:lTempArray];
	}
	[fBoxesToAdd addObjectsFromArray:lTempArray];
	[lTempArray release];
	if (fLastMessageID) [fLastMessageID release];
	fLastMessageID = [[lLastDic objectForKey:@"id"] copy];
	[fRequestDetails removeObjectForKey:aIdentifier];
	fCurrentSoundStatus = ReplyOrMessageReceived;
	[self updateSessionStatus];
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
	[self updateSessionStatus];
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
		[self updateSessionStatus];
		[fRequestDetails setObject:@"UPDATE" 
							forKey:[fTwitterEngine getFollowedTimelineFor:[fTwitterEngine username] 
																  sinceID:[fLastUpdateID stringValue] startingAtPage:0 count:50]];
		if ([[PTPreferenceManager getInstance] receiveFromNonFollowers])
			[fRequestDetails setObject:@"REPLY_UPDATE" 
								forKey:[fTwitterEngine getRepliesSinceID:0 sinceID:[fLastReplyID stringValue]]];
		if (sender != self)
			[fRequestDetails setObject:@"MESSAGE_UPDATE" 
								forKey:[fTwitterEngine getDirectMessagesSinceID:[fLastMessageID  stringValue]
																 startingAtPage:0]];
	}
}

- (void)makePost:(NSString *)aMessage {
	[self updateSessionStatus];
	NSArray *lSeparated = [aMessage componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
				lMessageToSend = [aMessage substringFromIndex:3 + [lMessageTarget length]];
			}
		}
		[fRequestDetails setObject:@"MESSAGE" 
							forKey:[fTwitterEngine sendDirectMessage:lMessageToSend 
																  to:lMessageTarget]];
	} else {
		[fRequestDetails setObject:@"POST" 
							forKey:[fTwitterEngine sendUpdate:aMessage]];
	}
	[fStatusUpdateField setEnabled:NO];
}

- (IBAction)postStatus:(id)sender {
	[self makePost:[fStatusUpdateField stringValue]];
}

- (void)openTwitterWeb {
	PTStatusBox *lCurrentSelection = [[fStatusController selectedObjects] lastObject];
	if (lCurrentSelection && lCurrentSelection.sType != ErrorMessage)
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", lCurrentSelection.userID]]];
}

@end
