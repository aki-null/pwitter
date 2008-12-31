//
//  PTPreferenceWindow.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTPreferenceWindow : NSPanel {
    IBOutlet id password;
    IBOutlet id userName;
    IBOutlet id alwaysOnTop;
    IBOutlet id timeInterval;
    IBOutlet id mainController;
    IBOutlet id mainWindow;
    IBOutlet id autoLogin;
}
- (void)loadPreferences;
- (IBAction)pressOK:(id)sender;
- (IBAction)pressCancel:(id)sender;

@end
