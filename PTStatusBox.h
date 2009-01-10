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
	DirectMessage = 2,
	ErrorMessage = 3
}StatusType;

@interface PTStatusBox : NSObject {
	NSAttributedString *userName;
	NSAttributedString *statusMessage;
	NSImage *userImage;
	NSURL *userHome;
	NSString *userID;
	NSColor *entityColor;
	NSDate *time;
	NSString *strTime;
	NSString *searchString;
	StatusType sType;
}

@property(copy, readwrite) NSAttributedString *userName;
@property(copy, readwrite) NSAttributedString *statusMessage;
@property(copy, readwrite) NSImage *userImage;
@property(copy, readwrite) NSURL *userHome;
@property(copy, readwrite) NSString *userID;
@property(copy, readwrite) NSColor *entityColor;
@property(copy, readwrite) NSDate *time;
@property(copy, readwrite) NSString *strTime;
@property(copy, readwrite) NSString *searchString;
@property(readwrite) StatusType sType;

@end
