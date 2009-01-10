//
//  PTMainActionHandler.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTStatusBox.h"


@interface PTMainActionHandler : NSObject {
    IBOutlet id fAuthPanel;
    IBOutlet id fAuthPassword;
    IBOutlet id fAuthUserName;
    IBOutlet id fMainWindow;
    IBOutlet id fPreferenceWindow;
    IBOutlet id fSearchBox;
    IBOutlet id fSearchView;
    IBOutlet id fSelectedTextView;
    IBOutlet id fStatusScrollView;
    IBOutlet id fUserNameBox;
    IBOutlet id fStatusController;
    IBOutlet id fMainController;
    IBOutlet id fMessageButton;
    IBOutlet id fReplyButton;
    IBOutlet id fWebButton;
    IBOutlet id fStatusUpdateField;
    IBOutlet id fBottomView;
    IBOutlet id fSelectedStatusView;
    IBOutlet id fTopView;
	BOOL fSearchBoxIsOpen;
	BOOL fShouldExit;
}
- (IBAction)closeAuthSheet:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)messageToSelected:(id)sender;
- (IBAction)openHome:(id)sender;
- (IBAction)openWebSelected:(id)sender;
- (IBAction)replyToSelected:(id)sender;
- (IBAction)openPref:(id)sender;
- (IBAction)openSearchBox:(id)sender;
- (IBAction)closeSearchBox:(id)sender;
- (IBAction)clearErrors:(id)sender;
- (void)startAuthentication;
- (void)updateSelectedMessage:(PTStatusBox *)aBox;
- (void)updateViewSizes:(float)aHeightReq withAnim:(BOOL)aAnim;

@end
