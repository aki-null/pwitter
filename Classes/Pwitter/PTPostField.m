//
//  PTPostField.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 7/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTPostField.h"
#import "PTMain.h"
#import "AMCollectionView.h"


@implementation PTPostField

- (void)awakeFromNib {
	NSTextView *lField = (NSTextView*)[[self window] fieldEditor:TRUE forObject:self];
	[lField setInsertionPointColor:[NSColor whiteColor]];
	[lField toggleContinuousSpellChecking:self];
	[self setDelegate:self];
}

- (void)drawRect:(NSRect)aRect {
	[super drawRect:aRect];
	NSBezierPath *lPath = [NSBezierPath bezierPath];
	[lPath appendBezierPathWithRoundedRect:[self bounds] 
								   xRadius:4.0 
								   yRadius:4.0];
	[[NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:0.8] set];
	[lPath setLineWidth:2];
	[lPath stroke];
}

- (void)automaticallyResize {
	NSTextView *lFieldEditor = (NSTextView *)[[self window] fieldEditor:YES forObject:self];
	float lHeight;
	if ([self stringValue] == nil || [[self stringValue] length] == 0)
		lHeight = 21.0;
	else
		lHeight = [[lFieldEditor layoutManager] usedRectForTextContainer:[lFieldEditor textContainer]].size.height + 5.0;
	if (lHeight < 21.0) lHeight = 21.0;
	NSRect lCurrentRect = [self frame];
	float lDelta = lHeight - lCurrentRect.size.height;
	[super setFrameSize:NSMakeSize(lCurrentRect.size.width, lHeight)];
	if (lDelta != 0) {
		NSPoint lTempPosition = [fReplyTextView frame].origin;
		lTempPosition.y += lDelta;
		[fReplyTextView setFrameOrigin:lTempPosition];
		NSRect lTempFrame = [fPostView frame];
		lTempFrame.size.height += lDelta;
		[fPostView setFrame:lTempFrame];
		lTempFrame = [fCollectionView frame];
		lTempFrame.size.height -= lDelta;
		lTempFrame.origin.y += lDelta;
		[fCollectionView setFrame:lTempFrame];
		[fCollection doLayout];
	}
}

- (void)textDidChange: (NSNotification *)note {
	[fCharacterCounter setIntValue:140 - [[self stringValue] length]];
	[self automaticallyResize];
}

- (void)viewDidEndLiveResize {
	[self automaticallyResize];
}

- (void)setStringValue:(NSString *)aString {
	NSTextView *lCurrentEditor = (NSTextView *)[self currentEditor];
	if (lCurrentEditor)
		[lCurrentEditor setString:aString];
	else
		[super setStringValue:aString];
	(void)[[lCurrentEditor layoutManager] glyphRangeForTextContainer:[lCurrentEditor textContainer]];
	[self automaticallyResize];
}

- (void)dealloc {
	[super dealloc];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
	if (command == @selector(cancelOperation:)) {
		[fMainActionController closeReplyView];
	}
	
	if (![[PTPreferenceManager sharedInstance] postWithModifier]) {
		return NO;
	}
	if (command == @selector(insertNewline:)) {
		return YES;
	} else if (command == @selector(insertLineBreak:)) {
		[[control target] performSelector:[control action]];
		return YES;
	} else {
		return NO;
	}
}

@end