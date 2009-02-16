//
//  PTArrayObserver.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 27/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTArrayObserver.h"
#import "PTStatusBox.h"
#import "PTMainActionHandler.h"


@implementation PTArrayObserver

- (void)dealloc
{
	// remove the observer at deallocation
	[fArrayController removeObserver:self forKeyPath:@"selection"];
	[super dealloc];
}

-(void)awakeFromNib
{
	// add an observer to the array controller that manages the statuses
	[fArrayController addObserver:self 
					   forKeyPath:@"selection"
						  options:NSKeyValueObservingOptionNew 
						  context:nil];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath
					  ofObject:(id)aObject
						change:(NSDictionary *)aChange
					   context:(void *)aContext
{
	NSArrayController *lArrController = aObject;
	// get the status entry that is currently selected
	PTStatusBox *lSelectedBox = [[lArrController selectedObjects] lastObject];
	if (lSelectedBox)
		[[fStatusText textStorage] setAttributedString:lSelectedBox.statusMessage];
	else
		[[fStatusText textStorage] setAttributedString:[[[NSAttributedString alloc] init] autorelease]];
	[fActionHandler updateSelectedMessage:lSelectedBox];
}

@end
