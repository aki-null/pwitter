//
//  PTStatusBox.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 25/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum statusType {
	NormalMessage = 0,
	ReplyMessage = 1,
	DirectMessage = 2
}StatusType;

@interface PTStatusBox : NSObject {
	NSAttributedString *userName;
	NSAttributedString *statusMessage;
	NSImage *userImage;
	NSURL *userHome;
	NSString *userID;
	NSString *updateID;
	NSColor *entityColor;
	NSDate *time;
	NSString *strTime;
	StatusType sType;
}

@property(copy, readwrite) NSAttributedString *userName;
@property(copy, readwrite) NSAttributedString *statusMessage;
@property(copy, readwrite) NSImage *userImage;
@property(copy, readwrite) NSURL *userHome;
@property(copy, readwrite) NSString *userID;
@property(copy, readwrite) NSString *updateID;
@property(copy, readwrite) NSColor *entityColor;
@property(copy, readwrite) NSDate *time;
@property(copy, readwrite) NSString *strTime;
@property(readwrite) StatusType sType;

@end
