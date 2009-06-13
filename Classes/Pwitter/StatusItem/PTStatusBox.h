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
	NSString *userName;
	NSAttributedString *statusMessage;
	NSString *statusMessageString;
	NSImage *userImage;
	NSURL *userHome;
	NSURL *statusLink;
	NSString *userId;
	NSColor *entityColor;
	NSDate *time;
	NSString *searchString;
	StatusType sType;
	unsigned long updateId;
	unsigned long replyId;
	NSString *replyUserId;
	BOOL readFlag;
	BOOL fav;
}

@property(copy, readwrite) NSString *userName;
@property(copy, readwrite) NSAttributedString *statusMessage;
@property(copy, readwrite) NSString *statusMessageString;
@property(assign, readwrite) NSImage *userImage;
@property(copy, readwrite) NSURL *userHome;
@property(copy, readwrite) NSURL *statusLink;
@property(copy, readwrite) NSString *userId;
@property(copy, readwrite) NSColor *entityColor;
@property(copy, readwrite) NSDate *time;
@property(copy, readwrite) NSString *searchString;
@property(readwrite) StatusType sType;
@property(readwrite) unsigned long updateId;
@property(readwrite) unsigned long replyId;
@property(copy, readwrite) NSString *replyUserId;
@property(readwrite) BOOL readFlag;
@property(readwrite) BOOL fav;

@end
