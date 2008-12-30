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
	IBOutlet id replyButton;
	IBOutlet id userNameBox;
	IBOutlet id webButton;
	IBOutlet id messageButton;
	IBOutlet id statusArrayController;
	MGTwitterEngine *twitterEngine;
	bool shouldExit;
	NSString *lastUpdateID;
	NSString *lastMessageID;
	NSImage *defaultImage;
	NSImage *warningImage;
	NSMutableDictionary *requestDetails;
	NSMutableDictionary *imageLocationForReq;
	NSMutableDictionary *imageReqForLocation;
	NSMutableDictionary *statusBoxesForReq;
	NSMutableDictionary *userImageCache;
	PTStatusBox *currentSelection;
}
- (IBAction)updateTimeline:(id)sender;
- (IBAction)postStatus:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)closeAuthSheet:(id)sender;
- (IBAction)messageToSelected:(id)sender;
- (IBAction)openHome:(id)sender;
- (IBAction)openWebSelected:(id)sender;
- (IBAction)replyToSelected:(id)sender;
- (PTStatusBox *)constructErrorBox:(NSError *)error;
- (NSImage *)requestUserImage:(NSString *)imageLocation forBox:(PTStatusBox *)newBox;
- (void)selectStatusBox:(PTStatusBox *)newSelection;
@end
