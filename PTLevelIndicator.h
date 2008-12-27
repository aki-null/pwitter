//
//  PTLevelIndicator.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 27/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTLevelIndicator : NSLevelIndicator {
	IBOutlet id statusTextField;
}
- (void)controlTextDidChange:(NSNotification *)aNotification;

@end
