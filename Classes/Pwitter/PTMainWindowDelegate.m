//
//  PTMainWindowDelegate.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 2/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTMainWindowDelegate.h"
#import "PTMain.h"
#import "PTMainActionHandler.h"
#import "AMCollectionView.h"
#import "PTStatusCollectionItem.h"


@interface PTTextView : NSTextView {
    
}
@end

@implementation PTTextView

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
    [self setFieldEditor:YES];
	[self 
	return self;
}

// Copyright (c) 2007-2008, Akira Ueda
- (void)setMarkedText:(id)aString selectedRange:(NSRange)selRange
{
    id string;
    if ([aString isKindOfClass:[NSAttributedString class]]) {
        string = [[aString mutableCopy] autorelease];
        selRange = NSMakeRange( 0, [string length]);
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
							   [NSColor whiteColor], NSUnderlineColorAttributeName,
							   [NSColor whiteColor], NSForegroundColorAttributeName, 
                               nil];
        [string setAttributes:attrs range:selRange];
    } else {
        string = aString;
    }
    
    [super setMarkedText:string selectedRange:selRange];
}

@end

@implementation PTMainWindowDelegate

- (id)init {
	self = [super init];
	fFieldEditor = [[PTTextView alloc] init];
	return self;
}

- (void)dealloc {
	[super dealloc];
	[fFieldEditor release];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[fStatusCollection setAllowsMultipleSelection:NO];
	[fStatusCollection setRowHeight:38];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelection:) name:AMCollectionViewSelectionDidChangeNotification object:nil];
	[fMainActionHandler startAuthentication];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)aApplication 
					hasVisibleWindows:(BOOL)aFlag
{
	if(!aFlag) [fMainWindow makeKeyAndOrderFront:self];
	return YES;
}

- (BOOL)applicationDidBecomeActive:(NSNotification *)aNotification {
	[[fMainController fMenuItem] setImage:[NSImage imageNamed:@"menu_icon_off"]];
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[fMainController saveUnread];
}

- (BOOL)windowShouldClose:(id)sender
{
	BOOL lResult = YES;
	if (sender == fMainWindow) {
		[fMainWindow orderOut:self];
		lResult = NO;
	}
	return lResult;
}

- (void)updateSelection:(NSNotification *)aNotification {
	PTStatusBox *lSelectedBox = [[fStatusCollection selectedObjects] lastObject];
	if ([[PTPreferenceManager sharedSingleton] useMiniView]) {
		if (fOldSelection != lSelectedBox && fOldSelection != nil) {
			PTStatusCollectionItem *lOldItem = (PTStatusCollectionItem *)[fStatusCollection itemForObject:fOldSelection];
			if (lOldItem)
				[fStatusCollection noteSizeForItemsChanged:[NSArray arrayWithObject:lOldItem]];
		}
		if (lSelectedBox)
			[fStatusCollection noteSizeForItemsChanged:[NSArray arrayWithObject:lSelectedBox]];
	}
	[fMainActionHandler updateSelectedMessage:lSelectedBox];
	fOldSelection = lSelectedBox;
}


- (id)windowWillReturnFieldEditor:(NSWindow *)window toObject:(id)anObject
{
	return fFieldEditor;
}


@end
