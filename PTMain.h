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
	MGTwitterEngine *fTwitterEngine;
	NSString *fLastUpdateID;
	NSString *fLastMessageID;
	long long int fLastReplyID;
	NSImage *fDefaultImage;
	NSMutableDictionary *fRequestDetails;
	NSMutableDictionary *fImageLocationForReq;
	NSMutableDictionary *fImageReqForLocation;
	NSMutableDictionary *fStatusBoxesForReq;
	NSMutableDictionary *fUserImageCache;
	NSTimer *fUpdateTimer;
	NSTimer *fMessageUpdateTimer;
}
- (IBAction)updateTimeline:(id)sender;
- (IBAction)postStatus:(id)sender;
- (IBAction)changeAccount:(id)sender;
- (NSImage *)requestUserImage:(NSString *)aImageLocation forBox:(PTStatusBox *)aNewBox;
- (void)selectStatusBox:(PTStatusBox *)aSelection;
- (void)setupUpdateTimer;
- (void)openTwitterWeb;
- (void)runInitialUpdates;
- (void)setUpTwitterEngine;

@end
