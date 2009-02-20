//
//  PTStatusFilterController.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 3/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusFilterController.h"
#import "PTStatusBox.h"


@implementation PTStatusFilterController
- (IBAction)showAll:(id)sender {
	[fStatusController setFilterPredicate:nil];
}

- (IBAction)showMessages:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 2", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
}

- (IBAction)showReplies:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 1", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
}

- (IBAction)showUpdates:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 0", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
}

- (IBAction)showError:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 3", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
}

@end
