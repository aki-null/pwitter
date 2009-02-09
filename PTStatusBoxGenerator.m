//
//  PTStatusBoxGenerator.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusBoxGenerator.h"
#import "PTStatusFormatter.h"
#import "PTMain.h"
#import "PTDateToStringTransformer.h"
#import "PTReadStatusTransformer.h"
#import "PTReadManager.h"


@implementation PTStatusBoxGenerator

+ (void)initialize {
	PTDateToStringTransformer *lTransformer = [[[PTDateToStringTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:lTransformer forName:@"DateToStringTransformer"];
	PTReadStatusTransformer *lReadTrans = [[[PTReadStatusTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:lReadTrans forName:@"ReadImageTransformer"];
}

- (PTStatusBox *)constructStatusBox:(NSDictionary *)aStatusInfo isReply:(BOOL)aIsReply {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userId = [[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"];
	lNewBox.userName = [PTStatusFormatter createUserLabel:[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"] 
													 name:[[aStatusInfo objectForKey:@"user"] objectForKey:@"name"]];
	NSDate *lReceivedTime = [aStatusInfo objectForKey:@"created_at"];
	lNewBox.time = lReceivedTime;
	lNewBox.statusMessage = [PTStatusFormatter formatStatusMessage:[aStatusInfo objectForKey:@"text"] forBox:lNewBox];
	lNewBox.userImage = [fMainController requestUserImage:[[aStatusInfo objectForKey:@"user"] objectForKey:@"profile_image_url"]
												   forBox:lNewBox];
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"user"] objectForKey:@"url"];
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	if (aIsReply) {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.8 green:0.28 blue:0.28 alpha:0.7];
		lNewBox.sType = ReplyMessage;
	} else {
		if ([[[PTPreferenceManager getInstance] userName] isEqualToString:[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"]]) {
			lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:0.7];
		} else {
			lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
		}
		lNewBox.sType = NormalMessage;
	}
	if ([[aStatusInfo objectForKey:@"favorited"] boolValue]) {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:1.0 green:0.6 blue:0.0 alpha:0.7];
	}
	lNewBox.searchString = [NSString stringWithFormat:@"%@ %@ %@",
							[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"], 
							[[aStatusInfo objectForKey:@"user"] objectForKey:@"name"], 
							[aStatusInfo objectForKey:@"text"]];
	lNewBox.updateId = [[aStatusInfo objectForKey:@"id"] intValue];
	lNewBox.replyId = [[aStatusInfo objectForKey:@"in_reply_to_status_id"] intValue];
	lNewBox.replyUserId = [aStatusInfo objectForKey:@"in_reply_to_screen_name"];
	lNewBox.readFlag = [[PTReadManager getInstance] isUpdateRead:lNewBox.updateId];
	return [lNewBox autorelease];
}

- (PTStatusBox *)constructErrorBox:(NSError *)aError {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userName = [PTStatusFormatter createErrorLabel];
	lNewBox.userId = [NSString stringWithString:@"Twitter Error:"];
	lNewBox.statusMessage = [PTStatusFormatter createErrorMessage:aError];
	lNewBox.userImage = [NSImage imageNamed:@"console.png"];
	lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	lNewBox.time = [NSDate date];
	lNewBox.userHome = nil;
	lNewBox.sType = ErrorMessage;
	lNewBox.searchString = [NSString stringWithFormat:@"Twitter Error: %@", 
							[aError localizedDescription]];
	lNewBox.readFlag = YES;
	return [lNewBox autorelease];
}

- (PTStatusBox *)constructMessageBox:(NSDictionary *)aStatusInfo {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userName = [PTStatusFormatter createUserLabel:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"] 
													 name:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"]];
	lNewBox.userId = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"];
	lNewBox.time = [aStatusInfo objectForKey:@"created_at"];
	lNewBox.statusMessage = [PTStatusFormatter formatStatusMessage:[aStatusInfo objectForKey:@"text"] forBox:lNewBox];
	lNewBox.userImage = [fMainController requestUserImage:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"profile_image_url"]
												   forBox:lNewBox];
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"url"];
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.5 blue:0.7 alpha:0.8];
	lNewBox.sType = DirectMessage;
	lNewBox.searchString = [NSString stringWithFormat:@"%@ %@ %@",
							[[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"], 
							[[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"], 
							[aStatusInfo objectForKey:@"text"]];
	lNewBox.updateId = [[aStatusInfo objectForKey:@"id"] intValue];
	lNewBox.readFlag = [[PTReadManager getInstance] isUpdateRead:lNewBox.updateId];
	return [lNewBox autorelease];
}

@end
