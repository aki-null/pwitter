//
//  PTStatusScrollView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 10/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusScrollView.h"


@implementation PTStatusScrollView

- (void)awakeFromNib {
	NSRect lTempRect = [[self contentView] visibleRect];
	fLastWidth = lTempRect.size.width;
	fLastHeight = lTempRect.size.height;
}

- (void)viewDidMoveToWindow
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(boundsChanged:) 
												 name:NSViewBoundsDidChangeNotification 
											   object:[self contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(frameResized:) 
												 name:NSViewFrameDidChangeNotification 
											   object:[self contentView]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)boundsChanged:(NSNotification *)aNotification;
{
	if (fViewChanged) {
		[[self contentView] scrollToPoint:NSMakePoint(0, fLastPosition)];
		fViewChanged = NO;
	}
	NSRect lTempRect = [[self contentView] visibleRect];
	if (fLastPosition != lTempRect.origin.y) {
		fOldPosition = fLastPosition;
		fLastPosition = lTempRect.origin.y;
	}
	fLastWidth = lTempRect.size.width;
	fLastHeight = lTempRect.size.height;
}

- (void)frameResized:(NSNotification *)aNotification;
{
	NSRect lTempRect = [[self contentView] visibleRect];
	if (fLastWidth == lTempRect.size.width && fLastHeight == lTempRect.size.height) {
		[[self contentView] scrollToPoint:NSMakePoint(0, fOldPosition)];
	} else {
		fViewChanged = YES;
	}
}

@end
