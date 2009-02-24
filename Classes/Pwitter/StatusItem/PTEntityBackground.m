//
//  PTEntityBackground.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 30/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTEntityBackground.h"
#import "PTStatusEntityView.h"
#import "PTStatusBox.h"
#import "PTPreferenceManager.h"

// Bubble factory singleton
// This is used to create bubble path with caching
@interface PTBubbleFactory : NSObject
{
	BOOL fIsMini;
	BOOL fIsClassic;
	float fWidth;
	float fHeight;
	NSBezierPath *fPath;
}

+ (PTBubbleFactory *)sharedSingleton;
- (NSBezierPath *)bubbleWithWidth:(float)aWidth height:(float)aHeight;

@end

@implementation PTBubbleFactory

static PTBubbleFactory *sharedSingleton;

+ (PTBubbleFactory *)sharedSingleton
{
	@synchronized(self)
	{
		if (!sharedSingleton)
			[[PTBubbleFactory alloc] init];
		return sharedSingleton;
	}
	return nil;
}

+(id)alloc
{
	@synchronized(self)
	{
		NSAssert(sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedSingleton = [super alloc];
		return sharedSingleton;
	}
	return nil;
}

- (NSBezierPath *)bubbleWithWidth:(float)aWidth height:(float)aHeight {
	if (fIsMini != [[PTPreferenceManager sharedInstance] useMiniView] || 
		fIsClassic != [[PTPreferenceManager sharedInstance] useClassicView] || 
		fWidth != aWidth || 
		fHeight != aHeight) {
		fWidth = aWidth;
		fHeight = aHeight;
		fIsMini = [[PTPreferenceManager sharedInstance] useMiniView];
		fIsClassic = [[PTPreferenceManager sharedInstance] useClassicView];
		if (fIsClassic) {
			if (fPath) [fPath release];
			fPath = [[NSBezierPath alloc] init];
			[fPath appendBezierPathWithRoundedRect:NSInsetRect(NSMakeRect(0, 0, aWidth, aHeight), 10.0, 3.0) 
										   xRadius:6.0 
										   yRadius:6.0];
		} else {
			float lLeftOffset;
			float lTriangleOffset;
			if (fIsMini) {
				lLeftOffset = 44;
				lTriangleOffset = 14;
			} else {
				lLeftOffset = 67;
				lTriangleOffset = 19;
			}
			if (fPath) [fPath release];
			fPath = [[NSBezierPath alloc] init];
			[fPath setLineJoinStyle:NSRoundLineJoinStyle];
			[fPath moveToPoint:NSMakePoint(lLeftOffset, 7.0)];
			[fPath curveToPoint:NSMakePoint(lLeftOffset + 4.0, 3.0) 
				  controlPoint1:NSMakePoint(lLeftOffset, 5.0) 
				  controlPoint2:NSMakePoint(lLeftOffset + 2.0, 3.0)];
			int lCurrentOffsetX = aWidth - 10.0;
			int lCurrentOffsetY = aHeight - 2.0;
			[fPath lineToPoint:NSMakePoint(lCurrentOffsetX - 4.0, 3.0)];
			[fPath curveToPoint:NSMakePoint(lCurrentOffsetX, 7.0) 
				  controlPoint1:NSMakePoint(lCurrentOffsetX - 2, 3.0) 
				  controlPoint2:NSMakePoint(lCurrentOffsetX, 7.0)];
			[fPath lineToPoint:NSMakePoint(lCurrentOffsetX, lCurrentOffsetY - 4.0)];
			[fPath curveToPoint:NSMakePoint(lCurrentOffsetX - 4.0, lCurrentOffsetY) 
				  controlPoint1:NSMakePoint(lCurrentOffsetX, lCurrentOffsetY - 2.0) 
				  controlPoint2:NSMakePoint(lCurrentOffsetX - 2.0, lCurrentOffsetY)];
			[fPath lineToPoint:NSMakePoint(lLeftOffset + 4.0, lCurrentOffsetY)];
			[fPath curveToPoint:NSMakePoint(lLeftOffset, lCurrentOffsetY - 4.0) 
				  controlPoint1:NSMakePoint(lLeftOffset + 2.0, lCurrentOffsetY) 
				  controlPoint2:NSMakePoint(lLeftOffset, lCurrentOffsetY - 2.0)];
			[fPath lineToPoint:NSMakePoint(lLeftOffset, lTriangleOffset + 4.5)];
			[fPath lineToPoint:NSMakePoint(lLeftOffset - 4.0, lTriangleOffset)];
			[fPath lineToPoint:NSMakePoint(lLeftOffset, lTriangleOffset - 4.5)];
			[fPath closePath];
		}
	}
	return fPath;
}

@end


@implementation PTEntityBackground

- (void)drawRect:(NSRect)aRect {
	BOOL lIsSelected = [(PTStatusEntityView *)[self superview] selected];
	if (lIsSelected) {
		[[[self textColor] highlightWithLevel:0.1] set];
	} else 
		[[self textColor] set];
	NSBezierPath *lPath = [[PTBubbleFactory sharedSingleton] bubbleWithWidth:[self bounds].size.width 
																	  height:[self bounds].size.height];
	[lPath fill];
	[[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0] set];
	[lPath setLineWidth:1.0];
	[lPath stroke];
	//	[lPath appendBezierPathWithRoundedRect:NSInsetRect([self bounds], 10.0, 2.0) 
	//								   xRadius:12.0 
	//								   yRadius:12.0];
	// render the selection border
	if(lIsSelected) {
		[[NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1.0] set];
		[lPath setLineWidth:2.5];
		[lPath stroke];
	}
	[super drawRect:aRect];
}

- (void)mouseDown:(NSEvent *)aEvent {
	// pass the event to the super class as usual
	[super mouseDown:aEvent];
	// send a message to the owner of the status view to select this entity
	[[self superview] mouseDown:aEvent];
}

- (void)rightMouseDown:(NSEvent *)aEvent {
	//[super rightMouseDown:aEvent];
	//[(PTStatusEntityView *)[self superview] forceSelect:YES];
	[[self superview] mouseDown:aEvent];
	[(PTStatusEntityView *)[self superview] openContextMenu:aEvent];
}

@end
