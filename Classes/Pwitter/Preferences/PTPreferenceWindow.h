//
//  PTPreferenceWindow.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/SRRecorderControl.h>
#import "PTHotKey.h"
#import "PTMainActionHandler.h"


@interface PTPreferenceWindow : NSPanel {
    IBOutlet id fPassword;
    IBOutlet id fUserName;
    IBOutlet id fAlwaysOnTop;
    IBOutlet id fTimeInterval;
    IBOutlet id fMainController;
    IBOutlet id fMainWindow;
    IBOutlet id fAutoLogin;
    IBOutlet id fReceiveFromNonFollowers;
    IBOutlet id fMessageUpdateInterval;
    IBOutlet id fUseMiniView;
    IBOutlet id fActivateGlobalKey;
    IBOutlet id fShortcutRecorder;
    IBOutlet id fIgnoreErrors;
    IBOutlet PTMainActionHandler *fMainActionHandler;
    IBOutlet id fDisableGrowl;
    IBOutlet id fDisableMessageNotification;
    IBOutlet id fDisableReplyNotification;
    IBOutlet id fDisableSoundNotification;
    IBOutlet id fDisableStatusNotification;
    IBOutlet id fPostTextField;
    IBOutlet id fBehaviorAfterUpdate;
    IBOutlet id fStatusController;
    IBOutlet id fDisableErrorNotification;
    IBOutlet id fHideDockIcon;
    IBOutlet id fSwapMenuItem;
    IBOutlet id fUseTwelveHour;
    IBOutlet id fHideTopView;
    IBOutlet id fActivateQuickReadKey;
    IBOutlet id fQuickReadShortcutRecorder;
    IBOutlet id fStatusCollectionView;
    IBOutlet id fUsePOSTMethod;
	PTHotKey *fHotKey;
	PTHotKey *fHotKeyRead;
}
- (void)loadPreferences;
- (IBAction)pressOK:(id)sender;
- (IBAction)quickPostChanged:(id)sender;
- (IBAction)growlDisabled:(id)sender;
- (IBAction)quickReadChanged:(id)sender;
- (void)turnOnHotKey;
- (void)turnOnReadHotKey;
- (void)turnOffHotKey;
- (void)saveKeyCombo;
- (void)loadKeyCombo;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end
