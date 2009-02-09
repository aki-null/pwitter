//
//  PTGrowlDelegate.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 9/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>


@interface PTGrowlDelegate : NSObject <GrowlApplicationBridgeDelegate> {
    IBOutlet id fMainController;
}

- (void)growlNotificationWasClicked:(id)clickContext;

@end
