//
//  PTPreferenceWindow.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


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
}
- (void)loadPreferences;
- (IBAction)pressOK:(id)sender;
- (IBAction)pressCancel:(id)sender;

@end
