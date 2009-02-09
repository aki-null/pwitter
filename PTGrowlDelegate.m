//
//  PTGrowlDelegate.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 9/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTGrowlDelegate.h"
#import "PTMain.h"


@implementation PTGrowlDelegate

- (void)awakeFromNib {
	[GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)growlNotificationWasClicked:(id)clickContext {
	[fMainController activateApp:self];
}

@end
