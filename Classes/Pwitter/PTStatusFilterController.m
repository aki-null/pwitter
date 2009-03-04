//
//  PTStatusFilterController.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 3/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusFilterController.h"
#import "PTStatusBox.h"
#import "PTMainActionHandler.h"
#import "PTPreferenceManager.h"


@implementation PTStatusFilterController
- (IBAction)showAll:(id)sender {
	[fStatusController setFilterPredicate:nil];
	[fMainActionHandler updateCollection];
}

- (IBAction)showMessages:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 2", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
	[fMainActionHandler updateCollection];
}

- (IBAction)showReplies:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 1", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
	[fMainActionHandler updateCollection];
}

- (IBAction)showUpdates:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 0", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
	[fMainActionHandler updateCollection];
}

- (IBAction)showError:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == 3", @"sType"];
	[fStatusController setFilterPredicate:lPredicate];
	[fMainActionHandler updateCollection];
}

- (IBAction)showFavorites:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == YES", @"fav"];
	[fStatusController setFilterPredicate:lPredicate];
	[fMainActionHandler updateCollection];
}

- (IBAction)showMyPosts:(id)sender {
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"userId", [[PTPreferenceManager sharedSingleton] userName]];
	[fStatusController setFilterPredicate:lPredicate];
	[fMainActionHandler updateCollection];
}

@end
