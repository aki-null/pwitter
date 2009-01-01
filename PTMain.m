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
	if (updateTimer) {
		[updateTimer invalidate];
		[updateTimer release];
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
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:lIntervalTime 
													target:self 
												  selector:@selector(runUpdateFromTimer:) 
												  userInfo:nil 
												   repeats:YES] retain];
}

- (void)runUpdateFromTimer:(NSTimer *)aTimer {
	[self updateTimeline:aTimer];
}

- (void)setUpTwitterEngine {
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine setClientName:@"Pwitter" version:@"0.2" URL:@"" token:@"pwitter"];
	[twitterEngine setUsername:[[PTPreferenceManager getInstance] userName] 
					  password:[[PTPreferenceManager getInstance] password]];
	[progressBar startAnimation:self];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					   forKey: [twitterEngine getDirectMessagesSince:nil
													  startingAtPage:0]];
	[requestDetails setObject:@"INIT_UPDATE" 
					   forKey:[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] userName] 
															  since:nil startingAtPage:0 count:50]];
	[self setupUpdateTimer];
}

- (void)changeAccount {
	[progressBar startAnimation:self];
	[[statusController content] removeAllObjects];
	[twitterEngine setUsername:[[PTPreferenceManager getInstance] userName] 
					  password:[[PTPreferenceManager getInstance] password]];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					   forKey:[twitterEngine getDirectMessagesSince:nil
													 startingAtPage:0]];
	[requestDetails setObject:@"INIT_UPDATE" 
					   forKey:[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] userName] 
															  since:nil startingAtPage:0 count:50]];
	[self setupUpdateTimer];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	if ([[PTPreferenceManager getInstance] autoLogin]) {
		[self setUpTwitterEngine];
		return;
	}
	[NSApp beginSheet:authPanel
	   modalForWindow:mainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
	NSString *lTempName = [[PTPreferenceManager getInstance] userName];
	NSString *lTempPass = [[PTPreferenceManager getInstance] password];
	if (lTempName)
		[authUserName setStringValue:lTempName];
	if (lTempPass)
		[authPassword setStringValue:lTempPass];
}

- (void)awakeFromNib
{
	updateTimer = nil;
	shouldExit = NO;
	requestDetails = [[NSMutableDictionary alloc] init];
	imageLocationForReq = [[NSMutableDictionary alloc] init];
	imageReqForLocation = [[NSMutableDictionary alloc] init];
	statusBoxesForReq = [[NSMutableDictionary alloc] init];
	userImageCache = [[NSMutableDictionary alloc] init];
	defaultImage = [NSImage imageNamed:@"default.png"];
	warningImage = [NSImage imageNamed:@"console.png"];
	NSDictionary *lLinkFormat =
	[NSDictionary dictionaryWithObjectsAndKeys:
	 [NSColor cyanColor], @"NSColor",
	 [NSCursor pointingHandCursor], @"NSCursor",
	 [NSNumber numberWithInt:1], @"NSUnderline",
	 nil];
	[selectedTextView setLinkTextAttributes:lLinkFormat];
	NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	[statusArrayController setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
	[sortDesc release];
	[preferenceWindow loadPreferences];
}

- (IBAction)closeAuthSheet:(id)aSender
{
	[[PTPreferenceManager getInstance] setUserName:[authUserName stringValue] 
										  password:[authPassword stringValue]];
    [NSApp endSheet:authPanel];
}

- (void)didEndSheet:(NSWindow *)aSheet returnCode:(int)aReturnCode contextInfo:(void *)aContextInfo
{
	[aSheet orderOut:self];
	if (shouldExit) [NSApp terminate:self];
	if (aSheet == authPanel) [self setUpTwitterEngine];
}

- (void)dealloc
{
	if (requestDetails) [requestDetails release];
	if (imageLocationForReq) [imageLocationForReq release];
	if (imageReqForLocation) [imageReqForLocation release];
	if (statusBoxesForReq) [statusBoxesForReq release];
	if (userImageCache) [userImageCache release];
	if (twitterEngine) [twitterEngine release];
	if (lastUpdateID) [lastUpdateID release];
	if (lastMessageID) [lastMessageID release];
	if (updateTimer) {
		[updateTimer invalidate];
		[updateTimer release];
	}
	[super dealloc];
}

- (void)requestSucceeded:(NSString *)requestIdentifier
{
	if ([requestDetails objectForKey:requestIdentifier] == @"MESSAGE") {
		[statusUpdateField setEnabled:YES];
		[statusUpdateField setStringValue:@""];
		[messageButton setState:NSOffState];
		[textLevelIndicator setIntValue:140];
	}
}

- (void)requestFailed:(NSString *)aRequestIdentifier withError:(NSError *)aError
{
	BOOL lIgnoreError = NO;
	NSString *lRequestType = [requestDetails objectForKey:aRequestIdentifier];
	if (lRequestType == @"POST" || lRequestType == @"MESSAGE") {
		[statusUpdateField setEnabled:YES];
	} else if (lRequestType == @"IMAGE") {
		[statusBoxesForReq removeObjectForKey:aRequestIdentifier];
		[imageReqForLocation removeObjectForKey:[imageLocationForReq objectForKey:aRequestIdentifier]];
		[imageLocationForReq removeObjectForKey:aRequestIdentifier];
		lIgnoreError = YES;
	}
	[requestDetails removeObjectForKey:aRequestIdentifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
	if (!lIgnoreError) {
		PTStatusBox *lErrorBox = [self constructErrorBox:aError];
		[statusController addObject:lErrorBox];
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
	lNewBox.userImage = warningImage;
	lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	lNewBox.time = [NSDate date];
	lNewBox.strTime = [lNewBox.time descriptionWithCalendarFormat:@"%H:%M:%S" 
					   timeZone:[NSTimeZone systemTimeZone] 
					   locale:nil];
	return lNewBox;
}

- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox {
	NSImage *lImageData = [userImageCache objectForKey:aImageLocation];
	if (!lImageData) {
		if (![imageReqForLocation objectForKey:aImageLocation]) {
			[progressBar startAnimation:self];
			NSString *lImageReq = [twitterEngine getImageAtURL:aImageLocation];
			[requestDetails setObject:@"IMAGE" forKey:lImageReq];
			[imageReqForLocation setObject:lImageReq forKey:aImageLocation];
			[imageLocationForReq setObject:aImageLocation forKey:lImageReq];
			[statusBoxesForReq setObject:[[[NSMutableArray alloc] init] autorelease] forKey:lImageReq];
		}
		NSMutableArray *lRequestedBoxes = [statusBoxesForReq objectForKey:[imageReqForLocation objectForKey:aImageLocation]];
		[lRequestedBoxes addObject:aNewBox];
		return defaultImage;
	} else {
		return lImageData;
	}
}

- (PTStatusBox *)constructStatusBox:(NSDictionary *)aStatusInfo {
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
	if ([[aStatusInfo objectForKey:@"in_reply_to_screen_name"] isEqualToString:[twitterEngine username]]) {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:1.0 green:0.3 blue:0.3 alpha:0.7];
	} else {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	}
	return lNewBox;
}

- (void)statusesReceived:(NSArray *)aStatuses forRequest:(NSString *)aIdentifier
{
	if ([aStatuses count] == 0) {
		[requestDetails removeObjectForKey:aIdentifier];
		if ([requestDetails count] == 0) [progressBar stopAnimation:self];
		return;
	}
	NSDictionary *lCurrentStatus;
	NSDictionary *lLastStatus = nil;
	NSMutableArray *lTempBoxes = [[NSMutableArray alloc] init];
	for (lCurrentStatus in aStatuses) {
		PTStatusBox *lBoxToAdd = [self constructStatusBox:lCurrentStatus];
		[lTempBoxes addObject:lBoxToAdd];
		[lBoxToAdd release];
		if (!lLastStatus) lLastStatus = lCurrentStatus;
	}
	[statusController addObjects:lTempBoxes];
	[lTempBoxes release];
	if (lastUpdateID) [lastUpdateID release];
	lastUpdateID = [[NSString alloc] initWithString:[lLastStatus objectForKey:@"id"]];
	if ([requestDetails objectForKey:aIdentifier] == @"POST") {
		[statusUpdateField setEnabled:YES];
		[statusUpdateField setStringValue:@""];
		[textLevelIndicator setIntValue:140];
	}
	[requestDetails removeObjectForKey:aIdentifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
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
	[requestDetails removeObjectForKey:aIdentifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
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
	[statusController addObjects:lTempArray];
	[lTempArray release];
	if (lastUpdateID) [lastUpdateID release];
	lastMessageID = [[NSString alloc] initWithString:[lLastDic objectForKey:@"id"]];
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
	for (lCurrentBox in [statusBoxesForReq objectForKey:aIdentifier]) {
		lCurrentBox.userImage = aImage;
	}
	NSString *lImageLocation = [imageLocationForReq objectForKey:aIdentifier];
	[userImageCache setObject:aImage forKey:lImageLocation];
	[statusBoxesForReq removeObjectForKey:aIdentifier];
	[imageReqForLocation removeObjectForKey:lImageLocation];
	[imageLocationForReq removeObjectForKey:aIdentifier];
	[requestDetails removeObjectForKey:aIdentifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
}

- (IBAction)updateTimeline:(id)aSender {
	[progressBar startAnimation:aSender];
	[requestDetails setObject:@"UPDATE" 
					   forKey: [twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] userName] 
															 sinceID:lastUpdateID startingAtPage:0 count:100]];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					   forKey: [twitterEngine getDirectMessagesSinceID:lastMessageID
														startingAtPage:0]];
}

- (IBAction)postStatus:(id)aSender {
	[progressBar startAnimation:aSender];
	if ([messageButton state] == NSOnState) {
		[requestDetails setObject:@"MESSAGE" 
						   forKey:[twitterEngine sendDirectMessage:[statusUpdateField stringValue]
																to:currentSelection.userID]];
	} else if ([replyButton state] == NSOnState) {
		[requestDetails setObject:@"POST" 
						   forKey:[twitterEngine sendUpdate:[statusUpdateField stringValue] 
												  inReplyTo:currentSelection.updateID]];
	} else {
		[requestDetails setObject:@"POST" 
						   forKey:[twitterEngine sendUpdate:[statusUpdateField stringValue]]];
	}
	[statusUpdateField setEnabled:NO];
}

- (IBAction)quitApp:(id)aSender {
	shouldExit = YES;
	[NSApp endSheet:authPanel];
}

- (IBAction)messageToSelected:(id)aSender {
	if ([aSender state] == NSOnState) {
		if ([replyButton state] == NSOnState) {
			[replyButton setState:NSOffState];
		}
		[statusUpdateField selectText:aSender];
	}
}

- (IBAction)openHome:(id)aSender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://twitter.com/home"]];
}

- (void)openTwitterWeb {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", currentSelection.userID]]];
}

- (IBAction)openWebSelected:(id)aSender {
	[[NSWorkspace sharedWorkspace] openURL:currentSelection.userHome];
}

- (IBAction)replyToSelected:(id)aSender {
	if ([aSender state] == NSOnState) {
		if ([messageButton state] == NSOnState) {
			[messageButton setState:NSOffState];
		}
		NSString *replyTarget = [NSString stringWithFormat:@"@%@ %@", currentSelection.userID, [statusUpdateField stringValue]];
		[statusUpdateField setStringValue:replyTarget];
		[mainWindow makeFirstResponder:statusUpdateField];
		[(NSText *)[mainWindow firstResponder] setSelectedRange:NSMakeRange([[statusUpdateField stringValue] length], 0)];
	}
}

- (void)selectStatusBox:(PTStatusBox *)aSelection {
	if (!aSelection) return;
	[replyButton setState:NSOffState];
	[messageButton setState:NSOffState];
	if (!aSelection.userHome) {
		[webButton setEnabled:NO];
	} else {
		[webButton setEnabled:YES];
	}
	if (aSelection.userName == @"Twitter Error:") {
		[replyButton setEnabled:NO];
		[messageButton setEnabled:NO];
	} else {
		[replyButton setEnabled:YES];
		[messageButton setEnabled:YES];
	}
	currentSelection = aSelection;
}

- (IBAction)openPref:(id)aSender {
	[preferenceWindow loadPreferences];
	[NSApp beginSheet:preferenceWindow
	   modalForWindow:mainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

@end
