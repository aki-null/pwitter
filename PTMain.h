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

typedef enum soundEventType {
	NoneReceived = 0,
	StatusReceived = 1,
	ReplyOrMessageReceived = 2,
	ErrorReceived = 3
}SoundEventType;

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
    IBOutlet id fMainWindow;
	MGTwitterEngine *fTwitterEngine;
	NSNumber *fLastUpdateID;
	NSNumber *fLastMessageID;
	NSNumber *fLastReplyID;
	NSImage *fDefaultImage;
	NSSound *fStatusReceived;
	NSSound *fReplyReceived;
	NSMutableDictionary *fRequestDetails;
	NSMutableDictionary *fImageLocationForReq;
	NSMutableDictionary *fImageReqForLocation;
	NSMutableDictionary *fStatusBoxesForReq;
	NSMutableDictionary *fUserImageCache;
	NSMutableDictionary *fIgnoreUpdate;
	NSTimer *fUpdateTimer;
	NSTimer *fMessageUpdateTimer;
	SoundEventType fCurrentSoundStatus;
	// array of boxes that has been received for the current session
	NSMutableArray *fBoxesToNotify;
	NSMutableArray *fBoxesToAdd;
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
