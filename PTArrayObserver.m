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
	[arrayController removeObserver:self forKeyPath:@"selectionIndexes"];
	[super dealloc];
}

-(void)awakeFromNib
{
	// add an observer to the array controller that manages the statuses
	[arrayController addObserver:self 
					  forKeyPath:@"selectionIndexes"
						 options:NSKeyValueObservingOptionNew 
						 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	NSArrayController *arrController = object;
	// get the status entry that is currently selected
	PTStatusBox *selectedBox = [[arrController selectedObjects] lastObject];
	// inform the main program about the new selection
	[mainProgram selectStatusBox:selectedBox];
}

@end
