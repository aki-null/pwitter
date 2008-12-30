#import "PTMain.h"

@implementation PTMain

- (void)setUpTwitterEngine {
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine setClientName:@"Pwitter" version:@"0.1" URL:@"" token:@"pwitter"];
	[twitterEngine setUsername:[[PTPreferenceManager getInstance] getUserName] 
				   password:[[PTPreferenceManager getInstance] getPassword]];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					forKey: [twitterEngine getDirectMessagesSince:nil
										   startingAtPage:0]];
	[requestDetails setObject:@"INIT_UPDATE" 
					forKey:[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] 
					since:nil startingAtPage:0]];
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
	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	[statusArrayController setSortDescriptors:[NSArray arrayWithObject:sd]];
}

- (IBAction)closeAuthSheet:(id)sender
{
	[[PTPreferenceManager getInstance] setUserName:[authUserName stringValue]];
	[[PTPreferenceManager getInstance] savePassword:[authPassword stringValue]];
    [NSApp endSheet:authPanel];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[authPanel orderOut:self];
	if (shouldExit) [NSApp terminate:self];
	[self setUpTwitterEngine];
}

- (void)dealloc
{
	[twitterEngine release];
	[super dealloc];
}

- (void)requestSucceeded:(NSString *)requestIdentifier
{
	NSLog(@"Request succeeded (%@)", requestIdentifier);
	if ([requestDetails objectForKey:requestIdentifier] == @"MESSAGE") {
		[statusUpdateField setEnabled:YES];
		[statusUpdateField setStringValue:@""];
		[messageButton setState:NSOffState];
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
	[statusController addObject:[self constructErrorBox:error]];
}

+ (void)processLinks:(NSMutableAttributedString *)targetString {
	NSString* string = [targetString string];
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
		[targetString addAttributes:linkAttributes range:foundRange];
	}
}

- (PTStatusBox *)constructErrorBox:(NSError *)error {
	PTStatusBox *newBox = [[PTStatusBox alloc] init];
	newBox.userName = @"Twitter request failed:";
	NSMutableString *errorMessage = 
		[[NSMutableString alloc] initWithFormat:@"%@ (%@)", 
								 [error localizedDescription], 
								 [[error userInfo] objectForKey:NSErrorFailingURLStringKey]];
	NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithString:errorMessage];
	[finalString addAttribute:NSForegroundColorAttributeName
				 value:[NSColor whiteColor]
				 range:NSMakeRange(0, [finalString length])];
	newBox.statusMessage = finalString;
	newBox.userImage = warningImage;
	newBox.entityColor = [NSColor redColor];
	newBox.time = [[NSDate alloc] init];
	return newBox;
}

- (PTStatusBox *)constructStatusBox:(NSDictionary *)statusInfo {
	PTStatusBox *newBox = [[PTStatusBox alloc] init];
	NSString *comboName = 
		[[NSString alloc] initWithFormat:@"%@ / %@", 
						  [[statusInfo objectForKey:@"user"] objectForKey:@"screen_name"], 
						  [[statusInfo objectForKey:@"user"] objectForKey:@"name"]];
	newBox.userName = comboName;
	newBox.userID = [[NSString alloc] initWithString:[[statusInfo objectForKey:@"user"] objectForKey:@"screen_name"]];
	newBox.time = [statusInfo objectForKey:@"created_at"];
	NSMutableAttributedString *newMessage = 
		[[NSMutableAttributedString alloc] initWithString:[statusInfo objectForKey:@"text"]];
	[newMessage addAttribute:NSForegroundColorAttributeName
				value:[NSColor whiteColor]
				range:NSMakeRange(0, [newMessage length])];
	[PTMain processLinks:newMessage];
	newBox.statusMessage = newMessage;
	NSString *imageLocation = [[statusInfo objectForKey:@"user"] objectForKey:@"profile_image_url"];
	NSImage *imageData = [userImageCache objectForKey:imageLocation];
	if (!imageData) {
		if (![imageReqForLocation objectForKey:imageLocation]) {
			NSString *imageReq = [twitterEngine getImageAtURL:imageLocation];
			[requestDetails setObject:@"IMAGE" forKey:imageReq];
			[imageReqForLocation setObject:imageReq forKey:imageLocation];
			[imageLocationForReq setObject:imageLocation forKey:imageReq];
			[statusBoxesForReq setObject:[[NSMutableArray alloc] init] forKey:imageReq];
		}
		NSMutableArray *requestedBoxes = [statusBoxesForReq objectForKey:[imageReqForLocation objectForKey:imageLocation]];
		[requestedBoxes addObject:newBox];
		newBox.userImage = defaultImage;
	} else {
		newBox.userImage = imageData;
	}
	newBox.updateID = [[NSString alloc] initWithString:[statusInfo objectForKey:@"id"]];
	NSString *urlStr = [[statusInfo objectForKey:@"user"] objectForKey:@"url"];
	if ([urlStr length] != 0) {
		newBox.userHome = [[NSURL alloc] initWithString:urlStr];
	} else {
		newBox.userHome = nil;
	}
	newBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.8];
	return newBox;
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
	[requestDetails removeObjectForKey:identifier];
	if ([statuses count] == 0) return;
	NSDictionary *currentStatus;
	NSDictionary *lastStatus;
	for (currentStatus in [statuses reverseObjectEnumerator]) {
		[statusController addObject:[self constructStatusBox:currentStatus]];
		lastStatus = currentStatus;
	}
	lastUpdateID = [[NSString alloc] initWithString:[lastStatus objectForKey:@"id"]];
	if ([requestDetails objectForKey:identifier] == @"POST") {
		[statusUpdateField setEnabled:YES];
		[statusUpdateField setStringValue:[[NSString alloc] init]];
		[textLevelIndicator setIntValue:0];
	}
}

- (PTStatusBox *)constructMessageBox:(NSDictionary *)statusInfo {
	PTStatusBox *newBox = [[PTStatusBox alloc] init];
	NSString *comboName = 
		[[NSString alloc] initWithFormat:@"%@ / %@", 
						  [[statusInfo objectForKey:@"sender"] objectForKey:@"screen_name"], 
						  [[statusInfo objectForKey:@"sender"] objectForKey:@"name"]];
	newBox.userName = comboName;
	newBox.userID = [[NSString alloc] initWithString:[[statusInfo objectForKey:@"sender"] objectForKey:@"screen_name"]];
	newBox.time = [statusInfo objectForKey:@"created_at"];
	NSMutableAttributedString *newMessage = 
		[[NSMutableAttributedString alloc] initWithString:[statusInfo objectForKey:@"text"]];
	[newMessage addAttribute:NSForegroundColorAttributeName
				value:[NSColor whiteColor]
				range:NSMakeRange(0, [newMessage length])];
	[PTMain processLinks:newMessage];
	newBox.statusMessage = newMessage;
	NSString *imageLocation = [[statusInfo objectForKey:@"sender"] objectForKey:@"profile_image_url"];
	NSImage *imageData = [userImageCache objectForKey:imageLocation];
	if (!imageData) {
		if (![imageReqForLocation objectForKey:imageLocation]) {
			NSString *imageReq = [twitterEngine getImageAtURL:imageLocation];
			[requestDetails setObject:@"IMAGE" forKey:imageReq];
			[imageReqForLocation setObject:imageReq forKey:imageLocation];
			[imageLocationForReq setObject:imageLocation forKey:imageReq];
			[statusBoxesForReq setObject:[[NSMutableArray alloc] init] forKey:imageReq];
		}
		NSMutableArray *requestedBoxes = [statusBoxesForReq objectForKey:[imageReqForLocation objectForKey:imageLocation]];
		[requestedBoxes addObject:newBox];
		newBox.userImage = defaultImage;
	} else {
		newBox.userImage = imageData;
	}
	newBox.updateID = [[NSString alloc] initWithString:[statusInfo objectForKey:@"id"]];
	NSString *urlStr = [[statusInfo objectForKey:@"sender"] objectForKey:@"url"];
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
	if ([messages count] == 0) return;
	NSDictionary *currentDic;
	NSDictionary *lastDic;
	for (currentDic in [messages reverseObjectEnumerator]) {
		[statusController addObject:[self constructMessageBox:currentDic]];
		lastDic = currentDic;
	}
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
}

- (IBAction)updateTimeline:(id)sender {
	[requestDetails setObject:@"UPDATE" 
					forKey: [twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] 
										   sinceID:lastUpdateID startingAtPage:0 count:100]];
	[requestDetails setObject:@"MESSAGE_UPDATE" 
					forKey: [twitterEngine getDirectMessagesSinceID:lastMessageID
										   startingAtPage:0]];
}

- (IBAction)postStatus:(id)sender {
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
			[[NSString alloc] initWithFormat:@"%@ %@", 
			currentSelection.userID, 
			[statusUpdateField stringValue]];
		[statusUpdateField setStringValue:replyTarget];
		[statusUpdateField selectText:sender];
	}
}

- (void)selectStatusBox:(PTStatusBox *)newSelection {
	NSMutableAttributedString *selectedMessage = 
		[[NSMutableAttributedString alloc] initWithAttributedString:newSelection.statusMessage];
	[selectedMessage addAttribute:NSFontAttributeName
					 value:[NSFont fontWithName:@"Helvetica" size:11.0]
					 range:NSMakeRange(0, [selectedMessage length])];
	[[selectedTextView textStorage]setAttributedString:selectedMessage];
	[userNameBox setStringValue:newSelection.userName];
	[replyButton setState:NSOffState];
	[messageButton setState:NSOffState];
	if (!newSelection.userHome) {
		[webButton setEnabled:NO];
	} else {
		[webButton setEnabled:YES];
	}
	currentSelection = newSelection;
}

@end
