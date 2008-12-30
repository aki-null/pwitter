//
//  PTStatusBox.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 25/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTStatusBox : NSObject {
	NSString *userName;
	NSAttributedString *statusMessage;
	NSImage *userImage;
	NSURL *userHome;
	NSString *userID;
	NSString *updateID;
	NSColor *entityColor;
}

@property(copy, readwrite) NSString *userName;
@property(copy, readwrite) NSAttributedString *statusMessage;
@property(copy, readwrite) NSImage *userImage;
@property(copy, readwrite) NSURL *userHome;
@property(copy, readwrite) NSString *userID;
@property(copy, readwrite) NSString *updateID;
@property(copy, readwrite) NSColor *entityColor;

@end
