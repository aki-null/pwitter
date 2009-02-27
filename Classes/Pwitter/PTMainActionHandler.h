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
    IBOutlet id fStatusScrollView;
    IBOutlet id fStatusController;
    IBOutlet id fMainController;
    IBOutlet id fMessageButton;
    IBOutlet id fReplyButton;
    IBOutlet id fWebButton;
    IBOutlet id fStatusUpdateField;
    IBOutlet id fBottomView;
    IBOutlet id fMiniItemPrototype;
    IBOutlet id fNormalItemPrototype;
    IBOutlet id fStatusCollectionView;
    IBOutlet id fPostView;
    IBOutlet id fReplyToBox;
    IBOutlet id fFavButton;
    IBOutlet id fCharacterCounter;
    IBOutlet id fReplyInfoView;
    IBOutlet id fMiniClassicItemPrototype;
    IBOutlet id fNormalClassicItemPrototype;
	BOOL fSearchBoxIsOpen;
	BOOL fReplyViewIsOpen;
	BOOL fShouldExit;
	BOOL fTopViewIsDisabled;
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
- (IBAction)closeReplyViewFromButton:(id)sender;
- (IBAction)favSelected:(id)sender;
- (IBAction)retweetSelection:(id)sender;
- (IBAction)markAllAsRead:(id)sender;
- (IBAction)openSelectedLink:(id)sender;
- (IBAction)openSelectedUser:(id)sender;
- (IBAction)openPwitterHome:(id)sender;
- (IBAction)endSearch:(id)sender;
- (IBAction)openTweet:(id)sender;
- (IBAction)openReplyInBrowser:(id)sender;
- (void)startAuthentication;
- (void)updateSelectedMessage:(PTStatusBox *)aBox;
- (void)setCollectionViewPrototype:(BOOL)aIsMini useClassic:(BOOL)aIsClassic;
- (void)openReplyView;
- (void)closeReplyView;
- (void)replyToStatus:(PTStatusBox *)aBox;
- (void)messageToStatus:(PTStatusBox *)aBox;
- (void)updateCollection;
- (void)retweetStatus:(PTStatusBox *)aBox;

@end
