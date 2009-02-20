//
//  PTSelectedStatusView.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 10/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTSelectedStatusView : NSScrollView {
    IBOutlet id fActionHandler;
    IBOutlet id fSelectedTextView;
}

@end
