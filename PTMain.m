#import "PTMain.h"

@implementation PTMain

- (void)setUpTwitterEngine {
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine setUsername:[[PTPreferenceManager getInstance] getUserName] password:[[PTPreferenceManager getInstance] getPassword]];
	[twitterEngine getFollowedTimelineFor:[[PTPreferenceManager getInstance] getUserName] since:nil startingAtPage:0];
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

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
	NSLog(@"Got statuses:\r%@", statuses);
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
	
}

- (IBAction)postStatus:(id)sender {
	
}

- (IBAction)quitApp:(id)sender {
	shouldExit = true;
	[NSApp endSheet:authPanel];
}

@end
