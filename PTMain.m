#import "PTMain.h"

@implementation PTMain

- (void)setupUpdateTimer {
	if (updateTimer) {
		[updateTimer invalidate];
		[updateTimer release];
	}
	int intervalTime;
	switch ([[PTPreferenceManager getInstance] timeInterval]) {
		case 1:
			intervalTime = 180;
			break;
		case 2:
			intervalTime = 120;
			break;
		case 3:
			intervalTime = 90;
			break;
	}
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:intervalTime 
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
	[twitterEngine setClientName:@"Pwitter" version:@"0.1" URL:@"" token:@"pwitter"];
	[twitterEngine setUsername:[[PTPreferenceManager getInstance] getUserName] 
					  password:[[PTPreferenceManager getInstance] getPassword]];
	[progressBar startAnimation:self];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					   forKey: [twitterEngine getDirectMessagesSince:nil
													  startingAtPage:0]];
	[requestDetails setObject:@"INIT_UPDATE" 
					   forKey:[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] 
															  since:nil startingAtPage:0 count:50]];
	[self setupUpdateTimer];
}

- (void)changeAccount {
	[progressBar startAnimation:self];
	[[statusController content] removeAllObjects];
	[twitterEngine setUsername:[[PTPreferenceManager getInstance] getUserName] 
					  password:[[PTPreferenceManager getInstance] getPassword]];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					   forKey:[twitterEngine getDirectMessagesSince:nil
													 startingAtPage:0]];
	[requestDetails setObject:@"INIT_UPDATE" 
					   forKey:[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] 
															  since:nil startingAtPage:0 count:50]];
	[self setupUpdateTimer];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[NSApp beginSheet:authPanel
	   modalForWindow:mainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
	NSString *tempName = [[PTPreferenceManager getInstance] getUserName];
	NSString *tempPass = [[PTPreferenceManager getInstance] getPassword];
	if (tempName)
		[authUserName setStringValue:tempName];
	if (tempPass)
		[authPassword setStringValue:tempPass];
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
	NSDictionary *linkFormat =
	[NSDictionary dictionaryWithObjectsAndKeys:
	 [NSColor cyanColor], @"NSColor",
	 [NSCursor pointingHandCursor], @"NSCursor",
	 [NSNumber numberWithInt:1], @"NSUnderline",
	 nil];
	[selectedTextView setLinkTextAttributes:linkFormat];
	NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	[statusArrayController setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
	[sortDesc release];
	[preferenceWindow loadPreferences];
}

- (IBAction)closeAuthSheet:(id)sender
{
	[[PTPreferenceManager getInstance] setUserName:[authUserName stringValue]];
	[[PTPreferenceManager getInstance] savePassword:[authPassword stringValue]];
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
	[twitterEngine release];
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

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error
{
	NSString *requestType = [requestDetails objectForKey:requestIdentifier];
	if (requestType == @"POST" || requestType == @"MESSAGE") {
		[statusUpdateField setEnabled:YES];
	} else if (requestType == @"IMAGE") {
		[statusBoxesForReq removeObjectForKey:requestIdentifier];
		[imageReqForLocation removeObjectForKey:[imageLocationForReq objectForKey:requestIdentifier]];
		[imageLocationForReq removeObjectForKey:requestIdentifier];
	}
	[requestDetails removeObjectForKey:requestIdentifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
	[statusController addObject:[self constructErrorBox:error]];
}

+ (void)processLinks:(NSMutableAttributedString *)aTargetString {
	NSString* string = [aTargetString string];
	NSRange searchRange = NSMakeRange(0, [string length]);
	NSRange foundRange;
	foundRange = [string rangeOfString:@"http://" options:0 range:searchRange];
	if (foundRange.length > 0) {
		NSURL* theURL;
		NSDictionary* linkAttributes;
		NSRange endOfURLRange;
		searchRange.location = foundRange.location + foundRange.length;
		searchRange.length = [string length] - searchRange.location;
		endOfURLRange = [string rangeOfCharacterFromSet:
						 [NSCharacterSet whitespaceAndNewlineCharacterSet]
												options:0 range:searchRange];
		if (endOfURLRange.length == 0)
			endOfURLRange.location = [string length] - 1;
		foundRange.length = endOfURLRange.location - foundRange.location + 1;
		theURL=[NSURL URLWithString:[string substringWithRange:foundRange]];
		linkAttributes= [NSDictionary dictionaryWithObjectsAndKeys:theURL, NSLinkAttributeName,
						 [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
						 [NSColor cyanColor], NSForegroundColorAttributeName,
						 nil];
		[aTargetString addAttributes:linkAttributes range:foundRange];
	}
}

- (PTStatusBox *)constructErrorBox:(NSError *)aError {
	PTStatusBox *newBox = [[PTStatusBox alloc] init];
	newBox.userName = @"Twitter Error:";
	NSMutableString *errorMessage = 
	[[NSMutableString alloc] initWithFormat:@"%@ (%@)", 
	 [aError localizedDescription], 
	 [[aError userInfo] objectForKey:NSErrorFailingURLStringKey]];
	NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithString:errorMessage];
	[finalString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor whiteColor] 
						range:NSMakeRange(0, [finalString length])];
	[finalString addAttribute:NSFontAttributeName 
						value:[NSFont fontWithName:@"Helvetica" size:10.0] 
						range:NSMakeRange(0, [finalString length])];
	newBox.statusMessage = finalString;
	newBox.userImage = warningImage;
	newBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	newBox.time = [[NSDate alloc] init];
	return newBox;
}

- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox {
	NSImage *imageData = [userImageCache objectForKey:aImageLocation];
	if (!imageData) {
		if (![imageReqForLocation objectForKey:aImageLocation]) {
			[progressBar startAnimation:self];
			NSString *imageReq = [twitterEngine getImageAtURL:aImageLocation];
			[requestDetails setObject:@"IMAGE" forKey:imageReq];
			[imageReqForLocation setObject:imageReq forKey:aImageLocation];
			[imageLocationForReq setObject:aImageLocation forKey:imageReq];
			[statusBoxesForReq setObject:[[NSMutableArray alloc] init] forKey:imageReq];
		}
		NSMutableArray *requestedBoxes = [statusBoxesForReq objectForKey:[imageReqForLocation objectForKey:aImageLocation]];
		[requestedBoxes addObject:aNewBox];
		return defaultImage;
	} else {
		return imageData;
	}
}

- (PTStatusBox *)constructStatusBox:(NSDictionary *)aStatusInfo {
	PTStatusBox *newBox = [[PTStatusBox alloc] init];
	newBox.userName = 
	[[NSString alloc] initWithFormat:@"%@ / %@", 
	 [[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"], 
	 [[aStatusInfo objectForKey:@"user"] objectForKey:@"name"]];
	newBox.userID = [[NSString alloc] initWithString:[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"]];
	newBox.time = [aStatusInfo objectForKey:@"created_at"];
	NSMutableAttributedString *newMessage = 
	[[NSMutableAttributedString alloc] initWithString:[aStatusInfo objectForKey:@"text"]];
	[newMessage addAttribute:NSForegroundColorAttributeName
					   value:[NSColor whiteColor]
					   range:NSMakeRange(0, [newMessage length])];
	[newMessage addAttribute:NSFontAttributeName 
					   value:[NSFont fontWithName:@"Helvetica" size:10.0] 
					   range:NSMakeRange(0, [newMessage length])];
	[PTMain processLinks:newMessage];
	newBox.statusMessage = newMessage;
	newBox.userImage = [self requestUserImage:[[aStatusInfo objectForKey:@"user"] objectForKey:@"profile_image_url"]
									   forBox:newBox];
	newBox.updateID = [[NSString alloc] initWithString:[aStatusInfo objectForKey:@"id"]];
	NSString *urlStr = [[aStatusInfo objectForKey:@"user"] objectForKey:@"url"];
	if ([urlStr length] != 0) {
		newBox.userHome = [[NSURL alloc] initWithString:urlStr];
	} else {
		newBox.userHome = nil;
	}
	if ([[aStatusInfo objectForKey:@"in_reply_to_screen_name"] isEqualToString:[twitterEngine username]]) {
		newBox.entityColor = [NSColor colorWithCalibratedRed:1.0 green:0.3 blue:0.3 alpha:0.7];
	} else {
		newBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	}
	return newBox;
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
	if ([statuses count] == 0) {
		[requestDetails removeObjectForKey:identifier];
		if ([requestDetails count] == 0) [progressBar stopAnimation:self];
		return;
	}
	NSDictionary *currentStatus;
	NSDictionary *lastStatus;
	NSMutableArray *tempBoxes = [[NSMutableArray alloc] init];
	for (currentStatus in [statuses reverseObjectEnumerator]) {
		[tempBoxes addObject:[self constructStatusBox:currentStatus]];
		lastStatus = currentStatus;
	}
	[statusController addObjects:tempBoxes];
	lastUpdateID = [[NSString alloc] initWithString:[lastStatus objectForKey:@"id"]];
	if ([requestDetails objectForKey:identifier] == @"POST") {
		[statusUpdateField setEnabled:YES];
		[statusUpdateField setStringValue:[[NSString alloc] init]];
		[textLevelIndicator setIntValue:140];
	}
	[requestDetails removeObjectForKey:identifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
}

- (PTStatusBox *)constructMessageBox:(NSDictionary *)aStatusInfo {
	PTStatusBox *newBox = [[PTStatusBox alloc] init];
	NSString *comboName = 
	[[NSString alloc] initWithFormat:@"%@ / %@", 
	 [[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"], 
	 [[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"]];
	newBox.userName = comboName;
	newBox.userID = [[NSString alloc] initWithString:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"]];
	newBox.time = [aStatusInfo objectForKey:@"created_at"];
	NSMutableAttributedString *newMessage = 
	[[NSMutableAttributedString alloc] initWithString:[aStatusInfo objectForKey:@"text"]];
	[newMessage addAttribute:NSForegroundColorAttributeName
					   value:[NSColor whiteColor]
					   range:NSMakeRange(0, [newMessage length])];
	[newMessage addAttribute:NSFontAttributeName 
					   value:[NSFont fontWithName:@"Helvetica" size:10.0] 
					   range:NSMakeRange(0, [newMessage length])];
	[PTMain processLinks:newMessage];
	newBox.statusMessage = newMessage;
	newBox.userImage = [self requestUserImage:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"profile_image_url"]
									   forBox:newBox];
	newBox.updateID = [[NSString alloc] initWithString:[aStatusInfo objectForKey:@"id"]];
	NSString *urlStr = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"url"];
	if ([urlStr length] != 0) {
		newBox.userHome = [[NSURL alloc] initWithString:urlStr];
	} else {
		newBox.userHome = nil;
	}
	newBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.5 blue:1.0 alpha:0.8];
	return newBox;
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier
{
	[requestDetails removeObjectForKey:identifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
	if ([messages count] == 0) return;
	NSDictionary *currentDic;
	NSDictionary *lastDic;
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (currentDic in [messages reverseObjectEnumerator]) {
		[tempArray addObject:[self constructMessageBox:currentDic]];
		lastDic = currentDic;
	}
	[statusController addObjects:tempArray];
	lastMessageID = [[NSString alloc] initWithString:[lastDic objectForKey:@"id"]];
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier
{
	// not implemented
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)identifier
{
	// not implemented
}

- (void)imageReceived:(NSImage *)image forRequest:(NSString *)identifier
{
	PTStatusBox *currentBox;
	for (currentBox in [statusBoxesForReq objectForKey:identifier]) {
		currentBox.userImage = image;
	}
	NSString *imageLocation = [imageLocationForReq objectForKey:identifier];
	[userImageCache setObject:image forKey:imageLocation];
	[statusBoxesForReq removeObjectForKey:identifier];
	[imageReqForLocation removeObjectForKey:imageLocation];
	[imageLocationForReq removeObjectForKey:identifier];
	[requestDetails removeObjectForKey:identifier];
	if ([requestDetails count] == 0) [progressBar stopAnimation:self];
}

- (IBAction)updateTimeline:(id)sender {
	[progressBar startAnimation:sender];
	[requestDetails setObject:@"UPDATE" 
					   forKey: [twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] 
															 sinceID:lastUpdateID startingAtPage:0 count:100]];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					   forKey: [twitterEngine getDirectMessagesSinceID:lastMessageID
														startingAtPage:0]];
	[self setupUpdateTimer];
}

- (IBAction)postStatus:(id)sender {
	[progressBar startAnimation:sender];
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

- (IBAction)quitApp:(id)sender {
	shouldExit = YES;
	[NSApp endSheet:authPanel];
}

- (IBAction)messageToSelected:(id)sender {
	if ([sender state] == NSOnState) {
		if ([replyButton state] == NSOnState) {
			[replyButton setState:NSOffState];
		}
		[statusUpdateField selectText:sender];
	}
}

- (IBAction)openHome:(id)sender {
	NSURL *homeURL = [[NSURL alloc] initWithString:@"http://twitter.com/home"];
	[[NSWorkspace sharedWorkspace] openURL:homeURL];
}

- (IBAction)openWebSelected:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:currentSelection.userHome];
}

- (IBAction)replyToSelected:(id)sender {
	if ([sender state] == NSOnState) {
		if ([messageButton state] == NSOnState) {
			[messageButton setState:NSOffState];
		}
		NSString *replyTarget = 
		[[NSString alloc] initWithFormat:@"@%@ %@", 
		 currentSelection.userID, 
		 [statusUpdateField stringValue]];
		[statusUpdateField setStringValue:replyTarget];
		[statusUpdateField selectText:sender];
	}
}

- (void)selectStatusBox:(PTStatusBox *)aSelection {
	if (!aSelection) return;
	NSMutableAttributedString *selectedMessage = 
	[[NSMutableAttributedString alloc] initWithAttributedString:aSelection.statusMessage];
	[selectedMessage addAttribute:NSFontAttributeName 
							value:[NSFont fontWithName:@"Helvetica" size:11.0] 
							range:NSMakeRange(0, [selectedMessage length])];
	[[selectedTextView textStorage]setAttributedString:selectedMessage];
	[userNameBox setStringValue:aSelection.userName];
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

- (IBAction)openPref:(id)sender {
	[NSApp beginSheet:preferenceWindow
	   modalForWindow:mainWindow
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

@end
