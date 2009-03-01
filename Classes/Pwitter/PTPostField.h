//
//  PTPostField.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 7/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTPostField : NSTextField {
    IBOutlet id fCollectionView;
    IBOutlet id fPostView;
    IBOutlet id fReplyTextView;
    IBOutlet id fCollection;
    IBOutlet id fCharacterCounter;
    IBOutlet id fMainActionController;
    IBOutlet id fMainWindow;
}

- (void)automaticallyResize;

@end
