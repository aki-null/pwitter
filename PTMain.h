#import <Cocoa/Cocoa.h>
#import <MGTwitterEngine.h>
#import <PTPreferenceManager.h>
#import <PTStatusBox.h>

@interface PTMain : NSObject <MGTwitterEngineDelegate> {
	IBOutlet id statusUpdateField;
	IBOutlet id statusController;
	IBOutlet id preferenceWindow;
	IBOutlet id authPanel;
	IBOutlet id mainWindow;
	IBOutlet id authPassword;
	IBOutlet id authUserName;
	IBOutlet id selectedTextView;
	IBOutlet id textLevelIndicator;
	MGTwitterEngine *twitterEngine;
	bool shouldExit;
	NSString *lastUpdateID;
	NSImage *defaultImage;
	NSImage *warningImage;
	NSMutableDictionary *requestDetails;
	NSMutableDictionary *imageLocationForReq;
	NSMutableDictionary *imageReqForLocation;
	NSMutableDictionary *statusBoxesForReq;
	NSMutableDictionary *userImageCache;
}
- (IBAction)updateTimeline:(id)sender;
- (IBAction)postStatus:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)closeAuthSheet:(id)sender;
- (PTStatusBox *)constructErrorBox:(NSError *)error;
@end
