//
//  PTMenuBarIcon.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 3/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

// FROM ADIUM

#import <Cocoa/Cocoa.h>


@interface PTMenuBarIcon : NSView {
	NSStatusItem *fStatusItem;
	BOOL fMouseDown;
	NSImage *fImage;
	NSImage *fAlternateImage;
	NSMenu *fMainMenu;
	id fMainController;
	BOOL fIsSwapped;
}

- (void)setImage:(NSImage *)aImage;
- (NSImage *)image;
- (void)setMenu:(NSMenu *)aMenu;
- (NSMenu *)menu;
- (void)setStatusItem:(NSStatusItem *)aStatusItem;
- (NSStatusItem *)statusItem;
- (void)setMainController:(id)aMainController;
- (void)setSwapped:(BOOL)aFlag;

@end
