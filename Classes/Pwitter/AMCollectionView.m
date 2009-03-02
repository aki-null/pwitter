//
//	AMCollectionView.m
//	AMCollectionViewTest
//
//	Created by Andreas on 19.11.07.
//	Copyright 2007 Andreas Mayer. All rights reserved.
//

#import "AMCollectionView.h"
#import "AMCollectionViewItem.h"
#import "AMCollectionViewItemProtocol.h"


@interface AMCollectionViewItem (Private)
- (void)setCollectionView:(AMCollectionView *)value;
@end

@interface AMCollectionView (Private)
- (BOOL)needsLayout;
- (void)setNeedsLayout:(BOOL)value;
- (NSDictionary *)itemsForObjects;
- (void)setItemsForObjects:(NSDictionary *)value;
- (NSData *)archivedItemPrototype;
- (void)setArchivedItemPrototype:(NSData *)value;
- (void)doLayout;
- (void)archiveItemPrototype:(AMCollectionViewItem *)item;
- (AMCollectionViewItem *)itemAtPoint:(NSPoint)point;
- (void)setNeedsDisplayForItems:(NSArray *)items;
- (void)redrawAllSubviewsInRect:(NSRect)rect;
- (void)sendSelectionDidChangeNotification;
- (BOOL)deselectAllButItems:(NSArray *)items;
- (NSArray *)setNeedsDisplayForSelectedItems;
@end



@implementation AMCollectionView

- (id)initWithFrame:(NSRect)frame
{
	am_initializing = YES;
	self = [super initWithFrame:frame];
	if (self) {
		[self setPostsFrameChangedNotifications:YES];
		[self setPostsBoundsChangedNotifications:YES];
		[self setItemsForObjects:[[[NSMutableDictionary alloc] init] autorelease]];
	}
	return self;
}

- (void)awakeFromNib
{
	am_initializing = NO;
	if ([self itemPrototype]) {
		[self archiveItemPrototype:[self itemPrototype]];
		am_itemRespondsToSizeForViewWithProposedSize = [[self itemPrototype] respondsToSelector:@selector(sizeForViewWithProposedSize:)];
		if ([[self itemPrototype] view]) {
			[self setRowHeight:[[[self itemPrototype] view] frame].size.height];
		}
	}
}

- (void)dealloc
{
	[itemPrototype release];
	[content release];
	[am_itemsForObjects release];
	[am_archivedItemPrototype release];
	[super dealloc];
}


//============================================================================
#pragma mark	accessor methods
//============================================================================

- (AMCollectionViewItem *)itemPrototype
{
	return [[itemPrototype retain] autorelease];
}

- (void)setItemPrototype:(AMCollectionViewItem *)value
{
	if (am_initializing) {
		// view outlet is not set yet, so we need to defer this until awakeFromNib
		itemPrototype = [value retain];
	} else {
		if (itemPrototype != value) {
			[itemPrototype release];
			itemPrototype = [value retain];
			[itemPrototype setCollectionView:self];
			[self archiveItemPrototype:value];
			am_itemRespondsToSizeForViewWithProposedSize = [itemPrototype respondsToSelector:@selector(sizeForViewWithProposedSize:)];
			[self setRowHeight:[[itemPrototype view] frame].size.height];
			NSArray *lBackUp = [self content];
			[self setContent:[NSArray array]];
			[self setContent:lBackUp];
		}
	}
}

- (float)rowHeight
{
	return rowHeight;
}

- (void)setRowHeight:(float)value
{
	if (rowHeight != value) {
		rowHeight = value;
	}
}

- (NSArray *)content
{
	return [[content retain] autorelease];
}

- (void)setContent:(NSArray *)value
{
	if (content != value) {
		[content release];
		content = [value copy];
		
		// reuse previous items
		NSMutableArray *oldItems = [[am_itemsForObjects allValues] mutableCopy]; // release at end of method
		NSMutableDictionary *newItems = [[[NSMutableDictionary alloc] init] autorelease];
		NSEnumerator *enumerator = [content objectEnumerator];
		id object;
		id selectedObject = [[self selectedObjects] lastObject];
		AMCollectionViewItem *item;
		while ((object = [enumerator nextObject])) {
			item = [self itemForObject:object];
			if (item) {
				[oldItems removeObject:item];
				[item setAnimated:YES];
			} else {
				item = [self newItemForRepresentedObject:object];
				[item setAnimated:NO];
				am_itemRespondsToSizeForViewWithProposedSize = (am_itemRespondsToSizeForViewWithProposedSize || [item respondsToSelector:@selector(sizeForViewWithProposedSize:)]);
			}
			[newItems setObject:item forKey:[NSValue valueWithNonretainedObject:object]];
		}
		[self setItemsForObjects:newItems];

		// remove old items
		enumerator = [oldItems objectEnumerator];
		while ((item = [enumerator nextObject])) {
			[item removeFromCollectionView];
		}
		[oldItems release];

		[self doLayout];
		if ([self itemForObject:selectedObject] == nil) {
			[self deselectAllButItems:[NSArray array]];
			[self sendSelectionDidChangeNotification];
		}
		[self setNeedsDisplay:YES];
	}
}

- (NSIndexSet *)selectionIndexes
{
	NSMutableIndexSet *result = [[[NSMutableIndexSet alloc] init] autorelease];
	int index = 0;
	NSEnumerator *enumerator = [content objectEnumerator];
	id object;
	AMCollectionViewItem *item;
	while (object = [enumerator nextObject]) {
		item = [am_itemsForObjects objectForKey:[NSValue valueWithNonretainedObject:object]];
		if ([item isSelected]) {
			[result addIndex:index];
		}
		index++;
	}
	return result;
}

- (void)setSelectionIndexes:(NSIndexSet *)indexSet
{
	// change selection for items
	AMCollectionViewItem *item = nil;
	int index = 0;
	NSEnumerator *enumerator = [content objectEnumerator];
	id object;
	while (object = [enumerator nextObject]) {
		item = [am_itemsForObjects objectForKey:[NSValue valueWithNonretainedObject:object]];
		[item setSelected:[indexSet containsIndex:index]];
		index++;
	}
	[self sendSelectionDidChangeNotification];
}

- (BOOL)isSelectable
{
	return selectable;
}

- (void)setSelectable:(BOOL)value
{
	if (selectable != value) {
		selectable = value;
	}
}

- (BOOL)allowsMultipleSelection
{
	return allowsMultipleSelection;
}

- (void)setAllowsMultipleSelection:(BOOL)value
{
	if (allowsMultipleSelection != value) {
		allowsMultipleSelection = value;
	}
}

- (BOOL)isFirstResponder
{
	NSResponder *firstResponder = [[self window] firstResponder];
	return ([[self window] isKeyWindow] && ((firstResponder == self) || ([firstResponder isKindOfClass:[NSView class]] && [(NSView *)firstResponder isDescendantOf:self])));
}

- (NSDictionary *)itemsForObjects
{
	return am_itemsForObjects;
}

- (void)setItemsForObjects:(NSDictionary *)value
{
	if (am_itemsForObjects != value) {
		[am_itemsForObjects release];
		am_itemsForObjects = [value retain];
	}
}

- (BOOL)needsLayout
{
	return am_needsLayout;
}

- (void)setNeedsLayout:(BOOL)value
{
	am_needsLayout = value;
}

- (NSData *)archivedItemPrototype
{
	return am_archivedItemPrototype;
}

- (void)setArchivedItemPrototype:(NSData *)value
{
	if (am_archivedItemPrototype != value) {
		[am_archivedItemPrototype release];
		am_archivedItemPrototype = [value retain];
	}
}


//============================================================================
#pragma mark	NSView methods
//============================================================================

- (void)drawRect:(NSRect)rect
{
//	NSLog(@"drawRect:%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	if ([self needsLayout]) {
		[self doLayout];
	}
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setFrameSize:(NSSize)newSize
{
	BOOL didChangeWidth = (fabsf([self frame].size.width - newSize.width) > 0.1);
	[super setFrameSize:newSize];
	if (am_itemRespondsToSizeForViewWithProposedSize && didChangeWidth) {
		[self setNeedsLayout:YES];
		[self setNeedsDisplay:YES];
	}
}

- (void)viewDidMoveToWindow
{
	// we need to observe key window and first responder status
	if ([self window]) {
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:[self window]];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidUpdateNotification object:[self window]];
	} else {
//		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
//		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidUpdateNotification object:nil];
	}
}


//============================================================================
#pragma mark	NSResponder methods
//============================================================================

- (void)moveUp:(id)sender
{
	// find first selected row
	NSArray *objects = [self content];
	AMCollectionViewItem *item;
	id object;
	id previousObject = nil;
	int row, selectedRow = NSNotFound;;
	for (row = 0; row < [objects count]; row++) {
		object = [objects objectAtIndex:row];
		item = [self itemForObject:object];
		if ([item isSelected]) {
			selectedRow = row;
			break;
		}
		previousObject = object;
	}
	if ((selectedRow != NSNotFound) && previousObject) {
		// select previous object
		[self selectItemsForObjects:[NSArray arrayWithObject:previousObject]];
		[self performSelector:@selector(scrollObjectToVisible:) withObject:previousObject afterDelay:0.0];
	}
}

- (void)moveDown:(id)sender
{
	// find last selected row
	NSArray *objects = [self content];
	AMCollectionViewItem *item;
	id object;
	id previousObject = nil;
	int row, selectedRow = NSNotFound;;
	for (row = [objects count]-1; row >= 0 ; row--) {
		object = [objects objectAtIndex:row];
		item = [self itemForObject:object];
		if ([item isSelected]) {
			selectedRow = row;
			break;
		}
		previousObject = object;
	}
	if ((selectedRow != NSNotFound) && previousObject) {
		// select following object
		[self selectItemsForObjects:[NSArray arrayWithObject:previousObject]];
		[self performSelector:@selector(scrollObjectToVisible:) withObject:previousObject afterDelay:0.0];
	}
}

- (void)moveRight:(id)sender
{
	[self moveDown:sender];
}

- (void)moveLeft:(id)sender
{
	[self moveUp:sender];
}

- (void)keyDown:(NSEvent *)aEvent {
	if ([[aEvent characters] isEqualToString:@"k"]) {
		[self moveUp:self];
	} else if ([[aEvent characters] isEqualToString:@"j"]) {
		[self moveDown:self];
	} else if ([[aEvent characters] isEqualToString:@"h"]) {
		[self moveUp:self];
	} else if ([[aEvent characters] isEqualToString:@"l"]) {
		[self moveDown:self];
	} else {
		[super keyDown:aEvent];
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[[self window] makeFirstResponder:self];
	// handle selection
	BOOL selectionDidChange = NO;
	// !!!: Shift-Select is missing
	BOOL toggleSelection = (([theEvent modifierFlags] & NSCommandKeyMask) > 0);
	NSPoint location = [theEvent locationInWindow];
	NSPoint pointInView = [self convertPoint:location fromView:nil];
	AMCollectionViewItem *item = [self itemAtPoint:pointInView];
	if (item) {
		if (toggleSelection) {
			selectionDidChange = YES;
			if ([item isSelected]) {
				[item setSelected:NO];
			} else {
				if (![self allowsMultipleSelection]) {
					[self deselectAll:self];
				}
				[item setSelected:YES];
			}
		} else {
			if (![item isSelected]) {
				selectionDidChange = YES;
				[self deselectAll:self];
				[item setSelected:YES];
			}
		}
		[self setNeedsDisplayForItems:[NSArray arrayWithObject:item]];
		if (selectionDidChange) {
			[self sendSelectionDidChangeNotification];
		}
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}


//============================================================================
#pragma mark	public methods
//============================================================================

- (AMCollectionViewItem *)newItemForRepresentedObject:(id)object
{
	AMCollectionViewItem *result;
	NSData *data = [self archivedItemPrototype];
	result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//	[result setView:view];
	[result setRepresentedObject:object];
	[result setCollectionView:self];
	return result;
}

- (AMCollectionViewItem *)itemForObject:(id)object
{
	return [am_itemsForObjects objectForKey:[NSValue valueWithNonretainedObject:object]];
}

- (NSArray *)selectedObjects
{
	NSMutableArray *result = [NSMutableArray array];
	NSEnumerator *enumerator = [[am_itemsForObjects allKeys] objectEnumerator];
	id key;
	AMCollectionViewItem *item;
	while ((key = [enumerator nextObject])) {
		id object = [(NSValue *)key nonretainedObjectValue];
		item = [self itemForObject:object];
		if ([item isSelected]) {
			[result addObject:object];
		}
	}
	return result;
}

- (void)selectItemsForObjects:(NSArray *)objects
{
	NSMutableArray *itemsToDeselect = [[am_itemsForObjects allValues] mutableCopy];
	AMCollectionViewItem *item;
	NSEnumerator *enumerator = [objects objectEnumerator];
	id object;
	while ((object = [enumerator nextObject])) {
		item = [self itemForObject:object];
		if (item) {
			[item setSelected:YES];
			[itemsToDeselect removeObject:item];
		}
	}
	enumerator = [itemsToDeselect objectEnumerator];
	while ((item = [enumerator nextObject])) {
		[item setSelected:NO];
	}
	[itemsToDeselect release];
	[self sendSelectionDidChangeNotification];
}

- (void)deselectAll:(id)sender
{
	if ([self deselectAllButItems:nil]) {
		[self sendSelectionDidChangeNotification];
	}
}

- (void)scrollObjectToVisible:(id)object
{
	AMCollectionViewItem *item = [self itemForObject:object];
	NSView *view = [item view];
	NSRect viewFrame = [view frame];
	NSClipView *clipView = [[self enclosingScrollView] contentView];
	if ([clipView respondsToSelector:@selector(scrollToPoint:)]) {
		BOOL needsScroll = NO;
		NSPoint newOrigin;
		NSRect visibleRect = [clipView documentVisibleRect];
//		NSLog(@"view:    top %f  bottom %f", viewFrame.origin.y, viewFrame.origin.y+viewFrame.size.height);
//		NSLog(@"visible: top %f  bottom %f", visibleRect.origin.y, visibleRect.origin.y+visibleRect.size.height);
		if (NSMinY(viewFrame) < NSMinY(visibleRect)) {
			// scroll to top
			newOrigin = viewFrame.origin;
			needsScroll = YES;
		} else if (NSMaxY(viewFrame) > NSMaxY(visibleRect)) {
			// scroll to bottom
			newOrigin = NSMakePoint(0.0, viewFrame.origin.y-visibleRect.size.height+viewFrame.size.height);
			needsScroll = YES;
		}
		if (needsScroll) {
			newOrigin = [clipView constrainScrollPoint:newOrigin];
			[clipView scrollToPoint:newOrigin];
			[[self enclosingScrollView] reflectScrolledClipView:clipView];
		}
	}
}


//============================================================================
#pragma mark	private methods
//============================================================================

- (void)doLayout
{
	[self setNeedsLayout:NO];
//	[self removeAllSubviews];
	NSEnumerator *enumerator = [[self content] objectEnumerator];
	id object;
	float y = 0.0;
	AMCollectionViewItem *item;
	NSView *view;
	NSSize viewSize;
	NSRect viewFrame;
	CGRect visibleRect = NSRectToCGRect([[[self enclosingScrollView] contentView] documentVisibleRect]);
	[NSAnimationContext beginGrouping];
//	[[NSAnimationContext currentContext] setDuration:1.0];
	while ((object = [enumerator nextObject])) {
		item = [self itemForObject:object];
		view = [item view];
		viewSize = [view frame].size;
		viewSize.width = [self frame].size.width;
		if ([item respondsToSelector:@selector(sizeForViewWithProposedSize:)]) {
			viewSize = [item sizeForViewWithProposedSize:viewSize];
		}
		viewFrame.origin = NSMakePoint(0.0, y);
		viewFrame.size = viewSize;
		if ([item isAnimated]) {
			if (CGRectIntersectsRect(NSRectToCGRect([view frame]), visibleRect) || 
				CGRectIntersectsRect(NSRectToCGRect(viewFrame), visibleRect)) {
				[[view animator] setFrame:viewFrame];
			} else 
				[view setFrame:viewFrame];
		} else {
			if (CGRectIntersectsRect(NSRectToCGRect(viewFrame), visibleRect)) {
				NSRect lTempRect = viewFrame;
				lTempRect.size.height = 1;
				lTempRect.origin.y = 0;
				[view setFrame:lTempRect];
				[[view animator] setFrame:viewFrame];
				[[view animator] setAlphaValue:1.0];
			} else 
				[view setFrame:viewFrame];
			[item setAnimated:YES];
		}
		[self addSubview:view];
		y += viewSize.height;
	}
	viewSize.width = [self frame].size.width;
	viewSize.height = y;
	[self setFrameSize:viewSize];
	[NSAnimationContext endGrouping];
}

- (void)redrawAllSubviewsInRect:(NSRect)rect
{
	NSEnumerator *enumerator = [[self subviews] objectEnumerator];
	id view;
	while ((view = [enumerator nextObject])) {
		if (NSIntersectsRect(rect, [view frame])) {
			NSRect localRect = [self convertRect:rect toView:view];
			[view drawRect:localRect];
		}
	}
}

- (void)archiveItemPrototype:(AMCollectionViewItem *)item
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
	[self setArchivedItemPrototype:data];
}

- (AMCollectionViewItem *)itemAtPoint:(NSPoint)point
{
	AMCollectionViewItem *result = nil;
	if (am_itemRespondsToSizeForViewWithProposedSize) {
		// variable row height
		// !!!: some optimization might be in order ...
		NSEnumerator *enumerator = [[self content] objectEnumerator];
		id object;
		AMCollectionViewItem *item;
		NSRect viewFrame;
		while ((object = [enumerator nextObject])) {
			item = [self itemForObject:object];
			viewFrame = [[item view] frame];
			if (NSPointInRect(point, viewFrame)) {
				result = item;
				break;
			}
		}
	} else {
		// fixed row height
		int index = (point.y / [self rowHeight]);
		if (index < [[self content] count]) {
			result = [self itemForObject:[[self content] objectAtIndex:index]];
		} else {
			NSLog(@"registered click beyond content area");
		}
	}
	return result;
}

- (BOOL)deselectAllButItems:(NSArray *)items
{
	BOOL result = NO;
	NSMutableArray *changedItems = [NSMutableArray array];
	AMCollectionViewItem *item;
	NSEnumerator *enumerator = [[self content] objectEnumerator];
	id object;
	while ((object = [enumerator nextObject])) {
		item = [self itemForObject:object];
		if (item && ![items containsObject:item]) {
			if ([item isSelected]) {
				[item setSelected:NO];
				[changedItems addObject:item];
			}
		}
	}
	[self setNeedsDisplayForItems:changedItems];
	result = ([changedItems count] > 0);
	return result;
}

- (void)setNeedsDisplayForItems:(NSArray *)items
{
	NSEnumerator *enumerator = [items objectEnumerator];
	AMCollectionViewItem *item;
	while ((item = [enumerator nextObject])) {
		NSRect rect = [[item view] frame];
		[self setNeedsDisplayInRect:rect];
	}
}

- (NSArray *)setNeedsDisplayForSelectedItems
{
	NSMutableArray *result = [NSMutableArray array];
	NSEnumerator *enumerator = [[am_itemsForObjects allKeys] objectEnumerator];
	id key;
	AMCollectionViewItem *item;
	while ((key = [enumerator nextObject])) {
		id object = [(NSValue *)key nonretainedObjectValue];
		item = [self itemForObject:object];
		if ([item isSelected]) {
			NSRect rect = [[item view] frame];
			[self setNeedsDisplayInRect:rect];
		}
	}
	return result;
}

- (void)windowDidUpdate:(NSNotification *)aNotification
{
//	NSLog(@"windowDidUpdate:");
	BOOL newFirstResponder = [self isFirstResponder];
	if (newFirstResponder != am_isFirstResponder) {
//		NSLog(@"redraw selection");
		am_isFirstResponder = newFirstResponder;
		[self setNeedsDisplayForSelectedItems];
	}
}

- (void)sendSelectionDidChangeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:AMCollectionViewSelectionDidChangeNotification object:self];
}


//============================================================================
#pragma mark	collection view protocol
//============================================================================

- (void)noteSizeForItemsChanged:(NSArray *)items
{
	// !!!: we should optimize this
	[self setNeedsLayout:YES];
	[self setNeedsDisplay:YES];
}


@end


NSString *const AMCollectionViewSelectionDidChangeNotification = @"AMCollectionViewSelectionDidChangeNotification";

