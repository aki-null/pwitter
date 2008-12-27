#import "PTMain.h"

@implementation PTMain

- (void)setUpTwitterEngine {
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine setUsername:[[PTPreferenceManager getInstance] getUserName] password:[[PTPreferenceManager getInstance] getPassword]];
	[requestDetails setObject:@"INIT_UPDATE" forKey:
		[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] since:nil startingAtPage:0]];
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
	shouldExit = false;
	requestDetails = [[NSMutableDictionary alloc] init];
	imageReqForLocation = [[NSMutableDictionary alloc] init];
	statusBoxesForReq = [[NSMutableDictionary alloc] init];
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
}

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed! (%@) Error: %@ (%@)", 
          requestIdentifier, 
          [error localizedDescription], 
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

+ (void)processLinks:(NSMutableAttributedString *)targetString {
	NSString* string = [targetString string];
	NSRange searchRange = NSMakeRange(0, [string length]);
	NSRange foundRange;
	foundRange=[string rangeOfString:@"http://" options:0 range:searchRange];
	if (foundRange.length > 0) {
		NSURL* theURL;
		NSDictionary* linkAttributes;
		NSRange endOfURLRange;
		searchRange.location=foundRange.location+foundRange.length;
		searchRange.length = [string length]-searchRange.location;
		endOfURLRange = [string rangeOfCharacterFromSet:
								[NSCharacterSet whitespaceAndNewlineCharacterSet]
								options:0 range:searchRange];
		if (endOfURLRange.length == 0)
			endOfURLRange.location = [string length] - 1;
		foundRange.length = endOfURLRange.location - foundRange.location + 1;
		theURL=[NSURL URLWithString:[string substringWithRange:foundRange]];
		linkAttributes= [NSDictionary dictionaryWithObjectsAndKeys: theURL, NSLinkAttributeName,
						[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
						[NSColor cyanColor], NSForegroundColorAttributeName,
						nil];
		[targetString addAttributes:linkAttributes range:foundRange];
	}
}

- (PTStatusBox *)constructStatusBox:(NSDictionary *)statusInfo {
	PTStatusBox *newBox = [[PTStatusBox alloc] init];
	NSMutableString *comboName = [[NSMutableString alloc] init];
	[comboName appendString:[[statusInfo objectForKey:@"user"] objectForKey:@"screen_name"]];
	[comboName appendString:@" / "];
	[comboName appendString:[[statusInfo objectForKey:@"user"] objectForKey:@"name"]];
	newBox.userName = comboName;
	NSMutableAttributedString *newMessage = 
		[[NSMutableAttributedString alloc] initWithString:[statusInfo objectForKey:@"text"]];
	[newMessage addAttribute:NSForegroundColorAttributeName
				value:[NSColor whiteColor]
				range:NSMakeRange(0, [newMessage length])];
	[PTMain processLinks:newMessage];
	newBox.statusMessage = newMessage;
	return newBox;
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
	if ([statuses count] == 0)
	{
		[requestDetails removeObjectForKey:identifier];
		return;
	}
	NSDictionary *currentStatus;
	NSDictionary *lastStatus;
	for (currentStatus in [statuses reverseObjectEnumerator]) {
		[statusController insertObject:[self constructStatusBox:currentStatus] atArrangedObjectIndex:0];
		lastStatus = currentStatus;
	}
	lastUpdateID = [[NSString alloc] initWithString:[lastStatus objectForKey:@"id"]];
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier
{
	NSLog(@"Got direct messages:\r%@", messages);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier
{
	NSLog(@"Got user info:\r%@", userInfo);
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)identifier
{
	NSLog(@"Got misc info:\r%@", miscInfo);
}

- (void)imageReceived:(NSImage *)image forRequest:(NSString *)identifier
{
	NSLog(@"Got an image: %@", image);
}

- (IBAction)updateTimeline:(id)sender {
	[requestDetails setObject:@"UPDATE" forKey:
		[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] sinceID:lastUpdateID startingAtPage:0 count:20]];
}

- (IBAction)postStatus:(id)sender {
	
}

- (IBAction)quitApp:(id)sender {
	shouldExit = true;
	[NSApp endSheet:authPanel];
}

@end
