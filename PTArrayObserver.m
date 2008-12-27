//
//  PTArrayObserver.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 27/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PTArrayObserver.h"
#import "PTStatusBox.h"

@implementation PTArrayObserver

- (void)dealloc
{
	[arrayController removeObserver:self forKeyPath:@"selectionIndexes"];
	[super dealloc];
}

-(void)awakeFromNib
{
	[arrayController addObserver:self forKeyPath:@"selectionIndexes"
					 options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
							   ofObject:(id)object
							   change:(NSDictionary *)change
							   context:(void *)context
{
	NSArrayController *arrController = object;
	PTStatusBox *selectedBox = [[arrController selectedObjects] lastObject];
	[[statusDetailBox textStorage]setAttributedString:selectedBox.statusMessage];
}

@end