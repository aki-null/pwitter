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
#import "PTURLUtils.h"
#import "PTColorManager.h"


@implementation PTMain

- (void)setupUpdateTimer {
	// stop the old timer
	if (fUpdateTimer) {
		[fUpdateTimer invalidate];
		[fUpdateTimer release];
	}
	// determine the timer delay
	int lIntervalTime;
	switch ([[PTPreferenceManager sharedSingleton] timeInterval]) {
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
	switch ([[PTPreferenceManager sharedSingleton] messageInterval]) {
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
	if (![[PTPreferenceManager sharedSingleton] disableSoundNotification]) {
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
//	fCurrentSoundStatus = NoneReceived;
//	[fBoxesToAdd removeAllObjects];
//	[fBoxesToNotify removeAllObjects];
	if ([fTwitterEngine numberOfConnections] == 0) {
		[fProgressBar startAnimation:self];
		[fProgressBar setHidden:NO];
		[fUpdateButton setEnabled:NO];
	}
}

- (void)endingTransaction {
	fIgnoreErrors = NO;
	fUpdating = NO;
	[self playSoundEffect];
	[fProgressBar stopAnimation:self];
	[fProgressBar setHidden:YES];
	[fUpdateButton setEnabled:YES];
	NSPredicate *lBackupPredicate = [[fStatusController filterPredicate] copy];
	[self addNewStatusBoxes];
	[self removeStatusBoxes];
	// limit the number of status boxes
	int lStatusCount = [[fStatusController content] count] + 1;
	int lMaxTweets = [[PTPreferenceManager sharedSingleton] maxTweets];
	if (lStatusCount > lMaxTweets) {
		NSRange lDeletionRange = NSMakeRange(lMaxTweets - 1, lStatusCount - lMaxTweets);
		NSIndexSet *lToDelete = [NSIndexSet indexSetWithIndexesInRange:lDeletionRange];
		[fStatusController removeObjectsAtArrangedObjectIndexes:lToDelete];
	}
	if (lBackupPredicate) {
		[fStatusController setFilterPredicate:lBackupPredicate];
		[lBackupPredicate release];
	}
	[self postGrowlNotifications];
	[fStatusCollection setContent:[fStatusController arrangedObjects]];
	if ([fStatusController selectsInsertedObjects]) {
		id lObj = [[fStatusController selectedObjects] objectAtIndex:0];
		if (lObj) [fStatusCollection selectItemsForObjects:[NSArray arrayWithObject:lObj]];
	}
	[fRequestDetails removeAllObjects];
}

- (void)runMessageUpdateFromTimer:(NSTimer *)aTimer {
	if ([fTwitterEngine numberOfConnections] == 0)
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
						forKey:[fTwitterEngine getDirectMessagesSinceID:0
													   startingAtPage:0]];
	[fRequestDetails setObject:@"INIT_UPDATE" 
						forKey:[fTwitterEngine getFollowedTimelineSinceID:0 startingAtPage:1 count:200]];
	[fRequestDetails setObject:@"INIT_REPLY_UPDATE" 
						forKey:[fTwitterEngine getRepliesSinceID:fLastReplyID startingAtPage:0 count:100]];
}

- (void)setUpTwitterEngine {
	fTwitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[fTwitterEngine setClientName:@"Pwitter" 
						  version:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
							  URL:@"http://github.com/koroshiya1/pwitter/wikis/home" 
							token:@"pwitter"];
	[fTwitterEngine setUsername:[[PTPreferenceManager sharedSingleton] userName] 
					   password:[[PTPreferenceManager sharedSingleton] password]];
	[self loadUnread];
	[self runInitialUpdates];
	[self setupUpdateTimer];
	[self setupMessageUpdateTimer];
}

- (void)initTransaction {
	fRequestDetails = [[NSMutableDictionary alloc] init];
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
	[fStatusRecord removeAllObjects];
	[fTwitterEngine setUsername:[[PTPreferenceManager sharedSingleton] userName] 
					   password:[[PTPreferenceManager sharedSingleton] password]];
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
	fStatusRecord = [[NSMutableSet set] retain];
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
	[fMenuItem setSwapped:[[PTPreferenceManager sharedSingleton] swapMenuItemBehavior]];
	fImageMan = [[PTImageManager alloc] init];
	[self initTransaction];
	if (![[PTPreferenceManager sharedSingleton] disableSoundNotification])
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

- (void)connectionFinished:(NSString *)connectionIdentifier {
	if ([fTwitterEngine numberOfConnections] == 0)
		[self endingTransaction];
}

- (void)requestSucceeded:(NSString *)requestIdentifier
{
	NSString *lReqType = [fRequestDetails objectForKey:requestIdentifier];
	if (lReqType == @"FAV") {
		PTStatusBox *lBoxToFav = [fFavRecord objectForKey:requestIdentifier];
		lBoxToFav.entityColor = [[PTColorManager sharedSingleton] favoriteColor];
		lBoxToFav.fav = YES;
		[fFavRecord removeObjectForKey:requestIdentifier];
	} else if (lReqType == @"UNFAV") {
		PTStatusBox *lBoxToFav = [fFavRecord objectForKey:requestIdentifier];
		if (lBoxToFav.sType == ReplyMessage) {
			lBoxToFav.entityColor = [[PTColorManager sharedSingleton] replyColor];
		} else {
			lBoxToFav.entityColor = [[PTColorManager sharedSingleton] tweetColor];
		}
		lBoxToFav.fav = NO;
		[fFavRecord removeObjectForKey:requestIdentifier];
	} else if (lReqType == @"MESSAGE") {
		[self postComplete];
	} else if (lReqType == @"DELETE") {
		PTStatusBox *lToDelete = [fDeleteRecord objectForKey:requestIdentifier];
		[fDeleteRecord removeObjectForKey:requestIdentifier];
		[fBoxesToRemove addObject:lToDelete];
	}
}

- (void)requestFailed:(NSString *)aRequestIdentifier withError:(NSError *)aError
{
	BOOL lIgnoreError = [[PTPreferenceManager sharedSingleton] ignoreErrors] || fIgnoreErrors;
	NSString *lRequestType = [fRequestDetails objectForKey:aRequestIdentifier];
	if (lRequestType == @"POST" || lRequestType == @"MESSAGE") {
		[fStatusUpdateField setEnabled:YES];
	} else if (lRequestType == @"IMAGE") {
		[fImageMan requestFailed:aRequestIdentifier];
		lIgnoreError = YES;
	}
	if (!lIgnoreError) {
		fCurrentSoundStatus = ErrorReceived;
		PTStatusBox *lErrorBox = [fStatusBoxGenerator constructErrorBox:aError];
		[fBoxesToAdd addObject:lErrorBox];
		[fBoxesToNotify addObject:lErrorBox];
		fIgnoreErrors = YES;
	}
}

- (void)statusesReceived:(NSArray *)aStatuses forRequest:(NSString *)aIdentifier
{
	NSString *lReqType = [fRequestDetails objectForKey:aIdentifier];
	if ([aStatuses count] == 0 || 
		lReqType == @"FAV" || 
		lReqType == @"UNFAV" || 
		lReqType == @"DELETE") {
		return;
	}
	NSString *lUpdateType = [fRequestDetails objectForKey:aIdentifier];
	NSDictionary *lCurrentStatus;
	NSDictionary *lLastStatus = nil;
	NSMutableArray *lTempBoxes = [[NSMutableArray alloc] init];
	for (lCurrentStatus in aStatuses) {
		unsigned long tweetID = [[NSDecimalNumber decimalNumberWithString:[lCurrentStatus valueForKeyPath:@"id"]] unsignedLongValue];
		if (![fStatusRecord containsObject:[NSNumber numberWithUnsignedInt:tweetID]]) {
			int lDecision = 0;
			if ([[lCurrentStatus objectForKey:@"in_reply_to_screen_name"] isEqualToString:[fTwitterEngine username]]) {
				if (lUpdateType == @"REPLY_UPDATE" || 
					lUpdateType == @"INIT_REPLY_UPDATE" || 
					lUpdateType == @"POST" ||
					(![[PTPreferenceManager sharedSingleton] receiveFromNonFollowers] && lUpdateType != @"INIT_UPDATE")) {
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
				[fStatusRecord addObject:[NSNumber numberWithUnsignedLong:lBoxToAdd.updateId]];
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
	unsigned long lNewId = [[NSDecimalNumber decimalNumberWithString:[lLastStatus valueForKeyPath:@"id"]] unsignedLongValue];
	if (lUpdateType == @"POST") {
		fCurrentSoundStatus = StatusSent;
		[self postComplete];
		if ([[PTPreferenceManager sharedSingleton] updateAfterPost] && !fUpdating)
			[self updateTimeline:fMainWindow];
	} else if ((lUpdateType == @"REPLY_UPDATE" || lUpdateType == @"INIT_REPLY_UPDATE") && 
			   fLastReplyID < lNewId) {
		fLastReplyID = lNewId;
	} else if (fLastUpdateID < lNewId) {
		fLastUpdateID = lNewId;
	}
	[lTempBoxes release];
}

- (void)directMessagesReceived:(NSArray *)aMessages forRequest:(NSString *)aIdentifier
{
	NSString *lReqType = [fRequestDetails objectForKey:aIdentifier];
	if (lReqType == @"DELETE") {
		return;
	} else if (lReqType == @"MESSAGE")
		fCurrentSoundStatus = StatusSent;
	if ([aMessages count] == 0 || 
		[[NSDecimalNumber decimalNumberWithString:[[aMessages objectAtIndex:0] valueForKeyPath:@"id"]] unsignedLongValue] == 0 || 
		[fRequestDetails objectForKey:aIdentifier] == @"MESSAGE") {
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
	fLastMessageID = [[NSDecimalNumber decimalNumberWithString:[lLastDic valueForKeyPath:@"id"]] unsignedLongValue];;
	if (fCurrentSoundStatus != ErrorReceived)
		fCurrentSoundStatus = ReplyOrMessageReceived;
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
		fUpdating = YES;
		[fRequestDetails setObject:@"UPDATE" 
							forKey:[fTwitterEngine getFollowedTimelineSinceID:fLastUpdateID 
															   startingAtPage:0 count:200]];
		if ([[PTPreferenceManager sharedSingleton] receiveFromNonFollowers]) {
			[fRequestDetails setObject:@"REPLY_UPDATE" 
								forKey:[fTwitterEngine getRepliesSinceID:fLastReplyID startingAtPage:0 count:200]];
		}
	}
}

- (NSString *)createShortURLs:(NSString *)aMessage {
	NSString *lServiceURL;
	switch ([[PTPreferenceManager sharedSingleton] urlShorteningService]) {
		case 1:
			lServiceURL = @"http://tinyurl.com/api-create.php?url=";
			break;
		case 2:
			lServiceURL = @"http://is.gd/api.php?longurl=";
			break;
		default:
			return aMessage;
			break;
	}
	NSString *lFinalMessage = aMessage;
	PTURLUtils *lUtils = [PTURLUtils utils];
	NSArray *lTokens = [lUtils tokenizeByAll:aMessage];
	int i;
	for (i = 0; i < [lTokens count]; i++) {
		NSString *lToken = [lTokens objectAtIndex:i];
		if ([lUtils isURLToken:lToken]) {
			NSURL *lUrl = [NSURL URLWithString:[lServiceURL stringByAppendingString:lToken]];
			NSString *lTinyURLString = [NSString stringWithContentsOfURL:lUrl 
																encoding:NSUTF8StringEncoding 
																   error:nil];
			if (lTinyURLString && [lUtils isURLToken:lTinyURLString])
				lFinalMessage = [lFinalMessage stringByReplacingCharactersInRange:[lFinalMessage rangeOfString:lToken] 
																	   withString:lTinyURLString];
		}
	}
	return lFinalMessage;
}

- (void)makePost:(NSString *)aMessage {
	if ([aMessage length] == 0) return;
	[self startingTransaction];
	if ([[PTPreferenceManager sharedSingleton] urlShorteningService])
		aMessage = [self createShortURLs:aMessage];
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

- (void)setReplyID:(unsigned long)aId {
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
							forKey:[NSNumber numberWithUnsignedLong:lCurrentBox.updateId]];
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
		if ([aBox.userId isEqualToString:[[PTPreferenceManager sharedSingleton] userName]] && 
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
