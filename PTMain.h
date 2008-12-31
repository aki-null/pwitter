#import <Cocoa/Cocoa.h>
#import <MGTwitterEngine.h>
#import "PTPreferenceManager.h"
#import "PTStatusBox.h"
#import "PTPreferenceWindow.h"

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
	IBOutlet id progressBar;
	MGTwitterEngine *twitterEngine;
	BOOL shouldExit;
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
	NSTimer *updateTimer;
}
- (IBAction)updateTimeline:(id)sender;
- (IBAction)postStatus:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)closeAuthSheet:(id)sender;
- (IBAction)messageToSelected:(id)sender;
- (IBAction)openHome:(id)sender;
- (IBAction)openWebSelected:(id)sender;
- (IBAction)replyToSelected:(id)sender;
- (IBAction)openPref:(id)sender;
- (PTStatusBox *)constructErrorBox:(NSError *)aError;
- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox;
- (void)selectStatusBox:(PTStatusBox *)aSelection;
- (void)changeAccount;
- (void)setupUpdateTimer;
@end
