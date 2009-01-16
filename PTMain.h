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
    IBOutlet id fTextLevelIndicator;
    IBOutlet id fReplyButton;
    IBOutlet id fWebButton;
    IBOutlet id fMessageButton;
    IBOutlet id fProgressBar;
    IBOutlet id fStatusBoxGenerator;
    IBOutlet id fUpdateButton;
    IBOutlet id fNotificationMan;
    IBOutlet id fSelectedTextView;
    IBOutlet id fQuickPostButton;
    IBOutlet id fQuickPostField;
    IBOutlet id fQuickPostPanel;
    IBOutlet id fQuickTextLevelIndicator;
	MGTwitterEngine *fTwitterEngine;
	NSString *fLastUpdateID;
	NSString *fLastMessageID;
	NSString *fLastReplyID;
	NSImage *fDefaultImage;
	NSMutableDictionary *fRequestDetails;
	NSMutableDictionary *fImageLocationForReq;
	NSMutableDictionary *fImageReqForLocation;
	NSMutableDictionary *fStatusBoxesForReq;
	NSMutableDictionary *fUserImageCache;
	NSMutableDictionary *fIgnoreUpdate;
	NSTimer *fUpdateTimer;
	NSTimer *fMessageUpdateTimer;
}
- (IBAction)updateTimeline:(id)sender;
- (IBAction)postStatus:(id)sender;
- (IBAction)changeAccount:(id)sender;
- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox;
- (void)setupUpdateTimer;
- (void)setupMessageUpdateTimer;
- (void)openTwitterWeb;
- (void)runInitialUpdates;
- (void)setUpTwitterEngine;
- (void)makePost:(NSString *)aMessage;

@end
