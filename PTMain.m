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
#import "PTMainActionHandler.h"

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
	switch ([[PTPreferenceManager getInstance] messageInterval]) {
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
	if (![[PTPreferenceManager getInstance] disableSoundNotification]) {
		switch (fCurrentSoundStatus) {
			case StatusReceived:
				[fStatusReceived play];
				break;
			case ReplyOrMessageReceived:
				[fReplyReceived play];
				break;
			case ErrorReceived:
				[fErrorReceived play];
				break;
			case StatusSent:
				[fStatusSent play];
				break;
		}
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
	if (![NSApp isActive]) {
		[self sortArray:fBoxesToNotify];
		[fNotificationMan postNotifications:fBoxesToNotify 
							   defaultImage:fDefaultImage];
	}
	[fBoxesToNotify removeAllObjects];
}

- (void)addNewStatusBoxes {
	if (![NSApp isActive] && [fBoxesToAdd count])
		[fMenuItem setImage:[NSImage imageNamed:@"menu_icon_on"]];
	[self sortArray:fBoxesToAdd];
	[fStatusController addObjects:fBoxesToAdd];
	[fBoxesToAdd removeAllObjects];
}

- (void)startingTransaction {
	if ([fRequestDetails count] == 0) {
		[fProgressBar startAnimation:self];
		[fProgressBar setHidden:NO];
		[fUpdateButton setEnabled:NO];
	}
}

- (void)endingTransaction {
	if ([fRequestDetails count] == 0) {
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

- (void)runMessageUpdateFromTimer:(NSTimer *)aTimer {
	[self startingTransaction];
	[fRequestDetails setObject:@"MESSAGE_UPDATE" 
						forKey:[fTwitterEngine getDirectMessagesSinceID:fLastMessageID 
														 startingAtPage:0]];
}

- (void)runUpdateFromTimer:(NSTimer *)aTimer {
	[self updateTimeline:self];
}

- (void)runInitialUpdates {
	[self startingTransaction];
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
	fBoxesToNotify = [[NSMutableArray alloc] init];
	fBoxesToAdd = [[NSMutableArray alloc] init];
	fLastReplyID = 0;
	fLastUpdateID = 0;
	fLastMessageID = 0;
}

- (void)deallocTransaction {
	if (fRequestDetails) [fRequestDetails release];
	if (fImageLocationForReq) [fImageLocationForReq release];
	if (fImageReqForLocation) [fImageReqForLocation release];
	if (fStatusBoxesForReq) [fStatusBoxesForReq release];
	if (fUserImageCache) [fUserImageCache release];
	if (fBoxesToNotify) [fBoxesToNotify release];
	if (fBoxesToAdd) [fBoxesToAdd release];
	fLastReplyID = 0;
	fLastUpdateID = 0;
	fLastMessageID = 0;
}

- (IBAction)changeAccount:(id)sender {
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

- (void)activateApp {
	[fMenuItem setImage:[NSImage imageNamed:@"menu_icon_off"]];
	[NSApp activateIgnoringOtherApps:YES];
	[fMainWindow makeKeyAndOrderFront:self];
}

- (void)awakeFromNib
{
	[NSApp activateIgnoringOtherApps:YES];
	[fMainWindow makeKeyAndOrderFront:self];
	NSStatusBar *lBar = [NSStatusBar systemStatusBar];
	fMenuItem = [[lBar statusItemWithLength:NSVariableStatusItemLength] retain];
	[fMenuItem setImage:[NSImage imageNamed:@"menu_icon_off"]];
	[fMenuItem setHighlightMode:YES];
	[fMenuItem setTarget:self];
	[fMenuItem setAction:@selector(activateApp)];
	[self initTransaction];
	fDefaultImage = [NSImage imageNamed:@"default.png"];
	fMaskImage = [NSImage imageNamed:@"icon_mask"];
	fStatusReceived = [NSSound soundNamed:@"statusReceived"];
	fReplyReceived = [NSSound soundNamed:@"replyReceived"];
	fStatusSent = [NSSound soundNamed:@"statusPosted"];
	[[NSSound soundNamed:@"startUp"] play];
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

- (void)connectionFinished {
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
	[self endingTransaction];
	if (!lIgnoreError) {
		PTStatusBox *lErrorBox = [fStatusBoxGenerator constructErrorBox:aError];
		[fBoxesToAdd addObject:lErrorBox];
		[fBoxesToNotify addObject:lErrorBox];
	}
}

- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox {
	NSImage *lImageData = [fUserImageCache objectForKey:aImageLocation];
	if (!lImageData) {
		if (![fImageReqForLocation objectForKey:aImageLocation]) {
			[self startingTransaction];
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
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self endingTransaction];
		return;
	}
	NSString *lUpdateType = [fRequestDetails objectForKey:aIdentifier];
	if (lUpdateType == @"POST") {
		fCurrentSoundStatus = StatusSent;
		[self postComplete];
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self endingTransaction];
		return;
	}
	NSDictionary *lCurrentStatus;
	NSDictionary *lLastStatus = nil;
	NSMutableArray *lTempBoxes = [[NSMutableArray alloc] init];
	for (lCurrentStatus in aStatuses) {
		int lDecision = 0;
		if ([[lCurrentStatus objectForKey:@"in_reply_to_screen_name"] isEqualToString:[fTwitterEngine username]]) {
			if (lUpdateType == @"REPLY_UPDATE" || 
				lUpdateType == @"INIT_REPLY_UPDATE" || 
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
		if (!lLastStatus) lLastStatus = lCurrentStatus;
	}
	if (fCurrentSoundStatus == NoneReceived && 
		[lTempBoxes count] != 0)
		fCurrentSoundStatus = StatusReceived;
	if (lUpdateType == @"UPDATE" || lUpdateType == @"REPLY_UPDATE") {
		[fBoxesToNotify addObjectsFromArray:lTempBoxes];
	}
	[fBoxesToAdd addObjectsFromArray:lTempBoxes];
	[lTempBoxes release];
	int lNewId = [[lLastStatus objectForKey:@"id"] intValue];
	if ((lUpdateType == @"REPLY_UPDATE" || lUpdateType == @"INIT_REPLY_UPDATE") && 
		fLastReplyID < lNewId) {
		fLastReplyID = lNewId;
	} else if (fLastUpdateID < lNewId) {
		fLastUpdateID = lNewId;
	}
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self endingTransaction];
}

- (void)directMessagesReceived:(NSArray *)aMessages forRequest:(NSString *)aIdentifier
{
	if ([aMessages count] == 0 || 
		[[[aMessages objectAtIndex:0] objectForKey:@"id"] intValue] == 0 || 
		[fRequestDetails objectForKey:aIdentifier] == @"MESSAGE") {
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self endingTransaction];
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
	if ([fRequestDetails objectForKey:aIdentifier] != @"INIT_MESSAGE_UPDATE") {
		[fBoxesToNotify addObjectsFromArray:lTempArray];
	}
	[fBoxesToAdd addObjectsFromArray:lTempArray];
	[lTempArray release];
	fLastMessageID = [[lLastDic objectForKey:@"id"] intValue];
	[fRequestDetails removeObjectForKey:aIdentifier];
	if (fCurrentSoundStatus != ErrorReceived)
		fCurrentSoundStatus = ReplyOrMessageReceived;
	fCurrentSoundStatus = ReplyOrMessageReceived;
	[self endingTransaction];
}

- (void)userInfoReceived:(NSArray *)aUserInfo forRequest:(NSString *)aIdentifier
{
	// not implemented
}

- (void)miscInfoReceived:(NSArray *)aMiscInfo forRequest:(NSString *)aIdentifier
{
	// not implemented
}

- (NSImage *)maskImage:(NSImage *)aImage {
	NSImage *lNewImage = [fMaskImage copy];
	[lNewImage lockFocus];
	[aImage drawInRect: NSMakeRect(0, 0, 48, 48) 
			  fromRect: NSMakeRect(0, 0, [aImage size].width, [aImage size].height) 
			 operation: NSCompositeSourceIn 
			  fraction: 1.0];
	[lNewImage unlockFocus];
	return [lNewImage autorelease];
}

- (void)imageReceived:(NSImage *)aImage forRequest:(NSString *)aIdentifier
{
	NSImage *lNewImage = [self maskImage:aImage];
	PTStatusBox *lCurrentBox;
	for (lCurrentBox in [fStatusBoxesForReq objectForKey:aIdentifier]) {
		lCurrentBox.userImage = lNewImage;
	}
	NSString *lImageLocation = [fImageLocationForReq objectForKey:aIdentifier];
	[fUserImageCache setObject:lNewImage forKey:lImageLocation];
	[fStatusBoxesForReq removeObjectForKey:aIdentifier];
	[fImageReqForLocation removeObjectForKey:lImageLocation];
	[fImageLocationForReq removeObjectForKey:aIdentifier];
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self endingTransaction];
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
		[self startingTransaction];
		[fRequestDetails setObject:@"UPDATE" 
							forKey:[fTwitterEngine getFollowedTimelineFor:[fTwitterEngine username] 
																  sinceID:fLastUpdateID startingAtPage:0 count:50]];
		if ([[PTPreferenceManager getInstance] receiveFromNonFollowers])
			[fRequestDetails setObject:@"REPLY_UPDATE" 
								forKey:[fTwitterEngine getRepliesSinceID:fLastReplyID startingAtPage:0 count:20]];
		if (sender != self)
			[fRequestDetails setObject:@"MESSAGE_UPDATE" 
								forKey:[fTwitterEngine getDirectMessagesSinceID:fLastMessageID 
																 startingAtPage:0]];
	}
}

- (void)makePost:(NSString *)aMessage {
	[self startingTransaction];
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
							forKey:[fTwitterEngine sendUpdate:aMessage 
													inReplyTo:fReplyUpdateId]];
	}
	[fStatusUpdateField setEnabled:NO];
	fReplyUpdateId = 0;
	[fMainActionHandler closeReplyView];
}

- (IBAction)postStatus:(id)sender {
	[self makePost:[fStatusUpdateField stringValue]];
}

- (void)openTwitterWeb {
	PTStatusBox *lCurrentSelection = [[fStatusController selectedObjects] lastObject];
	if (lCurrentSelection && lCurrentSelection.sType != ErrorMessage)
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", lCurrentSelection.userID]]];
}

- (void)setReplyID:(int)aId {
	fReplyUpdateId = aId;
}

@synthesize fMenuItem;

@end
