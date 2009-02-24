//
//  AMCollectionView.h
//  AMCollectionViewTest
//
//  Created by Andreas on 19.11.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//

//  functionality is similar to NSCollectionView
//  - handles rows only for now
//  - no constraints for number of rows or view sizes


#import <Cocoa/Cocoa.h>

@class AMCollectionViewItem;


@interface AMCollectionView : NSControl {
	IBOutlet AMCollectionViewItem *itemPrototype;
	NSArray *content;
	BOOL selectable;
	BOOL allowsMultipleSelection;
	NSDictionary *am_itemsForObjects;
	BOOL am_needsLayout;
	NSData *am_archivedItemPrototype;
	BOOL am_itemRespondsToSizeForViewWithProposedSize;
	BOOL am_initializing;
	float rowHeight;
	BOOL am_isFirstResponder;
}

- (AMCollectionViewItem *)itemPrototype;
- (void)setItemPrototype:(AMCollectionViewItem *)value;

- (float)rowHeight;
- (void)setRowHeight:(float)value;

- (NSArray *)content;
- (void)setContent:(NSArray *)value;

- (NSIndexSet *)selectionIndexes;
- (void)setSelectionIndexes:(NSIndexSet *)value;

- (BOOL)isSelectable;
- (void)setSelectable:(BOOL)value;

- (BOOL)allowsMultipleSelection;
- (void)setAllowsMultipleSelection:(BOOL)value;

- (BOOL)isFirstResponder;

- (AMCollectionViewItem *)newItemForRepresentedObject:(id)object;

- (AMCollectionViewItem *)itemForObject:(id)object;

- (NSArray *)selectedObjects;
- (void)selectItemsForObjects:(NSArray *)objects;

- (void)deselectAll:(id)sender;

- (void)noteSizeForItemsChanged:(NSArray *)items;

- (void)scrollObjectToVisible:(id)object;


@end


APPKIT_EXTERN NSString *const AMCollectionViewSelectionDidChangeNotification;


@interface NSObject (AMCollectionViewDelegate)
- (void)collectionViewSelectionDidChange:(NSNotification *)aNotification;
@end
