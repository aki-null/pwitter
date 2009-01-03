//
//  PTMain.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 24/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTMain.h"


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

- (void)runInitialUpdates {
	[fProgressBar startAnimation:self];
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

- (IBAction)changeAccount:(id)aSender {
	[[fStatusController content] removeAllObjects];
	[fTwitterEngine setUsername:[[PTPreferenceManager getInstance] userName] 
					   password:[[PTPreferenceManager getInstance] password]];
	[self runInitialUpdates];
	[self setupUpdateTimer];
}

- (void)startAuthentication {
	if ([[PTPreferenceManager getInstance] autoLogin]) {
		[self setUpTwitterEngine];
		return;
	}
	[NSApp beginSheet:fAuthPanel
	   modalForWindow:fMainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
	NSString *lTempName = [[PTPreferenceManager getInstance] userName];
	NSString *lTempPass = [[PTPreferenceManager getInstance] password];
	if (lTempName)
		[fAuthUserName setStringValue:lTempName];
	if (lTempPass)
		[fAuthPassword setStringValue:lTempPass];
}

- (void)awakeFromNib
{
	fUpdateTimer = nil;
	fShouldExit = NO;
	fRequestDetails = [[NSMutableDictionary alloc] init];
	fImageLocationForReq = [[NSMutableDictionary alloc] init];
	fImageReqForLocation = [[NSMutableDictionary alloc] init];
	fStatusBoxesForReq = [[NSMutableDictionary alloc] init];
	fUserImageCache = [[NSMutableDictionary alloc] init];
	fDefaultImage = [NSImage imageNamed:@"default.png"];
	fWarningImage = [NSImage imageNamed:@"console.png"];
	NSDictionary *lLinkFormat =
	[NSDictionary dictionaryWithObjectsAndKeys:
	 [NSColor cyanColor], @"NSColor",
	 [NSCursor pointingHandCursor], @"NSCursor",
	 [NSNumber numberWithInt:1], @"NSUnderline",
	 nil];
	[fSelectedTextView setLinkTextAttributes:lLinkFormat];
	NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	[fStatusArrayController setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
	[sortDesc release];
	[fPreferenceWindow loadPreferences];
}

- (IBAction)closeAuthSheet:(id)aSender
{
	[[PTPreferenceManager getInstance] setUserName:[fAuthUserName stringValue] 
										  password:[fAuthPassword stringValue]];
    [NSApp endSheet:fAuthPanel];
}

- (void)didEndSheet:(NSWindow *)aSheet returnCode:(int)aReturnCode contextInfo:(void *)aContextInfo
{
	[aSheet orderOut:self];
	if (fShouldExit) [NSApp terminate:self];
	if (aSheet == fAuthPanel) [self setUpTwitterEngine];
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
	if ([fRequestDetails count] == 0) [fProgressBar stopAnimation:self];
	if (!lIgnoreError) {
		PTStatusBox *lErrorBox = [self constructErrorBox:aError];
		[fStatusController addObject:lErrorBox];
		[lErrorBox release];
	}
}

+ (void)processLinks:(NSMutableAttributedString *)aTargetString {
	NSString* lString = [aTargetString string];
	NSRange lSearchRange = NSMakeRange(0, [lString length]);
	NSRange lFoundRange;
	lFoundRange = [lString rangeOfString:@"http://" options:0 range:lSearchRange];
	if (lFoundRange.length > 0) {
		NSURL* lUrl;
		NSDictionary* lLinkAttributes;
		NSRange lEndOfURLRange;
		lSearchRange.location = lFoundRange.location + lFoundRange.length;
		lSearchRange.length = [lString length] - lSearchRange.location;
		lEndOfURLRange = [lString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
												  options:0 range:lSearchRange];
		if (lEndOfURLRange.length == 0)
			lEndOfURLRange.location = [lString length] - 1;
		lFoundRange.length = lEndOfURLRange.location - lFoundRange.location + 1;
		lUrl = [NSURL URLWithString:[lString substringWithRange:lFoundRange]];
		lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:lUrl, NSLinkAttributeName,
						   [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
						   [NSColor cyanColor], NSForegroundColorAttributeName,
						   nil];
		[aTargetString addAttributes:lLinkAttributes range:lFoundRange];
	}
}

- (PTStatusBox *)constructErrorBox:(NSError *)aError {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userName = @"Twitter Error:";
	lNewBox.userID = @"Twitter Error:";
	NSString *lErrorMessage = [NSString stringWithFormat:@"%@ (%@)", 
							   [aError localizedDescription], 
							   [[aError userInfo] objectForKey:NSErrorFailingURLStringKey]];
	NSMutableAttributedString *lFinalString = [[NSMutableAttributedString alloc] initWithString:lErrorMessage];
	[lFinalString addAttribute:NSForegroundColorAttributeName 
						 value:[NSColor whiteColor] 
						 range:NSMakeRange(0, [lFinalString length])];
	[lFinalString addAttribute:NSFontAttributeName 
						 value:[NSFont fontWithName:@"Helvetica" size:10.0] 
						 range:NSMakeRange(0, [lFinalString length])];
	lNewBox.statusMessage = lFinalString;
	[lFinalString release];
	lNewBox.userImage = fWarningImage;
	lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	lNewBox.time = [NSDate date];
	lNewBox.strTime = [lNewBox.time descriptionWithCalendarFormat:@"%H:%M:%S" 
					   timeZone:[NSTimeZone systemTimeZone] 
					   locale:nil];
	return lNewBox;
}

- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox {
	NSImage *lImageData = [fUserImageCache objectForKey:aImageLocation];
	if (!lImageData) {
		if (![fImageReqForLocation objectForKey:aImageLocation]) {
			[fProgressBar startAnimation:self];
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

- (PTStatusBox *)constructStatusBox:(NSDictionary *)aStatusInfo isReply:(BOOL)aIsReply {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userID = [[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"];
	NSString *lTempUserLabel = [NSString stringWithFormat:@"%@ / %@", 
								[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"], 
								[[aStatusInfo objectForKey:@"user"] objectForKey:@"name"]];
	NSMutableAttributedString *lUserLabel = [[NSMutableAttributedString alloc] initWithString:lTempUserLabel];
	NSDictionary *lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
									 [NSColor whiteColor], NSForegroundColorAttributeName,
									 nil];
	[lUserLabel addAttributes:lLinkAttributes range:NSMakeRange(0, [lUserLabel length])];
	lNewBox.userName = lUserLabel;
	[lUserLabel release];
	lNewBox.time = [aStatusInfo objectForKey:@"created_at"];
	lNewBox.strTime = [lNewBox.time descriptionWithCalendarFormat:@"%H:%M:%S" 
					   timeZone:[NSTimeZone systemTimeZone] 
					   locale:nil];
	NSString *lUnescaped = (NSString *)CFXMLCreateStringByUnescapingEntities(nil, (CFStringRef)[aStatusInfo objectForKey:@"text"], nil);
	NSMutableAttributedString *lNewMessage = [[NSMutableAttributedString alloc] initWithString:lUnescaped];
	[lNewMessage addAttribute:NSForegroundColorAttributeName 
						value:[NSColor whiteColor] 
						range:NSMakeRange(0, [lNewMessage length])];
	[lNewMessage addAttribute:NSFontAttributeName 
						value:[NSFont fontWithName:@"Helvetica" size:10.0] 
						range:NSMakeRange(0, [lNewMessage length])];
	[PTMain processLinks:lNewMessage];
	lNewBox.statusMessage = lNewMessage;
	[lNewMessage release];
	lNewBox.userImage = [self requestUserImage:[[aStatusInfo objectForKey:@"user"] objectForKey:@"profile_image_url"]
										forBox:lNewBox];
	lNewBox.updateID = [aStatusInfo objectForKey:@"id"];
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"user"] objectForKey:@"url"];
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	if (aIsReply) {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:1.0 green:0.3 blue:0.3 alpha:0.7];
	} else {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	}
	return lNewBox;
}

- (void)statusesReceived:(NSArray *)aStatuses forRequest:(NSString *)aIdentifier
{
	if ([aStatuses count] == 0) {
		[fRequestDetails removeObjectForKey:aIdentifier];
		if ([fRequestDetails count] == 0) [fProgressBar stopAnimation:self];
		return;
	}
	NSDictionary *lCurrentStatus;
	NSDictionary *lLastStatus = nil;
	NSMutableArray *lTempBoxes = [[NSMutableArray alloc] init];
	for (lCurrentStatus in aStatuses) {
		PTStatusBox *lBoxToAdd = nil;
		if ([[lCurrentStatus objectForKey:@"in_reply_to_screen_name"] isEqualToString:[fTwitterEngine username]]) {
			if ([fRequestDetails objectForKey:aIdentifier] != @"INIT_UPDATE")
				lBoxToAdd = [self constructStatusBox:lCurrentStatus isReply:YES];
		} else lBoxToAdd = [self constructStatusBox:lCurrentStatus isReply:NO];
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
	if ([fRequestDetails count] == 0) [fProgressBar stopAnimation:self];
}

- (PTStatusBox *)constructMessageBox:(NSDictionary *)aStatusInfo {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	NSString *lTempUserLabel = [NSString stringWithFormat:@"%@ / %@", 
								[[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"], 
								[[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"]];
	NSMutableAttributedString *lUserLabel = [[NSMutableAttributedString alloc] initWithString:lTempUserLabel];
	NSDictionary *lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
									 [NSColor whiteColor], NSForegroundColorAttributeName,
									 nil];
	[lUserLabel addAttributes:lLinkAttributes range:NSMakeRange(0, [lUserLabel length])];
	lNewBox.userName = lUserLabel;
	[lUserLabel release];
	lNewBox.userID = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"];
	lNewBox.time = [aStatusInfo objectForKey:@"created_at"];
	lNewBox.strTime = [lNewBox.time descriptionWithCalendarFormat:@"%H:%M:%S" 
					   timeZone:[NSTimeZone systemTimeZone] 
					   locale:nil];
	NSString *lUnescaped = (NSString *)CFXMLCreateStringByUnescapingEntities(nil, (CFStringRef)[aStatusInfo objectForKey:@"text"], nil);
	NSMutableAttributedString *lNewMessage = [[NSMutableAttributedString alloc] initWithString:lUnescaped];
	[lNewMessage addAttribute:NSForegroundColorAttributeName
						value:[NSColor whiteColor]
						range:NSMakeRange(0, [lNewMessage length])];
	[lNewMessage addAttribute:NSFontAttributeName 
						value:[NSFont fontWithName:@"Helvetica" size:10.0] 
						range:NSMakeRange(0, [lNewMessage length])];
	[PTMain processLinks:lNewMessage];
	lNewBox.statusMessage = lNewMessage;
	[lNewMessage release];
	lNewBox.userImage = [self requestUserImage:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"profile_image_url"]
										forBox:lNewBox];
	lNewBox.updateID = [aStatusInfo objectForKey:@"id"];
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"url"];
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.5 blue:1.0 alpha:0.8];
	return lNewBox;
}

- (void)directMessagesReceived:(NSArray *)aMessages forRequest:(NSString *)aIdentifier
{
	[fRequestDetails removeObjectForKey:aIdentifier];
	if ([fRequestDetails count] == 0) [fProgressBar stopAnimation:self];
	if ([aMessages count] == 0) return;
	NSDictionary *lCurrentDic;
	NSDictionary *lLastDic = nil;
	NSMutableArray *lTempArray = [[NSMutableArray alloc] init];
	for (lCurrentDic in aMessages) {
		PTStatusBox *lBoxToAdd = [self constructMessageBox:lCurrentDic];
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
	if ([fRequestDetails count] == 0) [fProgressBar stopAnimation:self];
}

- (IBAction)updateTimeline:(id)aSender {
	[fProgressBar startAnimation:aSender];
	[fRequestDetails setObject:@"UPDATE" 
						forKey: [fTwitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] userName] 
															   sinceID:fLastUpdateID startingAtPage:0 count:100]];
	[fRequestDetails setObject:@"MESSAGE_UPDATE" 
						forKey: [fTwitterEngine getDirectMessagesSinceID:fLastMessageID
														  startingAtPage:0]];
}

- (IBAction)postStatus:(id)aSender {
	[fProgressBar startAnimation:aSender];
	if ([fMessageButton state] == NSOnState) {
		[fRequestDetails setObject:@"MESSAGE" 
							forKey:[fTwitterEngine sendDirectMessage:[fStatusUpdateField stringValue]
																  to:fCurrentSelection.userID]];
	} else if ([fReplyButton state] == NSOnState) {
		[fRequestDetails setObject:@"POST" 
							forKey:[fTwitterEngine sendUpdate:[fStatusUpdateField stringValue] 
													inReplyTo:fCurrentSelection.updateID]];
	} else {
		[fRequestDetails setObject:@"POST" 
							forKey:[fTwitterEngine sendUpdate:[fStatusUpdateField stringValue]]];
	}
	[fStatusUpdateField setEnabled:NO];
}

- (IBAction)quitApp:(id)aSender {
	fShouldExit = YES;
	[NSApp endSheet:fAuthPanel];
}

- (IBAction)messageToSelected:(id)aSender {
	if ([aSender state] == NSOnState) {
		if ([fReplyButton state] == NSOnState) {
			[fReplyButton setState:NSOffState];
		}
		[fStatusUpdateField selectText:aSender];
	}
}

- (IBAction)openHome:(id)aSender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://twitter.com/home"]];
}

- (void)openTwitterWeb {
	if (fCurrentSelection && fCurrentSelection.userID != @"Twitter Error:")
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", fCurrentSelection.userID]]];
}

- (IBAction)openWebSelected:(id)aSender {
	[[NSWorkspace sharedWorkspace] openURL:fCurrentSelection.userHome];
}

- (IBAction)replyToSelected:(id)aSender {
	if ([aSender state] == NSOnState) {
		if ([fMessageButton state] == NSOnState) {
			[fMessageButton setState:NSOffState];
		}
		NSString *replyTarget = [NSString stringWithFormat:@"@%@ %@", fCurrentSelection.userID, [fStatusUpdateField stringValue]];
		[fStatusUpdateField setStringValue:replyTarget];
		[fMainWindow makeFirstResponder:fStatusUpdateField];
		[(NSText *)[fMainWindow firstResponder] setSelectedRange:NSMakeRange([[fStatusUpdateField stringValue] length], 0)];
	}
}

- (void)selectStatusBox:(PTStatusBox *)aSelection {
	if (!aSelection) return;
	[fReplyButton setState:NSOffState];
	[fMessageButton setState:NSOffState];
	if (!aSelection.userHome) {
		[fWebButton setEnabled:NO];
	} else {
		[fWebButton setEnabled:YES];
	}
	if (aSelection.userName == @"Twitter Error:") {
		[fReplyButton setEnabled:NO];
		[fMessageButton setEnabled:NO];
	} else {
		[fReplyButton setEnabled:YES];
		[fMessageButton setEnabled:YES];
	}
	fCurrentSelection = aSelection;
}

- (IBAction)openPref:(id)aSender {
	[fPreferenceWindow loadPreferences];
	[NSApp beginSheet:fPreferenceWindow
	   modalForWindow:fMainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

@end
