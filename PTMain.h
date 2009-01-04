//
//  PTMain.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 24/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MGTwitterEngine.h>
#import "PTPreferenceManager.h"
#import "PTStatusBox.h"
#import "PTPreferenceWindow.h"

@interface PTMain : NSObject <MGTwitterEngineDelegate> {
	IBOutlet id fStatusUpdateField;
	IBOutlet id fStatusController;
	IBOutlet id fPreferenceWindow;
	IBOutlet id fAuthPanel;
	IBOutlet id fMainWindow;
	IBOutlet id fAuthPassword;
	IBOutlet id fAuthUserName;
	IBOutlet id fSelectedTextView;
	IBOutlet id fTextLevelIndicator;
	IBOutlet id fReplyButton;
	IBOutlet id fUserNameBox;
	IBOutlet id fWebButton;
	IBOutlet id fMessageButton;
	IBOutlet id fStatusArrayController;
	IBOutlet id fProgressBar;
	IBOutlet id fSearchView;
	IBOutlet id fStatusScrollView;
	IBOutlet id fSearchBox;
	IBOutlet id fStatusBoxGenerator;
	MGTwitterEngine *fTwitterEngine;
	BOOL fShouldExit;
	NSString *fLastUpdateID;
	NSString *fLastMessageID;
	NSImage *fDefaultImage;
	NSMutableDictionary *fRequestDetails;
	NSMutableDictionary *fImageLocationForReq;
	NSMutableDictionary *fImageReqForLocation;
	NSMutableDictionary *fStatusBoxesForReq;
	NSMutableDictionary *fUserImageCache;
	NSTimer *fUpdateTimer;
	BOOL fSearchBoxIsOpen;
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
- (IBAction)updateTimeline:(id)sender;
- (IBAction)postStatus:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)closeAuthSheet:(id)sender;
- (IBAction)messageToSelected:(id)sender;
- (IBAction)openHome:(id)sender;
- (IBAction)openWebSelected:(id)sender;
- (IBAction)replyToSelected:(id)sender;
- (IBAction)openPref:(id)sender;
- (IBAction)openSearchBox:(id)sender;
- (IBAction)closeSearchBox:(id)sender;
- (void)startAuthentication;
- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox;
- (void)selectStatusBox:(PTStatusBox *)aSelection;
- (IBAction)changeAccount:(id)sender;
- (void)setupUpdateTimer;
- (void)openTwitterWeb;
- (void)runInitialUpdates;

@end
