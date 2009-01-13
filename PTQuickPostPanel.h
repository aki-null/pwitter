//
//  PTQuickPostPanel.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 13/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTQuickPostPanel : NSPanel {
    IBOutlet id fCancelButton;
    IBOutlet id fPostButton;
    IBOutlet id fStatusUpdateField;
    IBOutlet id fMainController;
}
- (IBAction)cancelPost:(id)sender;
- (IBAction)post:(id)sender;
@end
