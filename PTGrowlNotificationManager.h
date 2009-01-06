//
//  PTGrowlNotificationManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 6/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTStatusBox.h"


@interface PTGrowlNotificationManager : NSObject {

}
- (void)postReplyNotification:(PTStatusBox *)aReplyInfo;
- (void)postMessageNotification:(PTStatusBox *)aReplyInfo;

@end
