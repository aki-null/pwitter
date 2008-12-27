//
//  PTPreferenceWindow.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTPreferenceWindow : NSView {
    IBOutlet id password;
    IBOutlet id userName;
}
- (IBAction)pressOK:(id)sender;
- (NSString *)getUserName;
- (NSString *)getPassword;

@end
