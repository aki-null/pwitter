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
- (PTStatusBox *)constructErrorBox:(NSError *)aError;
- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox;
- (void)selectStatusBox:(PTStatusBox *)aSelection;
- (void)changeAccount;
- (void)setupUpdateTimer;
- (void)openTwitterWeb;

@end
