#import "PTMain.h"

@implementation PTMain

- (void)setUpTwitterEngine {
	// Create a TwitterEngine and set our login details.
    twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
    [twitterEngine setUsername:username password:password];
    
    // Get updates from people the authenticated user follows.
    [twitterEngine getFollowedTimelineFor:username since:nil startingAtPage:0];
}

- (void)awakeFromNib
{
	[NSApp beginSheet:authPanel
		   modalForWindow:mainWindow
		   modalDelegate:self
		   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		   contextInfo:nil];
	
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
    
    // Save image to the Desktop.
    NSString *path = [[NSString stringWithFormat:@"~/Desktop/%@.tiff", identifier] 
                      stringByExpandingTildeInPath];
    [[image TIFFRepresentation] writeToFile:path atomically:NO];
}

- (IBAction)updateTimeline:(id)sender {
    
}

- (IBAction)postStatus:(id)sender {
    
}

- (IBAction)quitApp:(id)sender {
    
}

- (IBAction)closeAuthSheet:(id)sender {
    
}
@end
