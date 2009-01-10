//
//  PTSelectedStatusView.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 10/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTSelectedStatusView.h"
#import "PTMainActionHandler.h"


@implementation PTSelectedStatusView

- (void)viewDidMoveToWindow
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(windowResized:) 
												 name:NSWindowDidResizeNotification 
											   object:[self window]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)windowResized:(NSNotification *)aNotification;
{
	NSRect lFrame = NSMakeRect(0, 0, [fSelectedTextView frame].size.width, MAXFLOAT);
	NSTextView *lTempTextView = [[NSTextView alloc] initWithFrame:lFrame];
	[[lTempTextView textStorage] setAttributedString:[fSelectedTextView textStorage]];
	[lTempTextView setHorizontallyResizable:NO];
	[lTempTextView sizeToFit];
	float lHeightReq = [lTempTextView frame].size.height;
	[lTempTextView release];
	[fActionHandler updateViewSizes:lHeightReq withAnim:NO];
}

@end
