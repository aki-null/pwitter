//
//  PTPreferenceWindow.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTPreferenceWindow.h"


@implementation PTPreferenceWindow

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)pressOK:(id)sender {
    
}

- (NSString *)getUserName {
	return [userName stringValue];
}

- (NSString *)getPassword {
	return [password stringValue];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

@end
