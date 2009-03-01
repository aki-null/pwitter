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
    IBOutlet id fShortcutRecorder;
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
    IBOutlet id fQuickReadShortcutRecorder;
    IBOutlet id fStatusCollectionView;
    IBOutlet id fHideWhenReading;
    IBOutlet id fSelectOldestUnread;
	PTHotKey *fHotKey;
	PTHotKey *fHotKeyRead;
	BOOL fShouldReset;
}
- (void)loadPreferences;
- (IBAction)pressOK:(id)sender;
- (IBAction)quickPostChanged:(id)sender;
- (IBAction)growlDisabled:(id)sender;
- (IBAction)quickReadChanged:(id)sender;
- (IBAction)resetTimeline:(id)sender;
- (void)turnOnHotKey;
- (void)turnOnReadHotKey;
- (void)turnOffHotKey;
- (void)saveKeyCombo;
- (void)loadKeyCombo;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end
