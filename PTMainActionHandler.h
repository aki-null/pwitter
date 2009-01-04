//
//  PTMainActionHandler.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


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
- (void)startAuthentication;

@end
