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
    IBOutlet id fMiniItemPrototype;
    IBOutlet id fNormalItemPrototype;
    IBOutlet id fStatusCollectionView;
    IBOutlet id fPostView;
    IBOutlet id fReplyToBox;
    IBOutlet id fFavButton;
    IBOutlet id fCharacterCounter;
    IBOutlet id fReplyInfoView;
	BOOL fSearchBoxIsOpen;
	BOOL fReplyViewIsOpen;
	BOOL fShouldExit;
	BOOL fNoAnim;
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
- (void)startAuthentication;
- (void)updateSelectedMessage:(PTStatusBox *)aBox;
- (void)updateViewSizes:(float)aHeightReq withAnim:(BOOL)aAnim;
- (void)setCollectionViewPrototype:(BOOL)aIsMini;
- (void)openReplyView:(BOOL)aAnimate;
- (void)closeReplyView;
- (void)replyToStatus:(PTStatusBox *)aBox shouldAnimate:(BOOL)aAnimate;
- (void)messageToStatus:(PTStatusBox *)aBox;
- (void)disableAnimation;
- (void)disableTopView;
- (void)enableTopView;

@end
