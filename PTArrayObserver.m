//
//  PTArrayObserver.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 27/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTArrayObserver.h"
#import "PTStatusBox.h"
#import "PTMain.h"


@implementation PTArrayObserver

- (void)dealloc
{
	// remove the observer at deallocation
	[fArrayController removeObserver:self forKeyPath:@"selectionIndexes"];
	[super dealloc];
}

-(void)awakeFromNib
{
	// add an observer to the array controller that manages the statuses
	[fArrayController addObserver:self 
					   forKeyPath:@"selectionIndexes"
						  options:NSKeyValueObservingOptionNew 
						  context:nil];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath
					  ofObject:(id)aObject
						change:(NSDictionary *)aChange
					   context:(void *)aContext
{
	NSArrayController *arrController = aObject;
	// get the status entry that is currently selected
	PTStatusBox *selectedBox = [[arrController selectedObjects] lastObject];
	// inform the main program about the new selection
	[fMainController selectStatusBox:selectedBox];
}

@end
