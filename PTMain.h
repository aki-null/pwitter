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
	MGTwitterEngine *fTwitterEngine;
	BOOL fShouldExit;
	NSString *fLastUpdateID;
	NSString *fLastMessageID;
	NSImage *fDefaultImage;
	NSImage *fWarningImage;
	NSMutableDictionary *fRequestDetails;
	NSMutableDictionary *fImageLocationForReq;
	NSMutableDictionary *fImageReqForLocation;
	NSMutableDictionary *fStatusBoxesForReq;
	NSMutableDictionary *fUserImageCache;
	PTStatusBox *fCurrentSelection;
	NSTimer *fUpdateTimer;
}
- (IBAction)updateTimeline:(id)aSender;
- (IBAction)postStatus:(id)aSender;
- (IBAction)quitApp:(id)aSender;
- (IBAction)closeAuthSheet:(id)aSender;
- (IBAction)messageToSelected:(id)aSender;
- (IBAction)openHome:(id)aSender;
- (IBAction)openWebSelected:(id)aSender;
- (IBAction)replyToSelected:(id)aSender;
- (IBAction)openPref:(id)aSender;
- (IBAction)updateTimeline:(id)aSender;
- (IBAction)postStatus:(id)aSender;
- (IBAction)quitApp:(id)aSender;
- (IBAction)closeAuthSheet:(id)aSender;
- (IBAction)messageToSelected:(id)aSender;
- (IBAction)openHome:(id)aSender;
- (IBAction)openWebSelected:(id)aSender;
- (IBAction)replyToSelected:(id)aSender;
- (IBAction)openPref:(id)aSender;
- (void)startAuthentication;
- (PTStatusBox *)constructErrorBox:(NSError *)aError;
- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox;
- (void)selectStatusBox:(PTStatusBox *)aSelection;
- (void)changeAccount;
- (void)setupUpdateTimer;
- (void)openTwitterWeb;

@end
