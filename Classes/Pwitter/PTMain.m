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
#import "PTReadManager.h"
#import "PTCollectionView.h"

#define STATUS_LIMIT 1000


@implementation PTMain

- (void)setupUpdateTimer {
	// stop the old timer
	if (fUpdateTimer) {
		[fUpdateTimer invalidate];
		[fUpdateTimer release];
	}
	// determine the timer delay
	int lIntervalTime;
	switch ([[PTPreferenceManager sharedInstance] timeInterval]) {
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
	switch ([[PTPreferenceManager sharedInstance] messageInterval]) {
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
	if (![[PTPreferenceManager sharedInstance] disableSoundNotification]) {
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
				[fStatusPosted play];
				break;
			default:
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
							   defaultImage:[NSImage imageNamed:@"default.png"]];
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

- (void)removeStatusBoxes {
	[fStatusController removeObjects:fBoxesToRemove];
	[fBoxesToRemove removeAllObjects];
}

- (void)startingTransaction {
	if ([fRequestDetails count] == 0) {
		fCurrentSoundStatus = NoneReceived;
		[fBoxesToAdd removeAllObjects];
		[fProgressBar startAnimation:self];
		[fProgressBar setHidden:NO];
		[fUpdateButton setEnabled:NO];
	}
}

- (void)endingTransaction {
	if ([fRequestDetails count] == 0) {
		[self playSoundEffect];
		[fProgressBar stopAnimation:self];
		[fProgressBar setHidden:YES];
		[fUpdateButton setEnabled:YES];
		NSPredicate *lBackupPredicate = [[fStatusController filterPredicate] copy];
		[self addNewStatusBoxes];
		[self removeStatusBoxes];
		// limit the number of status boxes
		int lStatusCount = [[fStatusController content] count] + 1;
		if (lStatusCount > STATUS_LIMIT) {
			NSRange lDeletionRange = NSMakeRange(STATUS_LIMIT - 1, lStatusCount - STATUS_LIMIT);
			NSIndexSet *lToDelete = [NSIndexSet indexSetWithIndexesInRange:lDeletionRange];
			[fStatusController removeObjectsAtArrangedObjectIndexes:lToDelete];
		}
		if (lBackupPredicate) {
			[fStatusController setFilterPredicate:lBackupPredicate];
			[lBackupPredicate release];
		}
		[fStatusCollection setContent:[fStatusController arrangedObjects]];
		if ([fStatusController selectsInsertedObjects]) {
			id lObj = [[fStatusController selectedObjects] objectAtIndex:0];
			if (lObj) [fStatusCollection selectItemsForObjects:[NSArray arrayWithObject:lObj]];
		}
		[self postGrowlNotifications];
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
						forKey:[fTwitterEngine getFollowedTimelineFor:[[PTPreferenceManager sharedInstance] userName] 
																since:nil startingAtPage:1 count:200]];
	[fRequestDetails setObject:@"INIT_UPDATE" 
						forKey:[fTwitterEngine getFollowedTimelineFor:[[PTPreferenceManager sharedInstance] userName] 
																since:nil startingAtPage:2 count:200]];
	[fRequestDetails setObject:@"INIT_REPLY_UPDATE" 
						forKey:[fTwitterEngine getRepliesStartingAtPage:1]];
	[fRequestDetails setObject:@"INIT_REPLY_UPDATE" 
						forKey:[fTwitterEngine getRepliesStartingAtPage:2]];
}

- (void)setUpTwitterEngine {
	fTwitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[fTwitterEngine setClientName:@"Pwitter" 
						  version:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
							  URL:@"http://github.com/koroshiya1/pwitter/wikis/home" 
							token:@"pwitter"];
	[fTwitterEngine setUsername:[[PTPreferenceManager sharedInstance] userName] 
					   password:[[PTPreferenceManager sharedInstance] password]];
	[self loadUnread];
	[self runInitialUpdates];
	[self setupUpdateTimer];
	[self setupMessageUpdateTimer];
}

- (void)initTransaction {
	fRequestDetails = [[NSMutableDictionary alloc] init];
	fIgnoreList = [[NSMutableDictionary alloc] init];
	fFavRecord = [[NSMutableDictionary alloc] init];
	fDeleteRecord = [[NSMutableDictionary alloc] init];
	[fImageMan initResource];
	fBoxesToNotify = [[NSMutableArray alloc] init];
	fBoxesToAdd = [[NSMutableArray alloc] init];
	fBoxesToRemove = [[NSMutableArray alloc] init];
	fLastReplyID = 0;
	fLastUpdateID = 0;
	fLastMessageID = 0;
}

- (void)deallocTransaction {
	if (fRequestDetails) [fRequestDetails release];
	if (fIgnoreList) [fIgnoreList release];
	if (fFavRecord) [fFavRecord release];
	if (fDeleteRecord) [fDeleteRecord release];
	[fImageMan clearResource];
	if (fBoxesToNotify) [fBoxesToNotify release];
	if (fBoxesToAdd) [fBoxesToAdd release];
	if (fBoxesToRemove) [fBoxesToRemove release];
	fLastReplyID = 0;
	fLastUpdateID = 0;
	fLastMessageID = 0;
}

- (IBAction)changeAccount:(id)sender {
	[self saveUnread];
	[[fStatusController content] removeAllObjects];
	[fStatusController rearrangeObjects];
	[fTwitterEngine setUsername:[[PTPreferenceManager sharedInstance] userName] 
					   password:[[PTPreferenceManager sharedInstance] password]];
	[self setupUpdateTimer];
	[self setupMessageUpdateTimer];
	[fTwitterEngine closeAllConnections];
	[self deallocTransaction];
	[self initTransaction];
	[fProgressBar stopAnimation:self];
	[fProgressBar setHidden:YES];
	[fUpdateButton setEnabled:YES];
	[self loadUnread];
	[self runInitialUpdates];
}

- (IBAction)activateApp:(id)sender {
	[fMenuItem setImage:[NSImage imageNamed:@"menu_icon_off"]];
	[NSApp activateIgnoringOtherApps:YES];
	[fMainWindow makeKeyAndOrderFront:self];
}

- (void)toggleApp {
	if ([NSApp isActive] && [fMainWindow isKeyWindow]) {
		[NSApp hide:self];
	} else {
		[fMainWindow makeKeyAndOrderFront:self];
		[self activateApp:self];
	}
}

- (void)awakeFromNib
{
	fStatusReceived = [NSSound soundNamed:@"statusReceived"];
	fReplyReceived = [NSSound soundNamed:@"replyReceived"];
	fErrorReceived = [NSSound soundNamed:@"error"];
	fStatusPosted = [NSSound soundNamed:@"statusPosted"];
	[NSApp activateIgnoringOtherApps:YES];
	[fMainWindow makeKeyAndOrderFront:self];
	NSStatusItem *lItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:25] retain];
	fMenuItem = [[PTMenuBarIcon alloc] initWithFrame:NSMakeRect(0, 0, 18, 25)];
	[fMenuItem setStatusItem:lItem];
	[lItem setView:fMenuItem];
	[fMenuItem setImage:[NSImage imageNamed:@"menu_icon_off"]];
	[fMenuItem setMenu:fIconMenu];
	[fMenuItem setMainController:self];
	[fMenuItem setSwapped:[[PTPreferenceManager sharedInstance] swapMenuItemBehavior]];
	fImageMan = [[PTImageManager alloc] init];
	[self initTransaction];
	if (![[PTPreferenceManager sharedInstance] disableSoundNotification])
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
	[fMainWindow makeFirstResponder:fStatusCollection];
}

- (void)connectionFinished {
}

- (void)requestSucceeded:(NSString *)requestIdentifier
{
	NSString *lReqType = [fRequestDetails objectForKey:requestIdentifier];
	if (lReqType == @"FAV") {
		PTStatusBox *lBoxToFav = [fFavRecord objectForKey:requestIdentifier];
		lBoxToFav.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.2 blue:0.0 alpha:1.0];
		lBoxToFav.fav = YES;
		[fRequestDetails removeObjectForKey:lReqType];
		[fFavRecord removeObjectForKey:requestIdentifier];
	} else if (lReqType == @"UNFAV") {
		PTStatusBox *lBoxToFav = [fFavRecord objectForKey:requestIdentifier];
		if (lBoxToFav.sType == ReplyMessage) {
			lBoxToFav.entityColor = [NSColor colorWithCalibratedRed:0.3 green:0.1 blue:0.1 alpha:1.0];
		} else {
			if ([[[PTPreferenceManager sharedInstance] userName] isEqualToString:lBoxToFav.userId]) {
				lBoxToFav.entityColor = [NSColor colorWithCalibratedRed:0.3 green:0.3 blue:0.3 alpha:1.0];
			} else {
				lBoxToFav.entityColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:1.0];
			}
		}
		lBoxToFav.fav = NO;
		[fRequestDetails removeObjectForKey:lReqType];
		[fFavRecord removeObjectForKey:requestIdentifier];
	} else if (lReqType == @"MESSAGE") {
		[self postComplete];
	} else if (lReqType == @"DELETE") {
		PTStatusBox *lToDelete = [fDeleteRecord objectForKey:requestIdentifier];
		[fDeleteRecord removeObjectForKey:requestIdentifier];
		[fBoxesToRemove addObject:lToDelete];
		[fRequestDetails removeObjectForKey:lReqType];
		[self endingTransaction];
	}
}

- (void)requestFailed:(NSString *)aRequestIdentifier withError:(NSError *)aError
{
	BOOL lIgnoreError = [[PTPreferenceManager sharedInstance] ignoreErrors];
	NSString *lRequestType = [fRequestDetails objectForKey:aRequestIdentifier];
	if (lRequestType == @"POST" || lRequestType == @"MESSAGE") {
		[fStatusUpdateField setEnabled:YES];
	} else if (lRequestType == @"IMAGE") {
		[fImageMan requestFailed:aRequestIdentifier];
		lIgnoreError = YES;
	}
	[fRequestDetails removeObjectForKey:aRequestIdentifier];
	[self endingTransaction];
	if (!lIgnoreError) {
		fCurrentSoundStatus = ErrorReceived;
		PTStatusBox *lErrorBox = [fStatusBoxGenerator constructErrorBox:aError];
		[fBoxesToAdd addObject:lErrorBox];
		[fBoxesToNotify addObject:lErrorBox];
	}
}

- (void)statusesReceived:(NSArray *)aStatuses forRequest:(NSString *)aIdentifier
{
	NSString *lReqType = [fRequestDetails objectForKey:aIdentifier];
	if ([aStatuses count] == 0 || 
		lReqType == @"FAV" || 
		lReqType == @"UNFAV" || 
		lReqType == @"DELETE") {
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self endingTransaction];
		return;
	}
	NSString *lUpdateType = [fRequestDetails objectForKey:aIdentifier];
	NSDictionary *lCurrentStatus;
	NSDictionary *lLastStatus = nil;
	NSMutableArray *lTempBoxes = [[NSMutableArray alloc] init];
	for (lCurrentStatus in aStatuses) {
		if (![fIgnoreList objectForKey:[lCurrentStatus objectForKey:@"id"]]) {
			int lDecision = 0;
			if ([[lCurrentStatus objectForKey:@"in_reply_to_screen_name"] isEqualToString:[fTwitterEngine username]]) {
				if (lUpdateType == @"REPLY_UPDATE" || 
					lUpdateType == @"INIT_REPLY_UPDATE" || 
					lUpdateType == @"POST" ||
					(![[PTPreferenceManager sharedInstance] receiveFromNonFollowers] && lUpdateType != @"INIT_UPDATE")) {
					lDecision = 1;
				}
			} else lDecision = 2;
			if (lDecision != 0) {
				PTStatusBox *lBoxToAdd = nil;
				lBoxToAdd = [fStatusBoxGenerator constructStatusBox:lCurrentStatus 
															isReply:lDecision == 1];
				if ((lDecision == 1 || lBoxToAdd.sType == ReplyMessage) && 
					fCurrentSoundStatus != ErrorReceived)
					fCurrentSoundStatus = ReplyOrMessageReceived;
				[lTempBoxes addObject:lBoxToAdd];
			}
			if (!lLastStatus) lLastStatus = lCurrentStatus;
		}
	}
	if (fCurrentSoundStatus == NoneReceived && 
		[lTempBoxes count] != 0)
		fCurrentSoundStatus = StatusReceived;
	if (lUpdateType == @"UPDATE" || lUpdateType == @"REPLY_UPDATE") {
		[fBoxesToNotify addObjectsFromArray:lTempBoxes];
	}
	[fBoxesToAdd addObjectsFromArray:lTempBoxes];
	int lNewId = [[lLastStatus objectForKey:@"id"] intValue];
	if (lUpdateType == @"POST") {
		[fIgnoreList setObject:@"" forKey:[[aStatuses lastObject] objectForKey:@"id"]];
		fCurrentSoundStatus = StatusSent;
		[self postComplete];
		if ([[PTPreferenceManager sharedInstance] updateAfterPost])
			[self updateTimeline:fMainWindow];
	} else if ((lUpdateType == @"REPLY_UPDATE" || lUpdateType == @"INIT_REPLY_UPDATE") && 
			   fLastReplyID < lNewId) {
		fLastReplyID = lNewId;
	} else if (fLastUpdateID < lNewId) {
		fLastUpdateID = lNewId;
	}
	[lTempBoxes release];
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self endingTransaction];
}

- (void)directMessagesReceived:(NSArray *)aMessages forRequest:(NSString *)aIdentifier
{
	NSString *lReqType = [fRequestDetails objectForKey:aIdentifier];
	if (lReqType == @"DELETE") {
		[fRequestDetails removeObjectForKey:aIdentifier];
		[self endingTransaction];
		return;
	} else if (lReqType == @"MESSAGE")
		fCurrentSoundStatus = StatusSent;
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

- (void)imageReceived:(NSImage *)aImage forRequest:(NSString *)aIdentifier
{
	[fImageMan addImage:aImage forRequest:aIdentifier];
	[fRequestDetails removeObjectForKey:aIdentifier];
	[self endingTransaction];
}

- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox {
	NSImage *lImageData = [fImageMan fetchImage:aImageLocation];
	if (!lImageData) {
		if (![fImageMan isRequestedImage:aImageLocation]) {
			[self startingTransaction];
			NSString *lImageReq = [fTwitterEngine getImageAtURL:aImageLocation];
			[fRequestDetails setObject:@"IMAGE" forKey:lImageReq];
			[fImageMan requestUserImage:aImageLocation forRequest:lImageReq];
		}
		[fImageMan registerStatusBox:aNewBox forLocation:aImageLocation];
		return [NSImage imageNamed:@"default.png"];
	} else {
		return lImageData;
	}
}

- (IBAction)updateTimeline:(id)sender {
	// sender is self when this method is provoked by the timer
	if (sender != self) {
		[self setupUpdateTimer];
	}
	if (!fLastUpdateID) {
		[self runInitialUpdates];
	} else {
		[self startingTransaction];
		[fRequestDetails setObject:@"UPDATE" 
							forKey:[fTwitterEngine getFollowedTimelineFor:[fTwitterEngine username] 
																  sinceID:fLastUpdateID startingAtPage:0 count:200]];
		if ([[PTPreferenceManager sharedInstance] receiveFromNonFollowers])
			[fRequestDetails setObject:@"REPLY_UPDATE" 
								forKey:[fTwitterEngine getRepliesSinceID:fLastReplyID startingAtPage:0 count:20]];
	}
}

- (void)makePost:(NSString *)aMessage {
	if ([aMessage length] == 0) return;
	[self startingTransaction];
	NSArray *lSeparated = [aMessage componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([lSeparated count] >= 2 && [[lSeparated objectAtIndex:0] isEqual:@"D"]) {
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
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", lCurrentSelection.userId]]];
}

- (void)setReplyID:(int)aId {
	fReplyUpdateId = aId;
}

- (void)favStatus:(PTStatusBox *)aBox {
	[self startingTransaction];
	NSString *lReqStr;
	if (aBox.fav) {
		lReqStr = [fTwitterEngine markUpdate:aBox.updateId 
								  asFavorite:NO];
		[fRequestDetails setObject:@"UNFAV" 
							forKey:lReqStr];
	} else {
		lReqStr = [fTwitterEngine markUpdate:aBox.updateId 
								  asFavorite:YES];
		[fRequestDetails setObject:@"FAV" 
							forKey:lReqStr];
	}
	[fFavRecord setObject:aBox forKey:lReqStr];
}

- (NSString *)pathForDataFile
{
	NSFileManager *lFileManager = [NSFileManager defaultManager];
	NSString *lFolder = @"~/Library/Application Support/Pwitter/";
	lFolder = [lFolder stringByExpandingTildeInPath];
	if ([lFileManager fileExistsAtPath: lFolder] == NO)
	{
		[lFileManager createDirectoryAtPath: lFolder attributes: nil];
	}
	NSString *lFileName = [[fTwitterEngine username] stringByAppendingString:@".unread"];
	return [lFolder stringByAppendingPathComponent: lFileName];
}

- (void)loadUnread {
	NSString *lPath = [self pathForDataFile];
	NSDictionary *lRootObj;
	lRootObj = [NSKeyedUnarchiver unarchiveObjectWithFile:lPath];
	[[PTReadManager getInstance] setUnreadDict:[lRootObj valueForKey:@"unreads"]];
}

- (void)saveUnread {
	NSMutableDictionary *lUnreadDict = [NSMutableDictionary dictionary];
	PTStatusBox *lCurrentBox;
	for (lCurrentBox in [fStatusController content]) {
		if (lCurrentBox.sType != ErrorMessage) {
			[lUnreadDict setObject:[NSNumber numberWithBool:lCurrentBox.readFlag] 
							forKey:[NSNumber numberWithInt:lCurrentBox.updateId]];
		}
	}
	NSString * lPath = [self pathForDataFile];
	NSMutableDictionary * lRootObj;
	lRootObj = [NSMutableDictionary dictionary];
	[lRootObj setValue:lUnreadDict forKey:@"unreads"];
	[NSKeyedArchiver archiveRootObject:lRootObj toFile:lPath];
}

- (void)deleteTweet:(PTStatusBox *)aBox {
	if (aBox) {
		if ([aBox.userId isEqualToString:[[PTPreferenceManager sharedInstance] userName]] && 
			(aBox.sType == NormalMessage || aBox.sType == ReplyMessage)) {
			[self startingTransaction];
			NSString *lRequestId = [fTwitterEngine deleteUpdate:aBox.updateId];
			[fRequestDetails setObject:@"DELETE" forKey:lRequestId];
			[fDeleteRecord setObject:aBox forKey:lRequestId];
		} else if (aBox.sType == DirectMessage) {
			[self startingTransaction];
			NSString *lRequestId = [fTwitterEngine deleteDirectMessage:aBox.updateId];
			[fRequestDetails setObject:@"DELETE" forKey:lRequestId];
			[fDeleteRecord setObject:aBox forKey:lRequestId];
		}
	}
}

@synthesize fMenuItem;

@end
